#!/usr/bin/env bash
#
# upgrade-engine.sh <repo's provision.sh> [--apply]
#
# Compares the ENGINE section of a repo's script with this set's template. It
# prints a diff; --apply writes it. The CONFIG and DATABASE blocks stay as they are.
#
# Last output line: current | upgradable | upgraded | own.
# `own` means the repo has its own engine, so nothing changes. It is a function
# name in both the repo's config and the template's ENGINE: replacing the section
# would overwrite the repo's function (KNOT's provision_db, for one).
set -euo pipefail

target="${1:?usage: upgrade-engine.sh <provision.sh> [--apply]}"
apply="${2:-}"
[[ -f "$target" ]] || { echo "no such file: $target" >&2; exit 2; }
template="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/provision.sh"
marker='^# ENGINE — repo-independent'

engine_line() { grep -n -m1 "$marker" "$1" | cut -d: -f1 || true; }
functions()   { grep -oE '^[A-Za-z_][A-Za-z0-9_]*\(\)' | sort -u; }

t_line="$(engine_line "$template")"
r_line="$(engine_line "$target")"
[[ -n "$r_line" ]] || { echo own; exit 0; }

# The banner line above the marker belongs to the section.
shared="$(comm -12 \
  <(head -n "$((r_line - 2))" "$target" | functions) \
  <(tail -n "+$((t_line - 1))" "$template" | functions))"
[[ -z "$shared" ]] || { echo own; exit 0; }

new="$(mktemp)"; trap 'rm -f "$new"' EXIT
{ head -n "$((r_line - 2))" "$target"; tail -n "+$((t_line - 1))" "$template"; } >"$new"

cmp -s "$new" "$target" && { echo current; exit 0; }
diff -u "$target" "$new" || true
if [[ "$apply" == "--apply" ]]; then
  cat "$new" >"$target"   # cat keeps the file's mode
  echo upgraded
else
  echo upgradable
fi
