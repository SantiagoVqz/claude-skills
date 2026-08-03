# Claude Skills

Personal collection of reusable Claude Code skills. Many are adapted from [`mattpocock/skills`](https://github.com/mattpocock/skills) and nudged to taste; the delivery lifecycle (`ticket-done`, `spec-done`, `cleanup`) is mine. Please check his work out!

Everything lives in [`v1.1/`](./v1.1), split by how each skill is reached:

| Folder | What's inside |
|--------|---------------|
| [`v1.1/user-invoked/`](./v1.1/user-invoked) | Reachable only when you type them. The pipeline: `setup-skills`, `grill-with-docs`, `to-spec`, `to-tickets`, `implement`, `ticket-done`, `spec-done`, `cleanup`, plus `wayfinder`, `triage`, `handoff` and the `ask` router. |
| [`v1.1/model-invoked/`](./v1.1/model-invoked) | Model- or user-reachable, so other skills can call them: `grilling`, `tdd`, `prototype`, `research`, `diagnosing-bugs`, `resolving-merge-conflicts`, `code-review`, `domain-modeling`, `codebase-design`. |

[`v1.1/README.md`](./v1.1/README.md) lists every skill with a one-line description.

## The flow

```
/setup-skills   (once per repo)

/grill-with-docs ──► /to-spec ──► /to-tickets ──► /implement ──┐
        ▲                                             ▲        │
  big effort ──/wayfinder                             └─ /ticket-done   (per ticket)
                                                               │
                                            /spec-done ◄────────┘   (once)
                                                 │
                                          PR ──► you merge ──► /cleanup
```

**One spec → one worktree → one feature branch → one PR per ticket.** The worktree is the parallel unit (fan out across specs, provisioned once and shared by every ticket in it). The feature branch is the integration branch inside it. Each ticket is a short-lived task branch, squash-merged into the feature branch by `/ticket-done` — which is what makes ticket N+1 buildable, since it's cut from a feature branch that already contains N. No stacking, no cascading rebase, no extension required.

A PR per ticket is worth it even solo: the AI wrote the code and you haven't read it, so that PR is your genuine first read rather than a formality.

**Three closures, three altitudes.** The ticket closes when its PR squash-merges into the feature branch (unblocking the next). The spec closes when the feature branch merges to the trunk — `/cleanup` does that, so an open spec issue always means work built but not shipped. The release closes when it deploys, via a project-local skill outside this pipeline.

**No skill merges to the trunk.** `/spec-done` opens the feature's PR and stops; landing it is always your call.

Two gates, sized differently, which is what keeps the loop fast: `/ticket-done` stays scoped to the diff and runs on every ticket (cold-read, checks, and `/simplify` all fired in one turn), while everything that scales with the *spec* — the traceability walk, the rebase onto the trunk, the full suite, cross-ticket duplication, spec conformance — waits for `/spec-done`.

## Installation

Skills install into either `~/.claude/skills/` (global, every project) or `.claude/skills/` (current project only), symlinked — so edits in this repo are live with no re-install.

```bash
./install.sh v1.1/user-invoked/cleanup          # one skill, current project
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
