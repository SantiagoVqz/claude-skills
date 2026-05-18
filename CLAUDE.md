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

- **planning/** — `grill-me`, `write-a-prd`, `prd-to-issues`, `promote-feature`
- **coding/** — `tdd`, `improve-codebase-architecture`
- **quality/** — `verify`
- **productivity/** — `handoff`

New categories are free to add — `install.sh` discovers any `*/<skill>/SKILL.md`.

## Installation

Use `install.sh` to install skills globally (`~/.claude/skills/`) or into a project (`.claude/skills/`). Skills are referenced by `<category>/<skill-name>` (e.g. `coding/tdd`) but install under their leaf name only.

## Conventions

- Skill names use kebab-case
- Each SKILL.md has YAML frontmatter with `name` and `description`
- Each category folder has a `README.md` describing its skills
- The root README.md and category READMEs should be kept in sync with actual skills
