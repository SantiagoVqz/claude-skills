# Claude Skills

Personal collection of reusable Claude Code skills, grouped by purpose.

## Categories

| Folder | What's inside |
|--------|---------------|
| [`planning/`](./planning) | Shape work before code: interviews, PRDs, issue slicing, feature promotion. |
| [`coding/`](./coding) | Write and refactor code: TDD loop, architecture improvement. |
| [`quality/`](./quality) | Confirm work works: end-to-end verification. |
| [`productivity/`](./productivity) | Manage your own working state: handoffs between conversations. |

Each category folder has its own `README.md` listing the skills inside.

## Installation

Skills install into either `~/.claude/skills/` (global, available in every project) or `.claude/skills/` (only the current project). Use `install.sh` from the repo root.

### Install one skill

```bash
# Into the current project
./install.sh <category>/<skill-name>
# Example:
./install.sh coding/tdd

# Globally
./install.sh <category>/<skill-name> --global
# Example:
./install.sh planning/grill-me --global
```

### Install everything

```bash
./install.sh --all --global   # all skills, globally
./install.sh --all            # all skills, current project
```

### Manual installation

```bash
# Global
cp -r <category>/<skill-name> ~/.claude/skills/<skill-name>

# Project
cp -r <category>/<skill-name> .claude/skills/<skill-name>
```

> Skills install by their leaf name (e.g. `tdd`, not `coding/tdd`) — the category folder is organizational only.

## Conventions

- Skill names use kebab-case.
- Each skill lives in `<category>/<skill-name>/SKILL.md` with YAML frontmatter (`name`, `description`).
- Each category folder has a `README.md` describing its skills.
- New categories are free to add — `install.sh` discovers any `*/<skill>/SKILL.md`.
