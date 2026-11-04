#!/usr/bin/env bash
# Backstop for a light plan: a written verdict records a judgment, and the diff catches a wrong one.
# Usage: hardstop-check.sh <base ref>
# It is armed only when a commit in <base>..HEAD says "Hard stops: none".
# UI, contract and third-issue stops stay judgment calls, because no file pattern finds them.
# Exit: 0 pass, 3 refused, 6 could not read git, 64 usage.
set -uo pipefail

[ $# -eq 1 ] || { echo "usage: hardstop-check.sh <base ref>" >&2; exit 64; }
base=$1

messages=$(git log --format=%B "$base..HEAD") || { echo "HARD-STOP: error · cannot read the log from $base"; exit 6; }
files=$(git diff --name-only "$base...HEAD") || { echo "HARD-STOP: error · cannot read the diff from $base"; exit 6; }

if ! printf '%s\n' "$messages" | grep -qiE '^Hard stops: none[[:space:]]*$'; then
  echo "HARD-STOP: pass · not armed, no commit says Hard stops: none"
  exit 0
fi

hits=0
report() { # kind, pattern
  matches=$(printf '%s\n' "$files" | grep -iE "$2" || true)
  [ -n "$matches" ] || return 0
  while IFS= read -r path; do
    echo "$1 · $path"
    hits=$((hits + 1))
  done <<< "$matches"
}

report migration '(^|/)(migrations?|alembic/versions|db/migrate)/'
report backfill '(^|/)[^/]*backfill[^/]*$'
report auth '(^|/)(auth|authn|authz|authentication|authorization)(/|\.[^/]+$)'
report permissions '(^|/)(permissions?|rbac)(/|\.[^/]+$)'

if [ "$hits" -gt 0 ]; then
  echo "HARD-STOP: refused · $hits files contradict Hard stops: none"
  exit 3
fi
echo "HARD-STOP: pass · the diff agrees with Hard stops: none"
