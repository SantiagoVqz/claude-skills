# Claude Skills

Personal collection of reusable Claude Code skills. Many are adapted from [`mattpocock/skills`](https://github.com/mattpocock/skills) and nudged to taste; the delivery lifecycle (`ticket-done`, `feature-done`, `ship`, `cleanup`) is mine. Please check his work out!

Everything lives in [`v1.1/`](./v1.1), split by how each skill is reached:

| Folder | What's inside |
|--------|---------------|
| [`v1.1/user-invoked/`](./v1.1/user-invoked) | Reachable only when you type them. The pipeline: `setup-skills`, `grill-with-docs`, `to-spec`, `to-tickets`, `implement`, `ticket-done`, `feature-done`, `ship`, `cleanup`, plus `wayfinder`, `triage`, `handoff` and the `ask` router. |
| [`v1.1/model-invoked/`](./v1.1/model-invoked) | Model- or user-reachable, so other skills can call them: `grilling`, `tdd`, `prototype`, `research`, `diagnosing-bugs`, `resolving-merge-conflicts`, `code-review`, `domain-modeling`, `codebase-design`. |

[`v1.1/README.md`](./v1.1/README.md) lists every skill with a one-line description.

## The flow

```
/setup-skills   (once per repo)

/grill-with-docs ──► /to-spec ──► /to-tickets ──► /implement ──┐
        ▲                                             ▲        │
  big effort ──/wayfinder                             └─ /ticket-done   (per ticket)
                                                               │
                                          /feature-done ◄───────┘   (once)
                                                 │
                                              /ship ──► merge ──► /cleanup
```

**One spec → one worktree → one stack → one PR per ticket.** The worktree is the parallel unit (fan out across features); the layer is the serial unit (one per ticket, inside the feature). `/to-tickets` emits a blocking DAG, and those edges order the layers — after that git holds the dependency, since ticket N's branch is based on N-1's.

A stack lives in one worktree — a cascading rebase has to move every branch in the chain, and git won't touch a branch checked out elsewhere. So the DAG gets serialized inside a feature; genuinely parallel tracks want their own spec and their own worktree.

Two gates, sized differently, which is what keeps the loop fast: `/ticket-done` stays scoped to the diff and runs on every ticket, while everything that scales with the *feature* — the full suite, `/simplify`, spec conformance — waits for `/feature-done`.

Requires [`gh stack`](https://github.com/github/gh-stack) (`gh extension install github/gh-stack`) for the stacked path; the skills fall back to solo-branch mode where stacked PRs aren't enabled.

## Installation

Skills install into either `~/.claude/skills/` (global, every project) or `.claude/skills/` (current project only), symlinked — so edits in this repo are live with no re-install.

```bash
./install.sh v1.1/user-invoked/ship             # one skill, current project
./install.sh v1.1/model-invoked/tdd --global    # one skill, globally
./install.sh --all --global                     # everything, globally
./install.sh --all                              # everything, current project
```

Fresh machine restore:

```bash
git clone <this-repo> && cd claude-skills && ./install.sh --all --global
```

> Skills install by their leaf name (e.g. `tdd`, not `v1.1/model-invoked/tdd`) — the folders above it are organizational only.

## Conventions

- Skill names use kebab-case.
- Each skill lives in a `<skill-name>/SKILL.md` folder with YAML frontmatter (`name`, `description`). The frontmatter `name` must match the folder name.
- User-invoked skills set `disable-model-invocation: true`; model-invoked ones carry rich trigger phrasing in their description instead.
- Reference material that only some runs need lives in a sibling `.md` file, reached by a pointer from `SKILL.md`.
- `install.sh` discovers any `SKILL.md` at any depth, so nesting is free.
