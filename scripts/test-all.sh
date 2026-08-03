#!/usr/bin/env bash
# test-all.sh — Run tests for every service and app in the Marketplace platform
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
COVERAGE=false

log()     { echo "[$(date '+%H:%M:%S')] $*"; }
success() { echo "[$(date '+%H:%M:%S')] ✔ $*"; }
error()   { echo "[$(date '+%H:%M:%S')] ✘ $*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --parallel) PARALLEL=true  ;;
    --coverage) COVERAGE=true  ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
  shift
done

$COVERAGE && export CI=true

test_one() {
  local path="$1"
  local name; name=$(basename "$path")
  local full="$ROOT_DIR/$path"

  [[ -d "$full" ]] || { error "Not found: $full"; return 1; }

  pushd "$full" > /dev/null
  pnpm install --frozen-lockfile --silent
  if $COVERAGE; then
    pnpm run test:coverage
  else
    pnpm run test
  fi
  popd > /dev/null
  success "$name tests passed"
}

log "Running tests for all services (parallel=$PARALLEL, coverage=$COVERAGE)..."

if $PARALLEL; then
  declare -A pids
  for svc in "${SERVICES[@]}"; do
    test_one "$svc" &
    pids[$!]="$svc"
  done
  for pid in "${!pids[@]}"; do
    if wait "$pid"; then PASSED+=("${pids[$pid]}")
    else               FAILED+=("${pids[$pid]}")
    fi
  done
else
  for svc in "${SERVICES[@]}"; do
    if test_one "$svc"; then PASSED+=("$svc")
    else                     FAILED+=("$svc")
    fi
  done
fi

echo ""
echo "════════════════════ Test Summary ═════════════════════"
printf "  ✔  %s\n" "${PASSED[@]}"
if (( ${#FAILED[@]} > 0 )); then
  printf "  ✘  %s\n" "${FAILED[@]}"
  echo "═══════════════════════════════════════════════════════"
  exit 1
fi
echo "═══════════════════════════════════════════════════════"
success "All tests passed (${#PASSED[@]} packages)"
