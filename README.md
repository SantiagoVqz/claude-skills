# Claude Skills

My own skill harness for Claude Code — highly inspired by [`mattpocock/skills`](https://github.com/mattpocock/skills) (please check his work out!), but authored for my workflow: trunk-based, per-ticket worktrees, parallel agents, TDD by default, minimal instructions. The upstream copies that used to live here were retired on 2026-08-12 (recoverable from git history); reference copies of the skills that inspired this set sit in [`Progress/reference/`](./Progress/reference/).

| Skill | Invocation | What it's for |
|-------|------------|---------------|
| [`ask`](./skills/ask) | `/ask` | The router: which skill or flow fits the situation. |
| [`setup-skills`](./skills/setup-skills) | `/setup-skills` | Once per repo: issue tracker (GitHub/GitLab/Linear/local), triage labels, domain docs, `provision.sh` worktree provisioning with Docker awareness. |
| [`grill`](./skills/grill) | `/grill` | Entry point: runs `/grilling` together with `/domain-modeling` — the interview that leaves a paper trail. |
| [`grilling`](./skills/grilling) | model | The pure interview engine: frontier-of-questions rounds. Composed by `grill`, `triage`, and `wayfinder`. |
| [`spec`](./skills/spec) | `/spec` | Synthesize the grilled conversation into a spec on the tracker. No interview. |
| [`tickets`](./skills/tickets) | `/tickets` | Cut a spec into strictly vertical tracer-bullet slices with blocking edges (logical **and** same-code-area), sized for parallel worktree agents. Backend + frontend bundled per slice — no half-features on trunk. |
| [`triage`](./skills/triage) | `/triage` | Classify captured tickets later: category + state roles, claim verification, `/grilling` + `/domain-modeling` when thin, agent briefs. |
| [`implement`](./skills/implement) | `/implement` | One ticket, ready → committed: worktree + provision, ground in rules/glossary/ADRs, TDD at agreed seams, full suite + lint, 3-attempt self-correction, commit. Loopable. |
| [`tdd`](./skills/tdd) | model | The red → green reference: seams, anti-patterns, rules of the loop. |
| [`wayfinder`](./skills/wayfinder) | `/wayfinder` | Fog-of-war planning at full fidelity: a shared map of decision tickets (grilling/research/prototype/task), resolved one at a time. |
| [`support/`](./skills/support) | model | The pipeline's modular helpers: `domain-modeling`, `research`, `prototype`, `resolving-merge-conflicts`, `wizard`. |
| [`ship`](./skills/ship) | `/ship` | Rebase onto trunk, full suite, push, PR. |
| [`reconcile-branch`](./skills/reconcile-branch) | model | Integrate a moved base and audit that the surviving diff is exactly the intended change. |
| [`cleanup`](./skills/cleanup) | `/cleanup` | Post-merge teardown of a ticket's worktree, branches, scratch DB, Docker leftovers, and a trunk refresh. |

See [`skills/README.md`](./skills/README.md) for the design rationale and what was deliberately dropped from the upstream set.

## The flow

Run `/setup-skills` once per repo. Then plan: `/grill` an idea → `/spec` → `/tickets` (tracer-bullet vertical slices with blocking edges — each ticket independently demoable, so each can land on the trunk by itself). Too big to grill in one sitting? `/wayfinder` first. Ticket arrived mid-flight? Capture it raw, `/triage` later. `/ask` routes when you don't remember which skill you want.

Then **per ticket, trunk-based**: worktree + branch off the trunk, provisioned by `scripts/provision.sh` (env, ports, deps, per-worktree DB — Docker-aware) → `/implement <ticket>` in it (drives `/tdd`, commits to the current branch) → `/ship` (rebase onto trunk, full suite, push, PR carrying `Closes #<ticket>`) → **you merge** → `/cleanup` (verify issue closed, tear down worktree/branch/DB/Docker leftovers, refresh trunk). Frontier tickets can run in parallel, one worktree + terminal pane each. When the trunk moves far enough that a branch's diff needs auditing rather than a plain rebase, `/reconcile-branch` instead of `/ship`'s rebase step.

## Installation

Skills install into either `~/.claude/skills/` (global, every project) or `.claude/skills/` (current project only), symlinked — so edits in this repo are live with no re-install.

```bash
./install.sh skills/cleanup    # one skill, current project
./install.sh skills/tdd --global   # one skill, globally
./install.sh --all --global        # everything, globally
./install.sh --all                 # everything, current project
```

Fresh machine restore:

```bash
git clone <this-repo> && cd claude-skills && ./install.sh --all --global
```

> Skills install by their leaf name (e.g. `tdd`, not `skills/tdd`) — folders above it are organizational only.

## Conventions

- `install.sh` discovers any `SKILL.md` at any depth (excluding `Progress/`, the drafting area), so nesting is free; two skills must never share a leaf name.
