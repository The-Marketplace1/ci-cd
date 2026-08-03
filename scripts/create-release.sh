#!/usr/bin/env bash
# create-release.sh — Bump version, tag, and create a GitHub release for a service
set -euo pipefail

command -v semver >/dev/null 2>&1 || npm install -g semver

die()  { echo "✘ $*" >&2; exit 1; }
log()  { echo "[$(date '+%H:%M:%S')] $*"; }

SERVICE=""
BUMP="auto"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service)   SERVICE="$2";   shift 2 ;;
    --bump)      BUMP="$2";      shift 2 ;;
    --dry-run)   DRY_RUN=true;   shift   ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[[ -z "$SERVICE" ]] && die "--service is required"

log "Creating release for $SERVICE (bump=$BUMP, dry-run=$DRY_RUN)"

# ── Determine current version ──────────────────────────────────────────────────
LATEST=$(git tag --sort=-v:refname | grep "^${SERVICE}@" | head -1 | sed "s/${SERVICE}@//" || echo "")
CURRENT="${LATEST:-0.0.0}"
log "Current version: $CURRENT"

# ── Determine bump type ────────────────────────────────────────────────────────
if [[ "$BUMP" == "auto" ]]; then
  LAST_TAG="${SERVICE}@${CURRENT}"
  COMMITS=$(git log "${LAST_TAG}..HEAD" --pretty=format:"%s" 2>/dev/null || git log --pretty=format:"%s")
  if echo "$COMMITS" | grep -qiE "BREAKING CHANGE|^(feat|fix)(\(.+\))?!:"; then
    BUMP="major"
  elif echo "$COMMITS" | grep -qiE "^feat(\(.+\))?:"; then
    BUMP="minor"
  else
    BUMP="patch"
  fi
  log "Auto-detected bump: $BUMP"
fi

# ── Compute new version ────────────────────────────────────────────────────────
NEW_VERSION=$(semver -i "$BUMP" "$CURRENT")
NEW_TAG="${SERVICE}@${NEW_VERSION}"
log "New version: $NEW_VERSION  →  tag: $NEW_TAG"

if $DRY_RUN; then
  log "DRY RUN — no changes made"
  exit 0
fi

# ── Generate changelog ─────────────────────────────────────────────────────────
bash "$(dirname "$0")/generate-changelog.sh" \
  --service "$SERVICE" \
  --from-tag "${SERVICE}@${CURRENT}" \
  --to HEAD \
  --output /tmp/changelog_fragment.md

# ── Create git tag ─────────────────────────────────────────────────────────────
git config user.name  "ci-cd-bot"
git config user.email "ci-cd-bot@noreply.github.com"
git tag -a "$NEW_TAG" -m "Release $NEW_TAG"
git push origin "$NEW_TAG"

# ── Create GitHub release ──────────────────────────────────────────────────────
gh release create "$NEW_TAG" \
  --title "${SERVICE} v${NEW_VERSION}" \
  --notes-file /tmp/changelog_fragment.md

log "✔ Release $NEW_TAG created"
