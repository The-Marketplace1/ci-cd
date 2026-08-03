#!/usr/bin/env bash
# deploy-all.sh — Deploy every service to a target environment
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SERVICES=(
  api-gateway
  auth-service
  backend-api
  payment-service
  notification-service
  realtime-service
  communication-service
  admin-dashboard
  customer-app
  professional-app
)

log()     { echo "[$(date '+%H:%M:%S')] $*"; }
success() { echo "[$(date '+%H:%M:%S')] ✔ $*"; }
error()   { echo "[$(date '+%H:%M:%S')] ✘ $*" >&2; }
die()     { error "$*"; exit 1; }

ENV=""
IMAGE_TAG="latest"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)       ENV="$2";       shift 2 ;;
    --image-tag) IMAGE_TAG="$2"; shift 2 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[[ -z "$ENV" ]] && die "--env is required (development|testing|staging|production)"

case "$ENV" in
  development) CLUSTER="development-cluster" ;;
  testing)     CLUSTER="testing-cluster"     ;;
  staging)     CLUSTER="staging-cluster"     ;;
  production)  CLUSTER="production-cluster"  ;;
  *)           die "Unknown environment: $ENV" ;;
esac

log "Deploying all services to $ENV (cluster: $CLUSTER, tag: $IMAGE_TAG)"

FAILED=()
PASSED=()

for svc in "${SERVICES[@]}"; do
  log "Deploying $svc..."
  IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${svc}:${IMAGE_TAG}"
  if bash "$SCRIPT_DIR/deploy-service.sh" \
       --service "${svc}-service" \
       --cluster "$CLUSTER" \
       --image   "$IMAGE"; then
    success "$svc deployed"
    PASSED+=("$svc")
  else
    error "$svc deployment FAILED"
    FAILED+=("$svc")
  fi
done

echo ""
echo "════════════════════ Deploy Summary ═══════════════════"
printf "  ✔  %s\n" "${PASSED[@]}"
if (( ${#FAILED[@]} > 0 )); then
  printf "  ✘  %s\n" "${FAILED[@]}"
  echo "═══════════════════════════════════════════════════════"
  exit 1
fi
echo "═══════════════════════════════════════════════════════"
success "All ${#PASSED[@]} services deployed to $ENV"
