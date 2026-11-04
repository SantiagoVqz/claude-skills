# Skills

This is a skill set for Claude Code. It takes work from an idea or a bug to a merged pull request, and it stays out of the way for small changes. It works for one person and for a team.

Each skill runs alone. No skill needs an earlier skill, and `/setup-skills` is optional.

## The flow

```text
Feature:  /spec ──► /build, once per ticket ──► /ship ──► you merge ──► /cleanup
Ticket:   you write it ──► /build ──► /ship ──► you merge ──► /cleanup
Bug:      /diagnose ──► /ship ──► you merge ──► /cleanup

Once a week: /retro
Not sure:    /ask
```

`/build` plans and implements one ticket in your session. It is light by default, and it picks the approach from the work: `tdd`, `refactor`, `diagnose`, or a direct build. `/ship` runs the one cold read of the whole diff and the one full check.

## Commands

### `/ask`

Run it when you do not know which command is next. The agent also runs it when work starts and no command was named.

- **Input:** your request and the state of the repo: setup, branch, issue, PR and any git conflict.
- **Output:** the next command, the facts that chose it, and the command after it. It changes nothing.

### `/issue [idea | bug | task] [what it is]`

Run it when you want to track work, or when you start work that has no issue. `/spec`, `/diagnose` and `interview` also call it to publish their issues.

- **Input:** your words, and what the conversation already found: an `/ask` route, a diagnosis, a screenshot. One request can hold several issues.
- **Process:**
  1. It finds the kind of each issue: idea, bug or task. It fills the template of the kind from the conversation and the code, and asks three questions at most for each issue.
  2. It finds the order between the issues, such as a bug that must be fixed before an idea.
  3. It searches the open issues for duplicates.
  4. It shows each draft. You approve before it files anything.
- **Output:** each issue with its label and blocking edges. An idea gets `idea`, a bug gets `bug`, and a task gets no label. A bug body has the symptom, the steps, the facts, the hypotheses to rank, the open question for the fix and where to look. A screenshot goes in as text, and you drag the image in after.
- **Follow-ups:** say "file a follow-up" during an interview. It files the issue from the conversation, then the interview goes on.
- **Next:** `/spec <n>` for an idea, `/diagnose <n>` for a bug, `/build <n>` for a task.

### `/research <question>`

Run it before you build or integrate something, such as a connection to SAT e-invoicing. It finds how the integration works, the options, the APIs to use and the risks. It needs no setup. Other skills can call it.

- **Input:** a question.
- **Process:**
  1. It reads the stack of the app, so that each option and SDK fits it.
  2. It picks the kind. An integration gets four researchers in parallel: process, options, APIs and operation. A lookup has one owner of the facts, and it gets one researcher. Another survey gets 3 to 5 researchers. Each kind except a lookup gets one writer.
  3. Each researcher follows each claim to the primary source that owns it, and cites it.
  4. It runs one more round for gaps at most. A gap that stays open goes into the report.
- **Output:** a cited report at `docs/research/<slug>.md`, or where the repo already keeps such notes. The answer comes first. An integration report then has the options table, the APIs, the steps to build and the risks. The report stays uncommitted.
- **Next:** `/issue idea` or `/spec`, with the report as input.

### `/setup-skills`

Run it once per repo, when you want the tracker docs, labels and worktree provisioning. Every other skill has fallbacks in `NO-SETUP.md`.

Run `/setup-skills --upgrade` in a repo that was set up earlier. It shows each difference from the current rules, then updates the provisioning engine and the compose file on a branch, and moves the database port when it must.

- **Input:** the repo.
- **Output:** the `## Agent skills` block in `AGENTS.md`, the tracker reference file for GitHub or Linear, the labels, `scripts/provision.sh`, and the session hook that runs it.

### `/spec`

- **Input:** an idea.
- **Process:** it calls `interview`, in rounds of four questions or fewer. Each question has a recommendation. The interview asks how the feature behaves, and the agent writes the user stories from your answers. When the spec touches a screen, it asks whether to prototype the look. It then cuts the spec into tickets.
- **Tickets:** one ticket by default. It splits at a boundary, such as an estimate over about 800 changed lines. Each ticket is a vertical slice that builds in one session and ships as one PR. Tickets build in blocking order, so a later ticket reads the merged code of an earlier one.
- **Approval:** one list of what you approve: problem, scope, out of scope, seams, schema, look, new terms and ADRs, size and tickets.
- **Output:** a spec issue with the `spec` label and its tickets as sub-issues with blocking links. With no tracker, a markdown file in `.scratch/spec/`. It makes no branch, no worktree and no commit.
- **Next:** `/build <n>` for each ticket with no blocker.

### `/build <ticket | spec | words>`

One `/build` takes one ticket to one commit, in your session. You see the work as it happens.

- **Input:** any issue, with or without labels or criteria, or a change in words. A spec with open tickets names the next ticket and stops. An idea goes to `/spec`.
- **Process:**
  1. It reads the ticket, the code and `git log` on the area.
  2. It checks the hard stops: a migration or backfill, auth or permissions, a production data write, a new or changed UI element, a contract that another repo or app consumes, or a third issue on one symptom.
  3. With no hard stop, it shows a plan of about 15 lines, for one approval. With a hard stop, it runs the full plan in `PLAN.md`, in the same session: a problem brief, and decisions in one form of four questions or fewer. A hard stop that the parent spec settled stays light.
  4. It makes the branch `fix/<n>-<slug>`. It uses the primary checkout when that checkout is clean, and a worktree when the checkout is busy or the plan has a migration.
  5. It picks the approach from the work and implements. It delegates to one subagent only for large work.
  6. It runs the typecheck, the lint and the tests that the diff touches, and squashes into one commit with a `Hard stops:` line. You ask for changes in the chat, and `/ui-check` runs only when you ask.
- **Output:** one commit on the branch, and the plan comment on the issue.
- **Next:** `/ship`.

### `/verify [ref]`

`/ship` runs it in a subagent as the cold read. `/build` also runs it after a phase of a multi-file migration or refactor. You can run it on any diff.

- **Input:** a diff, and the criteria of its issue.
- **Checks:** it runs the typecheck, lint, build and the tests that the diff touches. It runs the full suite when the caller asks, or when you run it. It checks the diff against the criteria and the spec's seams, then against the repo's written rules and a list of code smells.
- **Output:** findings. A hard finding is a failed check, a criterion with no test, a test at the wrong seam, a broken written rule, a defect a user can see, or work that is not a vertical slice. Everything else is a judgment call, and it reports the top five. It edits nothing.

### `/ui-check [issue | what to check]`

It runs only when you ask. Each run starts a dev server.

- **Process:** it starts the dev server and does the main flow of the change in Chrome, five steps or fewer. It uses Claude in Chrome, or Chrome DevTools when the extension is not connected. The server and the tab stay open until you answer.
- **Data:** when the database lacks the rows that the flow needs, it makes the fewest rows, through the seed script or the API.
- **Output:** the flow before the run, then a "Verified" list, one line per step, and a "Check yourself" list of three steps or fewer. You approve or ask for a change.

### `/ship [issue]`

It works on any branch with commits.

- **Process:**
  1. It rebases onto the trunk. On a conflict, it calls `resolve-conflicts`.
  2. It runs `hardstop-check.sh`. The script refuses a diff with a migration, a backfill, or auth or permission code when a commit says `Hard stops: none`. You stop, or you override with a reason.
  3. It runs one cold read of the whole diff with `/verify` in a subagent. It fixes each hard finding, with three cold reads at most.
  4. It runs the full suite, typecheck, lint and build once, only when CI does not cover the PR.
  5. It writes the PR body with `pr`, pushes and opens the PR. You get a short summary of what changed and why, not the body.
  6. It waits for CI to pass. It reports a failure and fixes nothing.
- **Output:** one PR with `Closes #<n>`, when the branch has an issue.
- **Next:** you merge with the method that `/ship` names. Then `/cleanup`.

### `/cleanup [issue]`

Run it after you merge.

- **Input:** a branch with a merged PR. It stops on an open PR or no PR.
- **Process:** it closes the issue that the PR closes, when it is still open, and the spec when its last ticket closes. It removes the worktree with `worktree`, deletes the local and remote branches, refreshes the trunk, and applies the new migrations to the trunk dev database.

### `/diagnose <bug>`

- **Input:** a Sentry link, a pasted error, or an issue.
- **Process:**
  1. If the input is not an issue, it creates an issue with the `bug` label through `issue`. If the input is an issue, it starts from its facts, hypotheses and places to look. With no setup, it uses `NO-SETUP.md`: with no tracker it keeps the issue text in the report.
  2. It calls `worktree` to make a fix branch, `fix/<n>-<slug>`, from the trunk. When the repo is not set up for worktrees, it makes the branch in a clean primary checkout, or leaves the fix uncommitted.
  3. It builds a feedback loop that goes red on the bug, and minimises the repro. When a person must reproduce the bug, `/ui-check` tries first, then it asks you one step at a time.
  4. It ranks 3 to 5 hypotheses, and you pick the first one to test. It instruments the code, fixes the cause with a regression test, and cleans up.
  5. It runs the checks that the fix touches. `/ship` runs the cold read.
  6. It shows a card: cause, fix and test. You approve, ask for a change, or ask for `/ui-check`.
  7. It squashes the branch into one commit, `Fix <title> (#n)`, with the cause in the message.
- **Output:** one fix commit. A comment on the issue records the cause.
- **Next:** `/ship`.

When `/build` calls `diagnose`, steps 1, 2, 5, 6 and 7 do not run. `/build` owns them.

### `/wizard [what to set up or migrate]`

Run it when a step needs a human: a key from a dashboard, a CI secret, or a one-off migration. The agent also runs it when work stops on such a step.

- **Input:** the procedure, and the repo: `.env*`, `docker-compose*`, the framework config and the `secrets.*` references in CI.
- **Process:**
  1. It lists the stages and the values of each stage. You confirm the list.
  2. It maps each stage to the exact clicks, from the docs or from you.
  3. It copies `template.sh` and writes one stage for each step.
  4. It checks the script with `bash -n` and a static trace. It does not run the script.
- **Output:** an executable bash script. You run it. It writes each value to `.env`, a GitHub secret or a GitHub variable, and lists what it could not do.
- **Next:** run the script. Delete it after the run, or commit it as a repeatable setup path.

## Skills that other skills call

You can run each of these alone. Other skills also call them.

| Skill | Called by | Job |
|---|---|---|
| `interview` | `/spec` | Interview in rounds of four questions or fewer on the design tree. Show recommendations and keep a decisions log. |
| `tdd` | `/build` | One red, green cycle per criterion, at the agreed seams, with a commit per green. One refactor pass at the end. |
| `refactor` | `/build` | Change the structure and keep the behavior, one named step at a time. |
| `resolve-conflicts` | `/ship` | Resolve a rebase conflict and keep both intents. Ask you only when both sides change the same behavior. |
| `worktree` | `/build`, `/diagnose` | Find or make the worktree, then provision it. |
| `pr` | `/ship` | Write the PR body: summary, evidence, merge danger. |

`prototype` is optional. Run it on its own, or let `/spec` call it when a question needs a demo to answer. It builds each prototype as one Claude artifact, for a UI question and for a logic question.

## Branches, worktrees and databases

| Thing | Rule |
|---|---|
| Branch | One per ticket or bug, `fix/<n>-<slug>`, from the trunk. It is one commit and one PR. |
| Primary checkout | `/build` uses it when it is clean and on the trunk. |
| Worktree | `/build` makes one when the checkout is busy, the plan has a migration, or you ask. It has its own folder, dev database fork and test database. |

To build two tickets at the same time, use two sessions. The second session finds the checkout busy and makes a worktree. `EnterWorktree` keeps a session in one worktree. A ticket sees the changes of another ticket only after that ticket merges, and `/ship` rebases onto the trunk.

## Labels

| Label | Set by | Read by |
|---|---|---|
| `idea` | `/issue` | `/build`, `/spec` |
| `spec` | `/spec` | `/build`, `/cleanup` |
| `bug` | `/issue`, `/diagnose` | `/build` |

Other labels change nothing. Blocked work uses native blocking links. Done work is a closed issue.

## How the set grows

- Run `/retro` about once a week. It reads each session since the last retro, in each project, where skills ran. It writes the findings to one file in `runs/` in this repo, with evidence and a proposed fix. Git ignores `runs/`, because a run file quotes the sessions of private projects.
- A finding that repeats across runs is fixed first. A fix commit names the finding ID and sets its status.
- A fix removes at least as many lines as it adds from the skill. A skill stays at about 80 lines.
- Add a skill only when a run shows a need for it.

## Layout

Each skill is in the folder of its phase. The number gives the order of the flow.

```text
skills/
├── 1-define/   spec, interview, prototype
├── 2-build/    build, tdd, refactor, resolve-conflicts, diagnose
├── 3-verify/   verify, ui-check
├── 4-ship/     ship, pr, cleanup
└── support/    ask, issue, research, setup-skills, worktree, retro, writing-for-agents, unslop, brief, wizard
```

A skill installs by its folder name only, for example `spec`. The phase folder groups skills and is not part of the name.

## Install

`install.sh` symlinks a skill. An edit in this repo is live at once.

```bash
./install.sh skills/1-define/spec  # one skill, into .claude/skills/ of the current project
./install.sh --all --global           # all skills, into ~/.claude/skills/
```

A plugin and `npx skills add` come later. See issue #3.

`ui-check` falls back to Chrome DevTools when the Claude in Chrome extension is not connected. Run the DevTools server with `--isolated`, so that each session gets its own Chrome and parallel checks do not collide. The `chrome-devtools-mcp` plugin shares one profile across all sessions, so turn it off and add the server yourself:

```bash
claude mcp add -s user chrome-devtools -- npx -y chrome-devtools-mcp@1.11.0 --isolated
```

Each isolated Chrome starts signed out, so you sign in once per Chrome. Keep the extension connected to avoid this, because it uses your own sign-ins. A fixed `--userDataDir` keeps a sign-in too, but two sessions then fight for one profile.
