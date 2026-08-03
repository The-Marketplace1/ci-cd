#!/usr/bin/env bash
# generate-changelog.sh — Generate a changelog from conventional commits
set -euo pipefail

log()  { echo "[$(date '+%H:%M:%S')] $*"; }
die()  { echo "✘ $*" >&2; exit 1; }

SERVICE=""
FROM_TAG=""
TO="HEAD"
OUTPUT="CHANGELOG.md"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service)   SERVICE="$2";   shift 2 ;;
    --from-tag)  FROM_TAG="$2";  shift 2 ;;
    --to)        TO="$2";        shift 2 ;;
    --output)    OUTPUT="$2";    shift 2 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[[ -z "$SERVICE" ]] && die "--service is required"

log "Generating changelog for $SERVICE (${FROM_TAG:-beginning}..${TO})"

if [[ -n "$FROM_TAG" ]]; then
  RANGE="${FROM_TAG}..${TO}"
else
  RANGE="$TO"
fi

# Collect commits by type
BREAKING=$(git log "$RANGE" --pretty=format:"%s" 2>/dev/null \
  | grep -iE "^(feat|fix|refactor|perf)(\(.+\))?!:|BREAKING CHANGE" || true)
FEATURES=$(git log "$RANGE" --pretty=format:"- %s (%h)" 2>/dev/null \
  | grep -E "^- feat(\(.+\))?:" | sed 's/^- feat[^:]*: /- /' || true)
FIXES=$(git log "$RANGE" --pretty=format:"- %s (%h)" 2>/dev/null \
  | grep -E "^- fix(\(.+\))?:" | sed 's/^- fix[^:]*: /- /' || true)
PERF=$(git log "$RANGE" --pretty=format:"- %s (%h)" 2>/dev/null \
  | grep -E "^- perf(\(.+\))?:" | sed 's/^- perf[^:]*: /- /' || true)
DEPS=$(git log "$RANGE" --pretty=format:"- %s (%h)" 2>/dev/null \
  | grep -E "^- (chore|deps|build)\(.*(dep|package)\)" || true)

DATE=$(date '+%Y-%m-%d')
{
  echo "# Changelog — ${SERVICE}"
  echo ""
  echo "## [Unreleased] — ${DATE}"
  echo ""

  if [[ -n "$BREAKING" ]]; then
    echo "### ⚠ BREAKING CHANGES"
    echo ""
    echo "$BREAKING" | while IFS= read -r line; do echo "- $line"; done
    echo ""
  fi

  if [[ -n "$FEATURES" ]]; then
    echo "### ✨ Features"
    echo ""
    echo "$FEATURES"
    echo ""
  fi

  if [[ -n "$FIXES" ]]; then
    echo "### 🐛 Bug Fixes"
    echo ""
    echo "$FIXES"
    echo ""
  fi

  if [[ -n "$PERF" ]]; then
    echo "### ⚡ Performance"
    echo ""
    echo "$PERF"
    echo ""
  fi

  if [[ -n "$DEPS" ]]; then
    echo "### 📦 Dependencies"
    echo ""
    echo "$DEPS"
    echo ""
  fi
} > "$OUTPUT"

log "Changelog written to $OUTPUT"
wc -l < "$OUTPUT" | xargs -I{} echo "  {} lines"
s