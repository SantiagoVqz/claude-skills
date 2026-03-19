#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README="$REPO_ROOT/README.md"
TABLE_FILE=$(mktemp)

# Build the skills table from all */SKILL.md files
{
  echo "| Skill | Description |"
  echo "|-------|-------------|"
  for skill_file in "$REPO_ROOT"/*/SKILL.md; do
    [ -f "$skill_file" ] || continue
    name=$(awk '/^name:/{print substr($0, index($0,$2)); exit}' "$skill_file")
    # Extract first sentence only for the table
    full_desc=$(awk '/^description:/{print substr($0, index($0,$2)); exit}' "$skill_file")
    desc=$(echo "$full_desc" | sed 's/\([^.]*\.\).*/\1/')
    echo "| \`$name\` | $desc |"
  done
} > "$TABLE_FILE"

# Replace the table between "## Skills" and the next "##" heading
awk -v tfile="$TABLE_FILE" '
  /^## Skills/ {
    print
    getline  # consume the blank line after heading
    print
    # skip old table rows
    while ((getline line) > 0) {
      if (line ~ /^\|/) continue
      if (line ~ /^[[:space:]]*$/) continue
      break
    }
    # insert new table
    while ((getline tline < tfile) > 0) print tline
    close(tfile)
    print ""
    # print the line that ended the skip (next heading or content)
    if (line != "") print line
    next
  }
  { print }
' "$README" > "$README.tmp" && mv "$README.tmp" "$README"

rm -f "$TABLE_FILE"
