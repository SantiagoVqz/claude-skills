# Claude Skills

Personal collection of reusable Claude Code skills, adapted from [`mattpocock/skills`](https://github.com/mattpocock/skills) and nudged to taste. Please check his work out!

Everything lives in [`v1.1/`](./v1.1), split by how each skill is reached:

| Folder | What's inside |
|--------|---------------|
| [`v1.1/user-invoked/`](./v1.1/user-invoked) | Reachable only when you type them. The pipeline: `setup-skills`, `grill-with-docs`, `to-spec`, `to-tickets`, `implement`, `cleanup`, plus `wayfinder`, `triage`, `improve-codebase-architecture`, `handoff`, `writing-great-skills`, and the `ask` router. |
| [`v1.1/model-invoked/`](./v1.1/model-invoked) | Model- or user-reachable, so other skills can call them: `grilling`, `tdd`, `prototype`, `research`, `diagnosing-bugs`, `resolving-merge-conflicts`, `code-review`, `domain-modeling`, `codebase-design`. |

[`v1.1/README.md`](./v1.1/README.md) lists every skill with a one-line description.

## The flow

```
/setup-skills   (once per repo)

/grill-with-docs ──► /to-spec ──► /to-tickets ──► /implement   (slice loop, per ticket)
        ▲                                              │
  big effort ──/wayfinder                              ▼
                                        committed code ── you review, push, PR, merge
```

`/implement` builds one ticket per pass through its **slice loop** — build with `/tdd`, then gate the diff (cold-read + scoped checks + `/simplify`, fired in one turn), then one full-body commit (stories, decisions, ticket ref) and close the issue. Ticket order comes from the blocking edges `/to-tickets` declared; context clears between tickets.

**The pipeline stops at committed code.** Branching, pushing, PRs, and merging are yours — no skill touches git beyond the commit. `/code-review` reviews the whole change against a fixed point when you're ready to land it (its Spec axis walks the traceability table `/to-tickets` wrote into the spec issue), and `/resolving-merge-conflicts` fires when an integration stops on a conflict. After you merge, `/cleanup` reclaims the machine — spec issue closed, worktree removed, branches deleted, scratch DB dropped, trunk refreshed.

The per-ticket commits are your first read even solo: the AI wrote the code and you haven't read it — the audit trail, not a formality.

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

**Dependencies:** the pipeline fires two Claude Code built-ins — the `/simplify` skill and the `Explore` agent type (`implement`'s slice gate uses both). Note that installing `code-review` shadows Claude Code's built-in `/code-review` — intentional; remove the symlink to get the built-in back.

## Conventions

- Skill names use kebab-case.
- Each skill lives in a `<skill-name>/SKILL.md` folder with YAML frontmatter (`name`, `description`). The frontmatter `name` must match the folder name.
- User-invoked skills set `disable-model-invocation: true`; model-invoked ones carry rich trigger phrasing in their description instead.
- Reference material that only some runs need lives in a sibling `.md` file, reached by a pointer from `SKILL.md`.
- `install.sh` discovers any `SKILL.md` at any depth, so nesting is free.
