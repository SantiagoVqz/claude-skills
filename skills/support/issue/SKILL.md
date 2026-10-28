---
name: issue
description: "File issues in the tracker: an idea, a bug, a task, a follow-up, or the specs and tickets that other skills of this set hand it. Use when the user runs /issue, asks to file, track or capture work for later, says \"file a follow-up\", or starts work that has no issue yet."
argument-hint: "[idea | bug | task] [what it is]"
---

# Issue

`/issue` is the clerk of the tracker. It turns what the user says, and what the conversation already found, into issues with the right template, labels and blocking edges. It gives back each number. It changes no code and no branch. Other skills call it to publish the issues that they wrote, so the create, label and link rules live here.

An issue from this skill is a **handoff**: the next skill, such as `/diagnose <n>`, starts from it with no new input from the user. So the body carries every finding that the conversation has, and the questions that are still open.

## Kinds

| Kind | Label | Body | Next step |
|---|---|---|---|
| Idea | `idea` | The idea template below. | `/spec <n>`, or `/prd <n>` with no setup |
| Bug | `bug` | The bug template below. | `/diagnose <n>` |
| Task | one `approach:` label | The `Lone ticket` section of [TICKETS.md](../../1-define/prd/TICKETS.md). | `/build <n>` |
| Spec | `spec` | The caller writes it. | the caller's |
| Ticket | one `approach:` label, and the parent spec | The caller writes it. | the caller's |

A task is a lone ticket: a one-off change with a known result, and no parent spec. A defect whose cause is unknown is a bug, and gets no `approach:` label: `/diagnose` finds the cause. Pick the approach label of a task from the table in `PLAN.md`, in the folder of the `build` skill: `approach:tdd` when the behavior changes, `approach:refactor` when it stays the same.

Idea template:

```markdown
## Problem

Who has the problem, and what it costs them now.

## Idea

The change that the user has in mind, in the user's words.

## Known facts

- Each fact about the current behavior, with the file or doc section that backs it.

## Open questions

- Each question that the spec must settle, with the current rule when one exists.

## Where to look

- The modules, docs sections and old issues that bear on the idea.
```

Bug template:

```markdown
## Symptom

What goes wrong, as the user sees it, with each error, status and count. Redact secrets, tokens and personal data.

## Steps to see it

1. Each step, from a known start.

## Known facts

- Each fact that the conversation proved, with the file or doc section that backs it. A fact also says what is not the cause.

## Hypotheses to rank

1. Each likely cause, with the place to check it.

## Open question for the fix

Each decision that the fix must make, with the current rule and the reason for it.

## Where to look

- The modules and functions, the tests and recorded fixtures that a loop can use, the docs sections, and old issues.
```

Leave out a section that has no content. The title uses the repo's words. A bug title says what goes wrong, such as "Invoice total ignores the discount".

Keep facts and hypotheses apart. A fact is something that the conversation saw in the code, a log or the screenshot. A likely cause is a hypothesis until `/diagnose` makes it go red.

A screenshot does not go into the issue through `gh`. Write what it shows as text: a table for a table, and each error, status and count exactly as it reads. The report tells the user to drag the image into the issue.

## Called by a skill

A caller, such as `/prd`, hands you a list of issues. Each issue has a ref such as `T1`, a kind, a title, a body, its labels, and, when they apply, a parent and its blockers. A blocker is a ref from the list or an issue number. The caller already has the user's approval, so do only step 1 and step 5 below.

Give back each ref with its number and URL, and each label that you could not add. With no tracker, give back the text of each issue, by its ref.

## 1. Load the setup

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md`. When the block is missing, read `NO-SETUP.md` in the folder of the `setup-skills` skill, and go on with its Tracker line. Run `gh label list` on GitHub.

Add a label only when it exists. When a label of the kind is missing, create the issue without it, and name the label in the report. `/setup-skills` creates it.

Completion: you know how to create, label and link an issue in this repo, and which labels exist, or you know that the repo has no tracker.

## 2. Gather

Read the conversation first. It often holds the work already done: an `/ask` route, a diagnosis, a decision in an interview, a screenshot. Each issue takes the findings that bear on it.

Find the issues to file. One request can hold several, such as a bug and an idea that waits for it. For each one, find its kind, and the issues that must finish before it: each one is a blocker. Ask for a kind only when two kinds fit.

Read the code that each issue touches, enough to use the repo's words, to check each finding, and to pick the approach of a task. This is a capture, not a spec: stop when you can fill the template.

Ask for each template section that the conversation and the code do not fill, one question at a time with the question tool. Put your best guess first. Ask three questions at most for each issue.

A **follow-up** is an issue that the user asks for during other work, such as an interview. Take its facts from the conversation, and ask nothing unless two kinds fit. When the work has an issue, add `Found during #<n>.` as the last line of the body. After step 5, go back to the work at the point where it stopped.

Completion: you have each issue with its kind and its blockers, and each section of its template that the facts can fill.

## 3. Look for duplicates

For each issue, search the open issues for the key words of its title: `gh issue list --state open --search "<words>"`. Read each result that could be the same issue.

When an open issue is the same one, show it, and ask: "Use #<n>", "Comment on #<n>" or "File a new one". A comment adds what the conversation knows that the issue does not say, as `tracker.md` says. A used issue keeps its number as a blocker for the others.

Completion: no open issue is the same one, or the user picked what to do with it.

## 4. Approve

Show each draft in your message: the title, the labels, the blockers, and the full body. For several issues, add the order in one line, such as "the bug first, then the idea". Then ask once with the question tool: "File them" or "Change". When the user picks Change, apply the edits, show the drafts again and ask again.

Completion: the user picked "File them".

## 5. File

Create the issues in order, blockers first, so that each blocker has a number before the issue that it blocks. For each one, write the body to a file with the Write tool, create the issue with its labels, and `--parent <n>` when it has a parent, as `tracker.md` says. Delete the file. Then add each blocking edge.

With no tracker, print the title and body of each issue in the chat, one block for each, in order, that the user can paste.

Completion: each issue exists with its labels, parent and blocking edges, and you have each number, or the user has the text of each issue.

## Report

For each issue: URL · kind · labels · blocked by. Then each missing label, each screenshot to drag into an issue, and the next step: the command from the Kinds table for each issue that has no open blocker, with its number.
