#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_DIR="$HOME/.claude/skills"

usage() {
  echo "Usage: ./install.sh [--all] [--global] [category/skill-name]"
  echo ""
  echo "Options:"
  echo "  --global    Install to ~/.claude/skills/ (default: .claude/skills/ in current dir)"
  echo "  --all       Install all skills"
  echo ""
  echo "Examples:"
  echo "  ./install.sh github/create-issue          # Install to current project"
  echo "  ./install.sh jira/jira-epic-import --global  # Install globally"
  echo "  ./install.sh --all --global               # Install all skills globally"
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
  for skill_dir in "$SCRIPT_DIR"/*/*/; do
    if [[ -f "$skill_dir/SKILL.md" ]]; then
      install_skill "$skill_dir"
    fi
  done
else
  src="$SCRIPT_DIR/$SKILL"
  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "Error: Skill not found at $src/SKILL.md"
    echo ""
    echo "Available skills:"
    find "$SCRIPT_DIR" -name "SKILL.md" -mindepth 3 | sed "s|$SCRIPT_DIR/||;s|/SKILL.md||" | sort
    exit 1
  fi
  install_skill "$src"
fi
