#!/usr/bin/env bash
# smoke-test.sh — Run basic smoke tests against a deployed service
set -euo pipefail

die()  { echo "✘ $*" >&2; exit 1; }
log()  { echo "[$(date '+%H:%M:%S')] $*"; }
ok()   { echo "  ✔ $*"; }
fail() { echo "  ✘ $*" >&2; FAILURES+=("$*"); }

URL=""
TIMEOUT=10
FAILURES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url)     URL="$2";     shift 2 ;;
    --timeout) TIMEOUT="$2"; shift 2 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[[ -z "$URL" ]] && die "--url is required"

log "Running smoke tests against: $URL"

# ── Test 1: Root health check ──────────────────────────────────────────────────
STATUS=$(curl -sf --max-time "$TIMEOUT" -o /dev/null -w "%{http_code}" "${URL}/health" || echo "000")
if [[ "$STATUS" == "200" ]]; then
  ok "GET /health → 200"
else
  fail "GET /health → $STATUS (expected 200)"
fi

# ── Test 2: Response time ──────────────────────────────────────────────────────
TTFB=$(curl -sf --max-time "$TIMEOUT" -o /dev/null -w "%{time_starttransfer}" "${URL}/health" || echo "999")
TTFB_MS=$(echo "$TTFB * 1000" | bc | cut -d. -f1)
if [[ "$TTFB_MS" -lt 2000 ]]; then
  ok "TTFB ${TTFB_MS}ms < 2000ms"
else
  fail "TTFB ${TTFB_MS}ms ≥ 2000ms (too slow)"
fi

# ── Test 3: Correct Content-Type ──────────────────────────────────────────────
CT=$(curl -sf --max-time "$TIMEOUT" -I "${URL}/health" 2>/dev/null \
  | grep -i content-type | head -1 | tr -d '\r\n' || echo "")
if echo "$CT" | grep -qi "application/json\|text/plain"; then
  ok "Content-Type header present"
else
  fail "Content-Type header missing or unexpected: $CT"
fi

# ── Test 4: No server errors on /api-docs (optional) ─────────────────────────
DOCS_STATUS=$(curl -sf --max-time "$TIMEOUT" -o /dev/null -w "%{http_code}" "${URL}/api-docs" || echo "000")
if [[ "$DOCS_STATUS" != "500" && "$DOCS_STATUS" != "503" ]]; then
  ok "GET /api-docs → $DOCS_STATUS (no server error)"
else
  fail "GET /api-docs → $DOCS_STATUS (server error)"
fi

# ── Result ─────────────────────────────────────────────────────────────────────
echo ""
if (( ${#FAILURES[@]} > 0 )); then
  echo "❌ Smoke tests FAILED (${#FAILURES[@]} failure(s)):"
  printf '  - %s\n' "${FAILURES[@]}"
  exit 1
fi
log "✔ All smoke tests passed for $URL"
