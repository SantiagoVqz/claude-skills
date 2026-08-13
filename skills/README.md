# My skill harness

My own skill set, highly inspired by [mattpocock/skills](https://github.com/mattpocock/skills) (reference copies in [`../Progress/reference/`](../Progress/reference/)) but authored for my workflow: trunk-based, per-ticket worktrees, parallel agents, TDD by default, minimal instructions.

## Structure

- **Top level** — the pipeline skills (plan → build → land), plus the two structural ones: `ask` (the router — "what skill do I run here?") and `setup-skills` (per-repo config: tracker, labels, domain docs, worktree/Docker provisioning).
- [`support/`](./support) — modular skills the pipeline composes but you rarely invoke by name: `domain-modeling` (paired with `/grilling` by grill/triage/wayfinder), `research` and `prototype` (wayfinder ticket types), `resolving-merge-conflicts` (ship/reconcile hand off to it). Keeping them separate is what lets wayfinder call exactly the piece it needs.

## The set

| Skill | Invocation | What it's for |
|-------|------------|---------------|
| `ask` | `/ask` | The router: flows, on-ramps, and which skill fits the situation. |
| `setup-skills` | `/setup-skills` | Once per repo: issue tracker (GitHub/GitLab/Linear/local), triage labels, domain docs, `provision.sh` worktree provisioning with Docker awareness. |
| `grill` | `/grill` | Entry point: runs `/grilling` together with `/domain-modeling` — the interview that leaves a paper trail. |
| `grilling` | model | The pure interview engine: frontier-of-questions rounds, facts are the agent's job, decisions are yours. Composed by `grill`, `triage`, and `wayfinder`. |
| `spec` | `/spec` | Synthesize the grilled conversation into a spec on the tracker. No interview. |
| `tickets` | `/tickets` | Cut a spec into strictly vertical tracer-bullet slices with blocking edges (logical **and** same-code-area), sized for parallel worktree agents. Backend + frontend bundled per slice. |
| `triage` | `/triage` | Classify captured tickets later: category + state roles, claim verification, `/grilling` + `/domain-modeling` when thin, agent briefs. |
| `implement` | `/implement` | One ticket, ready → committed: worktree + provision, ground in rules/glossary/ADRs, TDD at agreed seams, full suite + lint, 3-attempt self-correction, commit. Loopable. |
| `tdd` | model | The red → green reference: seams, anti-patterns, rules of the loop. |
| `wayfinder` | `/wayfinder` | Fog-of-war planning, upstream-faithful: shared map of decision tickets (grilling/research/prototype/task types), resolved one at a time. |
| `ship` | `/ship` | Rebase onto trunk, full suite, push, PR with `Closes #<ticket>`. Never merges. |
| `reconcile-branch` | model | Integrate a moved base and audit that the surviving diff is exactly the intended change. |
| `cleanup` | `/cleanup` | Post-merge teardown: worktree, branches, scratch DB, Docker leftovers ([docker.md](./cleanup/docker.md)), trunk refresh. |
| `support/domain-modeling` | model | The active glossary/ADR discipline: sharpen terms, update `CONTEXT.md` inline, offer ADRs behind the three gates ([formats](./support/domain-modeling)). |
| `support/research` | model | Background agent investigating against primary sources, leaving a cited markdown file. |
| `support/prototype` | model | Throwaway code answering one design question — logic demo or UI variations. |
| `support/resolving-merge-conflicts` | model | Resolve an in-progress merge/rebase hunk by hunk, by intent; never `--abort`. |
| `support/wizard` | model | Interactive bash wizard for steps only a human can take — credentials, CI secrets, third-party dashboards, one-off cutovers. Kept upstream-verbatim. |

## Deliberately dropped from the upstream set

- **improve-codebase-architecture / simplify** — not needed.
- **triage's PR-as-issue surface and `.out-of-scope/` knowledge base** — lean first; add back if rejected requests start recurring.
- **handoff / teach / to-questionnaire / wait-what / grill-me / two-axis-review / codebase-design / diagnosing-bugs** — not part of my flow (all recoverable from git history or upstream).

## Status

Live since 2026-08-12; the upstream engineering/productivity copies were deleted the same day (recoverable from git history). Installed globally via `./install.sh --all --global`.
