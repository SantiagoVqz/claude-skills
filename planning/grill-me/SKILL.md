---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.

If a question can be answered by exploring the codebase, explore the codebase instead.

## How to ask

Use the **AskUserQuestion** tool for every question so I can pick from concrete options instead of typing free-form replies. Rules:

- One forking decision at a time. Prefer a single question per turn so we resolve dependencies in order. Bundle 2–4 questions in one call only when they're genuinely independent.
- Each question gets 2–4 mutually-exclusive options. Don't add an "Other" option — the tool injects one automatically.
- Frame each option as a real, defensible position with its own trade-off. No straw-man choices. If you have a recommendation, put it first and tag the label with "(Recommended)".
- Use the `description` field to spell out the implication of choosing that option (what it commits us to, what it forecloses).
- Use `header` as a tight chip label (≤12 chars). Use `multiSelect: true` only when choices truly aren't mutually exclusive.
- Use the `preview` field for ASCII mockups, code snippets, or config variations the user needs to compare visually. Skip previews for plain preference questions.

## When NOT to use AskUserQuestion

- The answer is unbounded free text (a hex value, a URL, a name, a paragraph of context). Ask in plain prose instead.
- The answer lives in the codebase. Go read it.
- You're summarizing or confirming, not deciding. Use prose.

## Cadence

Before each question, write 1–3 sentences of framing: what you found, why this fork matters, what each branch implies downstream. Then fire the AskUserQuestion call. After the answer, drill into the next dependent decision — don't restart from the top.

## After consolidation

When the grilling wraps and you summarize locked decisions + defaults, end the message with one line nudging the next step:

> Next: run `/find-critical-gaps` to pressure-test the locked plan against the codebase for data-integrity, security, failure-mode, and architectural risks.

Skip the nudge if the user has already invoked or declined `find-critical-gaps` in this conversation.
