---
name: prd-to-issues
description: Break a PRD into independently-grabbable GitHub issues using tracer-bullet vertical slices. Use when user wants to convert a PRD to issues, create implementation tickets, or break down a PRD into work items.
---

# PRD to Issues

Break a PRD into independently-grabbable GitHub issues using vertical slices (tracer bullets).

## Process

### 1. Locate the PRD

The PRD lives in one of two places. Ask the user (or accept either as input):

- **A GitHub issue.** Ask for the issue number or URL. Fetch with `gh issue view <number>` (with comments) if not already in context.
- **A markdown doc in the repo.** Ask for the relative path (e.g. `docs/prds/feature-csv-import.md`). Read the file directly. Use this when the feature is small enough that no umbrella PRD issue was created.

Whichever the source, capture which form it is — it changes the issue-body template in step 5 (`## Parent PRD #<num>` for issue source; `## Parent doc <path>` for doc source).

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code.

### 3. Draft vertical slices

Break the PRD into **tracer bullet** issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
</vertical-slice-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories from the PRD this addresses

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user approves the breakdown.

Also confirm the **GitHub label** to apply to every created issue. Conventions vary by project — common patterns are `phase-N`, `feature/<slug>`, `epic/<slug>`. Suggest a sensible default based on the PRD title or scope; let the user override.

### 5. Ensure the GitHub label exists

Before filing any issues, make sure the target label exists. The label is what scope-keyed runners (e.g. ralph-loops) use to find work, so missing labels mean missing work.

```bash
# Check if the label exists. If not, create it.
gh label list --repo <owner/repo> --json name -q '.[].name' | grep -qx "<label>" \
  || gh label create "<label>" --repo <owner/repo> --color "<hex>" --description "<short>"
```

Pick a color that's distinct from existing labels in the repo (run `gh label list` to see them). This step is idempotent — running it twice is safe.

### 6. Create the GitHub issues

For each approved slice, create a GitHub issue using `gh issue create --label <label>`. Use the issue body template below, choosing the parent header that matches step 1's source form.

Create issues in dependency order (blockers first) so you can reference real issue numbers in the "Blocked by" field.

<issue-template>
## Parent PRD     <!-- use this header if step 1 source was an issue -->

#<prd-issue-number>

<!-- OR -->

## Parent doc    <!-- use this header if step 1 source was a markdown doc -->

<repo-relative-path-to-doc>

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation. Reference specific sections of the parent PRD rather than duplicating content.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by

- Blocked by #<issue-number> (if any)

Or "None - can start immediately" if no blockers.

## User stories addressed

Reference by number from the parent PRD:

- User story 3
- User story 7

</issue-template>

Do NOT close or modify the parent PRD issue.