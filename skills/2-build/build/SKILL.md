---
name: build
description: "Plan a spec as phases, then build them in one worktree, with an implementer and a verify subagent per phase, then the final review. Also builds a lone ticket as one phase."
disable-model-invocation: true
argument-hint: "<spec | ticket>"
---

# Build

`/build` plans a spec as phases, gets one approval, and builds every phase in one run. It ends with the spec branch in its own worktree, one commit per phase, pushed, and the user's approval from `final-review`. The user iterates at the review card: each change they ask for gets a fix round before the approval. A **lone ticket** has no parent spec. It is a plan of one phase, with the ticket's criteria, on its own `fix/<n>-<slug>` branch, ready for `/ship`.

This session is the **orchestrator**. It holds the plan, the phase reports and the questions to the user. Subagents do the heavy work, each in a fresh context, so this context stays small across many phases:

- The **planner** drafts the plan.
- The **implementer** builds one phase with the approach skill, and fixes what verify finds.
- The **verifier** runs `verify` on the diff of one phase.

The orchestrator reads reports, `git log` and `git status`. It reads no source file and runs no test itself. Each file it reads stays in its context for every later phase.

Run one subagent at a time. Two test suites at once share one test database and can stall for most of an hour.

Each subagent prompt names the worktree path and pastes these **shell rules**:

> Run one plain shell command per call, from the worktree root, on paths in the worktree. For a subfolder, use a flag such as `pnpm --dir` or `uv --directory`, because a `cd` stays in effect for the rest of the session. Change a file with the Edit tool, and make a new file with the Write tool. Quote each argument that holds `*`, `[` or `]`. The guard refuses only some other forms, such as a `&&` chain, `$(...)` or a heredoc, so a command that ran is no proof that its form is safe. Print no value from an env file, because a line such as `PROD_DATABASE_URL` holds a password. To see which variables a file sets, list the names only: `grep -oE '^[A-Z_]+=' <file>`.

The orchestrator follows the same rules after `EnterWorktree`.

## 1. Start

Read the `## Agent skills` block in `AGENTS.md`, then `docs/agents/tracker.md`. When the block is missing, tell the user to run `/setup-skills`, and stop. When the argument is not an issue number or an issue URL, such as a few ideas in words, stop and tell the user to file it with `/issue` first. Read the issue with its comments.

Find the kind of issue:

- **Spec**, an issue with the `spec` label. Its plan is the latest comment that starts with `### Plan of #<n>`, or step 2 drafts it.
- **Lone ticket**, an issue with an `approach:` label and no parent: the plan is one phase. Its title is the ticket title, its approach is the label, and its criteria are the ticket's acceptance criteria. Skip step 2.
- **Project**, an issue with the `project` label: stop. Name its child specs that have no open blocker. The next step is `/build <spec>` for one of them.
- **Ticket of a spec**, a sub-issue from before phases: stop. The next step is `/build <spec>`, which takes the open tickets into the plan.
- **Any other issue**: stop, because it has no agreed criteria to build against. Name the next step from its label: `/spec <n>` for an `idea`, `/diagnose <n>` for a `bug`, and `/issue` to give it a kind when it has no label.

Then check:

- **Blocked**: an issue in `blockedBy` is open. Stop, and name it.
- **Assigned to someone else**: ask with the question tool: "Take over" or "Stop". On Take over, assign the issue to the user.
- **Approach skill missing**: the approach skill has the name of the approach value, so `approach:tdd` runs `tdd`. When the skill of a phase is not installed, stop, and name it.

Set the issue to in progress, as `tracker.md` says.

Completion: the issue is in progress, assigned to the user, and has no open blocker. You know its kind.

## 2. Plan

Skip this step when the spec has a plan comment and no open ticket from before phases.

Start the planner: a subagent with a fresh context. Its prompt has the spec issue number and this task: read [PLAN.md](PLAN.md) in the folder of this skill, the spec issue with its comments and sub-issues, the glossary and ADRs on the trunk, and the code in the area that the spec touches; then return a plan in the format of `PLAN.md`. Tell it:

- A phase that has a commit on `origin/spec/<n>-<slug>` stays as it is. Find them with `git log --format='%(trailers:key=Phase,valueonly)' origin/<trunk>..origin/spec/<n>-<slug>`, when that branch exists.
- A closed ticket from before phases covers its stories. Each open ticket becomes the input of a phase.

Write the plan in your message, before the question. The user approves what they can read. Ask with the question tool: "Approve" or "Change". On Change, apply the edits, show the plan again and ask again.

On Approve, post the plan as a comment on the spec issue, as `tracker.md` says. Close each open ticket that a phase took over, with the comment `Planned as phase <k>: <comment URL>`.

Completion: the plan comment is on the spec issue, and you have each phase with its approach and criteria.

## 3. Enter the worktree

The branch is `spec/<n>-<slug>` for a spec, and `fix/<n>-<slug>` for a lone ticket. Call the Skill tool with `worktree` for it, made from the trunk. It finds the branch when it exists, also when it is only on the remote, and makes it when it does not.

Find the built phases with `git log --format='%(trailers:key=Phase,valueonly)' origin/<trunk>..HEAD`. Each value, such as `2/3`, names a phase that has its commit. When `git status` shows a rebase in progress, call the Skill tool with `resolve-conflicts` first. Commits or changes after the last phase commit are a phase in progress: its implementer starts from them.

For a spec with a `Domain changes` section, and no commit `Record terms and decisions for #<n>` on the branch, write the terms and ADRs of that section with [DOCS-FORMAT.md](DOCS-FORMAT.md). Add nothing else. Commit: `Record terms and decisions for #<n>`.

Completion: the session is in the worktree, the domain changes are committed or the spec has none, and you know the first phase to build.

## 4. Build each phase

Take each phase with no commit, in the order of the plan. For each phase:

1. **Start.** Record the phase start: `git rev-parse HEAD`.
2. **Implement.** Start a subagent with a fresh context. Its prompt has the worktree path, the shell rules, the issue number, the phase block from the plan word for word, the phase start, and this task: call the Skill tool with the approach skill for this phase, and return the approach skill's report. When the approach skill says to ask the user, the subagent stops and returns the question with its recommendation, because a subagent cannot reach the user. Ask that question with the question tool, then send the answer to the same subagent with `SendMessage`, so it resumes with its context.
3. **Verify.** Start only when the implementer returned its report and none of its checks still runs. Start a new subagent with a fresh context. Tell it to call the Skill tool with `verify`, with the issue number, the phase's criteria and the diff `<phase start>...HEAD`. Give it no list of checks to skip.
4. **Fix.** Send each hard finding, word for word, to the implementer with `SendMessage`. It fixes, commits, and after a fix for a word or a name greps `git diff <phase start>...HEAD` for each form of it. Then run a new verifier. Run three verifiers or fewer for each phase. When the third run still has a hard finding, stop. Show the findings. The issue stays in progress and the worktree stays. The user fixes it, or overrides it with a reason.
5. **Land.** Squash the phase into one commit: `git reset --soft <phase start>`, then `git commit` with one `-m` flag per paragraph:
   - `<phase title> (#<n>)`
   - one line for each criterion: `<criterion> · <test name>`, from the implementer's report
   - `Open judgment calls:`, then one line for each call of the last verify run, as verify gave it
   - `Override: <reason>`, when the user gave one
   - `Phase: <k>/<total>`, as the last paragraph, so git reads it as a trailer

   For a spec, push the branch: `git push -u origin <branch>`. A lone ticket stays local until `/ship`.
6. **Report.** Send one line to the user: `Phase <k>/<total> · <title> · <criteria count> criteria · <verify runs> verify runs · <short hash>`.

Completion: each phase of the plan has its commit with its `Phase:` trailer, and the user has one line for each phase.

## 5. Review

Call the Skill tool with `final-review`, with the issue number. It runs in this session, because its card and its approval need the user. It runs the checks, proves the stories, fixes each blocking gap and each change the user asks for, and posts the review comment that `/ship` reads.

Completion: `final-review` posted its review comment.

## Excuses

| Excuse | Answer |
|---|---|
| "The guard allowed the command." | The guard checks only some forms. Use the Edit tool, the Write tool, and one plain command per call. |
| "The second verify found the same word, so one more fix is enough." | The implementer greps the diff for each form of the word, then a new verifier runs. Three runs is the limit. |

Add a row only when `/retro` finds a new excuse.

## Report

Issue · plan comment URL · branch and worktree path · each phase with its commit · override reasons · review comment URL · what this session stopped, and what still runs, such as a database container or a browser · next step: `/ship <n>`.
