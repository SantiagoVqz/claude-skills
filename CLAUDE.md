# Claude Skills Repository

Personal collection of reusable Claude Code skills.

## Structure

Skills are grouped by purpose into category folders. Each skill lives in a `<skill-name>/SKILL.md` folder (plus optional reference docs). Nesting depth is free — a category may hold skills directly, or split them into sub-categories (as `engineering/` does):

```
<category>/
  README.md              # Lists the skills in this category
  [<sub-category>/]       # Optional grouping (e.g. engineering/plan)
    <skill-name>/
      SKILL.md           # Skill definition (frontmatter + instructions)
      *.md               # Optional reference docs
```

## Categories

- **engineering/** — the build pipeline, grouped by phase:
  - `plan/` — `grilling`, `grill-with-docs`, `wayfinder`, `research`, `prototype`, `domain-modeling`, `codebase-design`
  - `spec/` — `to-spec`, `to-tickets`
  - `build/` — `implement`, `tdd`
  - `review/` — `code-review`, `improve-codebase-architecture`, `reconcile-branch`, `triage`
  - `setup/` — `setup-skills`
- **productivity/** — `handoff`, `writing-great-skills`
- **design/** — `impeccable`
- **marketing/** — `seo-geo-audit`

Most engineering skills are adapted from [`mattpocock/skills`](https://github.com/mattpocock/skills) and nudged to taste; `reconcile-branch` and the `design/` skills are mine. Run `setup-skills` once per repo before the tracker-backed skills.

New categories and sub-categories are free to add — `install.sh` discovers any `SKILL.md` at any depth.

## Installation

Use `install.sh` to install skills globally (`~/.claude/skills/`) or into a project (`.claude/skills/`). Skills are referenced by their folder path (e.g. `engineering/build/tdd`) but install under their leaf name only. Fresh-machine restore: clone the repo and run `./install.sh --all --global`.

## Conventions

- Skill names use kebab-case
- Each SKILL.md has YAML frontmatter with `name` and `description`
- Each category folder has a `README.md` describing its skills
- The root README.md and category READMEs should be kept in sync with actual skills
