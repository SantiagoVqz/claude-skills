---
name: interview
description: "Interview the user in short rounds of up to four questions on a design tree until every decision is settled, and keep a decisions log. Use when the user says \"grill me\" or wants to stress-test a plan or decision, and when /spec interviews for a spec."
---

# Interview

Run the interview until you both share one understanding of the plan. Map the plan as a **design tree**: each decision branches into the decisions that depend on it. The **frontier** is every open decision whose prerequisites are settled.

The user's attention is the scarce resource, and each wait for an answer costs the most time: plan questions cost about 40 hours of waiting in one month. Ask in **rounds**: one question tool call with four questions or fewer. Spend each question on a decision that unblocks the tree.

## 1. Prepare

- Read what already bears on the plan: the code in the area, the glossary, the ADRs, and the issue or text the user gave.
- Open the **decisions log**. In a git repo, write it to `.scratch/interview/<slug>.md`, and add `.scratch/` to `.git/info/exclude` when git does not already ignore it. Outside a repo, keep the log in the conversation. The log has four sections: Decisions, Terms, ADR candidates, Out of scope.

Completion: you can name the root of the design tree, and the log exists.

## 2. Ask

Take the frontier decisions that the most open decisions depend on, four or fewer. Before the round, write one line in your message:

```markdown
Recorded: <each decision settled by the last round, a few words each> · about <k> questions left
```

Then ask the round in one question tool call. For each question:

- Write the question in one sentence that stands on its own text. Add one line of context only when the user cannot answer without it.
- Give two to four options, with your recommendation first, and the cost of each other option in its description.
- Use text in place of the tool only for an open question, and ask it alone.

A question earns its place only when the answer changes the plan. `<k>` is your estimate: answers can open new branches, so the count can go up.

- When the caller names required decisions, each one gets its own question. Ask about decisions, such as what a user can do, and never about the wording of content, such as user story text. The caller writes the content from the log.
- When the user asks to file a follow-up, call the Skill tool with `issue` for it. Then ask the open questions again.
- **Facts are your job. Decisions are the user's.** When a question needs a fact from the code, the tracker or the docs, look it up, and put it in the log. For a wide search, send a subagent.

Completion: one round is sent, and you wait for the answers.

## 3. Record

After each round:

- Write each settled decision to the log, in one sentence, with the reason when the user gave one.
- A word whose meaning got settled goes under Terms. A decision that is hard to reverse, surprising to a newcomer, and the result of a real choice goes under ADR candidates. Anything the user excluded goes under Out of scope.
- Recompute the frontier. An answer can close a branch, open a branch, or reverse an earlier decision. When it reverses one, update the log entry and say so in the next Recorded line.

Listen for **should-want** answers: best-practice words with no specifics, such as "scalable", "clean" or "the standard way". Ask what the user would choose if nobody would see the reason. Then record that answer.

Completion: the log matches every answer so far. Go back to step 2 while the frontier has a decision.

## 4. Close

When the frontier is empty and a skill called you, return the log and stop. The caller shows one approval of its own, so a second confirmation here only repeats it.

When the user called you, show the log, one line per decision, and ask the user to confirm it. "Sounds good" or "whatever you think" is not a confirmation. Ask what they would change.

Completion: the frontier is empty, and the log went to the caller, or the user confirmed it with an explicit yes. Then stop. The caller, or the user, decides what happens next.
