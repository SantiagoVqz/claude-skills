# Claude Skills

Personal collection of reusable Claude Code skills. The engineering and productivity sets are copied from [`mattpocock/skills`](https://github.com/mattpocock/skills) — please check his work out! — with exactly one local delta: `ask-matt` and `setup-matt-pocock-skills` are renamed to `ask` and `setup-skills` (and cross-references updated). One local skill (`cleanup`) rides alongside.

| Folder | What's inside |
|--------|---------------|
| [`skills/engineering/`](./skills/engineering) | Upstream: `ask` (the router), `setup-skills`, `grill-with-docs`, `to-spec`, `to-tickets`, `implement`, `wayfinder`, `triage`, `improve-codebase-architecture`, `code-review`, `tdd`, `prototype`, `research`, `diagnosing-bugs`, `resolving-merge-conflicts`, `domain-modeling`, `codebase-design`. |
| [`skills/productivity/`](./skills/productivity) | Upstream: `grilling`, `grill-me`, `handoff`, `teach`, `writing-great-skills`. |
| [`skills/own/`](./skills/own) | Mine: `cleanup` — post-merge teardown of a spec's worktree, branches, scratch DB, Docker leftovers, and a trunk refresh. |

## The flow

Run `/setup-skills` once per repo, then: `/grill-with-docs` → `/to-spec` → `/to-tickets` → `/implement` (drives `/tdd`, reviews with `/code-review`, commits to the current branch). `/ask` routes when you don't remember which skill you want. Landing the work — push, PR, merge — is yours; `/cleanup` reclaims the machine afterwards when the work lived in a worktree.

To resync with upstream: re-copy `skills/engineering` and `skills/productivity` from a fresh clone, then re-apply the rename (`ask-matt` → `ask`, `setup-matt-pocock-skills` → `setup-skills`, plus cross-references) — the only local edit they carry.

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

> Skills install by their leaf name (e.g. `tdd`, not `skills/engineering/tdd`) — the folders above it are organizational only. Note `code-review` shadows Claude Code's built-in `/code-review` when installed — intentional; remove the symlink to get the built-in back.

## Conventions

- `install.sh` discovers any `SKILL.md` at any depth, so nesting is free; two skills must never share a leaf name.
- Upstream folders stay byte-identical to upstream — local changes go in `skills/own/`.
