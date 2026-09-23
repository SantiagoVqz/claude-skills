# Skills

The upstream [`mattpocock/skills`](https://github.com/mattpocock/skills) set, kept verbatim and installed under my own names, plus my own skills, each marked below. Sections follow the [aihero.dev skills page](https://www.aihero.dev/skills).

Upstream was last synced on 2026-09-20 from commit `c55ee46` (v1.2.3). Every upstream skill is byte-for-byte upstream, apart from two renames applied to file contents, `setup-matt-pocock-skills` → `setup-skills` and `ask-matt` → `ask`, and these additions:

- `to-spec`: Implementation Decisions ends with a required `Schema changes:` line. The `worktree` skill reads it.
- `setup-skills`: the Domain docs line in the `## Agent skills` block says that a change to docs only is committed straight to the trunk. The label template has a `later` row, and missing labels are created on GitHub.
- `triage`: a sixth state role, `later`, for an issue that is decided but waits for a named condition with no issue. Discovery skips it.

`retro` and `pr` are copied from upstream's `in-progress` folder. My own skills are marked below. They read only what the upstream files define: the tracker doc, the triage labels, and the ticket templates from `/to-tickets`.

## 01 Getting started

Set up once, then find your way around.

- [`setup-skills`](./getting-started/setup-skills) — configure one repo: issue tracker, triage labels, domain doc layout. Run once per repo.
- [`setup-worktrees`](./getting-started/setup-worktrees) — install `scripts/provision.sh` and the session hook, so every linked worktree gets env files, dependencies, ports, its own test database, and the dev database shared or forked. Run once per repo. Own skill, not from upstream.
- [`upgrade-skills`](./getting-started/upgrade-skills) — bring a repo set up under an earlier version of this set to the current one: Agent skills block, linked skills, worktree harness. Own skill, not from upstream.
- [`ask`](./getting-started/ask) — which skill or flow fits the situation you are in.

## 02 The main flow

The idea → ship spine, in order.

- [`grill-with-docs`](./main-flow/grill-with-docs) — get interviewed about a plan and record the decisions.
- [`to-spec`](./main-flow/to-spec) — turn an agreed conversation into a written spec.
- [`to-tickets`](./main-flow/to-tickets) — split a spec into small tickets an agent can build.
- [`worktree`](./main-flow/worktree) — find or create the linked worktree for code work, provision it, and share or fork the dev database from the spec's `Schema changes:` line. Model-invoked so `/implement` and `/dispatch` reach it. Own skill, not from upstream.
- [`implement`](./main-flow/implement) — build a ticket into code, test-first.
- [`code-review`](./main-flow/code-review) — review a diff against your standards and against the spec.
- [`dispatch`](./main-flow/dispatch) — drive one spec ticket by ticket on its branch, in its own worktree: `/implement` per ticket in a subagent, `close-ticket` after each commit, `/ship` at the end. State is the triage labels. Own skill, not from upstream.
- [`pr`](./main-flow/pr) — write a PR body: summary, before and after evidence, merge danger. Promoted from upstream `in-progress`.
- [`ship`](./main-flow/ship) — rebase, test, push, and open the PR with a `/pr` body plus the spec's ticket table. Own skill, not from upstream.
- [`cleanup`](./main-flow/cleanup) — after the merge of a spec: confirm it landed, verify the tickets closed, remove the worktree and its databases, delete the branches, refresh the trunk. Own skill, not from upstream.

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
- [`ticket-clerk`](./upkeep/ticket-clerk) — file one thing you hit mid-task as a ticket, labelled for triage. Own skill, not from upstream.
- [`wizard`](./upkeep/wizard) — an interactive bash wizard for steps only a human can do.
- [`retro`](./upkeep/retro) — retrospective on a coding session: propose changes to the agent's environment, checks over prose. Promoted from upstream `in-progress`.
- [`ui-review`](./upkeep/ui-review) — browser-driven review loop: start or reuse the dev servers, open Chrome, then inspect, diagnose, fix, and verify each piece of feedback. Own skill, not from upstream.

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
- [`close-ticket`](./reference/close-ticket) — tick the acceptance criteria a commit meets and close the ticket, or report what is unmet. Model-invoked so dispatch subagents can reach it. Own skill, not from upstream.

## Resync

Clone upstream and re-copy each upstream skill's folder with the two renames applied to file contents. Re-apply the additions in `to-spec`, `setup-skills` and `triage`; a re-copy removes them. Then reread `worktree`, `dispatch`, `ship`, `close-ticket`, `cleanup`, `setup-worktrees` and `upgrade-skills` against `implement`, `to-spec`, `to-tickets`, the tracker docs and `triage-labels.md`: they depend on those and on nothing else.
