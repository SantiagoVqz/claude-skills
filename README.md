# Claude Skills

My skill harness for Claude Code. It is the [`mattpocock/skills`](https://github.com/mattpocock/skills) set, kept verbatim under my own names, apart from small additions to `to-spec`, `setup-skills` and `triage`. His work is worth a look. Beside it sit my own `worktree`, `dispatch`, `ship`, `cleanup`, `close-ticket`, `setup-worktrees`, `upgrade-skills`, `ticket-clerk`, `ui-review` and `unslop`, plus his in-progress `retro` and `pr`.

See [`skills/README.md`](./skills/README.md) for the full set. It follows the groups on the [aihero.dev skills page](https://www.aihero.dev/skills): getting started, the main flow, shaping, upkeep, productivity, reference.

## The flow

Run `/setup-skills` once per repo, and `/upgrade-skills` in a repo set up under an earlier version of this set. Then take an idea through `/grill-with-docs`, `/to-spec` and `/to-tickets`. For each ticket, run `/implement <ticket>` in a fresh context and commit. You open the PR and merge. If you do not remember which skill you want, `/ask` routes you.

My own skills sit on top of that flow without changing it. `/dispatch <spec>` runs `/implement` per ticket in a subagent on one spec branch, `close-ticket` closes each ticket as its commit lands, `/ship` opens the PR with a `/pr` body, and `/cleanup` tears the branch down after the merge.

Code work runs in a linked worktree, one spec per worktree. The primary checkout keeps planning and docs. A change to docs only, such as an ADR or `CONTEXT.md`, goes straight to the trunk with no branch and no PR. That fails on a trunk with branch protection, where docs still need a PR.

`/setup-worktrees` installs `scripts/provision.sh` and a session hook once per repo. A worktree made by Herdr, by `git worktree add`, or by the `worktree` skill is then provisioned the same way: env files, dependencies, free ports, and a test database of its own. The dev database is the primary's, shared, because a fork is slow. A spec whose `Schema changes:` line lists migrations gets its own fork, and so does a spec with no such line. `/implement` and `/dispatch` reach the `worktree` skill before they write code. When the conversation is in a worktree you made, the skill uses it. From the primary, it creates the worktree under `.claude/worktrees/` with plain git, so no new Herdr pane opens while the conversation stays in the primary's pane.

Dispatch state is the triage labels: `ready-for-agent` is the queue, `ready-for-human` is a checkpoint, `needs-triage` is a ticket the agent failed twice.

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
