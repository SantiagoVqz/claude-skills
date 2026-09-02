# Claude Skills

My skill harness for Claude Code. It is the [`mattpocock/skills`](https://github.com/mattpocock/skills) set (please check his work out!), kept verbatim under my own names, plus my `cleanup` skill and one edit to `implement`: the first ticket of a spec creates and provisions a worktree, so separate specs run in parallel.

See [`skills/README.md`](./skills/README.md) for the full set, grouped as on the [aihero.dev skills page](https://www.aihero.dev/skills): getting started, the main flow, shaping, upkeep, productivity, reference.

## The flow

Run `/setup-skills` once per repo. Then `/grill-with-docs` an idea → `/to-spec` → `/to-tickets`. Per ticket, `/implement <ticket>`: the first ticket of a spec creates the spec's worktree and branch and runs `scripts/provision.sh`; later tickets commit to the same branch. `/code-review` before each commit. You open the PR and merge. `/cleanup` after the merge. `/ask` routes when you do not remember which skill you want.

## Installation

Skills install into either `~/.claude/skills/` (global, every project) or `.claude/skills/` (current project only), symlinked, so edits in this repo are live with no re-install.

```bash
./install.sh skills/main-flow/cleanup      # one skill, current project
./install.sh skills/reference/tdd --global # one skill, globally
./install.sh --all --global                # everything, globally
./install.sh --all                         # everything, current project
```

Fresh machine restore:

```bash
git clone <this-repo> && cd claude-skills && ./install.sh --all --global
```

> Skills install by their leaf name (e.g. `tdd`, not `skills/reference/tdd`). Folders above it are organizational only.

## Conventions

- `install.sh` discovers any `SKILL.md` at any depth (excluding `Progress/`, the drafting area), so nesting is free; two skills must never share a leaf name.
