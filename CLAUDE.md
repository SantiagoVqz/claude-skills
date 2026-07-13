# Claude Skills Repository

Personal collection of reusable Claude Code skills.

## Structure

Skills are grouped by purpose into category folders. Each skill lives in `<category>/<skill-name>/SKILL.md` (plus optional reference docs):

```
<category>/
  README.md            # Lists the skills in this category
  <skill-name>/
    SKILL.md           # Skill definition (frontmatter + instructions)
    *.md               # Optional reference docs
```

## Categories

- **engineering/** — the build pipeline (`grilling`, `grill-with-docs`, `to-spec`, `to-tickets`, `implement`, `code-review`, `tdd`, `wayfinder`, `research`, `improve-codebase-architecture`, `codebase-design`, `domain-modeling`, `prototype`, `triage`, `reconcile-branch`, `setup-skills`)
- **productivity/** — `handoff`, `writing-great-skills`
- **design/** — `ui-ux-pro-max`, `impeccable`
- **marketing/** — `seo-geo-audit`

Most engineering skills are adapted from [`mattpocock/skills`](https://github.com/mattpocock/skills) and nudged to taste; `reconcile-branch` and the `design/` skills are mine. Run `setup-skills` once per repo before the tracker-backed skills.

New categories are free to add — `install.sh` discovers any `*/<skill>/SKILL.md`.

## Installation

Use `install.sh` to install skills globally (`~/.claude/skills/`) or into a project (`.claude/skills/`). Skills are referenced by `<category>/<skill-name>` (e.g. `engineering/tdd`) but install under their leaf name only. Fresh-machine restore: clone the repo and run `./install.sh --all --global`.

## Conventions

- Skill names use kebab-case
- Each SKILL.md has YAML frontmatter with `name` and `description`
- Each category folder has a `README.md` describing its skills
- The root README.md and category READMEs should be kept in sync with actual skills
