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
                                                            (slice loop, per ticket)
                                                                        ↓
    /cleanup  ←  you merge  ←  you verify in the worktree  ←  PR  ←  /spec-done  (once)
```

**One spec → one worktree → one feature branch → one gated commit per ticket.** Two units:

- **worktree** — horizontal. One per **spec**, worked in parallel with other specs. Provisioned once by `/implement` Step 0 — env, ports, DB — and shared by every ticket in it.
- **feature branch** — the only branch, cut once off the trunk. Named `<type>/<feature>`. Every ticket lands on it as one commit through `/implement`'s **slice loop** — build, gate (cold-read + scoped checks + `/simplify`, fired in one turn), commit with a full body (stories, decisions, ticket ref), close the issue. It first reaches origin when `/spec-done` opens its PR.

`/to-tickets` emits a blocking DAG whose edges set the ticket order; after that git holds the dependency, since ticket N+1 starts on a feature branch that already contains N's commit. Nothing needs unlocking and no rebase cascades. The cost is that this serializes the DAG — genuinely parallel tracks want their own spec and worktree.

The per-ticket commits and the spec PR are your first read even solo: the AI wrote the code and you haven't read it — the audit trail, not a formality. Work too small for a spec takes **light mode**: `/implement` runs the slice loop on one branch off the trunk, opens its PR to the trunk, and stops.

**Three closures, three altitudes.** A unit's state tracks what that unit controls:

- **ticket** (unit of work) — closes when its gated commit lands on the feature branch, which is what unblocks the next ticket. `/implement`'s slice loop does it.
- **spec** (unit of delivery) — closes when the feature branch merges to the trunk. `/cleanup` does it, so an open spec issue reliably means built-but-not-shipped.
- **release** (unit of value) — closes on deploy, via a project-local release skill outside this pipeline.

**No skill merges to the trunk.** `/spec-done` pushes the branch, opens the feature's PR, and stops — the user verifies in the still-standing worktree, pushes tweaks, and merges by hand.

**Two gates, sized differently.** The slice gate is tight — cold-read, scoped checks, and `/simplify` on this ticket's diff, all fired in one turn — and runs on every ticket inside `/implement`. `/spec-done` carries everything that scales with the spec — traceability walk, rebase onto the trunk, full suite, cross-ticket `/simplify`, `/code-review` against the spec — and runs once. Running one gate at both sizes is what makes a build feel slow.

**Traceability** is what makes conformance countable instead of a vibe: `/to-tickets` maps each numbered user story to the ticket delivering it and writes the table into the **spec issue body**; each ticket's commit body cites its story numbers; `/spec-done` walks it both ways, flagging stories with no ticket and tickets with no story.

Most skills are adapted from [`mattpocock/skills`](https://github.com/mattpocock/skills); the delivery lifecycle (`implement`'s slice gate, `spec-done`, `cleanup`) is mine. No `gh` extension is required.

Ticket state lives in **one** place: the tracker `/setup-skills` configured. On GitHub/Linear/Jira that's the issue (closed explicitly by the slice loop at commit — `Closes #N` only fires on merges into the *default* branch, which the feature branch isn't); on a local-markdown tracker it's the ticket file's checkboxes and Status. Never both.

## Installation

`install.sh` symlinks skills globally (`~/.claude/skills/`) or into a project (`.claude/skills/`), so repo edits are live with no re-install. Skills are referenced by folder path (e.g. `v1.1/model-invoked/tdd`) but install under their **leaf name** only — so two skills anywhere in the tree must never share a leaf name. Fresh-machine restore: clone and run `./install.sh --all --global`.

## Conventions

- Skill names use kebab-case, and the frontmatter `name` must match the folder name.
- User-invoked skills set `disable-model-invocation: true` and get a short human-facing description; model-invoked ones carry rich trigger phrasing instead.
- Steps end on a checkable completion criterion; skills that run a sequence end with a terse pipe-delimited `Report` line.
- Push reference material only some runs need into a sibling `.md`, reached by a pointer from `SKILL.md`.
- Keep the root README, `v1.1/README.md`, and the `ask` router in sync with the actual skill set — `ask` is the index, so a stale entry there is worse than a missing one.
