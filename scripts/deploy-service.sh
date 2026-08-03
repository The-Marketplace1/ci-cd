#!/usr/bin/env bash
# deploy-service.sh — Deploy a single service to an ECS cluster
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()     { echo "[$(date '+%H:%M:%S')] $*"; }
success() { echo "[$(date '+%H:%M:%S')] ✔ $*"; }
error()   { echo "[$(date '+%H:%M:%S')] ✘ $*" >&2; }
die()     { error "$*"; exit 1; }

# ── Argument parsing ───────────────────────────────────────────────────────────
SERVICE=""
CLUSTER=""
IMAGE=""
RUN_MIGRATIONS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service)         SERVICE="$2";           shift 2 ;;
    --cluster)         CLUSTER="$2";           shift 2 ;;
    --image)           IMAGE="$2";             shift 2 ;;
    --run-migrations)  RUN_MIGRATIONS="$2";    shift 2 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[[ -z "$SERVICE"  ]] && die "--service is required"
[[ -z "$CLUSTER"  ]] && die "--cluster is required"
[[ -z "$IMAGE"    ]] && die "--image is required"

# ── Validate inputs ────────────────────────────────────────────────────────────
log "Deploying $SERVICE to cluster $CLUSTER"
log "Image: $IMAGE"

# Verify the cluster exists
aws ecs describe-clusters --clusters "$CLUSTER" \
  --query "clusters[?clusterName=='$CLUSTER'] | [0].status" \
  --output text | grep -q "ACTIVE" || die "Cluster $CLUSTER is not active"

# Verify the service exists
aws ecs describe-services \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --query "services[0].status" \
  --output text | grep -q "ACTIVE" || die "Service $SERVICE not found in $CLUSTER"

# ── Run migrations ─────────────────────────────────────────────────────────────
if [[ "$RUN_MIGRATIONS" == "true" ]]; then
  log "Running database migrations..."
  TASK_DEF="${SERVICE}-migrate"
  TASK_ARN=$(aws ecs run-task \
    --cluster "$CLUSTER" \
    --task-definition "$TASK_DEF" \
    --launch-type FARGATE \
    --query 'tasks[0].taskArn' \
    --output text) || die "Failed to start migration task"

  log "Migration task ARN: $TASK_ARN"
  log "Waiting for migration task to complete..."

  aws ecs wait tasks-stopped \
    --cluster "$CLUSTER" \
    --tasks "$TASK_ARN"

  EXIT_CODE=$(aws ecs describe-tasks \
    --cluster "$CLUSTER" \
    --tasks "$TASK_ARN" \
    --query 'tasks[0].containers[0].exitCode' \
    --output text)

  [[ "$EXIT_CODE" == "0" ]] || die "Migration task failed with exit code $EXIT_CODE"
  success "Migrations completed successfully"
fi

# ── Update task definition ─────────────────────────────────────────────────────
log "Fetching current task definition..."
CURRENT_TASK_DEF=$(aws ecs describe-task-definition \
  --task-definition "$SERVICE" \
  --query 'taskDefinition')

log "Rendering new task definition with image: $IMAGE"
NEW_TASK_DEF=$(printf '%s' "$CURRENT_TASK_DEF" | python3 -c '
import json
import sys

service_name, image = sys.argv[1:3]
task_definition = json.load(sys.stdin)
for container in task_definition.get("containerDefinitions", []):
    if container["name"] == service_name:
        container["image"] = image

for key in (
    "taskDefinitionArn", "revision", "status", "requiresAttributes",
    "compatibilities", "registeredAt", "registeredBy",
):
    task_definition.pop(key, None)

print(json.dumps(task_definition))
' "$SERVICE" "$IMAGE")

NEW_TASK_ARN=$(echo "$NEW_TASK_DEF" | aws ecs register-task-definition \
  --cli-input-json file:///dev/stdin \
  --query 'taskDefinition.taskDefinitionArn' \
  --output text)

log "New task definition: $NEW_TASK_ARN"

# ── Rolling deploy ─────────────────────────────────────────────────────────────
log "Updating ECS service with new task definition..."
aws ecs update-service \
  --cluster "$CLUSTER" \
  --service "$SERVICE" \
  --task-definition "$NEW_TASK_ARN" \
  --force-new-deployment

log "Waiting for service to stabilise..."
aws ecs wait services-stable \
  --cluster "$CLUSTER" \
  --services "$SERVICE"

success "Service $SERVICE deployed successfully to $CLUSTER"
s