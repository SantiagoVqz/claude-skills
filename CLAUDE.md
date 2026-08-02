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
/setup-skills  →  /grill-with-docs  →  /to-spec  →  /to-tickets  →  fan out
                                                                      ↓
                              /cleanup  ←  merge  ←  /ship  ←  /phase-done  ←  /implement
```

`/to-tickets` emits a blocking DAG that drives the fan-out. Two units:

- **worktree** — horizontal. One isolated checkout per independent ticket, worked in parallel.
- **phase** — vertical. One step of a multi-phase build; a **stack layer** where stacked PRs are enabled, so each phase ships as its own PR.

A stack lives in one worktree: a cascading rebase must move every branch in the chain, and git refuses to touch a branch checked out elsewhere. Phase branches are named `<type>/<feature>-phase-<n>`.

Most skills are adapted from [`mattpocock/skills`](https://github.com/mattpocock/skills); `phase-done`, `ship`, and `cleanup` are mine. The stacked path needs `gh extension install github/gh-stack`, and falls back to solo-branch mode where stacked PRs aren't enabled.

## Installation

`install.sh` symlinks skills globally (`~/.claude/skills/`) or into a project (`.claude/skills/`), so repo edits are live with no re-install. Skills are referenced by folder path (e.g. `v1.1/model-invoked/tdd`) but install under their **leaf name** only — so two skills anywhere in the tree must never share a leaf name. Fresh-machine restore: clone and run `./install.sh --all --global`.

## Conventions

- Skill names use kebab-case, and the frontmatter `name` must match the folder name.
- User-invoked skills set `disable-model-invocation: true` and get a short human-facing description; model-invoked ones carry rich trigger phrasing instead.
- Steps end on a checkable completion criterion; skills that run a sequence end with a terse pipe-delimited `Report` line.
- Push reference material only some runs need into a sibling `.md`, reached by a pointer from `SKILL.md`.
- Keep the root README, `v1.1/README.md`, and the `ask` router in sync with the actual skill set — `ask` is the index, so a stale entry there is worse than a missing one.
