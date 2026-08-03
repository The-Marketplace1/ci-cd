#!/usr/bin/env bash
# build-all.sh — Build every service and app in the Marketplace platform
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

SERVICES=(
  services/api-gateway
  services/auth-service
  services/backend-api
  services/payment-service
  services/notification-service
  services/realtime-service
  services/communication-service
  apps/admin-dashboard
  apps/customer-app
  apps/professional-app
)

FAILED=()
PASSED=()
PARALLEL=false

log()     { echo "[$(date '+%H:%M:%S')] $*"; }
success() { echo "[$(date '+%H:%M:%S')] ✔ $*"; }
error()   { echo "[$(date '+%H:%M:%S')] ✘ $*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --parallel) PARALLEL=true ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
  shift
done

build_one() {
  local path="$1"
  local name; name=$(basename "$path")
  local full="$ROOT_DIR/$path"

  [[ -d "$full" ]] || { error "Not found: $full"; return 1; }

  pushd "$full" > /dev/null
  pnpm install --frozen-lockfile --silent
  pnpm run build
  popd > /dev/null
  success "$name built"
}

log "Building all services (parallel=$PARALLEL)..."

if $PARALLEL; then
  declare -A pids
  for svc in "${SERVICES[@]}"; do
    build_one "$svc" &
    pids[$!]="$svc"
  done
  for pid in "${!pids[@]}"; do
    if wait "$pid"; then PASSED+=("${pids[$pid]}")
    else               FAILED+=("${pids[$pid]}")
    fi
  done
else
  for svc in "${SERVICES[@]}"; do
    if build_one "$svc"; then PASSED+=("$svc")
    else                      FAILED+=("$svc")
    fi
  done
fi

echo ""
echo "════════════════════ Build Summary ════════════════════"
printf "  ✔  %s\n" "${PASSED[@]}"
if (( ${#FAILED[@]} > 0 )); then
  printf "  ✘  %s\n" "${FAILED[@]}"
  echo "═══════════════════════════════════════════════════════"
  exit 1
fi
echo "═══════════════════════════════════════════════════════"
success "All ${#PASSED[@]} packages built successfully"
