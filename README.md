# Claude Skills

Personal collection of reusable Claude Code skills, grouped by purpose. Many are adapted from [`mattpocock/skills`](https://github.com/mattpocock/skills) (v1.1) and nudged to taste; some are my own.

## Categories

| Folder | What's inside |
|--------|---------------|
| [`engineering/`](./engineering) | The build pipeline: grill → spec → tickets → implement, plus code review, TDD, refactoring, research, domain modeling, and branch reconciliation. |
| [`productivity/`](./productivity) | Manage your own working state: conversation handoffs and skill authoring. |
| [`design/`](./design) | UI/UX design and review intelligence. |
| [`marketing/`](./marketing) | Getting pages found, ranked, and cited: SEO + GEO auditing. |

Each category folder has its own `README.md` listing the skills inside.

## The engineering flow

Most engineering skills compose into one pipeline (run `setup-skills` once per repo first):

```
idea ──/grilling──► /to-spec ──► /to-tickets ──► /implement ──► /code-review
                                     ▲
        big effort, many sessions ──/wayfinder
```

`grilling` is the shared interview primitive; `grill-with-docs` is the same interview that also writes ADRs + glossary. `research`, `prototype`, `domain-modeling`, `codebase-design`, and `triage` are reached as needed.

## Installation

Skills install into either `~/.claude/skills/` (global, every project) or `.claude/skills/` (current project only). Use `install.sh` from the repo root.

### Install one skill

```bash
./install.sh <path/to/skill>                     # into current project
./install.sh engineering/build/tdd               # example

./install.sh <path/to/skill> --global            # globally
./install.sh engineering/plan/grilling --global  # example
```

### Install everything

```bash
./install.sh --all --global   # all skills, globally
./install.sh --all            # all skills, current project
```

### Fresh machine / backup restore

This repo is the source of truth. To restore everything on a new machine:

```bash
git clone <this-repo> && cd claude-skills && ./install.sh --all --global
```

> Skills install by their leaf name (e.g. `tdd`, not `engineering/build/tdd`) — the folders above it are organizational only.

## Conventions

- Skill names use kebab-case.
- Each skill lives in a `<skill-name>/SKILL.md` folder with YAML frontmatter (`name`, `description`). Nesting depth is free — a skill can sit under `<category>/` or a deeper `<category>/<sub-category>/` (as the busy `engineering/` tree does).
- Each category folder has a `README.md` describing its skills.
- New categories and sub-categories are free to add — `install.sh` discovers any `SKILL.md` at any depth.
