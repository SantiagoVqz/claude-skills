# Claude Skills

My skill harness for Claude Code. It is the [`mattpocock/skills`](https://github.com/mattpocock/skills) set, kept verbatim under my own names. His work is worth a look. On top of it I added my `cleanup` and `dispatch` skills and one edit to `implement`. The first ticket of a spec creates and provisions a worktree, so separate specs run in parallel.

See [`skills/README.md`](./skills/README.md) for the full set. It follows the groups on the [aihero.dev skills page](https://www.aihero.dev/skills): getting started, the main flow, shaping, upkeep, productivity, reference.

## The flow

Run `/setup-skills` once per repo. Then take an idea through `/grill-with-docs`, `/to-spec` and `/to-tickets`. For each ticket, run `/implement <ticket>`. The first ticket of a spec creates the spec's worktree and branch and runs `scripts/provision.sh`. Later tickets commit to the same branch. Run `/code-review` before each commit. You open the PR and merge. Run `/cleanup` after the merge.

To run a spec without babysitting, replace the per-ticket loop with `/dispatch <spec>` in its own pane. It runs `/implement` per ticket in the spec worktree, closes each ticket as it commits, and hands you a green branch to land. It opens no PR and merges nothing. Add `/loop` in front when the spec carries `hitl` checkpoints, so the session outlasts the wait for you. If you do not remember which skill you want, `/ask` routes you.

## Installation

`install.sh` symlinks a skill into `~/.claude/skills/` for every project, or into `.claude/skills/` for the current project only. Because they are symlinks, an edit in this repo is live at once. No re-install.

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

> A skill installs by its leaf name, so `tdd` and not `skills/reference/tdd`. The folders above it only group skills.

## Conventions

- `install.sh` finds every `SKILL.md` at any depth, so you can nest folders as you like. It skips `Progress/`, the drafting area.
- Two skills must never share a leaf name.
