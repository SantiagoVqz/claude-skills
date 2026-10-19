# Skills

This is a skill set for Claude Code. It takes work from an idea or a bug to a merged pull request. It works for one person and for a team.

The set has two entry points:

- `/spec` starts a feature.
- `/diagnose` starts a bug fix.

Each phase has one command. Each command reads the output of the command before it. The tracker holds the work: GitHub Issues or Linear.

## The flow

`/prd` is the setup-free path. It writes a PRD, and tickets if you want them, in any repo.

```text
Feature:  /spec ──► /plan ──► /build (one per ticket) ──► /review ──► /ship ──► you merge ──► /cleanup
                                 └─ runs /verify

Bug:      /diagnose ──► /ship ──► you merge ──► /cleanup
             └─ runs /verify

Once per repo:  /setup-skills
End of the day: /retro
```

## Commands

### `/setup-skills`

Run it once per repo.

- **Input:** the repo.
- **Output:** the `## Agent skills` block in `AGENTS.md`, the tracker reference file for GitHub or Linear, the labels, `scripts/provision.sh`, and the session hook that runs it.
- **Next:** every other command reads the `## Agent skills` block to find the tracker.

### `/spec`

- **Input:** an idea.
- **Process:** it calls `interview` to interview you, one question at a time. It keeps a decisions log during the interview. It records new glossary terms and ADRs in the log. When the spec touches a screen, it asks whether to prototype the look, and records the chosen variant.
- **Output:**
  - A spec issue with the `spec` label.
  - A spec branch, `spec/<n>-<slug>`, in its own worktree, with its own dev database.
  - The `GLOSSARY.md` and ADR changes, committed on the spec branch.
- **Next:** `/plan` reads the spec issue.

### `/prd`

It needs no `/setup-skills`. It works in any repo.

- **Input:** an idea or an issue.
- **Process:** it calls `interview` to interview you, the same as `/spec`. You approve the draft. You pick where it goes.
- **Output:**
  - The PRD, as a GitHub issue or as markdown that you paste into Linear, Jira or a doc.
  - If you want them, tickets: sub-issues with native blocking links, or a numbered list in the markdown.
  - No branch, no worktree, no database, no labels and no commits.
- **Next:** you start the tickets that have no blockers.

### `/plan`

- **Input:** a spec issue.
- **Process:** it cuts the spec into tickets and shows you the breakdown. You approve the breakdown before it publishes anything.
- **Output:** tickets as sub-issues of the spec, with native blocking links. Each ticket has an `approach:` label and a `Covers stories` line.
- **Rules:**
  - A ticket fits in one context window and one worktree.
  - All schema changes go in one early ticket. Every ticket that needs the new schema is blocked by it.
  - Each user story is in one ticket or more. `/plan` does not publish while a story has no ticket.
  - A rerun cuts tickets only for the stories that no ticket covers. It does not change the open tickets.
- **Next:** you run `/build` on each ticket that has no open blockers.

### `/build <ticket> [--ui]`

You start each `/build` by hand, in its own terminal. You decide how many run at the same time.

- **Input:** one ticket.
- **Process:**
  1. It stops when a blocker is open. When someone else has the ticket, it asks whether you take it over. It sets the ticket to in progress and assigns it to you.
  2. It pushes the spec branch when the remote does not have it. When no spec branch exists, it stops and tells you to push it from the machine that ran `/spec`.
  3. It calls `worktree` to make a ticket worktree from the spec branch. When the worktree has commits, it resumes from them.
  4. It calls the skill that the ticket's `approach:` label names: `tdd`, `refactor` or `diagnose`. When that skill does not exist yet, it stops.
  5. It runs `/verify` in a subagent with a fresh context. It fixes the hard findings and runs `/verify` again one time. When a hard finding remains, it stops. You fix it, or you override it with a reason.
  6. It rebases onto the spec branch and runs every check. On a conflict, it calls `resolve-conflicts`, runs `/verify` again, and asks for your approval again.
  7. It shows a checkpoint card: each criterion with its test, the judgment calls, and a short "Check yourself" list. You approve, ask for a change, or ask for `/ui-check`. It starts no dev server until you ask. With `--ui`, it runs `/ui-check` before the card.
  8. It squashes the ticket into one commit on the spec branch and pushes it. It closes the ticket and removes the ticket worktree.
- **Output:** one commit per ticket on the spec branch, and a closed ticket.
- **Next:** `/build` on the tickets it unblocked. When all tickets are closed, you run `/review`.

### `/verify [ref]`

`/build` and `/diagnose` run it in a subagent. You can also run it on any diff.

- **Input:** a diff and the ticket or issue it comes from.
- **Checks:** it runs the tests, typecheck, lint and build itself. It checks the diff against the ticket's acceptance criteria and the spec's seams, then against the repo's written rules and a list of code smells.
- **Output:** findings. A hard finding blocks the ticket: a failed check, a criterion with no test, a test at the wrong seam, a broken written rule, or a ticket that is not a vertical slice. Everything else is a judgment call, and it reports the top five. It edits nothing.

### `/ui-check [ticket | what to check]`

You run it when you want a browser check. `/build --ui` runs it too. Each run starts a dev server, so it never runs on its own.

- **Process:** it starts the dev server and does the main flow of the change in Chrome, five steps or fewer. For `/review`, it does one step per story. It uses Claude in Chrome, or Chrome DevTools when the extension is not connected. The server and the tab stay open until you answer.
- **Output:** a "Verified" list, one line per step, and a "Check yourself" list of three steps or fewer. You approve or ask for a change.

### `/review <spec> [--no-ui]`

Run it when all tickets of a spec are closed. Each ticket already passed `/verify` and your approval, so `/review` checks only what the whole spec shows.

- **Checks:**
  - **Checks of the repo:** the full suite, typecheck, lint and build.
  - **Coverage:** each user story has tickets and a test. A story with no test is a gap.
  - **Drift:** a subagent with a fresh context reads the whole spec diff. It looks for faults between tickets: duplication, two names for one term, a helper that one ticket ignored.
  - **Walk:** `/ui-check` does one step per story on the merged app. `--no-ui` skips it.
- **Gaps:** you mark each gap "Ticket" or "Out of scope". A missing story gets its own ticket. The other gaps share one follow-up ticket. When it creates a ticket, you `/build` it and run `/review` again.
- **Partial:** when a ticket is open, it asks whether to review the closed tickets only.
- **Output:** a card that you approve. Then it posts the card as a comment on the spec issue, with the reviewed commit. The evidence is text only: the "Verified" lines.
- **Next:** `/ship`.

### `/ship [spec | bug]`

- **Input:** a spec branch with an approved review comment, or a fix branch from `/diagnose`.
- **Process:**
  1. It reads the latest review comment. It stops when the branch has a commit after the reviewed commit.
  2. It rebases onto the trunk. A clean rebase keeps the review. On a conflict, it calls `resolve-conflicts`. A spec then goes back to `/review`. A fix gets a fresh `/verify` and goes on.
  3. It runs every check, and writes the PR body with `pr`. The evidence is text: story, test and the "Verified" line.
  4. It pushes and opens the PR, ready for review. You get a short summary of what changed and why, not the body.
  5. When the repo has CI, it watches the checks. It reports a failure and fixes nothing.
- **Output:** one PR.
  - A full review or a fix gives `Closes #<n>`.
  - A partial review gives `Part of #<spec>` and the list of open tickets.
- **Next:** you merge with rebase and merge, so each ticket stays one commit on the trunk. Then `/cleanup`.

### `/cleanup [spec | bug]`

Run it after you merge.

- **Input:** a spec or fix branch with a merged PR. It stops on an open PR or no PR.
- **Process:** it closes the issues that the PR closes and that are still open. It removes the worktree with `worktree`, deletes the local and remote branches, refreshes the trunk, and applies the new migrations to the trunk dev database.
- **Partial ship:** it leaves the spec issue and the open tickets open. Their ticket worktrees stay. The next `/build` on the spec makes a new spec branch from the trunk and rebases the ticket onto it.

### `/diagnose <bug>`

- **Input:** a Sentry link, a pasted error, or an issue.
- **Process:**
  1. If the input is not an issue, it creates an issue with the `bug` label.
  2. It calls `worktree` to make a fix branch, `fix/<n>-<slug>`, from the trunk.
  3. It builds a feedback loop that goes red on the bug, and minimises the repro. When a person must reproduce the bug, `/ui-check` tries first, then it asks you one step at a time.
  4. It ranks 3 to 5 hypotheses, and you pick the first one to test. It instruments the code, fixes the cause with a regression test, and cleans up.
  5. It runs `/verify` in a subagent, the same as `/build`.
  6. It shows a card: cause, fix, test and judgment calls. You approve, ask for a change, or ask for `/ui-check`.
  7. It squashes the branch into one commit, `Fix <title> (#n)`, with the cause in the message.
- **Output:** one fix commit. A comment on the issue records the cause.
- **Next:** `/ship`.

When `/build` calls `diagnose` for an `approach:diagnose` ticket, steps 1, 2, 5, 6 and 7 do not run. `/build` owns them.

## Skills that other skills call

You do not type these. Other skills call them.

| Skill | Called by | Job |
|---|---|---|
| `interview` | `/spec`, `/prd` | Interview one question at a time on the design tree. Show a recommendation and a progress count. Keep a decisions log. |
| `tdd` | `/build` | One red, green cycle per acceptance criterion, at the seams that the spec agreed, with a commit per green. One refactor pass at the end. |
| `refactor` | `/build` | Change the structure and keep the behavior, one named step at a time. Pin tests come first, and no expected value changes. |
| `resolve-conflicts` | `/build` | Resolve a rebase conflict and keep both intents. Ask you only when both sides change the same behavior. |
| `worktree` | `/spec`, `/build`, `/diagnose` | Find or make the worktree, then provision it. |
| `pr` | `/ship` | Write the PR body: summary, evidence, merge danger. |

`prototype` is optional. Use it during `/spec` when a question needs a demo to answer. It publishes the variants as one artifact.

## Branches, worktrees and databases

| Thing | Rule |
|---|---|
| Spec branch | One per spec, `spec/<n>-<slug>`, from the trunk. It is the one PR. |
| Ticket branch | One per ticket, `ticket/<n>-<slug>`, from the spec branch. It merges into the spec branch locally. It never gets a PR. |
| Fix branch | One per bug, `fix/<n>-<slug>`, from the trunk. |
| Primary checkout | It stays on the trunk. Code work never happens here. |
| Dev database | Each branch from the trunk gets its own fork of the trunk dev database. Ticket worktrees use the fork of their spec. |
| Test database | Each worktree gets its own. |

## Labels

| Label | Set by | Read by |
|---|---|---|
| `spec` | `/spec` | `/plan`, `/review`, `/ship`, `/cleanup` |
| `bug` | `/diagnose` | `/ship`, `/cleanup` |
| `approach:tdd`, `approach:refactor`, `approach:diagnose` | `/plan` | `/build` |
| `in-progress` | `/build` | you and your team |

On Linear, `/build` sets the native In Progress status. It does not use the `in-progress` label. Blocked work uses native blocking links. Done work is a closed issue.

## How the set grows

- Run `/retro` at the end of a day of work. It reads each session since the last retro, in each project, where skills ran. It writes the findings to one file in `runs/` in this repo, with evidence and a proposed fix. The Sessions list of each run file records the lines it read, so no line is read twice.
- A finding that repeats across runs is fixed first. A fix commit names the finding ID and sets its status.
- Fix the skill after each run. Do not fix it by prompting again.
- Add a skill only when a run shows a need for it.
- Add a row to an anti-rationalization table only when a run shows a new excuse. These tables are in `tdd`, `refactor`, `diagnose`, `verify` and `review`.
- Put each engineering principle in the one skill where it applies.

## Layout

Each skill is in the folder of its phase. The number gives the order of the flow.

```text
skills/
├── 1-define/   spec, prd, interview, prototype
├── 2-plan/     plan
├── 3-build/    build, tdd, refactor, resolve-conflicts, diagnose
├── 4-verify/   verify, ui-check, review
├── 5-ship/     ship, pr, cleanup
└── support/    setup-skills, worktree, retro, writing-for-agents, unslop
```

A skill installs by its folder name only, for example `spec`. The phase folder groups skills and is not part of the name.

## Install

`install.sh` symlinks a skill. An edit in this repo is live at once.

```bash
./install.sh skills/1-define/spec     # one skill, into .claude/skills/ of the current project
./install.sh --all --global           # all skills, into ~/.claude/skills/
```

A plugin and `npx skills add` come later. See issue #3.
