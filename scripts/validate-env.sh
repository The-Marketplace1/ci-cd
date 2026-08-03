#!/usr/bin/env bash
# validate-env.sh — Validate that required environment variables are set before deployment
set -euo pipefail

die() { echo "✘ $*" >&2; exit 1; }

ENV=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env) ENV="$2"; shift 2 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[[ -z "$ENV" ]] && die "--env is required"

# Required for all environments
COMMON_REQUIRED=(
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY
  AWS_REGION
  AWS_ACCOUNT_ID
)

# Additional production-only requirements
PROD_REQUIRED=(
  SLACK_WEBHOOK_URL
)

check_vars() {
  local missing=()
  for var in "$@"; do
    if [[ -z "${!var:-}" ]]; then
      missing+=("$var")
    fi
  done
  if (( ${#missing[@]} > 0 )); then
    echo "❌ Missing required environment variables:"
    printf '  - %s\n' "${missing[@]}"
    return 1
  fi
  return 0
}

echo "Validating environment: $ENV"

check_vars "${COMMON_REQUIRED[@]}" || die "Common env validation failed"

if [[ "$ENV" == "production" ]]; then
  check_vars "${PROD_REQUIRED[@]}" || die "Production env validation failed"
fi

echo "✔ All required environment variables are set for $ENV"
