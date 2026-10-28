---
name: brief
description: "Explain a ticket or any technical text in plain technical terms: what it asks, what to do, when it is done, and what it leaves unclear. Use when the user runs /brief, or asks what a ticket or a description means."
argument-hint: "[issue number | URL | tracker key | pasted text]"
---

# Brief

A brief tells the reader what a ticket asks, in plain technical words, so they can act on it. Print the brief in chat. The source stays as it is.

The reader is an engineer who knows the field but not this ticket's context. Keep the technical terms that carry meaning, such as "migration" or "race condition". Explain the project's own names.

## 1. Get the text

- Pasted text: use it.
- An issue number or a GitHub URL: run `gh issue view <n> --comments`.
- Another tracker's key or URL: read it with that tracker's tool when one is connected. Otherwise ask the user to paste it.

Read the comments too, because they often change the scope.

Completion: you hold the full text and its comments.

## 2. Decode the terms

List each name the reader must decode: code names, system names, acronyms and team jargon. Find what each one does. Look in the text first, then in the code of the working directory when the term names something there. A term that stays unknown goes under Gaps.

Completion: each term has a plain definition or a line under Gaps.

## 3. Write the brief

Use this shape:

```
**Problem.** One sentence of 15 words or fewer.

**What to do.**
- Now: the current behavior.
- Wanted: the behavior after the change.
- The concrete changes, one per bullet, in order when order matters.

**Done when.**
- Each acceptance criterion as a check the reader can run.

**Terms.**
- `Name`: what it does, in one line.

**Gaps.**
- What the text leaves unclear, contradicts, or does not say.
```

- Drop Terms when no term needed decoding.
- Write "None" under Gaps when the text is complete.
- When the text gives no acceptance criteria, infer them from the ask and mark each one "(inferred)".
- When the text describes a system rather than asks for work, keep Problem, Terms and Gaps, and replace the middle sections with **How it works**.

Write in whole sentences, one idea per sentence, in active voice, with plain words. Each statement comes from the source or the code. Mark any other statement "(inferred)". The brief gets shorter by cutting repetition, history and filler. Each requirement stays.

Completion: each requirement of the source appears under What to do or Done when, and the brief is shorter than the source.
