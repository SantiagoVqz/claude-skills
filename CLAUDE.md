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
                            /cleanup  ←  you merge  ←  PR  ←  /spec-done  (once)
```

**One spec → one worktree → one feature branch → one PR per ticket.** Three units:

- **worktree** — horizontal. One per **spec**, worked in parallel with other specs. Provisioned once by `/implement` Step 0 — env, ports, DB — and shared by every ticket in it.
- **feature branch** — the integration branch inside the worktree, cut once off the trunk. Named `<type>/<feature>`. Never committed to directly.
- **task branch** — vertical. One per **ticket**: cut from the feature branch, its own PR, squash-merged back by `/ticket-done`. Named `<type>/<feature>-<NN>-<ticket-slug>`.

`/to-tickets` emits a blocking DAG whose edges set the ticket order; after that git holds the dependency, since ticket N+1 is cut from a feature branch that already contains N. Nothing needs unlocking and no rebase cascades. The cost is that this serializes the DAG — genuinely parallel tracks want their own spec and worktree.

A per-ticket PR earns its keep even solo: the AI wrote the code and you haven't read it, so that PR is your genuine first read, not a formality.

**Three closures, three altitudes.** A unit's state tracks what that unit controls:

- **ticket** (unit of work) — closes when its PR squash-merges into the feature branch, which is what unblocks the next ticket. `/ticket-done` does it.
- **spec** (unit of delivery) — closes when the feature branch merges to the trunk. `/cleanup` does it, so an open spec issue reliably means built-but-not-shipped.
- **release** (unit of value) — closes on deploy, via a project-local release skill outside this pipeline.

**No skill merges to the trunk.** `/ticket-done` merges task branches into the feature branch — not the trunk, nothing shipped. `/spec-done` opens the feature's PR and stops. Landing it is always the user's call.

**Two gates, sized differently.** `/ticket-done` is tight — cold-read, scoped checks, and `/simplify` on this ticket's diff, all fired in one turn — and runs on every ticket. `/spec-done` carries everything that scales with the spec — traceability walk, rebase onto the trunk, full suite, cross-ticket `/simplify`, `/code-review` against the spec — and runs once. Running one gate at both sizes is what makes a build feel slow.

**Traceability** is what makes conformance countable instead of a vibe: `/to-tickets` maps each numbered user story to the ticket delivering it and writes the table into the **spec issue body**; `/spec-done` walks it both ways, flagging stories with no ticket and tickets with no story.

Most skills are adapted from [`mattpocock/skills`](https://github.com/mattpocock/skills); `ticket-done`, `spec-done`, and `cleanup` are mine. No `gh` extension is required.

Ticket state lives in **one** place: the tracker `/setup-skills` configured. On GitHub/Linear/Jira that's the issue (closed explicitly by `/ticket-done` — `Closes #N` only fires on merges into the *default* branch, which the feature branch isn't); on a local-markdown tracker it's the ticket file's checkboxes and Status. Never both.

## Installation

`install.sh` symlinks skills globally (`~/.claude/skills/`) or into a project (`.claude/skills/`), so repo edits are live with no re-install. Skills are referenced by folder path (e.g. `v1.1/model-invoked/tdd`) but install under their **leaf name** only — so two skills anywhere in the tree must never share a leaf name. Fresh-machine restore: clone and run `./install.sh --all --global`.

## Conventions

- Skill names use kebab-case, and the frontmatter `name` must match the folder name.
- User-invoked skills set `disable-model-invocation: true` and get a short human-facing description; model-invoked ones carry rich trigger phrasing instead.
- Steps end on a checkable completion criterion; skills that run a sequence end with a terse pipe-delimited `Report` line.
- Push reference material only some runs need into a sibling `.md`, reached by a pointer from `SKILL.md`.
- Keep the root README, `v1.1/README.md`, and the `ask` router in sync with the actual skill set — `ask` is the index, so a stale entry there is worse than a missing one.
