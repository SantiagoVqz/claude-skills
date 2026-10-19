# 2026-10-19 · vvfapp, habit-tracker · worktree, verify, pr, ui-check, review, cleanup

In vvfapp, two sessions built tickets #196 and #197 and opened PRs #221 and #222. A third session cleaned up #196 after its merge. In habit-tracker, `/review 1` stopped on a question that the user rejected.

## Sessions

- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp/e6588ba8-7940-4dbb-a6f6-ac522ada54d0.jsonl · lines 1-293
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-Personal-learning-habit-tracker--claude-worktrees-spec-1-habit-tracker/b03c86f6-67d2-4c3a-9d66-b3033dc0bc15.jsonl · lines 1-84
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp--claude-worktrees-fix-196-shared-layout/f59d8ab1-aca4-4f9e-a5e1-d10092af5cf9.jsonl · lines 1-1863
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-VVF-vvfapp--claude-worktrees-fix-197-fechas-e-inicio/d852f3a0-f3b2-4e65-9b70-ffe07ce7621f.jsonl · lines 1-1611
- /Users/santivqz/.claude/projects/-Users-santivqz-Documents-Developer-Personal-learning-habit-tracker/07561853-b5ff-4e17-9bdf-ad4bed3e1690.jsonl · lines 1-45

## Findings

### F1 · worktree · step 4 · Provisioned by hand when provision.sh was missing

Status: applied, as a stop with no .env copied by hand
Seen in: f59d8ab1, d852f3a0, e6588ba8 (3 sessions), first time
What happened: vvfapp has no `scripts/provision.sh` but has gitignored `.env` files. Two times, the agent said that the ticket was frontend only, copied the `.env` files and continued. It then reported the worktree as made. One worktree used the shared dev database. In the other, compose recreated the database container on the wrong port, and the agent used about 200 lines to debug it. In e6588ba8, step 4 did not run (see F8).
Evidence: f59d8ab1:192: "The repo has no `provision.sh`, so I'll copy the env files and install deps, since this ticket is frontend only."; d852f3a0:205: "This ticket is frontend-only and needs no database, so I'll install the frontend packages and copy the frontend `.env` instead."; d852f3a0:1131: "The database listens on 5432, but `backend/.env` points at 5433."; e6588ba8:265: "ls: scripts/provision.sh: No such file or directory"
Fix: anti-rationalization row: add an Excuses table with the row "The ticket is frontend only, so I can copy the env files" -> "A copied `.env` points at the shared dev database, and a browser check later needs the API and the database. Stop and tell the user to run `/setup-skills`." Sharpen wording: the Completion line says that the report is "blocked: run /setup-skills" when the script is missing in a repo that needs provisioning. Project part: vvfapp needs `/setup-skills`.

### F2 · worktree · step 3 · The shell rule was broken with cd, &&, $(...) and variables

Status: applied
Seen in: f59d8ab1, d852f3a0, e6588ba8 (3 sessions), first time
What happened: After the worktree was entered, the agent used `cd`, `&&` chains, `$(...)` and shell variables. The guard refused five calls, and each refusal caused a retry. One refusal came after a context compaction. In d852f3a0, a `cd` stayed in effect and a later `uv --directory backend` failed.
Evidence: f59d8ab1:454: "this command names git in a form too complex to verify"; f59d8ab1:1685: "this command changes directory to a location computed at runtime before running git"; d852f3a0:469: "this command runs sed with a value computed at runtime (the variable W)"; d852f3a0:1075: "The shell was still in `frontend/src/routes` from an earlier `cd`."; e6588ba8:193: "cd frontend/src && ..."
Fix: sharpen wording: in step 3, name `cd`, `&&`, `$(...)` and shell variables. Say that a `cd` stays in effect for the rest of the session. Tell the agent to use absolute paths, or flags such as `pnpm --dir` and `uv --directory`. Put the rule in the Report line too, so that it stays in a compaction summary.

### F3 · verify · Report · No Hard and Judgment calls block before the commit

Status: applied
Seen in: f59d8ab1, d852f3a0 (2 sessions), first time
What happened: Two times, verify printed no report block. One sentence of prose took its place, and the commit came next. In f59d8ab1, two criteria had no test. The agent decided in its thinking that a test would be tautological and did not report a hard finding. In d852f3a0, three judgment calls appeared only in the final chat report.
Evidence: f59d8ab1:1749: "the measure and section-head changes were verified manually in-browser since a class-name test would be tautological. Committing now."; d852f3a0:1445: "The diff reads clean against the ticket."; d852f3a0:1607: "Calls you may want to change"
Fix: sharpen wording: the Report section says "Always print the report block before the caller commits, with 'None' under an empty heading." Anti-rationalization row: "A test of a class name is tautological, and I checked it in the browser" -> "Report it as hard, with the browser evidence. The user decides."

### F4 · verify · step 1 · The diff does not fit work that is not committed

Status: applied
Seen in: f59d8ab1, d852f3a0 (2 sessions), first time
What happened: Verify ran before the commit, so `<ref>...HEAD` was empty. In f59d8ab1, the agent diffed against a local `main` that was ahead of the branch base, and a detour was necessary to explain the extra files. In d852f3a0, `git diff origin/main` did not show the new untracked `fecha.spec.ts`.
Evidence: f59d8ab1:1718: "Local `main` is ahead of the branch base, which is why that stat shows unrelated files."; d852f3a0:1410: "git -C … diff --stat origin/main"; d852f3a0:1477: "?? ../lib/fecha.spec.ts"
Fix: sharpen wording: in step 1, use `git merge-base origin/<trunk> HEAD` as the base. For work that is not committed, use `git diff <base>`, which includes the working tree. Run `git status --short` and read each untracked file. The completion line names the untracked files.

### F5 · worktree · Branches · No row for a ticket with no spec branch

Status: applied, as a fix branch for each issue that ships alone
Seen in: f59d8ab1, d852f3a0, e6588ba8 (3 sessions), first time
What happened: #196 and #197 are tickets under audit #190, which has no spec branch. The table has no row for this case, so the agent selected `fix/` two times. In e6588ba8, the caller gave only the issue number, and the agent found `fix/196-shared-layout` by hand.
Evidence: f59d8ab1:126: "219 fix/193-lifecycle-acts 217 feat/195-proveedores 216 feat/207-confirmacion"; d852f3a0:147: "No spec branch exists, and sibling tickets merged straight to main, so I'll branch from main."; e6588ba8:135: "ticket 196, branch for \"Lists and detail pages share one layout\""
Fix: sharpen wording: add a row for "ticket whose spec has no branch", with its prefix, its base (the trunk) and its database. In Locate, add: "When you know only the issue number, match any `<type>/<n>-` branch in `git worktree list` and `git branch -a` before you make a new one."

### F6 · pr · Evidence · No shape for a ticket PR

Status: applied, as the issue PR shape
Seen in: f59d8ab1, d852f3a0 (2 sessions), first time
What happened: Evidence has a Spec PR shape and a Fix PR shape. Two ticket PRs had neither shape, so each agent made its own.
Evidence: f59d8ab1:1788: "Closes #196. This PR does the P2 and P3 layout findings of audit #190."; d852f3a0:1523: "1. Each format of `fecha.ts` · `fecha.spec.ts` · ✓ day and instant for each format…"
Fix: sharpen wording: add "Ticket PR: one line for each acceptance criterion: `<n>. <criterion> · <test name> · ✓ <what you saw>`."

### F7 · review · step 1 · No rule for a review comment at the same head

Status: applied
Seen in: b03c86f6, first time
What happened: Spec #1 already had a full review comment for head 112fb11, and the head did not move. The skill has no rule for this case, so the agent made up a question. The user rejected it and interrupted the session, and the session had no outcome.
Evidence: b03c86f6:42: "### Review of #1 · 112fb115855ddb775e2721592626d2a4849bf1bf · full"; b03c86f6:76: "Spec #1 already has a full review comment for 112fb11, and the branch head has not moved since. Run the review again?"; b03c86f6:77: "The user doesn't want to proceed with this tool use."
Fix: add step: in step 1, find a comment whose first line starts with `### Review of #<spec>`. After step 2, compare its hash with `git rev-parse HEAD`. When they match, tell the user that the review is current and that the next step is `/ship <spec>`, and stop. When they do not match, continue.

### F8 · worktree · step 1 · "Use it" was read as done, so Enter and Provision did not run

Status: applied
Seen in: e6588ba8, first time
What happened: Locate found the existing worktree. The agent went into it with `cd` and did not call `EnterWorktree` or run step 4. Later, cleanup started in a worktree that the harness did not know.
Evidence: e6588ba8:166: "A worktree for #196 already exists, with a pushed branch. Checking what it holds."; e6588ba8:167: "cd /Users/santivqz/Documents/Developer/VVF/vvfapp/.claude/worktrees/fix-196-shared-layout && git status --short && git log ..."
Fix: sharpen wording: change the first case to "A worktree has the branch: use its path, and go on to steps 2 to 4." Under Enter, add: "Never enter with `cd`. Only `EnterWorktree` puts the guard on the session."

### F9 · ui-check · step 3 · A run that the agent started skipped the lists and the question

Status: applied
Seen in: d852f3a0, first time
What happened: The agent started ui-check itself to check the ticket in a browser. Step 3 covers only "a caller ran you" and "the user ran you". The agent printed no lists, asked no question and went to verify.
Evidence: d852f3a0:926: "SKILL ui-check #197: home page at / …"; d852f3a0:1401: "Next, `/verify` before the commit."
Fix: sharpen wording: in step 3, say that when no caller skill ran ui-check, the agent acts as if the user ran it. It shows both lists and asks before it stops the server.

### F10 · verify · step 3 · The review left out the test files

Status: applied
Seen in: d852f3a0, first time
What happened: The one full diff that verify read excluded `*.spec.ts`. No one checked the seam or the expected values of the tests. The agent then said that the diff was clean.
Evidence: d852f3a0:1429: "diff origin/main -- frontend/src/routes frontend/src/lib/components frontend/src/lib/schemas/correccion.ts ':!*.spec.ts'"; d852f3a0:1445: "The diff reads clean against the ticket."
Fix: anti-rationalization row: "The code diff reads clean" -> "Read each changed and new test file before you call the diff clean." Add to the completion of step 3: each changed or new test file was read.

### F11 · ui-check · step 1 · No flow was written, and the scope went past five steps

Status: applied
Seen in: d852f3a0, first time
What happened: The agent wrote no step list. It checked the home page and six date pages at two widths, with fetch-and-regex scripts, which is not a user flow. An id pattern did not match, so it had to try again.
Evidence: d852f3a0:926: "home page at / (…), and dates in cotizaciones list/detail, remisiones list/detail, facturas list, cajas materiales. Check at 1280px and 390px."; d852f3a0:1309: "The detail links didn't match my id pattern, so I'll find them by href."
Fix: sharpen wording: in step 1, write "Print the flow as a numbered list before step 2. A width, such as 390px, is a parameter of a step and not a new step."

### F12 · ui-check · step 2 · No check of what the app needs to run

Status: applied
Seen in: d852f3a0, first time
What happened: Step 2 says only "start the dev server". The app also needed Docker, the API and a Clerk session. The agent found each need only when something failed.
Evidence: d852f3a0:905: "Cannot connect to the Docker daemon"; d852f3a0:1029: "error: No such file or directory (os error 2) [exited with code 2]"; d852f3a0:1212: "The DevTools browser has no session, so it landed on `/sign-in`."
Fix: add step: before the dev server starts, read the run section of the README and start each service that the pages need. When the app goes to a sign-in page, ask the user to sign in in that window. Project part: the README and env layout of vvfapp.

### F13 · verify · step 2 · Lint did not run again in the verify run

Status: applied
Seen in: f59d8ab1, first time
What happened: Verify ran only `pnpm test`. Lint last ran at line 655, before many edits and a compaction, and the agent reported it as clean.
Evidence: f59d8ab1:1698: "pnpm test 2>&1 | tail -6"; f59d8ab1:1855: "after the rebase, `pnpm check` and `pnpm lint` are clean"
Fix: anti-rationalization row: "Check and lint passed earlier in this session" -> "Run each check again in this verify run. Edits since then can break it."

### F14 · verify · step 3 · The SMELLS.md link caused a call to a tool that does not exist

Status: applied
Seen in: d852f3a0, first time
What happened: The relative link `[SMELLS.md](SMELLS.md)` caused a call to a tool with the name SmellsRead. The call failed, and the agent then used Read.
Evidence: d852f3a0:1415: "Error: No such tool available: SmellsRead"
Fix: sharpen wording: write "Read `SMELLS.md` in the folder of this skill with the Read tool."

### F15 · project · vvfapp keeps its glossary in CONTEXT.md

Status: open: setup-skills records the glossary path, in the next commit
Seen in: d852f3a0, first time
What happened: The pr skill uses the terms in `GLOSSARY.md`. vvfapp has its glossary in `CONTEXT.md`.
Evidence: d852f3a0:365: "sed -n 70,100p CONTEXT.md"
Fix: project: run `/setup-skills` in vvfapp.

### F16 · project · The auto-mode classifier blocked the merge

Status: rejected: project, the merge is the user's by design
Seen in: f59d8ab1, first time
What happened: The user said "close the ticket". The classifier refused `gh pr merge` two times as "Merge Without Review". The agent reported the block and gave the merge command to the user.
Evidence: f59d8ab1:1636: "cool, bring back the role of director to the account please and close the ticket."; f59d8ab1:1841: "Reason: [Merge Without Review]"
Fix: project: harness permission policy. No skill change.

## Worked

- worktree step 1: each run read `git worktree list --porcelain` and `git symbolic-ref` before it made a worktree. In e6588ba8 it found the existing worktree and made no second one.
- worktree step 3: after a refusal, the agent changed to the Edit tool or to one plain command, and did not retry the same command (f59d8ab1:466, d852f3a0:481).
- verify step 2 in d852f3a0: the agent ran check, lint and test again after a format fix (d852f3a0:1445).
- ui-check: the agent did not type the user's password and asked the user to sign in (d852f3a0:1212). It went to `about:blank` and did not close the last DevTools page (d852f3a0:1568).
- pr: Merge Danger gave the concrete effect, for example "`.tabla { position: relative }` applies to every table in the app" (f59d8ab1:1788). The body went in through `--body-file`.
- cleanup: the gate checked the merged PR and the commit on `origin/main` before it deleted anything. The report gave each field (e6588ba8:250, e6588ba8:289).
- review step 1: the `### Review of #<spec>` first line with the full hash made the earlier review easy to find (b03c86f6:42).
