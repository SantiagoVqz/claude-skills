# Skills

The upstream [`mattpocock/skills`](https://github.com/mattpocock/skills) set, kept verbatim and installed under my own names, plus my `cleanup` skill. Sections follow the [aihero.dev skills page](https://www.aihero.dev/skills).

The only edited skill is `implement`: on the first ticket of a spec it creates the spec's worktree and runs `scripts/provision.sh`, so separate specs run in parallel, one worktree each.

## 01 Getting started

Set up once, then find your way around.

- [`setup-skills`](./getting-started/setup-skills) — configure one repo: issue tracker, triage labels, domain doc layout. Run once per repo.
- [`ask`](./getting-started/ask) — which skill or flow fits the situation you are in.

## 02 The main flow

The idea → ship spine, in order.

- [`grill-with-docs`](./main-flow/grill-with-docs) — get interviewed about a plan and record the decisions.
- [`to-spec`](./main-flow/to-spec) — turn an agreed conversation into a written spec.
- [`to-tickets`](./main-flow/to-tickets) — split a spec into small tickets an agent can build.
- [`implement`](./main-flow/implement) — build a ticket into code, test-first. First ticket of a spec creates and provisions the spec worktree.
- [`code-review`](./main-flow/code-review) — review a diff against your standards and against the spec.
- [`cleanup`](./main-flow/cleanup) — after the merge of a spec: tear down its worktree, branches, scratch DB, Docker leftovers, and refresh the trunk.

## 03 Shaping

Explore an open question and produce a decision that feeds the flow.

- [`wayfinder`](./shaping/wayfinder) — plan a huge chunk of work as a shared map of decision tickets.
- [`prototype`](./shaping/prototype) — throwaway code that answers one design question.
- [`research`](./shaping/research) — investigate against primary sources, as a background agent.

## 04 Upkeep

Keep the codebase and issue list healthy; generates work for the flow.

- [`improve-codebase-architecture`](./upkeep/improve-codebase-architecture) — scan for deepening opportunities and grill through one.
- [`diagnosing-bugs`](./upkeep/diagnosing-bugs) — diagnosis loop for hard bugs and performance regressions.
- [`resolving-merge-conflicts`](./upkeep/resolving-merge-conflicts) — work an in-progress merge or rebase conflict by intent.
- [`triage`](./upkeep/triage) — move issues through the triage state machine.
- [`wizard`](./upkeep/wizard) — an interactive bash wizard for steps only a human can do.

## 05 Productivity

Human-facing workflows you run, not about code.

- [`grill-me`](./productivity/grill-me) — relentless interview, no repo needed.
- [`handoff`](./productivity/handoff) — compact the conversation for another agent.
- [`to-questionnaire`](./productivity/to-questionnaire) — turn a decision into a questionnaire for the one person who can answer it.
- [`teach`](./productivity/teach) — learn a skill or concept over multiple sessions.
- [`wait-what`](./productivity/wait-what) — the last message did not land; re-pitch it in plain English.
- [`writing-for-agents`](./productivity/writing-for-agents) — writing skills, AGENTS.md, CLAUDE.md.

## 06 Reference

Vocabulary layers the flow skills run underneath.

- [`codebase-design`](./reference/codebase-design) — deep modules, small interfaces, clean seams.
- [`domain-modeling`](./reference/domain-modeling) — sharpen terms, update `CONTEXT.md` and ADRs inline.
- [`grilling`](./reference/grilling) — the interview engine.
- [`tdd`](./reference/tdd) — red → green → refactor.

## Resync

Clone upstream, re-copy each section's folders, then re-apply the two local deltas: the renames (`setup-matt-pocock-skills` → `setup-skills`, `ask-matt` → `ask`, and every `/setup-matt-pocock-skills` and `/ask-matt` reference) and the worktree step plus `provision.sh` in `implement`.
