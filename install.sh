#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_DIR="$HOME/.claude/skills"

usage() {
  echo "Usage: ./install.sh [--all | --pipeline | path/to/skill] [--global] [--prefix <p>]"
  echo ""
  echo "Options:"
  echo "  --global      Install to ~/.claude/skills/ (default: .claude/skills/ in current dir)"
  echo "  --all         Install all skills (symlinked)"
  echo "  --pipeline    Copy the engineering pipeline (main skills + everything they call)"
  echo "                into the current project's .claude/skills/. Copies, not symlinks —"
  echo "                meant to be committed and shared with a team. Prompts for a name"
  echo "                prefix (e.g. 'knot' installs knot_grilling, knot_implement, ...)."
  echo "  --prefix <p>  Pipeline prefix, non-interactive (skips the prompt; '' = none)"
  echo ""
  echo "A skill path is its folder relative to the repo root. Nesting depth is free"
  echo "(category or category/sub-category); skills always install under their leaf name."
  echo ""
  echo "Examples:"
  echo "  ./install.sh engineering/build/tdd            # Install to current project"
  echo "  ./install.sh engineering/plan/grilling --global  # Install globally"
  echo "  ./install.sh --all --global                   # Install all skills globally"
  echo "  ./install.sh --pipeline                       # Pipeline into current project (prompts prefix)"
  echo "  ./install.sh --pipeline --prefix knot         # Pipeline as knot_<skill>"
  exit 1
}

# The engineering pipeline: the main skills run by hand, plus every skill they
# call transitively. Derived from cross-references in the SKILL.md files —
# update this list if a pipeline skill starts calling a new one.
#   Roots:   grilling grill-with-docs wayfinder implement phase-done cleanup
#   Called:  domain-modeling+prototype+research+setup-skills (wayfinder/grill-with-docs),
#            tdd+two-axis-review+phase-done (implement), ship (phase-done), cleanup (ship)
PIPELINE_SKILLS=(
  engineering/plan/grilling
  engineering/plan/grill-with-docs
  engineering/plan/wayfinder
  engineering/plan/domain-modeling
  engineering/plan/prototype
  engineering/plan/research
  engineering/setup/setup-skills
  engineering/build/implement
  engineering/build/tdd
  engineering/build/phase-done
  engineering/review/two-axis-review
  engineering/review/ship
  engineering/review/cleanup
)

GLOBAL=false
ALL=false
PIPELINE=false
PREFIX=""
PREFIX_SET=false
SKILL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global) GLOBAL=true ;;
    --all) ALL=true ;;
    --pipeline) PIPELINE=true ;;
    --prefix) shift; PREFIX="${1:-}"; PREFIX_SET=true ;;
    --prefix=*) PREFIX="${1#--prefix=}"; PREFIX_SET=true ;;
    --help|-h) usage ;;
    *) SKILL="$1" ;;
  esac
  shift
done

if [[ "$ALL" == false && "$PIPELINE" == false && -z "$SKILL" ]]; then
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

  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"           # drop any prior copy or stale symlink
  ln -s "$src" "$dest"     # symlink → edits in the repo are live, no re-install
  echo "Linked $skill_name → $dest"
}

# Copy one pipeline skill into .claude/skills/, applying the prefix to the
# folder name, the frontmatter `name:`, and every /<skill> cross-reference.
install_pipeline_skill() {
  local src="$1"
  local leaf target dest
  leaf="$(basename "$src")"
  target="${PREFIX:+${PREFIX}_}$leaf"
  dest=".claude/skills/$target"

  mkdir -p .claude/skills
  rm -rf "$dest"
  cp -R "$src" "$dest"

  if [[ -n "$PREFIX" ]]; then
    # Frontmatter name must match the installed folder name.
    local tmp="$dest/SKILL.md.tmp"
    awk -v n="$target" 'BEGIN{done=0} !done && /^name:/{print "name: " n; done=1; next} {print}' \
      "$dest/SKILL.md" >"$tmp" && mv "$tmp" "$dest/SKILL.md"

    # Rewrite /<skill> invocations of other pipeline skills to their prefixed
    # names, so the copied pipeline stays internally connected. Only slashed
    # references not embedded in a path (lookbehind bars a preceding word char,
    # so scripts/cleanup*.sh survives). Built-ins like /simplify are untouched.
    local p other
    for p in "${PIPELINE_SKILLS[@]}"; do
      other="$(basename "$p")"
      find "$dest" -name '*.md' -exec \
        perl -pi -e "s{(?<![\\w.-])/\Q$other\E(?![\\w-])}{/${PREFIX}_$other}g" {} +
    done
  fi

  echo "Copied $leaf → $dest"
}

if [[ "$PIPELINE" == true ]]; then
  if [[ "$GLOBAL" == true ]]; then
    echo "Error: --pipeline installs into the current project (it's meant to be committed and shared); --global is not supported."
    exit 1
  fi
  if [[ "$PREFIX_SET" == false ]]; then
    read -r -p "Prefix for skill names (e.g. 'knot' → knot_grilling; empty for none): " PREFIX
  fi
  if [[ -n "$PREFIX" && ! "$PREFIX" =~ ^[A-Za-z0-9-]+$ ]]; then
    echo "Error: prefix must be letters, digits, or hyphens (got '$PREFIX')"
    exit 1
  fi
  for p in "${PIPELINE_SKILLS[@]}"; do
    if [[ ! -f "$SCRIPT_DIR/$p/SKILL.md" ]]; then
      echo "Error: pipeline skill missing from repo: $p (fix PIPELINE_SKILLS in install.sh)"
      exit 1
    fi
  done
  for p in "${PIPELINE_SKILLS[@]}"; do
    install_pipeline_skill "$SCRIPT_DIR/$p"
  done
  echo ""
  echo "Pipeline installed: ${#PIPELINE_SKILLS[@]} skills copied into .claude/skills/."
  echo "These are copies (not symlinks) — commit them so the team gets the whole pipeline."
  if [[ -n "$PREFIX" ]]; then
    echo "Cross-references between pipeline skills were rewritten to the ${PREFIX}_ names."
  fi
  echo "Next: run /${PREFIX:+${PREFIX}_}setup-skills once in this repo to configure the tracker, labels, and worktree provisioner."
  exit 0
fi

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
