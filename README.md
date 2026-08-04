# Claude Skills

Personal collection of reusable Claude Code skills. The engineering and productivity sets are copied from [`mattpocock/skills`](https://github.com/mattpocock/skills) — please check his work out! — with exactly two local deltas: `ask-matt` and `setup-matt-pocock-skills` are renamed to `ask` and `setup-skills` (and cross-references updated), and `setup-skills` carries a restored **Section D — Worktree provisioning** (`provision.sh` template + exploration bullet + seed-template entry) for parallel-worktree work. Local skills (`ship`, `reconcile-branch`, `cleanup`) ride alongside.

| Folder | What's inside |
|--------|---------------|
| [`skills/engineering/`](./skills/engineering) | Upstream: `ask` (the router), `setup-skills`, `grill-with-docs`, `to-spec`, `to-tickets`, `implement`, `wayfinder`, `triage`, `improve-codebase-architecture`, `two-axis-review`, `tdd`, `prototype`, `research`, `diagnosing-bugs`, `resolving-merge-conflicts`, `domain-modeling`, `codebase-design`. |
| [`skills/productivity/`](./skills/productivity) | Upstream: `grilling`, `grill-me`, `handoff`, `teach`, `writing-great-skills`. |
| [`skills/own/`](./skills/own) | Mine: `ship` — rebase onto trunk, full suite, push, PR; `reconcile-branch` — integrate a moved base and audit that the surviving diff is exactly the intended change; `cleanup` — post-merge teardown of a ticket's worktree, branches, scratch DB, Docker leftovers, and a trunk refresh. |

## The flow

Run `/setup-skills` once per repo, then plan: `/grill-with-docs` → `/to-spec` → `/to-tickets` (tracer-bullet vertical slices with blocking edges — each ticket independently demoable, so each can land on the trunk by itself).

Then **per ticket, trunk-based**: worktree + branch off the trunk (provision per Section D) → `/implement <ticket>` in it (drives `/tdd`, reviews with `/two-axis-review`, commits to the current branch) → `/ship` (rebase onto trunk, full suite, push, PR carrying `Closes #<ticket>`) → **you merge** → `/cleanup` (verify issue closed, tear down worktree/branch/DB, refresh trunk). Frontier tickets can run in parallel, one worktree + terminal pane each. When the trunk moves far enough that a branch's diff needs auditing rather than a plain rebase, `/reconcile-branch` instead of `/ship`'s rebase step. `/ask` routes when you don't remember which skill you want.

To resync with upstream: re-copy `skills/engineering` and `skills/productivity` from a fresh clone, then re-apply both deltas: (1) the rename (`ask-matt` → `ask`, `setup-matt-pocock-skills` → `setup-skills`, plus cross-references); (2) `setup-skills` Section D — restore `provision.sh` into the skill folder and the three Section D edits in its `SKILL.md` (scaffold bullet, exploration bullet, Section D itself, seed-template entry) from git history.

## Installation

Skills install into either `~/.claude/skills/` (global, every project) or `.claude/skills/` (current project only), symlinked — so edits in this repo are live with no re-install.

```bash
./install.sh skills/own/cleanup                 # one skill, current project
./install.sh skills/engineering/tdd --global    # one skill, globally
./install.sh --all --global                     # everything, globally
./install.sh --all                              # everything, current project
```

Fresh machine restore:

```bash
git clone <this-repo> && cd claude-skills && ./install.sh --all --global
```

> Skills install by their leaf name (e.g. `tdd`, not `skills/engineering/tdd`) — the folders above it are organizational only. `two-axis-review` is deliberately *not* named `code-review`: that name collides with Claude Code's built-in `/code-review` (the billed multi-agent cloud review), and the ambiguity leaked into skills that reference it, like `/implement`.

## Conventions

- `install.sh` discovers any `SKILL.md` at any depth, so nesting is free; two skills must never share a leaf name.
- Upstream folders stay byte-identical to upstream except the two documented deltas above — all other local changes go in `skills/own/`.
