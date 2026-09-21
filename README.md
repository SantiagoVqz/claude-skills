# Claude Skills

My skill harness for Claude Code. It is the [`mattpocock/skills`](https://github.com/mattpocock/skills) set, kept verbatim under my own names. His work is worth a look. Beside it sit my own `worktree`, `dispatch`, `ship`, `cleanup`, `close-ticket`, `ticket-clerk`, `ui-review` and `unslop`, plus his in-progress `retro` and `pr`.

See [`skills/README.md`](./skills/README.md) for the full set. It follows the groups on the [aihero.dev skills page](https://www.aihero.dev/skills): getting started, the main flow, shaping, upkeep, productivity, reference.

## The flow

Run `/setup-skills` once per repo. Then take an idea through `/grill-with-docs`, `/to-spec` and `/to-tickets`. For each ticket, run `/implement <ticket>` in a fresh context and commit. You open the PR and merge. If you do not remember which skill you want, `/ask` routes you.

My own skills sit on top of that flow without changing it. `/dispatch <spec>` runs `/implement` per ticket in a subagent on one spec branch, `close-ticket` closes each ticket as its commit lands, `/ship` opens the PR with a `/pr` body, and `/cleanup` tears the branch and its worktree down after the merge.

Every spec branch lives in its own linked worktree, so the primary checkout stays free. `/setup-skills` installs the repo's `scripts/provision.sh` and a session hook. The script gives a worktree env files, dependencies, and a forked database. The hook provisions any worktree you open by hand, whatever tool made it, and you never call `/worktree` yourself. `/worktree <branch>` finds or creates the worktree for a branch and provisions it; `/dispatch` calls it, because subagents run inside a session already open in the primary. Dispatch state is the five triage labels: `ready-for-agent` is the queue, `ready-for-human` is a checkpoint, `needs-triage` is a ticket the agent failed twice.

## Installation

`install.sh` symlinks a skill into `~/.claude/skills/` for every project, or into `.claude/skills/` for the current project only. Because they are symlinks, an edit in this repo is live at once. No re-install.

```bash
./install.sh skills/main-flow/cleanup --prefix acme   # one skill, current project, as acme-cleanup
./install.sh skills/reference/tdd --global            # one skill, globally
./install.sh --all --global                           # everything, globally
./install.sh --all --no-prefix                        # everything, current project, bare names
```

Fresh machine restore:

```bash
git clone <this-repo> && cd claude-skills && ./install.sh --all --global
```

> A skill installs by its leaf name, so `tdd` and not `skills/reference/tdd`. The folders above it only group skills.

## Conventions

- A project install asks for a prefix. `--prefix acme` installs `acme-cleanup`, so the project copy does not shadow a global `cleanup`. `--no-prefix` skips the question.
- `install.sh` finds every `SKILL.md` at any depth, so you can nest folders as you like. It skips `Progress/`, the drafting area.
- Two skills must never share a leaf name.
