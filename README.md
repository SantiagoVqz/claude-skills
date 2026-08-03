# Claude Skills

Personal collection of reusable Claude Code skills. Many are adapted from [`mattpocock/skills`](https://github.com/mattpocock/skills) and nudged to taste; the delivery lifecycle (`spec-done`, `cleanup`, and `implement`'s slice gate) is mine. Please check his work out!

Everything lives in [`v1.1/`](./v1.1), split by how each skill is reached:

| Folder | What's inside |
|--------|---------------|
| [`v1.1/user-invoked/`](./v1.1/user-invoked) | Reachable only when you type them. The pipeline: `setup-skills`, `grill-with-docs`, `to-spec`, `to-tickets`, `implement`, `spec-done`, `cleanup`, plus `wayfinder`, `triage`, `handoff` and the `ask` router. |
| [`v1.1/model-invoked/`](./v1.1/model-invoked) | Model- or user-reachable, so other skills can call them: `grilling`, `tdd`, `prototype`, `research`, `diagnosing-bugs`, `resolving-merge-conflicts`, `code-review`, `domain-modeling`, `codebase-design`. |

[`v1.1/README.md`](./v1.1/README.md) lists every skill with a one-line description.

## The flow

```
/setup-skills   (once per repo)

/grill-with-docs ──► /to-spec ──► /to-tickets ──► /implement   (slice loop, per ticket)
        ▲                                              │
  big effort ──/wayfinder                              ▼
                                                  /spec-done   (once)
                                                       │
                          /cleanup ◄── you merge ◄──── PR ── you verify in the worktree
```

**One spec → one worktree → one feature branch → one gated commit per ticket.** The worktree is the parallel unit (fan out across specs, provisioned once and shared by every ticket in it). The feature branch is the only branch: `/implement`'s slice loop lands each ticket on it as one commit — build, then gate (cold-read + scoped checks + `/simplify`, fired in one turn), then commit with a full body and close the issue. Ticket N+1 starts on a branch that already contains N. No task branches, no per-ticket PRs, no cascading rebase.

The per-ticket commits and the spec PR are your first read even solo: the AI wrote the code and you haven't read it — the audit trail, not a formality.

Work too small for a spec takes **light mode**: `/implement` runs the same slice loop on one branch off the trunk, opens its PR to the trunk, and stops — you merge; no worktree, no `/spec-done`, no `/cleanup`.

**Three closures, three altitudes.** The ticket closes when its gated commit lands on the feature branch (unblocking the next). The spec closes when the feature branch merges to the trunk — `/cleanup` does that, so an open spec issue always means work built but not shipped. The release closes when it deploys, via a project-local skill outside this pipeline.

**No skill merges to the trunk.** `/spec-done` pushes the branch (its first trip to origin), opens the feature's PR, and stops; you verify in the still-standing worktree, push tweaks, and merge by hand.

Two gates, sized differently, which is what keeps the loop fast: the slice gate stays scoped to the diff and runs on every ticket inside `/implement`, while everything that scales with the *spec* — the traceability walk, the rebase onto the trunk, the full suite, cross-ticket duplication, spec conformance — waits for `/spec-done`.

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

**Dependencies:** the pipeline fires two Claude Code built-ins — the `/simplify` skill and the `Explore` agent type (`implement`'s slice gate and `spec-done` use both). Note that installing `code-review` shadows Claude Code's built-in `/code-review` — intentional; remove the symlink to get the built-in back.

## Conventions

- Skill names use kebab-case.
- Each skill lives in a `<skill-name>/SKILL.md` folder with YAML frontmatter (`name`, `description`). The frontmatter `name` must match the folder name.
- User-invoked skills set `disable-model-invocation: true`; model-invoked ones carry rich trigger phrasing in their description instead.
- Reference material that only some runs need lives in a sibling `.md` file, reached by a pointer from `SKILL.md`.
- `install.sh` discovers any `SKILL.md` at any depth, so nesting is free.
