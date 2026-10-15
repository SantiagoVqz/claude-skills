# 2026-10-15 · habit_tracker · spec, interview, worktree

Transcript: /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-Personal-learning-habit-tracker--claude-worktrees-spec-1-habit-tracker/48c2c767-58ab-43d2-ac47-c29d58e15dd2.jsonl

The session ran `/spec` for a habit tracker. It published spec issue #1, made the branch `spec/1-habit-tracker` in a worktree, and committed a glossary and two ADRs.

## Findings

### F1 · spec · step 7 · A term outside the log reached the glossary

Status: applied
Seen in: first time
What happened: The agent added the term "Owner" to `GLOSSARY.md`. The confirmed decisions log did not have this term. The agent told the user only in the final report.
Evidence: line 423: "**Owner**:"; line 516: "I added \"Owner\" to the glossary"
Fix: sharpen wording: In step 7, write only the terms and ADRs of the confirmed log. When the draft needs a new term, show it to the user before step 5.

### F2 · interview · step 2 and step 4 · User stories were drafted, not asked

Status: applied
Seen in: first time
What happened: `/spec` names user stories as a required decision. The agent wrote all eight stories and five new out-of-scope items without a question. It put them in the close message, and the user confirmed them with one "yes".
Evidence: line 293: "I drafted the parts below without asking"
Fix: add step: When the caller names a required decision, ask it as its own numbered question. Do not settle drafted content for the first time in the close.

### F3 · worktree · step 3 · The isolation guard refuses compound commands

Status: applied
Seen in: first time
What happened: After `EnterWorktree`, the harness refused a heredoc with a chained `git commit`, and later a `git -C` call. Each refusal cost a retry.
Evidence: line 425: "this command is too complex to verify that it stays inside the worktree"; line 534: same refusal
Fix: sharpen wording: After Enter, add a note. Run each git command as one plain command from the worktree root, with no `cd` and no `-C`. Write files with the Write tool. Pass a commit message with one `-m` flag per paragraph, because a message file in the worktree can get committed.

### F4 · worktree · Branches · The trunk rule fails when `origin/HEAD` is missing

Status: applied
Seen in: first time
What happened: `git symbolic-ref refs/remotes/origin/HEAD` failed, because the clone had no `origin/HEAD`. The agent used `gh repo view` as a fallback that the skill does not state.
Evidence: line 371: "not a symbolic ref"
Fix: sharpen wording: Add a fallback to the trunk rule. When the ref is missing, use `gh repo view --json defaultBranchRef`. Do not run `git remote set-head`, because it changes the repo config.

### F5 · setup-skills · step 2 · Choices are asked in prose

Status: applied
Seen in: first time
What happened: `/setup-skills` asked about the tracker and the other choices in plain text. The final approval was in plain text too.
Evidence: user-reported. The skill ran in an earlier session, so this transcript has no evidence.
Fix: sharpen wording: Ask each choice with the question tool, and ask for the final approval with it too.

## Worked

- interview step 2: the agent asked one question per message, with a recommendation each time, and asked no fact questions.
- interview step 4: the close asked what the user would change, and waited for an explicit yes.
- spec step 1: the agent read the tracker rules and checked the labels before the interview.
- spec step 4: the agent published the spec only after the user approved the draft.
