# Claude Skills

Personal collection of reusable Claude Code skills.

## Skills

| Skill | Description |
|-------|-------------|
| `grill-me` | Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. |
| `improve-codebase-architecture` | Explore a codebase to find opportunities for architectural improvement, focusing on making the codebase more testable by deepening shallow modules. |
| `prd-to-issues` | Break a PRD into independently-grabbable GitHub issues using tracer-bullet vertical slices. |
| `tdd` | Test-driven development with red-green-refactor loop. |
| `verify` | Generate and optionally execute E2E verification steps after completing a plan or implementation. |
| `write-a-prd` | Create a PRD through user interview, codebase exploration, and module design, then submit as a GitHub issue. |

## Installation

### Install a skill globally (all projects)

```bash
./install.sh <skill-name> --global
# Example: ./install.sh grill-me --global
```

### Install a skill into the current project

```bash
./install.sh <skill-name>
# Example: ./install.sh verify
```

### Install all skills globally

```bash
./install.sh --all --global
```

### Manual installation

```bash
# Global
cp -r <skill-name> ~/.claude/skills/<skill-name>

# Project
cp -r <skill-name> .claude/skills/<skill-name>
```
