# Full plan

`/build` runs this plan in the same session when a ticket has a hard stop, or when the user asks. It replaces step 3. The ticket stays in `/build`, and needs no spec.

## 1. Brief

Send one message that states the problem back:

- **The issue, plainly**: what is wrong or missing, for whom, and what it costs them. Use no symbol names.
- **The ask and the cause**: what the ticket asks, and what you think the cause is. When they differ, say how confident you are.
- **Ways to fix it**: the ticket's fix, the structural fix when one exists, and the cost of each, such as a migration or a locked-in contract. Name the settled practice when there is one. End with your recommendation and the reason in one line.
- **Out of scope**: what you leave as it is, and why.

Completion: the brief is in the chat.

## 2. Decisions

List each point where two reasonable answers lead to different plans. Facts are yours to find. A decision earns a question only when the answer changes the plan. Zero decisions is a valid result: say so, and name the defaults that you take.

The decisions go out with the approval, in one question tool call, as `interview` asks them: four questions at most, the approval included, with your recommendation first. Each question must stand on its own text.

Completion: you have each decision, with your recommendation or a default.

## 3. Plan

Write the plan in the format below, on the recommended options. Ask with the question tool: "Approve", "Change" or "Write a spec", with each decision of step 2 in the same call. Recommend "Write a spec" only when the work is a feature with stories to settle, over about 800 changed lines.

**One phase by default.** Split only at a real boundary: a contract that another part consumes, a migration that later code depends on, or a step whose failure must stay apart. Size alone is no boundary. A prefactor that keeps the behavior goes in its own first phase, with the `refactor` approach.

A **wide refactor** is one mechanical change, such as a column rename, that breaks call sites across the codebase. Plan it as phases: expand, with the new form next to the old one; one phase per batch of call sites; then contract, which removes the old form.

Write the criteria in the words of the ticket, with the edge cases of the work, such as an empty list or a value at its limit. Leave out file paths, code and test names, because they go stale before the work ends.

```markdown
### Plan of #<n>

Problem: <the brief, corrected by the user's answer>
Fix: <the chosen way, and the way you did not take, with the reason>
Decisions: <each decision and default, with the reason>
Hard stops: <the verdict line>

#### Phase 1: <title>
<approach> · boundary: <the boundary, or "one phase">

Builds: <one sentence, from the user's point of view>
Done when:
- <each criterion>
```

Completion: the user picked "Approve", or you stopped with `/spec <n>` as the next step. On "Approve", go to step 4 of `/build`.
