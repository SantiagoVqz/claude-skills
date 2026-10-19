---
name: sv-interview
description: "Interview the user one question at a time on a design tree until every decision is settled, and keep a decisions log. Use when the user says \"grill me\" or wants to stress-test a plan or decision, and when /sv-spec interviews for a spec."
---

# Interview

Run the interview until you both share one understanding of the plan. Map the plan as a **design tree**: each decision branches into the decisions that depend on it. The **frontier** is every open decision whose prerequisites are settled.

The user's attention is the scarce resource. Ask **one question per message**, and spend each question on the decision that unblocks the most of the tree.

## 1. Prepare

- Read what already bears on the plan: the code in the area, `GLOSSARY.md`, the ADRs, and the issue or text the user gave.
- Open the **decisions log**. In a git repo, write it to `.scratch/interview/<slug>.md`, and add `.scratch/` to `.git/info/exclude` when git does not already ignore it. Outside a repo, keep the log in the conversation. The log has four sections: Decisions, Terms, ADR candidates, Out of scope.

Completion: you can name the root of the design tree, and the log exists.

## 2. Ask

Pick the frontier decision that the most open decisions depend on. Format each message like this:

```markdown
Recorded:
- <each decision settled by the last answer>

## Q<n> · about <k> left on this branch

**<the question, in one sentence>**

<what depends on it, and the facts that bear on it>

My recommendation: <answer>, because <reason>. The other option is <alternative>, which costs <cost>.

Say yes to accept, or give your answer.
```

- Number questions across the whole conversation. A question you ask again keeps its number.
- `<k>` is your estimate of the questions left on the current branch. Answers can open new branches, so the count can go up.
- Write the question so that "yes" accepts your recommendation.
- When the options are few and discrete, use the question tool so the user picks one. Use text for open questions.
- When the caller names required decisions, each one gets its own question. For content such as user stories, show your draft in the question and ask the user to change it. Do not draft a required decision and settle it first in the close.
- **Facts are your job. Decisions are the user's.** When a question needs a fact from the code, the tracker or the docs, look it up. For a wide search, send a subagent. Ask the user only for what they decide.

Completion: one question is sent, and you wait for the answer.

## 3. Record

After each answer:

- Write each settled decision to the log, in one sentence, with the reason when the user gave one.
- A word whose meaning got settled goes under Terms. A decision that is hard to reverse, surprising to a newcomer, and the result of a real choice goes under ADR candidates. Anything the user excluded goes under Out of scope.
- Recompute the frontier. An answer can close a branch, open a branch, or reverse an earlier decision. When it reverses one, update the log entry and say so in the next Recorded list.

Listen for **should-want** answers: best-practice words with no specifics, such as "scalable", "clean" or "the standard way". Ask what the user would choose if nobody would see the reason. Then record that answer.

Completion: the log matches every answer so far. Go back to step 2 while the frontier has a decision.

## 4. Close

When the frontier is empty, show the full decisions log and ask the user to confirm it. The log has only decisions that the user settled in step 2, so the close adds nothing new. "Sounds good" or "whatever you think" is not a confirmation. Ask what they would change.

Completion: the user confirms the log with an explicit yes. Then stop. The caller, or the user, decides what happens next.
