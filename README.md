# Skills

This is a skill set for Claude Code. It takes work from an idea or a bug to a merged pull request. It works for one person and for a team.

The set has two entry points:

- `/spec` starts a feature.
- `/diagnose` starts a bug fix.

`/issue` files work for later: an idea, a bug, a task or a follow-up. Each entry point can start from its issue.

Each phase has one command. Each command reads the output of the command before it. The tracker holds the work: GitHub Issues or Linear.

## The flow

`/prd` is the setup-free path. It writes a PRD, and tickets if you want them, in any repo. `/issue`, `/diagnose`, `tdd` and `refactor` also run with no setup: they use the fallbacks in `NO-SETUP.md`, in the folder of `setup-skills`.

```text
Feature:  /spec ──► /build ──► /ship ──► you merge ──► /cleanup
                     │           └─ PR, then CI
                     ├─ plan: phases, one approval
                     ├─ each phase: implementer, then /verify
                     └─ final-review: you iterate at its card

Project:  /spec ──► the Feature flow from /build, once per child spec, in blocking order

Bug:      /diagnose ──► /ship ──► you merge ──► /cleanup
             └─ runs /verify

One-off:  /issue ──► /build ──► /ship ──► you merge ──► /cleanup
                      └─ one phase, then final-review

Once per repo:  /setup-skills
End of the day: /retro
Not sure:       /ask
```

## Commands

### `/ask`

Run it when you do not know which command is next. The agent also runs it when work starts and no command was named.

- **Input:** your request and the state of the repo: setup, branch, issue, PR and any git conflict.
- **Output:** the next command, the facts that chose it, and the command after it. It changes nothing.

### `/issue [idea | bug | task] [what it is]`

Run it when you want to track work, or when you start work that has no issue. `/spec`, `/prd`, `final-review`, `/diagnose` and `interview` also call it to publish their issues.

- **Input:** your words, and what the conversation already found: an `/ask` route, a diagnosis, a screenshot. One request can hold several issues.
- **Process:**
  1. It finds the kind of each issue: idea, bug or task. It fills the template of the kind from the conversation and the code, and asks three questions at most for each issue.
  2. It finds the order between the issues, such as a bug that must be fixed before an idea.
  3. It searches the open issues for duplicates.
  4. It shows each draft. You approve before it files anything.
- **Output:** each issue with its label and blocking edges. An idea gets `idea`, a bug gets `bug`, and a task gets one `approach:` label. A bug body has the symptom, the steps, the facts, the hypotheses to rank, the open question for the fix and where to look. A screenshot goes in as text, and you drag the image in after.
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

Run it once per repo.

- **Input:** the repo.
- **Output:** the `## Agent skills` block in `AGENTS.md`, the tracker reference file for GitHub or Linear, the labels, `scripts/provision.sh`, and the session hook that runs it.
- **Next:** every other command reads the `## Agent skills` block to find the tracker.

### `/spec`

- **Input:** an idea.
- **Process:** it calls `interview` to interview you, one question at a time. Each question is one sentence with a recommendation. The interview asks how the feature behaves, and the agent writes the user stories from your answers. When the spec touches a screen, it asks whether to prototype the look, and records the chosen variant.
- **Size:** a spec is one feature a user can demo, and one PR a reviewer reads in one sitting, about 2000 lines or fewer. A bigger idea becomes a project: a parent issue with 2 to 5 child specs. Each child spec is a vertical slice that ships alone, cut by user value, never by layer.
- **Approval:** one list of what you approve: problem, scope, out of scope, seams, schema, look, the story titles and the new terms and ADRs. For a project, one block per child spec.
- **Output:** a spec issue with the `spec` label, or a project issue with the `project` label and its child specs as sub-issues with blocking links. A `Domain changes` section holds the new glossary terms and ADRs. It makes no branch, no worktree and no commit.
- **Next:** `/build <n>`, for the spec or for each child spec with no open blocker.

### `/prd`

It needs no `/setup-skills`. It works in any repo.

- **Input:** an idea or an issue.
- **Process:** it calls `interview` to interview you, the same as `/spec`. You approve the draft. You pick where it goes.
- **Output:**
  - The PRD, as a GitHub issue or as markdown that you paste into Linear, Jira or a doc.
  - If you want them, tickets: sub-issues with native blocking links, or a numbered list in the markdown.
  - No branch, no worktree, no database, no labels and no commits.
- **Next:** you start the tickets that have no blockers.

### `/build <spec | ticket>`

One `/build` plans and builds a whole spec. Your session orchestrates, and subagents do the heavy work, so the session's context stays small.

- **Input:** a spec, or a lone ticket. A lone ticket has no parent spec, and builds as one phase on a `fix/<n>-<slug>` branch.
- **Process:**
  1. It stops when a blocker is open. When someone else has the issue, it asks whether you take it over. It sets the issue to in progress and assigns it to you.
  2. A planner subagent cuts the spec into phases, with the rules in `PLAN.md`. A spec is one phase by default. It splits only at a named boundary: a prefactor, or work too big for one implementer's context. Each phase is a vertical slice, with an approach, its stories and its done-when criteria. You approve the plan once, and it goes on the spec issue as a comment. A spec that has a plan skips this.
  3. It calls `worktree` to make the branch `spec/<n>-<slug>` from the trunk, in its own worktree. When the branch has phase commits, it resumes after them. It commits the spec's new terms and ADRs first.
  4. For each phase, an implementer subagent runs the skill that the phase's approach names: `tdd`, `refactor` or `diagnose`. A question from the subagent comes to you, and your answer goes back to the same subagent.
  5. A fresh subagent runs `/verify` on the phase diff. The implementer fixes the hard findings, three verify runs at most. When a hard finding remains, it stops. You fix it, or you override it with a reason.
  6. It squashes the phase into one commit, with each criterion and its test in the message, and pushes it. You get one line per phase, and no question.
  7. After the last phase, it calls `final-review`. You iterate at its card, for example on a design.
- **Output:** the plan comment, one commit per phase on the branch, and the review comment.
- **Next:** `/ship`.

### `/verify [ref]`

`/build`, `final-review` and `/diagnose` run it in a subagent. You can also run it on any diff.

- **Input:** a diff and the criteria of its phase or issue.
- **Checks:** it runs the typecheck, lint, build and the tests that the diff touches itself. It runs the full suite when the caller asks, or when you run it. It checks the diff against the criteria and the spec's seams, then against the repo's written rules and a list of code smells.
- **Output:** findings. A hard finding blocks the phase: a failed check, a criterion with no test, a test at the wrong seam, a broken written rule, a defect a user can see, or work that is not a vertical slice. Everything else is a judgment call, and it reports the top five. It edits nothing.

### `/ui-check [issue | what to check]`

You run it when you want a browser check. `final-review` runs it to walk the stories. Each run starts a dev server.

- **Process:** it starts the dev server and does the main flow of the change in Chrome, five steps or fewer. For `final-review`, it does one step per story. It uses Claude in Chrome, or Chrome DevTools when the extension is not connected. The server and the tab stay open until you answer.
- **Data:** when the worktree database lacks the rows that the flow needs, it makes the fewest rows, through the seed script or the API.
- **Output:** the flow before the run, then a "Verified" list, one line per step, and a "Check yourself" list of three steps or fewer. You approve or ask for a change.

### `/final-review <spec | ticket>`

`/build` runs it after the last phase. You can run it on its own, for example after a commit that came after the review. Each phase already passed `/verify`, so it checks only what the whole branch shows.

- **Checks:**
  - **Checks of the repo:** a subagent runs the full suite, typecheck, lint and build.
  - **Coverage:** each user story has a phase and a test, from the phase commits.
  - **Walk:** when you pick "Walk in browser" at the card, `/ui-check` does one step per story. It never runs on its own.
- **Gaps:** each gap is blocking or cleanup. A blocking gap is a failed check, a story with no test, a failed walk step, or a defect a user can see. Everything else is cleanup.
  - It fixes each blocking gap in the same run: an implementer subagent with `tdd`, then `/verify`, then the failed check again. Two fix rounds at most. A gap never needs another `/build`.
  - A cleanup is "Skip", on the card, or "Later", one lone ticket that ships on its own.
- **Iterate:** at the card, pick Change and say what to change, such as a design tweak. Each change gets a fix round with `/verify`, then the card comes back.
- **Output:** one card with the stories, the gaps it fixed, the walk and the cleanups. You approve it once. Then it posts the card as a comment on the issue, with the reviewed commit and the full story list in a collapsed block.
- **Next:** `/ship`.

### `/ship [spec | issue]`

It reviews nothing. `/build` closed with the review, and CI runs the checks.

- **Input:** a spec or lone ticket with an approved review comment, or a fix branch from `/diagnose`.
- **Process:**
  1. It reads the latest review comment. It stops when the branch has a commit after the reviewed commit.
  2. It rebases onto the trunk. On a conflict, it calls `resolve-conflicts`, then a fresh `/verify`.
  3. It writes the PR body with `pr`. It runs the checks locally only when the repo has no CI. The evidence is text: story, test and the "Verified" line.
  4. It pushes and opens the PR, ready for review. You get a short summary of what changed and why, not the body.
  5. It waits for CI to pass. It reports a failure and fixes nothing.
- **Output:** one PR with `Closes #<n>`.
- **Next:** you merge with rebase and merge, so each phase stays one commit on the trunk. Then `/cleanup`.

### `/cleanup [spec | issue]`

Run it after you merge.

- **Input:** a spec or fix branch with a merged PR. It stops on an open PR or no PR.
- **Process:** it closes the issue that the PR closes, when it is still open, and the project when its last child spec closes. It removes the worktree with `worktree`, deletes the local and remote branches, refreshes the trunk, and applies the new migrations to the trunk dev database.

### `/diagnose <bug>`

- **Input:** a Sentry link, a pasted error, or an issue.
- **Process:**
  1. If the input is not an issue, it creates an issue with the `bug` label through `issue`. If the input is an issue, it starts from its facts, hypotheses and places to look. With no setup, it uses `NO-SETUP.md`: with no tracker it keeps the issue text in the report.
  2. It calls `worktree` to make a fix branch, `fix/<n>-<slug>`, from the trunk. When the repo is not set up for worktrees, it makes the branch in a clean primary checkout, or leaves the fix uncommitted.
  3. It builds a feedback loop that goes red on the bug, and minimises the repro. When a person must reproduce the bug, `/ui-check` tries first, then it asks you one step at a time.
  4. It ranks 3 to 5 hypotheses, and you pick the first one to test. It instruments the code, fixes the cause with a regression test, and cleans up.
  5. It runs `/verify` in a subagent, the same as `/build`.
  6. It shows a card: cause, fix, test and judgment calls. You approve, ask for a change, or ask for `/ui-check`.
  7. It squashes the branch into one commit, `Fix <title> (#n)`, with the cause in the message.
- **Output:** one fix commit. A comment on the issue records the cause.
- **Next:** `/ship`.

When `/build` calls `diagnose` for an `approach:diagnose` phase or ticket, steps 1, 2, 5, 6 and 7 do not run. `/build` owns them.

## Skills that other skills call

You do not type these. Other skills call them.

| Skill | Called by | Job |
|---|---|---|
| `interview` | `/spec`, `/prd` | Interview one question at a time on the design tree. Show a recommendation and a progress count. Keep a decisions log. |
| `tdd` | `/build`, `final-review` | One red, green cycle per criterion, at the seams that the spec agreed, with a commit per green. One refactor pass at the end. |
| `refactor` | `/build` | Change the structure and keep the behavior, one named step at a time. Pin tests come first, and no expected value changes. |
| `final-review` | `/build` | Review the whole branch, fix the blocking gaps, and post the review comment. You can also run it. |
| `resolve-conflicts` | `/build`, `/ship` | Resolve a rebase conflict and keep both intents. Ask you only when both sides change the same behavior. |
| `worktree` | `/build`, `/diagnose` | Find or make the worktree, then provision it. |
| `pr` | `/ship` | Write the PR body: summary, evidence, merge danger. |

`prototype` is optional. Run it on its own, or let `/spec` and `/prd` call it when a question needs a demo to answer. It builds each prototype as one Claude artifact, for a UI question and for a logic question.

## Branches, worktrees and databases

| Thing | Rule |
|---|---|
| Spec branch | One per spec, `spec/<n>-<slug>`, from the trunk. `/build` makes it. Each phase is one commit on it. It is the one PR. |
| Fix branch | One per bug or lone ticket, `fix/<n>-<slug>`, from the trunk. |
| Primary checkout | It stays on the trunk. Code work never happens here. |
| Dev database | Each branch gets its own fork of the trunk dev database. |
| Test database | Each worktree gets its own. |

### Parallel specs

Git checks out a branch in one place only. Two different branches can be checked out at the same time in two different worktrees. Thus each spec has its own worktree, and the primary checkout stays on the trunk.

Example, with specs 12 and 15 in progress at the same time:

```
repo/                                  trunk (primary checkout)
.claude/worktrees/spec-12-foo          spec/12-foo
.claude/worktrees/spec-15-baz          spec/15-baz
```

Each worktree is a separate folder with its own branch, its own dev database fork and its own test database. The two specs share nothing until one of them merges into the trunk.

- **Sessions:** `EnterWorktree` keeps a session in one worktree. To build two specs at the same time, use two sessions.
- **Conflicts between specs:** a spec sees the changes of another spec only after that spec merges. `/ship` rebases onto the trunk and resolves the conflicts with `resolve-conflicts`.
- **Migrations:** each spec migrates its own fork, so parallel specs do not interfere.

## Labels

| Label | Set by | Read by |
|---|---|---|
| `idea` | `/issue` | `/spec`, `/prd` |
| `project` | `/spec` | `/build`, `/cleanup`, `/ask` |
| `spec` | `/spec` | `/build`, `final-review`, `/ship`, `/cleanup` |
| `bug` | `/issue`, `/diagnose` | `/ship`, `/cleanup` |
| `approach:tdd`, `approach:refactor`, `approach:diagnose` | `/issue`, for a task | `/build` |
| `in-progress` | `/build` | you and your team |

A phase's approach lives in the plan comment, not in a label. On Linear, `/build` sets the native In Progress status. It does not use the `in-progress` label. Blocked work uses native blocking links. Done work is a closed issue.

## How the set grows

- Run `/retro` at the end of a day of work. It reads each session since the last retro, in each project, where skills ran. It writes the findings to one file in `runs/` in this repo, with evidence and a proposed fix. Git ignores `runs/`, because a run file quotes the sessions of private projects. The Sessions list of each run file records the lines it read, so no line is read twice.
- A finding that repeats across runs is fixed first. A fix commit names the finding ID and sets its status.
- Fix the skill after each run. Do not fix it by prompting again.
- Add a skill only when a run shows a need for it.
- Add a row to an anti-rationalization table only when a run shows a new excuse. These tables are in `build`, `tdd`, `refactor`, `diagnose`, `verify`, `final-review`, `worktree`, `cleanup` and `setup-skills`.
- Put each engineering principle in the one skill where it applies.

## Layout

Each skill is in the folder of its phase. The number gives the order of the flow.

```text
skills/
├── 1-define/   spec, prd, interview, prototype
├── 2-build/    build, tdd, refactor, resolve-conflicts, diagnose
├── 3-verify/   verify, ui-check, final-review
├── 4-ship/     ship, pr, cleanup
└── support/    ask, issue, research, setup-skills, worktree, retro, writing-for-agents, unslop, brief
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

Each isolated Chrome starts signed out, so you sign in once per check.
