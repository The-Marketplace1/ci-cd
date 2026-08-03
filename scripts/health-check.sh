#!/usr/bin/env bash
# health-check.sh — Poll a service health endpoint until it responds or times out
set -euo pipefail

log()     { echo "[$(date '+%H:%M:%S')] $*"; }
success() { echo "[$(date '+%H:%M:%S')] ✔ $*"; }
error()   { echo "[$(date '+%H:%M:%S')] ✘ $*" >&2; }
die()     { error "$*"; exit 1; }

SERVICE=""
ENV=""
PATH_OVERRIDE="/health"
RETRIES=12
DELAY=15

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service) SERVICE="$2"; shift 2 ;;
    --env)     ENV="$2";     shift 2 ;;
    --path)    PATH_OVERRIDE="$2"; shift 2 ;;
    --retries) RETRIES="$2"; shift 2 ;;
    --delay)   DELAY="$2";   shift 2 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[[ -z "$SERVICE" ]] && die "--service is required"
[[ -z "$ENV"     ]] && die "--env is required"

case "$ENV" in
  development) BASE="https://dev.${SERVICE}.internal" ;;
  testing)     BASE="https://test.${SERVICE}.internal" ;;
  staging)     BASE="https://staging.${SERVICE}.marketplace.io" ;;
  production)  BASE="https://${SERVICE}.marketplace.io" ;;
  *) die "Unknown environment: $ENV" ;;
esac

URL="${BASE}${PATH_OVERRIDE}"
log "Health check: $URL (retries=$RETRIES, delay=${DELAY}s)"

ATTEMPT=0
until curl -sf --max-time 10 "$URL" > /dev/null 2>&1; do
  ATTEMPT=$((ATTEMPT + 1))
  if [[ $ATTEMPT -ge $RETRIES ]]; then
    error "Service $SERVICE did not become healthy after $RETRIES attempts"
    die "Health check FAILED for $SERVICE in $ENV"
  fi
  log "  Attempt $ATTEMPT/$RETRIES — not healthy yet, retrying in ${DELAY}s..."
  sleep "$DELAY"
done

success "Service $SERVICE is healthy in $ENV ($URL)"
