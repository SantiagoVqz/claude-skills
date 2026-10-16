# 2026-10-16 · habit-tracker · build, worktree, tdd, verify, ui-check

Transcript: ~/.claude/projects/-Users-santivqz-Documents-Developer-Personal-learning-habit-tracker/10cdce8f-f05f-4709-8e88-5613441033f9.jsonl

`/build 4 --ui` took ticket #4 from open to closed. The agent did 5 TDD cycles and 1 refactor. Verify found no hard finding. The ui-check passed 5 of 5 steps. The ticket landed as `162ebf1` on `spec/1-habit-tracker`.

## Findings

### F1 · build · step 7 · Change with no notes leads to a dead end

Status: applied in part. On Change with no notes, the agent asks in the chat. The "Check myself first" option is rejected: the dev server now stays open while the question waits.
Seen in: first time
What happened: The user picked Change with no notes. The agent asked a multi-select of verify's judgment calls, and the user rejected it. The user then ran `pnpm dev` and said "Looks good". The checkpoint made the user pick before they did the "Check yourself" steps.
Evidence: line 1113: "Ticket #4 passes its tests, verify and the browser check. Land it?"; line 1128: "The user doesn't want to proceed with this tool use"; line 1134: "pnpm dev"
Fix: add step: Give the checkpoint question a third option, "Check myself first". On that pick, wait for the user's answer in free text. On Change with no notes, ask in the chat what to change. Do not offer options that the agent picked.

### F2 · build · step 7 · The ticket landed on a free-text "Looks good"

Status: applied
Seen in: first time
What happened: The completion criterion says "the user picked Approve". The agent took the free-text "Looks good" as Approve and pushed, after an earlier Change pick. The read was fair, but the skill does not allow it.
Evidence: line 1138: "Looks good."; line 1158: "Taking \"Looks good\" as Approve, with no changes."
Fix: sharpen wording: A free-text answer that clearly approves counts as Approve. The first line of the reply says that the agent took it as Approve, before the push.

### F3 · ui-check · step 2 · The dev server port was in use

Status: applied
Seen in: first time
What happened: The agent started the server with `--port 5174 --strictPort`. The server of another worktree had the port, so the start failed. The agent tried again on port 5199.
Evidence: line 914: "Port 5174 is taken, probably by another worktree's server."
Fix: sharpen wording: Start the dev server with no fixed port. Read the URL from the ready line of the server. Then parallel ticket worktrees do not collide.

### F4 · ui-check · step 3 · Two Approve questions for one checkpoint

Status: applied
Seen in: first time
What happened: When `/build` runs ui-check, ui-check asks "Approve" or "Change", and build step 7 asks again. The agent merged the two questions into one by hand.
Evidence: line 1113: one question after both the ui-check lists and the build card
Fix: sharpen wording: When a caller runs ui-check, ui-check returns its two lists and asks no question. The caller asks.

### F5 · ui-check · step 2 · One batch per step does not fit `find`

Status: applied
Seen in: first time
What happened: A click on Yes or No needs a ref from `find` first. So steps 2 to 5 each took two calls, not one batch.
Evidence: line 1023: "Step 4: delete Read with Yes, then reload." That step took a batch with `find`, then a second batch for the click.
Fix: sharpen wording: A step can start with one `find` call, then do its actions in one batch.

## Worked

- tdd step 2: the first-pass rule from 2026-10-16-habit-tracker-build-worktree-tdd-verify#F2 worked twice. Each commit message names the break and the undo.
- build step 4: the tdd report came before verify. The fix for 2026-10-16-habit-tracker-build-worktree-tdd-verify#F5 holds.
- build step 9: the removal order worked again: enter, drop, exit, remove, then `git branch -D`, with no config error.
- worktree step 4: the EnterWorktree hook ran `provision.sh`, so the agent did not run it by hand.
- ui-check step 2: the browser check confirmed the focus loss that verify predicted, so the judgment call had evidence.
