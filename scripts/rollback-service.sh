#!/usr/bin/env bash
# rollback-service.sh — Roll back an ECS service to the previous task definition
set -euo pipefail

log()     { echo "[$(date '+%H:%M:%S')] $*"; }
success() { echo "[$(date '+%H:%M:%S')] ✔ $*"; }
error()   { echo "[$(date '+%H:%M:%S')] ✘ $*" >&2; }
die()     { error "$*"; exit 1; }

SERVICE=""
CLUSTER=""
TARGET_REVISION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service)          SERVICE="$2";           shift 2 ;;
    --cluster)          CLUSTER="$2";           shift 2 ;;
    --target-revision)  TARGET_REVISION="$2";   shift 2 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[[ -z "$SERVICE" ]] && die "--service is required"
[[ -z "$CLUSTER" ]] && die "--cluster is required"

log "Starting rollback for $SERVICE on $CLUSTER"

# ── Resolve target revision ────────────────────────────────────────────────────
if [[ -n "$TARGET_REVISION" ]]; then
  ROLLBACK_TD="${SERVICE}:${TARGET_REVISION}"
  log "Using specified revision: $ROLLBACK_TD"
else
  CURRENT_ARN=$(aws ecs describe-services \
    --cluster "$CLUSTER" \
    --services "$SERVICE" \
    --query 'services[0].taskDefinition' \
    --output text)
  CURRENT_REV=$(echo "$CURRENT_ARN" | grep -oE ':[0-9]+$' | tr -d ':')
  PREVIOUS_REV=$((CURRENT_REV - 1))
  ROLLBACK_TD="${SERVICE}:${PREVIOUS_REV}"
  log "Rolling back from revision $CURRENT_REV to $PREVIOUS_REV"
fi

# ── Verify the rollback task definition exists ─────────────────────────────────
aws ecs describe-task-definition \
  --task-definition "$ROLLBACK_TD" \
  --query 'taskDefinition.taskDefinitionArn' \
  --output text > /dev/null || die "Task definition $ROLLBACK_TD not found"

# ── Apply rollback ─────────────────────────────────────────────────────────────
log "Applying rollback to $ROLLBACK_TD..."
aws ecs update-service \
  --cluster "$CLUSTER" \
  --service "$SERVICE" \
  --task-definition "$ROLLBACK_TD" \
  --force-new-deployment

log "Waiting for service to stabilise after rollback..."
aws ecs wait services-stable \
  --cluster "$CLUSTER" \
  --services "$SERVICE"

success "Rollback of $SERVICE to $ROLLBACK_TD completed on $CLUSTER"

# ── Tag rollback in git ────────────────────────────────────────────────────────
ROLLBACK_TAG="rollback/${SERVICE}/${CLUSTER}/$(date +%Y%m%dT%H%M%S)"
git config user.name  "ci-cd-bot" 2>/dev/null || true
git config user.email "ci-cd-bot@noreply.github.com" 2>/dev/null || true
git tag "$ROLLBACK_TAG" 2>/dev/null && git push origin "$ROLLBACK_TAG" 2>/dev/null || true
log "Tagged rollback: $ROLLBACK_TAG"
