# 2026-10-16 · habit-tracker · build, worktree, tdd, verify

Transcript: ~/.claude/projects/-Users-santivqz-Documents-Developer-Personal-learning-habit-tracker/233a5bb4-8dbf-4263-a6d0-4e0e248fd896.jsonl

`/build 2` took ticket #2 from open to closed. The agent did 10 TDD cycles and 2 refactors. Verify found no hard finding, and the user approved an 8-stop tour. The ticket landed as `b1b405f` on `spec/1-habit-tracker`.

## Findings

### F1 · worktree · step 3 · The guard refuses any compound command, not only git

Status: applied
Seen in: 2026-10-15-habit_tracker-spec-interview-worktree#F3 (applied). This is the second run.
What happened: After `EnterWorktree`, the harness refused a chain of `node`, `cp` and `rm` with a scratchpad path. The note from F3 covers git commands only, so the agent did not apply it to other commands.
Evidence: line 224: "this command is too complex to verify that it stays inside the worktree"
Fix: sharpen wording: The rule covers every shell command in the worktree. Use one plain command per call, with no `cd`, no `&&` chain and no path outside the worktree. Write files with the Write tool. Make the same change in the preamble of `build`.

### F2 · tdd · step 2 · No rule for a test that passes on its first run

Status: applied
Seen in: first time
What happened: Two criteria could not go red. The agent moved criterion 2 after criterion 3. It proved the order test with a temporary change to `unshift`, then undid it. The skill says only "It must fail".
Evidence: line 337: "Criterion 2 cannot go red yet, because the page reads no storage"; line 695: "this test passed on its first run"
Fix: add step: When a new test passes on its first run, do one of these. Take a later criterion first, if that criterion makes the test fail. Or break the code for one run, see the test fail, and undo the break. Write which one you did in the commit message.

### F3 · build · step 7 · The tour used one browser call per action

Status: applied. The browser check moved to the new `ui-check` skill, which batches each step.
Seen in: first time
What happened: The agent did each click, key and screenshot as a separate call. The harness flagged this 30 times. The tour was slow for the user.
Evidence: line 1199: "Prefer browser_batch to execute multiple actions in one call"
Fix: sharpen wording: Load `browser_batch` with the core browser tools. Set up the state of each stop in one batch, with the screenshot as its last action.

### F4 · build · step 7 · One criterion had no stop

Status: rejected: the tour with one stop per criterion is gone. `ui-check` checks the main flow.
Seen in: first time
What happened: The criterion "The tests render the home page with Testing Library" got one sentence inside stop 8. It had no stop and no command output. The skill gives a command stop only when the whole ticket has nothing to show in a browser.
Evidence: line 1590: "Stop 8 of 8: the habits stay after a reload"
Fix: sharpen wording: Make one stop for each criterion. A criterion with nothing to show in the browser gets a command stop, also inside a browser tour.

### F5 · tdd · Report · The report was skipped

Status: applied
Seen in: first time
What happened: The agent went from the last refactor to verify with one line. The tdd report asks for each criterion with its test name, the commits, and the seam questions.
Evidence: line 1112: "TDD is done: 10 green cycles and 2 refactors."
Fix: sharpen wording: In `build` step 4, completion is that the agent shows the tdd report before verify starts.

### F6 · worktree · Remove step 3 · `--remove-section` fails after `git branch -D`

Status: applied
Seen in: first time
What happened: `git branch -D` removed the `branch.ticket/2-create-habit` config section. The next command then failed.
Evidence: line 1778: "fatal: no such section"
Fix: cut a no-op: Remove the `git config --remove-section branch.<branch>` command from Remove step 3.

### F7 · project · Test environment and import map

Status: rejected: project
Seen in: first time
What happened: Node 26 has its own `localStorage` global. Without a storage file it is undefined, and it hid the jsdom storage, so every client test failed. Also, the `#lib/*` import map needs the file extension, so `#lib/storage` failed the typecheck.
Evidence: line 209: "Cannot read properties of undefined (reading 'clear')"; line 459: "Cannot find module '#lib/storage'"
Fix: project. The ticket commit adds `--no-experimental-webstorage` to the client test project. The import map is how the repo is set up.

## Worked

- build step 5: verify ran in a fresh subagent, and it ran every check again.
- build step 7: the judgment calls came before the first stop, and each stop used the Check and Expect lines.
- build step 9: the removal order did what it should: enter, drop, exit, then remove.
- tdd step 2: the typecheck in each cycle found the bad `#lib/storage` import at once.
