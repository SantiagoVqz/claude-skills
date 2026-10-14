#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_DIR="$HOME/.claude/skills"

usage() {
  echo "Usage: ./install.sh [--all | path/to/skill] [--global] [--prefix NAME | --no-prefix]"
  echo ""
  echo "Options:"
  echo "  --global        Install to ~/.claude/skills/ (default: .claude/skills/ in current dir)"
  echo "  --all           Install all skills (symlinked)"
  echo "  --prefix NAME   Install as NAME-<skill> so project skills do not shadow global ones"
  echo "  --no-prefix     Install under the bare skill name without asking"
  echo ""
  echo "A skill path is its folder relative to the repo root. Nesting depth is free;"
  echo "skills always install under their leaf name, plus the prefix if one is set."
  echo "A project install with no --prefix/--no-prefix flag asks for one on a terminal."
  echo ""
  echo "Examples:"
  echo "  ./install.sh v1.1/user-invoked/cleanup --prefix acme   # .claude/skills/acme-cleanup"
  echo "  ./install.sh v1.1/model-invoked/tdd --global           # Install globally"
  echo "  ./install.sh --all --global                            # Install all skills globally"
  exit 1
}

GLOBAL=false
ALL=false
SKILL=""
PREFIX=""
PREFIX_SET=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global) GLOBAL=true ;;
    --all) ALL=true ;;
    --prefix)
      if [[ $# -lt 2 || "$2" == -* ]]; then
        echo "Error: --prefix needs a name"; echo ""; usage
      fi
      PREFIX="$2"; PREFIX_SET=true; shift
      ;;
    --no-prefix) PREFIX=""; PREFIX_SET=true ;;
    --help|-h) usage ;;
    # An unknown flag is a typo, not a skill path. Silently treating it as one
    # made `--globall --all` install locally with no warning.
    -*) echo "Error: unknown option: $1"; echo ""; usage ;;
    *)
      if [[ -n "$SKILL" ]]; then
        echo "Error: more than one skill path given: $SKILL and $1"; echo ""; usage
      fi
      SKILL="$1"
      ;;
  esac
  shift
done

if [[ "$ALL" == false && -z "$SKILL" ]]; then
  usage
fi

if [[ "$ALL" == true && -n "$SKILL" ]]; then
  echo "Error: --all takes no skill path, but got: $SKILL"
  echo ""
  usage
fi

# Project skills shadow global ones by name, so a project install asks for a
# prefix unless the caller already decided with --prefix or --no-prefix.
if [[ "$GLOBAL" == false && "$PREFIX_SET" == false && -t 0 ]]; then
  read -r -p "Prefix for project skills (e.g. acme -> acme-<skill>; empty for none): " PREFIX
fi

if [[ -n "$PREFIX" && ! "$PREFIX" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "Error: prefix must be lowercase letters, digits, and single dashes: $PREFIX"
  exit 1
fi

# List every skill path (folder relative to repo root that holds a SKILL.md).
list_skills() {
  find "$SCRIPT_DIR" -name SKILL.md -not -path '*/.git/*' -not -path "$SCRIPT_DIR/Progress/*" \
    | sed "s|$SCRIPT_DIR/||;s|/SKILL.md||" | sort
}

install_skill() {
  local src="$1"
  local skill_name
  skill_name="${PREFIX:+$PREFIX-}$(basename "$src")"

  if [[ "$GLOBAL" == true ]]; then
    local dest="$GLOBAL_DIR/$skill_name"
  else
    local dest=".claude/skills/$skill_name"
  fi

  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "Error: $dest exists and is not a symlink — refusing to overwrite. Remove it manually."
    exit 1
  fi
  rm -rf "$dest"           # drop any prior symlink
  ln -s "$src" "$dest"     # symlink → edits in the repo are live, no re-install
  echo "Linked $skill_name → $dest"
}

if [[ "$ALL" == true ]]; then
  # Skills install by leaf name, so two skills sharing one is a silent overwrite — refuse.
  dupes="$(list_skills | awk -F/ '{print $NF}' | sort | uniq -d)"
  if [[ -n "$dupes" ]]; then
    echo "Error: duplicate skill leaf names:"
    echo "$dupes"
    exit 1
  fi
  while IFS= read -r skill_md; do
    install_skill "$(dirname "$skill_md")"
  done < <(find "$SCRIPT_DIR" -name SKILL.md -not -path '*/.git/*' -not -path "$SCRIPT_DIR/Progress/*")
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
