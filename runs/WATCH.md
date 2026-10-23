# Watch

Each item is a recent change to the flow that no session has tested yet. `/sv-retro` checks each item against the sessions it reads. Remove an item when a retro shows that the change works, or when a finding replaces it.

## One ticket per spec, since 2026-10-23

`TICKETS.md` cuts a spec as one ticket, and splits only at a named boundary. `/sv-review` runs light on a one-ticket spec. The 2026-10-23 retro saw no `/sv-plan` run after the change.

- Count the tickets that `/sv-plan` cut for each spec, and the boundary that each split names.
- Look for a gap between `/sv-spec` and `/sv-plan` now that one plan makes one ticket: a step that does the same work twice, a question asked twice, or a `/sv-plan` run that adds nothing to the spec.
- Look for a `/sv-build` that ran out of context in `sv-tdd`, used all three verify runs, or showed a card too long to read.
- Check that each light review skipped steps 3, 5 and 6, and that `/sv-ship` took its comment.

## Blocking and cleanup gaps in `/sv-review`, since 2026-10-23

`/sv-review` sorts each gap as blocking or cleanup, holds the spec only for blocking gaps, and reads only the diff after the last `### Gaps of` comment. The 2026-10-23 retro saw only reviews that ran the old rules.

- Count the gaps for each review, by kind, and the sub-issues it created. A second sub-issue for the same spec is a loop.
- Look for a cleanup sorted as blocking, or a defect that a user can see sorted as cleanup.
- Check that a rerun read the diff from the `### Gaps of` commit, and not from the trunk.

## Retro fixes of 2026-10-23

The run `2026-10-23-vvfapp-knot-level8-build-review-prototype` applied 24 fixes. Check the largest ones first.

- Two `sv-ui-check` runs at the same time, each on its own isolated Chrome, with no "already running" error and no `about:blank` page.
- An `sv-prototype` run that builds a canvas of frames, adds each iteration as a new frame, and renders the page before it sends the link.
- An `sv-verify` hard finding for a defect that a user can see, so that `/sv-review` finds no blocking drift after it.
