# 2026-10-16 · habit-tracker · build, worktree, tdd, verify, ui-check, retro

Transcript: ~/.claude/projects/-Users-santivqz-Documents-Developer-Personal-learning-habit-tracker--claude-worktrees-ticket-3-check-off-streak/5a0e088a-bd05-4cf5-ac64-f6b29eb94bb2.jsonl

`/build 3` took ticket #3 to the checkpoint. The agent did 6 TDD cycles and 1 refactor. Verify found no hard finding. The ui-check passed 5 of 5 steps, and the user approved. Ticket #4 landed on `spec/1-habit-tracker` during the checkpoint. The rebase onto it conflicted, so the agent stopped. #3 did not land.

## Findings

### F1 · ui-check · step 3 · Two Approve questions for one checkpoint

Status: applied
Seen in: 2026-10-16-habit-tracker-build-worktree-tdd-verify-ui-check#F4. This is the second run.
What happened: The user picked "Run ui-check" at the build checkpoint. ui-check step 3 asks "Approve" or "Change", and build step 7 asks again. The agent merged the two questions into one by hand.
Evidence: line 1141: "ui-check passed all five steps. Land ticket #3?"
Fix: sharpen wording: When a caller runs ui-check, ui-check returns its two lists and asks no question. The caller asks.

### F2 · ui-check · step 2 · One batch per step does not fit `find`

Status: applied
Seen in: 2026-10-16-habit-tracker-build-worktree-tdd-verify-ui-check#F5. This is the second run.
What happened: A click on the checkbox needs a ref from `find` first. Steps 2 and 3 each took a `find` call, then a second batch.
Evidence: line 1041: "Step 1 passes. Step 2, tick the box:"; line 1066: the reload batch ends with `find`, and the untick is a second batch.
Fix: sharpen wording: A step can start with one `find` call, then do its actions in one batch.

### F3 · plan · step 3 · Parallel tickets rebuild the same component

Status: rejected: blocking parallel tickets on a shared file costs the parallel work. The new `resolve-conflicts` skill resolves such conflicts.
Seen in: first time
What happened: #3 and #4 were both blocked only by #2, so they ran in parallel. Both rewrote the habit row in `+page.svelte` and the `habitNames()` test helper. The rebase of #3 onto #4 conflicted in both files, after the user approved #3. Verify had flagged the helper as coupled.
Evidence: line 1227: "CONFLICT (content): Merge conflict in src/routes/+page.svelte"
Fix: add step: In step 3, list the files and test helpers that each ticket changes. When two tickets change the same component or helper, block one by the other. When they must run in parallel, name the shared file in both tickets.

### F4 · build · step 6 · Every rebase conflict stops the build

Status: applied
Seen in: first time
What happened: Each side of the conflict added separate behavior: delete controls and a check-off control. The merge had one correct result. The stop sent the work back to the user after the user had approved.
Evidence: line 1240: "The skill says to stop on a rebase conflict."
Fix: sharpen wording: When each side of a conflict only adds code, resolve it, run the full checks, run `verify` in a new subagent, and show the checkpoint card again. Stop only when both sides change the same behavior.

### F5 · tdd · step 2 · A criterion that constrains the tests gets no cycle

Status: applied
Seen in: first time
What happened: Criterion 7 says how each test sets the clock and seeds storage. It cannot go red. The skill asks for a passing test and a `Green:` commit for each criterion. The agent covered it with a note in the report.
Evidence: line 832: the agent states that the check-off tests meet criterion 7, then starts the refactor.
Fix: sharpen wording: A criterion that constrains the tests, not the behavior, gets no cycle. The report names the tests that meet it.

### F6 · retro · step 2 · The repo check uses git outside the worktree

Status: applied
Seen in: first time
What happened: The session was in a ticket worktree. The isolation guard refused `git -C <skills folder> rev-parse`. The agent used `ls` to find `.git` at the root of the skills folder.
Evidence: line 1292: "this command names git in a form too complex to verify that it stays inside the worktree"
Fix: sharpen wording: Resolve the path with `realpath`. Find the repo root with `ls` for a `.git` folder. Do not run git on a path outside the current worktree.

### F7 · tdd · step 2 · Breaks stack on each other

Status: applied
Seen in: first time
What happened: The agent placed a second break before it undid the first. The first break left a blank line with a tab, so the Edit for the second break did not match. The agent read the file again.
Evidence: line 535: "String to replace not found in file."
Fix: sharpen wording: Undo each break, and confirm that `git diff` on the source is empty before the next break.

## Worked

- tdd step 2: the first-run rule from 2026-10-16-habit-tracker-build-worktree-tdd-verify#F2 held for 4 criteria. Each commit message names the break and the undo.
- build step 8: the ancestor check found that #4 landed during the checkpoint. No stale squash reached the spec branch.
- build step 5: verify named `habitNames()` as a coupled helper before the rebase showed the conflict.
- worktree step 4: the EnterWorktree hook ran `provision.sh` again.
