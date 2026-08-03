# Claude Skills Repository

Personal collection of reusable Claude Code skills.

## Structure

Skills live under `v1.1/`, split by **how each skill is reached** rather than by topic. Each skill is a `<skill-name>/SKILL.md` folder plus optional reference docs:

```
v1.1/
  README.md              # Lists every skill with a one-line description
  user-invoked/          # disable-model-invocation: true — only reachable by typing
    <skill-name>/
      SKILL.md
      *.md               # Optional reference docs, reached by a pointer from SKILL.md
  model-invoked/         # Model- or user-reachable; other skills can call these
    <skill-name>/
      SKILL.md
```

The split is the load trade-off: a model-invoked description sits in context every turn, so it buys autonomous reach; a user-invoked skill costs nothing but has to be remembered — which is what the `ask` router is for.

## The pipeline

```
/setup-skills  →  /grill-with-docs  →  /to-spec  →  /to-tickets  →  /implement
                                                                        ↓
                                                    /ticket-done  (per ticket, tight)
                                                                        ↓
                              /cleanup  ←  merge  ←  /ship  ←  /feature-done  (once)
```

**One spec → one worktree → one stack → one PR per ticket.** Two units:

- **worktree** — horizontal. One per **feature**, worked in parallel with other features.
- **layer** — vertical. One per **ticket**: its own branch, its own PR, reviewable the moment it seals. Named `<type>/<feature>-<NN>-<ticket-slug>`.

`/to-tickets` emits a blocking DAG whose edges set the layer order; after that git holds the dependency, since ticket N's branch is based on N-1's. Nothing needs unlocking, and a ticket is unblocked when its blocker's PR **opens**, not merges. The cost is that a stack serializes the DAG — genuinely parallel tracks want their own spec and worktree.

A stack lives in one worktree: a cascading rebase must move every branch in the chain, and git refuses to touch a branch checked out elsewhere.

**Two gates, sized differently.** `/ticket-done` is tight — cold-read and checks scoped to the diff, run in parallel — and fires on every ticket. `/feature-done` carries everything that scales with the feature — full suite, `/simplify` over the whole diff, `/code-review` against the spec — and fires once. Running one gate at both sizes is what makes a build feel slow.

Most skills are adapted from [`mattpocock/skills`](https://github.com/mattpocock/skills); `ticket-done`, `feature-done`, `ship`, and `cleanup` are mine. The stacked path needs `gh extension install github/gh-stack`. Without it the shape collapses to **solo** — one feature branch, tickets as commits, one PR at the end — and both gates run unchanged; only per-ticket review is lost.

Ticket state lives in **one** place: the tracker `/setup-skills` configured. On GitHub/Linear/Jira that's the issue (`Closes #N` on the PR, `ready-for-agent` removed); on a local-markdown tracker it's the ticket file's checkboxes and Status. Never both.

## Installation

`install.sh` symlinks skills globally (`~/.claude/skills/`) or into a project (`.claude/skills/`), so repo edits are live with no re-install. Skills are referenced by folder path (e.g. `v1.1/model-invoked/tdd`) but install under their **leaf name** only — so two skills anywhere in the tree must never share a leaf name. Fresh-machine restore: clone and run `./install.sh --all --global`.

## Conventions

- Skill names use kebab-case, and the frontmatter `name` must match the folder name.
- User-invoked skills set `disable-model-invocation: true` and get a short human-facing description; model-invoked ones carry rich trigger phrasing instead.
- Steps end on a checkable completion criterion; skills that run a sequence end with a terse pipe-delimited `Report` line.
- Push reference material only some runs need into a sibling `.md`, reached by a pointer from `SKILL.md`.
- Keep the root README, `v1.1/README.md`, and the `ask` router in sync with the actual skill set — `ask` is the index, so a stale entry there is worse than a missing one.
