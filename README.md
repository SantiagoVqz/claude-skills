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
After a run:    /retro
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

- **Process:** it starts the dev server and does the main flow of the change in Chrome, five steps or fewer. It uses Claude in Chrome, or Chrome DevTools when the extension is not connected. Then it stops the server.
- **Output:** a "Verified" list, one line per step, and a "Check yourself" list of three steps or fewer. You approve or ask for a change.

### `/review`

- **Input:** the spec branch after all tickets are merged.
- **Checks:**
  - **Spec coverage:** each user story has code and a test. It lists stories that are missing or partial, and behavior that the spec did not ask for.
  - **Runtime proof:** it starts the app and does each user story. It uses a browser for UI and real requests for an API.
- **Output:** a report, plus screenshots and output as evidence. It does not fix gaps. You make each gap a new ticket, or you record it as out of scope.
- **Next:** `/ship` puts the evidence in the PR.

### `/ship [partial]`

- **Input:** a branch that passed `/review`, or a fix branch from `/diagnose`.
- **Process:** it integrates the base branch, runs the full suite, and pushes. It writes the PR body with `pr`.
- **Output:** one PR.
  - A full ship says `Closes #<spec>`. `/ship` stops if a ticket is still open.
  - `/ship partial` says `Part of #<spec>` and lists the open tickets. `/review` checks only the stories of the closed tickets.
- **Next:** you review and merge the PR. The merge is always yours.

### `/cleanup`

Run it after you merge.

- **Input:** the merged branch.
- **Process:** it confirms that the branch landed and that the issues closed. It removes the worktree and drops the branch's databases. It deletes the branches, refreshes the trunk, and applies the new migrations to the trunk dev database.
- **Partial ship:** it leaves the spec issue and the open tickets open. The next `/build` on the spec makes a new spec branch from the trunk.

### `/diagnose <bug>`

- **Input:** a Sentry link, a pasted error, or an issue.
- **Process:**
  1. If the input is not an issue, it creates an issue with the `bug` label.
  2. It calls `worktree` to make a fix branch, `fix/<n>-<slug>`, from the trunk.
  3. It builds a feedback loop that fails on the bug. Then it reproduces the bug, ranks hypotheses, instruments the code, fixes the bug with a regression test, and cleans up.
  4. It runs `/verify` in a subagent, the same as `/build`.
- **Output:** a fix commit. The issue records the cause.
- **Next:** `/ship`.

When `/build` calls `diagnose` for an `approach:diagnose` ticket, steps 1, 2 and 4 do not run. `/build` owns them.

## Skills that other skills call

You do not type these. Other skills call them.

| Skill | Called by | Job |
|---|---|---|
| `interview` | `/spec`, `/prd` | Interview one question at a time on the design tree. Show a recommendation and a progress count. Keep a decisions log. |
| `tdd` | `/build` | One red, green cycle per acceptance criterion, at the seams that the spec agreed, with a commit per green. One refactor pass at the end. |
| `refactor` | `/build` | Change the structure and keep the behavior. The suite stays green. Built when a ticket first needs it. |
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

- After each session in which skills ran, run `/retro`. It reads the transcript and writes the findings to `runs/` in this repo, one file per run, with evidence and a proposed fix.
- A finding that repeats across runs is fixed first. A fix commit names the finding ID and sets its status.
- Fix the skill after each run. Do not fix it by prompting again.
- Add a skill only when a run shows a need for it.
- Add a row to an anti-rationalization table only when a run shows a new excuse. These tables are in `tdd`, `diagnose`, `verify` and `review`.
- Put each engineering principle in the one skill where it applies.

## Layout

Each skill is in the folder of its phase. The number gives the order of the flow.

```text
skills/
├── 1-define/   spec, prd, interview, prototype
├── 2-plan/     plan
├── 3-build/    build, tdd, resolve-conflicts, diagnose
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

## Open questions

- **Evidence storage:** where `/review` saves screenshots, and how `/ship` puts them in the PR body.
