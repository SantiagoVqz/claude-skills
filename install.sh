#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_DIR="$HOME/.claude/skills"

usage() {
  echo "Usage: ./install.sh [--all] [--global] [path/to/skill]"
  echo ""
  echo "Options:"
  echo "  --global    Install to ~/.claude/skills/ (default: .claude/skills/ in current dir)"
  echo "  --all       Install all skills"
  echo ""
  echo "A skill path is its folder relative to the repo root. Nesting depth is free"
  echo "(category or category/sub-category); skills always install under their leaf name."
  echo ""
  echo "Examples:"
  echo "  ./install.sh engineering/build/tdd            # Install to current project"
  echo "  ./install.sh engineering/plan/grilling --global  # Install globally"
  echo "  ./install.sh design/impeccable --global       # Un-nested category also works"
  echo "  ./install.sh --all --global                   # Install all skills globally"
  exit 1
}

GLOBAL=false
ALL=false
SKILL=""

for arg in "$@"; do
  case "$arg" in
    --global) GLOBAL=true ;;
    --all) ALL=true ;;
    --help|-h) usage ;;
    *) SKILL="$arg" ;;
  esac
done

if [[ "$ALL" == false && -z "$SKILL" ]]; then
  usage
fi

# List every skill path (folder relative to repo root that holds a SKILL.md).
list_skills() {
  find "$SCRIPT_DIR" -name SKILL.md -not -path '*/.git/*' \
    | sed "s|$SCRIPT_DIR/||;s|/SKILL.md||" | sort
}

install_skill() {
  local src="$1"
  local skill_name
  skill_name="$(basename "$src")"

  if [[ "$GLOBAL" == true ]]; then
    local dest="$GLOBAL_DIR/$skill_name"
  else
    local dest=".claude/skills/$skill_name"
  fi

  mkdir -p "$dest"
  cp -r "$src"/* "$dest"/
  echo "Installed $skill_name → $dest"
}

if [[ "$ALL" == true ]]; then
  while IFS= read -r skill_md; do
    install_skill "$(dirname "$skill_md")"
  done < <(find "$SCRIPT_DIR" -name SKILL.md -not -path '*/.git/*')
else
  src="$SCRIPT_DIR/$SKILL"
  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "Error: Skill not found at $src/SKILL.md"
    echo ""
    echo "Available skills:"
    list_skills
    exit 1
  fi
  install_skill "$src"
fi
