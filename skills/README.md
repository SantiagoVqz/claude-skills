# Skills

The upstream [`mattpocock/skills`](https://github.com/mattpocock/skills) set, kept verbatim and installed under my own names, plus my `cleanup` skill. Sections follow the [aihero.dev skills page](https://www.aihero.dev/skills).

The upstream set was imported verbatim on 2026-09-02, then edited where it earns it. `implement` creates the spec's worktree on the first ticket and runs `scripts/provision.sh`, so separate specs run in parallel, one worktree each. A prompt audit the same day removed dated patterns (word caps, capitalized prohibitions, pinned token counts) from eight skills.

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
- [`dispatch`](./main-flow/dispatch) — drive one spec ticket by ticket in its worktree, closing each ticket against its acceptance criteria as it commits, then ship it.
- [`ship`](./main-flow/ship) — rebase, test, push, and open the spec PR with the spec record as its body; close the spec issue. Own skill, not from upstream.
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
- [`unslop`](./productivity/unslop) — cut AI tells from existing text and add human voice. Own skill, not from upstream.

## 06 Reference

Vocabulary layers the flow skills run underneath.

- [`codebase-design`](./reference/codebase-design) — deep modules, small interfaces, clean seams.
- [`domain-modeling`](./reference/domain-modeling) — sharpen terms, update `CONTEXT.md` and ADRs inline.
- [`grilling`](./reference/grilling) — the interview engine.
- [`tdd`](./reference/tdd) — red → green → refactor.
- [`close-ticket`](./reference/close-ticket) — tick the acceptance criteria a commit meets and close the ticket, or report what is unmet. Own skill, not from upstream.

## Resync

Clone upstream, re-copy each section's folders, then re-apply the local deltas by diffing this repo's previous commit against the fresh copy: the renames (`setup-matt-pocock-skills` → `setup-skills`, `ask-matt` → `ask`, and every `/setup-matt-pocock-skills` and `/ask-matt` reference), the worktree step plus `provision.sh` in `implement`, and the prompt-audit edits. Local edits are no longer limited to `implement` and `cleanup`.
