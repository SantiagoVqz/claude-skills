# Claude Skills Repository

Personal collection of reusable Claude Code skills.

## Structure

Each skill lives in its own top-level directory with a `SKILL.md` file (and optional reference files):

```
<skill-name>/
  SKILL.md        # Skill definition (frontmatter + instructions)
  *.md            # Optional reference docs
```

## Skills

- **grill-me** — Stress-test a plan or design through relentless interviewing
- **write-a-prd** — Create a PRD through interview, codebase exploration, and module design
- **prd-to-issues** — Break a PRD into vertical-slice GitHub issues
- **promote-feature** — Turn a deferred-features stub into a ralph-loop-ready scope (moves doc, files issues with `feature/<slug>` label, initializes `plans/`)
- **tdd** — Test-driven development with red-green-refactor loop
- **improve-codebase-architecture** — Find architectural improvement opportunities via deep modules
- **verify** — Generate and execute E2E verification steps post-implementation

## Installation

Use `install.sh` to install skills globally (`~/.claude/skills/`) or into a project (`.claude/skills/`).

## Conventions

- Skill names use kebab-case
- Each SKILL.md has YAML frontmatter with `name` and `description`
- README.md should be kept in sync with actual skills (a hook handles this automatically)
