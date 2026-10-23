# Skills

This is a skill set for Claude Code. It takes work from an idea or a bug to a merged pull request. It works for one person and for a team.

The set has two entry points:

- `/sv-spec` starts a feature.
- `/sv-diagnose` starts a bug fix.

`/sv-issue` files work for later: an idea, a bug, a task or a follow-up. Each entry point can start from its issue.

Each phase has one command. Each command reads the output of the command before it. The tracker holds the work: GitHub Issues or Linear.

## The flow

`/sv-prd` is the setup-free path. It writes a PRD, and tickets if you want them, in any repo. `/sv-issue`, `/sv-diagnose`, `sv-tdd` and `sv-refactor` also run with no setup: they use the fallbacks in `NO-SETUP.md`, in the folder of `sv-setup-skills`.

```text
Feature:  /sv-spec ──► /sv-plan ──► /sv-build (one per ticket) ──► /sv-review ──► /sv-ship ──► you merge ──► /sv-cleanup
                                 └─ runs /sv-verify

Bug:      /sv-diagnose ──► /sv-ship ──► you merge ──► /sv-cleanup
             └─ runs /sv-verify

One-off:  /sv-issue ──► /sv-build ──► /sv-ship ──► you merge ──► /sv-cleanup
                             └─ runs /sv-verify

Once per repo:  /sv-setup-skills
End of the day: /sv-retro
Not sure:       /sv-ask
```

## Commands

### `/sv-ask`

Run it when you do not know which command is next. The agent also runs it when work starts and no command was named.

- **Input:** your request and the state of the repo: setup, branch, issue, PR and any git conflict.
- **Output:** the next command, the facts that chose it, and the command after it. It changes nothing.

### `/sv-issue [idea | bug | task] [what it is]`

Run it when you want to track work, or when you start work that has no issue. `/sv-spec`, `/sv-prd`, `/sv-plan`, `/sv-diagnose` and `sv-interview` also call it to publish their issues.

- **Input:** your words, and what the conversation already found: an `/sv-ask` route, a diagnosis, a screenshot. One request can hold several issues.
- **Process:**
  1. It finds the kind of each issue: idea, bug or task. It fills the template of the kind from the conversation and the code, and asks three questions at most for each issue.
  2. It finds the order between the issues, such as a bug that must be fixed before an idea.
  3. It searches the open issues for duplicates.
  4. It shows each draft. You approve before it files anything.
- **Output:** each issue with its label and blocking edges. An idea gets `idea`, a bug gets `bug`, and a task gets one `approach:` label. A bug body has the symptom, the steps, the facts, the hypotheses to rank, the open question for the fix and where to look. A screenshot goes in as text, and you drag the image in after.
- **Follow-ups:** say "file a follow-up" during an interview. It files the issue from the conversation, then the interview goes on.
- **Next:** `/sv-spec <n>` for an idea, `/sv-diagnose <n>` for a bug, `/sv-build <n>` for a task.

### `/sv-research <question>`

Run it before you build or integrate something, such as a connection to SAT e-invoicing. It finds how the integration works, the options, the APIs to use and the risks. It needs no setup. Other skills can call it.

- **Input:** a question.
- **Process:**
  1. It reads the stack of the app, so that each option and SDK fits it.
  2. It picks the kind. An integration gets four researchers in parallel: process, options, APIs and operation. A lookup has one owner of the facts, and it gets one researcher. Another survey gets 3 to 5 researchers. Each kind except a lookup gets one writer.
  3. Each researcher follows each claim to the primary source that owns it, and cites it.
  4. It runs one more round for gaps at most. A gap that stays open goes into the report.
- **Output:** a cited report at `docs/research/<slug>.md`, or where the repo already keeps such notes. The answer comes first. An integration report then has the options table, the APIs, the steps to build and the risks. The report stays uncommitted.
- **Next:** `/sv-issue idea` or `/sv-spec`, with the report as input.

### `/sv-setup-skills`

Run it once per repo.

- **Input:** the repo.
- **Output:** the `## Agent skills` block in `AGENTS.md`, the tracker reference file for GitHub or Linear, the labels, `scripts/provision.sh`, and the session hook that runs it.
- **Next:** every other command reads the `## Agent skills` block to find the tracker.

### `/sv-spec`

- **Input:** an idea.
- **Process:** it calls `sv-interview` to interview you, one question at a time. It keeps a decisions log during the interview. It records new glossary terms and ADRs in the log. When the spec touches a screen, it asks whether to prototype the look, and records the chosen variant.
- **Output:**
  - A spec issue with the `spec` label.
  - A spec branch, `spec/<n>-<slug>`, in its own worktree, with its own dev database.
  - The glossary and ADR changes, committed on the spec branch.
- **Next:** `/sv-plan` reads the spec issue.

### `/sv-prd`

It needs no `/sv-setup-skills`. It works in any repo.

- **Input:** an idea or an issue.
- **Process:** it calls `sv-interview` to interview you, the same as `/sv-spec`. You approve the draft. You pick where it goes.
- **Output:**
  - The PRD, as a GitHub issue or as markdown that you paste into Linear, Jira or a doc.
  - If you want them, tickets: sub-issues with native blocking links, or a numbered list in the markdown.
  - No branch, no worktree, no database, no labels and no commits.
- **Next:** you start the tickets that have no blockers.

### `/sv-plan`

- **Input:** a spec issue.
- **Process:** it cuts the spec into tickets and shows you the breakdown. You approve the breakdown before it publishes anything.
- **Output:** tickets as sub-issues of the spec, with native blocking links. Each ticket has an `approach:` label and a `Covers stories` line.
- **Rules:**
  - A spec is one ticket by default. It splits only at a named boundary: parallel work, a schema change that parallel tickets share, a prefactor, work too big for one context window, or a part you ask to approve on its own.
  - Each ticket in a split names its boundary on its card. Story count is not a boundary.
  - Each user story is in one ticket or more. `/sv-plan` does not publish while a story has no ticket.
  - A rerun cuts tickets only for the stories that no ticket covers. It does not change the open tickets.
- **Next:** you run `/sv-build` on each ticket that has no open blockers.

### `/sv-build <ticket> [--no-ui]`

You start each `/sv-build` by hand, in its own terminal. You decide how many run at the same time.

- **Input:** one ticket. A lone ticket has no parent spec. It builds on a `fix/<n>-<slug>` branch from the trunk in place of a spec branch.
- **Process:**
  1. It stops when a blocker is open. When someone else has the ticket, it asks whether you take it over. It sets the ticket to in progress and assigns it to you.
  2. It pushes the spec branch when the remote does not have it. A lone ticket skips this step. When no spec branch exists, it stops and tells you to push it from the machine that ran `/sv-spec`.
  3. It calls `sv-worktree` to make a ticket worktree from the spec branch. When the worktree has commits, it resumes from them.
  4. It calls the skill that the ticket's `approach:` label names: `sv-tdd`, `sv-refactor` or `sv-diagnose`. When that skill does not exist yet, it stops.
  5. It runs `/sv-verify` in a subagent with a fresh context. It fixes the hard findings and runs `/sv-verify` again, three runs at most. When a hard finding remains, it stops. You fix it, or you override it with a reason.
  6. It rebases onto the spec branch and runs every check, with the full suite. This is the one full suite run after verify. On a conflict, it calls `sv-resolve-conflicts`, runs `/sv-verify` again, and asks for your approval again.
  7. It shows a checkpoint card: each criterion with its test, the judgment calls, and a short "Check yourself" list. You approve, ask for a change, or ask for `/sv-ui-check`. When a criterion shows in a browser, it runs `/sv-ui-check` before the card. `--no-ui` turns that off.
  8. It squashes the ticket into one commit on the spec branch and pushes it. It closes the ticket and removes the ticket worktree. A lone ticket becomes one commit on its own branch. The ticket stays open and the worktree stays, for `/sv-ship` and `/sv-cleanup`.
- **Output:** one commit per ticket on the spec branch, and a closed ticket.
- **Next:** `/sv-build` on the tickets it unblocked. When all tickets are closed, you run `/sv-review`. For a lone ticket, `/sv-ship`.

### `/sv-verify [ref]`

`/sv-build` and `/sv-diagnose` run it in a subagent. You can also run it on any diff.

- **Input:** a diff and the ticket or issue it comes from.
- **Checks:** it runs the typecheck, lint, build and the tests that the diff touches itself. It runs the full suite when the caller asks, or when you run it. It checks the diff against the ticket's acceptance criteria and the spec's seams, then against the repo's written rules and a list of code smells.
- **Output:** findings. A hard finding blocks the ticket: a failed check, a criterion with no test, a test at the wrong seam, a broken written rule, or a ticket that is not a vertical slice. Everything else is a judgment call, and it reports the top five. It edits nothing.

### `/sv-ui-check [ticket | what to check]`

You run it when you want a browser check. `/sv-build` runs it for a ticket whose criteria show in a browser, and `/sv-review` for the stories. Each run starts a dev server.

- **Process:** it starts the dev server and does the main flow of the change in Chrome, five steps or fewer. For `/sv-review`, it does one step per story. It uses Claude in Chrome, or Chrome DevTools when the extension is not connected. The server and the tab stay open until you answer.
- **Data:** when the worktree database lacks the rows that the flow needs, it makes the fewest rows, through the seed script or the API.
- **Output:** the flow before the run, then a "Verified" list, one line per step, and a "Check yourself" list of three steps or fewer. You approve or ask for a change.

### `/sv-review <spec> [--no-ui]`

Run it when all tickets of a spec are closed. Each ticket already passed `/sv-verify` and your approval, so `/sv-review` checks only what the whole spec shows.

- **Checks:**
  - **Checks of the repo:** the full suite, typecheck, lint and build.
  - **Coverage:** each user story has tickets and a test. A story with no test is a gap.
  - **Drift:** a subagent with a fresh context reads the whole spec diff. It looks for faults between tickets: duplication, two names for one term, a helper that one ticket ignored.
  - **Walk:** `/sv-ui-check` does one step per story on the merged app. `--no-ui` skips it.
- **Gaps:** each gap is blocking or cleanup. A blocking gap is a story with no test, a failed walk step, or a defect a user can see. Everything else is cleanup, and the drift subagent reports the top five only.
  - You get one list with a recommended action for each gap, and one question.
  - A blocking gap is "Ticket", a sub-issue that the spec waits for, or "Out of scope".
  - A cleanup is "Skip", on the card, or "Later", a lone ticket that the spec does not wait for.
  - After a blocking ticket, the next `/sv-review` reads only the diff after the last review, so it does not find the same drift again.
- **Partial:** when a ticket is open, it asks whether to review the closed tickets only.
- **Light:** a spec with one closed ticket, and no commit after it, gets coverage only. It skips the checks, the drift subagent and the walk, because `/sv-build` ran them on the same commit and `/sv-ship` runs the checks again.
- **Output:** a card that you approve. It counts the covered stories and lists only the stories that went out of scope. Then it posts the card as a comment on the spec issue, with the reviewed commit and the full story list in a collapsed block. The evidence is text only: the story list and the "Verified" lines.
- **Next:** `/sv-ship`.

### `/sv-ship [spec | issue]`

- **Input:** a spec branch with an approved review comment, or a fix branch from `/sv-diagnose`.
- **Process:**
  1. It reads the latest review comment. It stops when the branch has a commit after the reviewed commit.
  2. It rebases onto the trunk. A clean rebase keeps the review. On a conflict, it calls `sv-resolve-conflicts`. A spec then goes back to `/sv-review`. A fix gets a fresh `/sv-verify` and goes on.
  3. It runs every check, and writes the PR body with `sv-pr`. The evidence is text: story, test and the "Verified" line.
  4. It pushes and opens the PR, ready for review. You get a short summary of what changed and why, not the body.
  5. When the repo has CI, it watches the checks. It reports a failure and fixes nothing.
- **Output:** one PR.
  - A full review or a fix gives `Closes #<n>`.
  - A partial review gives `Part of #<spec>` and the list of open tickets.
- **Next:** you merge with rebase and merge, so each ticket stays one commit on the trunk. Then `/sv-cleanup`.

### `/sv-cleanup [spec | issue]`

Run it after you merge.

- **Input:** a spec or fix branch with a merged PR. It stops on an open PR or no PR.
- **Process:** it closes the issues that the PR closes and that are still open. It removes the worktree with `sv-worktree`, deletes the local and remote branches, refreshes the trunk, and applies the new migrations to the trunk dev database.
- **Partial ship:** it leaves the spec issue and the open tickets open. Their ticket worktrees stay. The next `/sv-build` on the spec makes a new spec branch from the trunk and rebases the ticket onto it.

### `/sv-diagnose <bug>`

- **Input:** a Sentry link, a pasted error, or an issue.
- **Process:**
  1. If the input is not an issue, it creates an issue with the `bug` label through `sv-issue`. If the input is an issue, it starts from its facts, hypotheses and places to look. With no setup, it uses `NO-SETUP.md`: with no tracker it keeps the issue text in the report.
  2. It calls `sv-worktree` to make a fix branch, `fix/<n>-<slug>`, from the trunk. When the repo is not set up for worktrees, it makes the branch in a clean primary checkout, or leaves the fix uncommitted.
  3. It builds a feedback loop that goes red on the bug, and minimises the repro. When a person must reproduce the bug, `/sv-ui-check` tries first, then it asks you one step at a time.
  4. It ranks 3 to 5 hypotheses, and you pick the first one to test. It instruments the code, fixes the cause with a regression test, and cleans up.
  5. It runs `/sv-verify` in a subagent, the same as `/sv-build`.
  6. It shows a card: cause, fix, test and judgment calls. You approve, ask for a change, or ask for `/sv-ui-check`.
  7. It squashes the branch into one commit, `Fix <title> (#n)`, with the cause in the message.
- **Output:** one fix commit. A comment on the issue records the cause.
- **Next:** `/sv-ship`.

When `/sv-build` calls `sv-diagnose` for an `approach:diagnose` ticket, steps 1, 2, 5, 6 and 7 do not run. `/sv-build` owns them.

## Skills that other skills call

You do not type these. Other skills call them.

| Skill | Called by | Job |
|---|---|---|
| `sv-interview` | `/sv-spec`, `/sv-prd` | Interview one question at a time on the design tree. Show a recommendation and a progress count. Keep a decisions log. |
| `sv-tdd` | `/sv-build` | One red, green cycle per acceptance criterion, at the seams that the spec agreed, with a commit per green. One refactor pass at the end. |
| `sv-refactor` | `/sv-build` | Change the structure and keep the behavior, one named step at a time. Pin tests come first, and no expected value changes. |
| `sv-resolve-conflicts` | `/sv-build` | Resolve a rebase conflict and keep both intents. Ask you only when both sides change the same behavior. |
| `sv-worktree` | `/sv-spec`, `/sv-build`, `/sv-diagnose` | Find or make the worktree, then provision it. |
| `sv-pr` | `/sv-ship` | Write the PR body: summary, evidence, merge danger. |

`sv-prototype` is optional. Run it on its own, or let `/sv-spec` and `/sv-prd` call it when a question needs a demo to answer. It builds each prototype as one Claude artifact, for a UI question and for a logic question.

## Branches, worktrees and databases

| Thing | Rule |
|---|---|
| Spec branch | One per spec, `spec/<n>-<slug>`, from the trunk. It is the one PR. |
| Ticket branch | One per ticket, `ticket/<n>-<slug>`, from the spec branch. It merges into the spec branch locally. It never gets a PR. |
| Fix branch | One per bug or lone ticket, `fix/<n>-<slug>`, from the trunk. |
| Primary checkout | It stays on the trunk. Code work never happens here. |
| Dev database | Each branch from the trunk gets its own fork of the trunk dev database. Ticket worktrees use the fork of their spec. |
| Test database | Each worktree gets its own. |

### Parallel specs

Git checks out a branch in one place only. Two different branches can be checked out at the same time in two different worktrees. Thus each spec and each ticket has its own worktree, and the primary checkout stays on the trunk.

Example, with specs 12 and 15 in progress at the same time:

```
repo/                                  trunk (primary checkout)
.claude/worktrees/spec-12-foo          spec/12-foo
.claude/worktrees/ticket-31-bar        ticket/31-bar   (from spec/12-foo)
.claude/worktrees/spec-15-baz          spec/15-baz
.claude/worktrees/ticket-40-qux        ticket/40-qux   (from spec/15-baz)
```

Each worktree is a separate folder with its own branch and its own test database. Each spec has its own dev database fork. The two specs share nothing until one of them merges into the trunk.

- **Sessions:** `EnterWorktree` keeps a session in one worktree. To work on two specs at the same time, use two sessions.
- **Landing a ticket:** `/sv-build` enters the spec worktree and squash-merges the ticket branch there. The spec worktree stays until `/sv-cleanup`, because each ticket of the spec lands there.
- **Conflicts in one spec:** when two tickets of a spec run in parallel, the second ticket to land rebases onto the spec branch first.
- **Conflicts between specs:** a spec sees the changes of another spec only after that spec merges. `/sv-ship` rebases onto the trunk and resolves the conflicts with `sv-resolve-conflicts`.
- **Migrations:** each spec migrates its own fork, so parallel specs do not interfere. In one spec, only the schema ticket migrates, because all tickets of the spec share the fork.

## Labels

| Label | Set by | Read by |
|---|---|---|
| `idea` | `/sv-issue` | `/sv-spec`, `/sv-prd` |
| `spec` | `/sv-spec` | `/sv-plan`, `/sv-review`, `/sv-ship`, `/sv-cleanup` |
| `bug` | `/sv-issue`, `/sv-diagnose` | `/sv-ship`, `/sv-cleanup` |
| `approach:tdd`, `approach:refactor`, `approach:diagnose` | `/sv-plan`, `/sv-issue` | `/sv-build` |
| `in-progress` | `/sv-build` | you and your team |

On Linear, `/sv-build` sets the native In Progress status. It does not use the `in-progress` label. Blocked work uses native blocking links. Done work is a closed issue.

## How the set grows

- Run `/sv-retro` at the end of a day of work. It reads each session since the last retro, in each project, where skills ran. It writes the findings to one file in `runs/` in this repo, with evidence and a proposed fix. Git ignores `runs/`, because a run file quotes the sessions of private projects. The Sessions list of each run file records the lines it read, so no line is read twice.
- A finding that repeats across runs is fixed first. A fix commit names the finding ID and sets its status.
- Fix the skill after each run. Do not fix it by prompting again.
- Add a skill only when a run shows a need for it.
- Add a row to an anti-rationalization table only when a run shows a new excuse. These tables are in `sv-build`, `sv-tdd`, `sv-refactor`, `sv-diagnose`, `sv-verify`, `sv-review`, `sv-worktree`, `sv-cleanup` and `sv-setup-skills`.
- Put each engineering principle in the one skill where it applies.

## Layout

Each skill is in the folder of its phase. The number gives the order of the flow.

```text
skills/
├── 1-define/   sv-spec, sv-prd, sv-interview, sv-prototype
├── 2-plan/     sv-plan
├── 3-build/    sv-build, sv-tdd, sv-refactor, sv-resolve-conflicts, sv-diagnose
├── 4-verify/   sv-verify, sv-ui-check, sv-review
├── 5-ship/     sv-ship, sv-pr, sv-cleanup
└── support/    sv-ask, sv-issue, sv-research, sv-setup-skills, sv-worktree, sv-retro, sv-writing-for-agents, sv-unslop
```

A skill installs by its folder name only, for example `sv-spec`. The phase folder groups skills and is not part of the name.

## Install

`install.sh` symlinks a skill. An edit in this repo is live at once.

```bash
./install.sh skills/1-define/sv-spec  # one skill, into .claude/skills/ of the current project
./install.sh --all --global           # all skills, into ~/.claude/skills/
```

A plugin and `npx skills add` come later. See issue #3.

`sv-ui-check` falls back to Chrome DevTools when the Claude in Chrome extension is not connected. Run the DevTools server with `--isolated`, so that each session gets its own Chrome and parallel checks do not collide. The `chrome-devtools-mcp` plugin shares one profile across all sessions, so turn it off and add the server yourself:

```bash
claude mcp add -s user chrome-devtools -- npx -y chrome-devtools-mcp@1.11.0 --isolated
```

Each isolated Chrome starts signed out, so you sign in once per check.
