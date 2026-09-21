---
name: ticket-clerk
description: Capture one thing worth doing later as a single ticket on the configured tracker. Use for a bug you just hit, a follow-up you owe, or a rough edge you noticed mid-task. Harvests the evidence from the conversation, asks only what a cold reader would need, labels it for triage, and hands the work back.
disable-model-invocation: true
---

# Ticket Clerk

Something surfaced that is worth doing later, and it is not the work in front of you. Write it down as one **ticket** on the tracker and return.

The issue tracker and triage label vocabulary should have been provided to you. If not, tell the user to run `/setup-skills`.

## Capture, don't solve

This skill files a ticket. It does not fix the thing, plan the fix, or break the work into slices. The session that reads this ticket later does that.

Sizing follows from that. One ticket, always. If the capture is big enough to need several, file the one ticket that names the whole thing and let a later `/to-tickets` or `/wayfinder` split it.

## The cold reader

Write for a **cold reader**: a session months from now with none of this conversation in its context, looking at this ticket alone. Everything it needs is on the ticket or reachable from it.

The cold reader is the completion criterion for the whole skill. A ticket passes when the cold reader can reproduce the problem, or knows exactly what it is being asked for, without asking you anything.

## Process

### 1. Harvest the conversation

The evidence is already in context. Take it from there rather than re-deriving it, and quote it exactly:

- The **trigger**: what was being done when this surfaced.
- The **symptom**: what happened, and what was expected instead.
- The **evidence**: the verbatim error text, the command that produced it, the failing test name, the commit sha the codebase sat at.
- The **location**: the domain concept and the symbol involved, with a file path as a hint that may go stale.

For a follow-up rather than a bug, harvest the same first two and the reason it was deferred: the shortcut taken, the case knowingly left unhandled, the decision made under time pressure.

### 2. Check the tracker for a twin

Search the tracker for an existing ticket on this, by domain concept rather than by the wording you just used. On a hit, add a comment with the new evidence and tell the user which ticket you fed. Stop there.

### 3. Ask only what the cold reader is missing

Read the draft as the cold reader and find what it cannot answer. Ask that, in one round, then write. Typical gaps:

- Reproduction steps that stop short of the failure.
- A symptom with no expected behaviour beside it.
- A follow-up with no trigger for acting on it: what makes it worth doing, or what breaks if it is not.

Skip the round when nothing is missing. Interrogation is `/grilling`'s job, and a captured ticket has not earned it yet.

### 4. Classify

Give the ticket one category role and one state role from the triage vocabulary.

Category: `bug` when something is broken, `enhancement` for everything else.

State: `needs-triage`. A captured ticket is unevaluated by construction, and `/triage` is the state machine that decides what happens to it next.

Two exceptions:

- The cold reader could start right now, because the change is small, the behaviour is settled, and the acceptance criteria are checkable. Then `ready-for-agent`, or `ready-for-human` when the work is human-only, such as a `/wizard` run or a dashboard change.
- The user overrides the state directly. Then trust them.

When you already know what the ticket needs before it can be built, record it as the **Next step** line: a named skill (`/grill-with-docs`, `/wayfinder`, `/research`, `/prototype`) and the one question it would answer. It is a hint for the triager, not a label and not a state.

### 5. Publish and return

Publish one ticket to the configured tracker, applying the two labels.

- **Local files** → write `.scratch/inbox/issues/<NN>-<slug>.md`, taking the next free number in that directory. Use the local template below.
- **A real issue tracker** → create one issue from the issue template below and apply the category and state labels.

Report to the user in two lines: the ticket's title with its link or path, and its two roles. Then resume whatever the capture interrupted.

<local-ticket-template>

# <NN>: <Ticket title>

**Status:** needs-triage
**Category:** bug
**Next step:** /grill-with-docs, to settle <the open question>. Or "None: ready to build as written."

**What happened:** the symptom, and the expected behaviour beside it.

**Reproduction:** the steps, ending on the failure.

**Evidence:** verbatim error text, the command, the failing test, the commit sha.

**Where:** the domain concept and symbol, with a file path as a stale-able hint.

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

## Comments

</local-ticket-template>

<issue-template>

## What happened

The symptom, and the expected behaviour beside it. For a follow-up: what was deferred and why it is worth doing.

## Reproduction

The steps, ending on the failure. Omit this section for a follow-up.

## Evidence

Verbatim error text, the command that produced it, the failing test name, the commit sha the codebase sat at.

## Where

The domain concept and symbol involved, with a file path as a hint that may go stale.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Next step

A named skill and the one question it would answer, or "None: ready to build as written."

</issue-template>

Acceptance criteria are what the cold reader checks the fix against. Write them even when the fix is unknown: they describe the behaviour you want, not the change that gets there.
