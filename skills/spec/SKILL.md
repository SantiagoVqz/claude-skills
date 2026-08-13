---
name: spec
description: Turn the current conversation into a spec on the issue tracker — pure synthesis, no interview.
disable-model-invocation: true
---

# Spec

Synthesize the current conversation and codebase understanding into a spec. Do NOT interview the user — the grilling already happened; this skill only writes down what was decided.

## Process

1. **Explore the repo** if you haven't already. Use the glossary vocabulary from `CONTEXT.md` throughout, and respect ADRs in the area you're touching.

2. **Sketch the seams** you'll test the feature at. Prefer existing seams; place any new one as high as possible — the fewer seams across the codebase the better, and the ideal number is one. Confirm the seams with the user before writing.

3. **Write the spec** from the template and publish it to the repo's issue tracker (GitHub via `gh` by default) labeled `ready-for-agent`. If the repo has no tracker, write it to `.scratch/<feature-slug>/spec.md`.

<spec-template>

## Problem Statement

The problem the user is facing, from the user's perspective.

## Solution

The solution, from the user's perspective.

## User Stories

A LONG numbered list — extensive, covering every aspect of the feature:

1. As an <actor>, I want <feature>, so that <benefit>

## Implementation Decisions

The decisions that were made: modules built/modified and their interfaces, architectural decisions, schema changes, API contracts, technical clarifications. No file paths or code snippets — they go stale fast. Exception: a prototype-derived snippet that encodes a decision more precisely than prose (state machine, schema, type shape) may be inlined, trimmed to the decision-rich parts.

## Testing Decisions

The seams under test, what makes a good test here (external behavior, never implementation details), and prior art — similar tests already in the codebase.

## Out of Scope

What this spec deliberately excludes.

</spec-template>
