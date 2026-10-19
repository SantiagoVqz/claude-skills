# 2026-10-19 · habit-tracker · review, ui-check, retro

Transcript: ~/.claude/projects/-Users-santivqz-Documents-Developer-Personal-learning-habit-tracker--claude-worktrees-spec-1-habit-tracker/5a0e088a-bd05-4cf5-ac64-f6b29eb94bb2.jsonl

This run covers lines 2486 to 3046. `/review 1` did a full review of spec #1 at `112fb11`. The checks passed, each of the 8 stories had a ticket and a test, and the ui-check walk passed 8 of 8 in DevTools. The user put the 3 drift findings out of scope, approved the card, and the agent posted it on #1.

## Findings

### F1 · review · step 7 and step 9 · "Close the tab" ignores the DevTools rule

Status: applied
Seen in: 2026-10-16-habit-tracker-build-resolve-conflicts-ui-check-worktree#F6 (applied in ui-check). This is the second run.
What happened: Review step 9 says to close the tab. The agent called `close_page`, and DevTools refused because it was the last page. The agent then navigated it to `about:blank`, as ui-check says.
Evidence: line 3011: "The last open page cannot be closed."
Fix: sharpen wording: In review steps 7 and 9, write "close the tab as `ui-check` says". Keep the `about:blank` rule only in ui-check.

### F2 · review · step 4 · Open judgment calls from the tickets do not reach the review

Status: applied
Seen in: first time
What happened: Verify on #3 reported that `today` is read once on mount, so a tab open past midnight checks off the old day. This breaks the spec rule "A new day starts at local midnight". No review step collects it. The agent put it on the card as a free note, and it got no Ticket or Out of scope choice.
Evidence: line 2967: "The stale-today judgment call from #3 is not on this card."
Fix: add step: In build step 9, the close comment lists each judgment call that is still open. In review step 4, read the close comment of each ticket, and make each open judgment call a gap for step 7.

### F3 · ui-check · step 2 · A DevTools click needs a snapshot

Status: applied
Seen in: first time
What happened: The skill says to end each DevTools step with one `evaluate_script` read, not a full snapshot. A DevTools click needs a uid, and only a snapshot gives one. Stories 3, 4 and 6 each took a snapshot before the click.
Evidence: lines 2806, 2874 and 2909: `take_snapshot` calls before the clicks.
Fix: sharpen wording: A DevTools step can start with one snapshot to get the uids, the same as the `find` rule for Chrome. It ends with one `evaluate_script` read.

### F4 · review · step 8 · Content outside the card template

Status: applied
Seen in: first time
What happened: The posted comment has a "Checks:" line that the template does not have. The chat card also had a free note about the stale-today call. `/ship` reads only the first line, so nothing broke.
Evidence: line 2967: the card with the extra note.
Fix: sharpen wording: Add a "Checks" line to the card template for the step 3 results. Any other note is a gap for step 7.

## Worked

- review step 5: the drift subagent ran in the background during coverage and the walk. Its findings were ready before step 7.
- review step 7: the agent asked one question for each gap, with all three in one call.
- ui-check step 1: the flow from review had one step for each story with no cap, and each story got a ✓ line.
- review step 9: the first line of the comment has the full commit hash, so `/ship` can find it.
