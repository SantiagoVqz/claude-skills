---
name: dispatch
description: "Drive one spec end to end: run each ready-for-agent ticket in its own subagent on the spec branch, close each ticket against its acceptance criteria as it commits, then ship the branch as a PR. Run as `/dispatch <spec>`, or under `/loop` when the spec has ready-for-human checkpoints."
disable-model-invocation: true
argument-hint: [spec]
---

# dispatch — one spec, ticket by ticket

`/dispatch <spec>` drives one spec to a green branch. The spec is an issue number or a `.scratch/<slug>` path, read through the configured tracker (`docs/agents/issue-tracker.md`). Its tickets are the ones `/to-tickets` published: sub-issues or issues whose Parent names the spec, or `.scratch/<slug>/issues/*.md` locally.

One spec = one branch off the trunk. Every ticket commits to that branch, so the work is sequential by construction and there is nothing to integrate at the end. Dispatch closes each ticket as its commit lands, and finishes by running `/ship`, which opens the PR. Dispatch merges nothing; the merge is the human's.

Each ticket runs in its own subagent, so implementation context never enters this session and each ticket starts from a clean slate, sized for one context window as `/to-tickets` cut it. What comes back is the agent's report: a commit hash, or a failure.

**All state lives on the tracker and in git, never in this conversation.** A rerun, a crash, or a fresh session reads the same picture. Rerunning `/dispatch <spec>` after a checkpoint or a crash is the normal way to carry on.

**Run it under `/loop` when the spec carries checkpoints** — `/loop /dispatch <spec>` — so the session outlasts the wait for the human. A spec with no checkpoints finishes in one pass and needs no loop.

## Vocabulary

- **Trunk**: the branch the repo merges into (`develop` on a git-flow repo, `main` otherwise); same rule as `/cleanup`.
- **Spec branch**: `<type>/<spec-number>-<spec-slug>` off the trunk.
- **Dispatch worktree**: `.claude/worktrees/dispatch`, one persistent worktree that dispatch owns. Subagents work there, so the primary checkout stays the human's.
- **Ticket ref**: `#<n>` on a real tracker, `NN-<slug>` on a local one. Every ticket commit carries it in the message; it is how git and the tracker are joined.
- **Done**: closed on the tracker (`Status: done` locally), by `close-ticket` after its commit. Only a done ticket unblocks its dependents.
- **Committed, open**: a commit on the spec branch carries the ticket ref but the ticket is still open. A crash between commit and close, or an unmet criterion, leaves a ticket here. It is reconciled before any new work starts.
- **Frontier**: open tickets labelled `ready-for-agent`, with no commit, whose blockers are all done.

Dispatch speaks only the five triage roles from `triage-labels.md`, so a ticket's state reads the same in `/triage` and here:

- `ready-for-agent`: dispatch may take it.
- `ready-for-human`: a checkpoint. Set by the human at `/to-tickets` time to stop dispatch before the ticket, or by dispatch when a committed ticket's unmet criterion only a human can verify. The human does the step and relabels `ready-for-agent`, or closes the ticket.
- `needs-triage`: dispatch failed the ticket twice and stopped touching it. The comment says why. The human relabels `ready-for-agent` to retry.

## 1. Read the state

1. **Worktree.** `git worktree list`. If `.claude/worktrees/dispatch` is missing, `git worktree add .claude/worktrees/dispatch <trunk>` and install dependencies the way the repo's README says. Every git command below runs with `-C .claude/worktrees/dispatch`.
2. **Clean tree.** `git status --porcelain` must be empty. A dirty dispatch worktree means a subagent died mid-ticket: stop, show the diff, and ask the human whether to keep it (commit it with the ticket ref) or drop it (`git checkout -- . && git clean -fd`).
3. **Branch.** `git fetch --all --prune`. Check out the spec branch; create it off `origin/<trunk>` if it does not exist. Then `git rebase origin/<trunk>`. The branch is unpushed until `/ship`, so the rebase is free. On conflict run `/resolving-merge-conflicts`.
4. **Tickets.** From the tracker, list the spec's tickets with state, labels, and Blocked by. From `git log <trunk>..<spec-branch>`, mark which tickets have a commit.
5. **Implement.** Locate the `implement` skill file: `.claude/skills/implement/SKILL.md`, else `~/.claude/skills/implement/SKILL.md`. Subagents read it by path, because a user-invoked skill cannot be reached through the Skill tool.

Completion: every ticket carries exactly one state: done, committed-open, frontier, blocked, `ready-for-human`, or `needs-triage`.

**The spec resolves to no tickets: say `Spec <spec> has no tickets` and stop.** A mistyped spec, a tracker `/setup-skills` never configured, and a spec whose tickets live somewhere else all look the same from here. Stopping loudly is the only way the human learns which one it is.

## 2. Reconcile committed-open tickets

Before any new ticket starts, settle every committed-open one, oldest commit first. Run `close-ticket` on it with its commit hash.

- **Done**: post `<ref> <title> done · <hash>`. Continue.
- **Open, unmet criteria the agent can meet**: relaunch the same ticket once, with the unmet criteria pasted into the task, so the second run builds on the first commit. Still open after that: relabel `needs-triage`, comment the unmet criteria, post `<ref> needs triage: unmet <criterion>`.
- **Open, a criterion only a human can verify** (close-ticket says so): relabel `ready-for-human`, comment the criterion, post `<ref> needs you: <criterion>`, and continue with tickets that do not depend on it.

Completion: no ticket is committed-open.

## 3. Drive the frontier

Take frontier tickets one at a time, in dependency order. Record `git rev-parse HEAD` as the ticket's fixed point. Dispatch one subagent per ticket and **wait for its report before starting the next**; two agents on one branch collide.

> Work in the worktree `.claude/worktrees/dispatch` on branch `<spec-branch>`. Read `<implement path>` and follow it for ticket `<ticket ref>`, whose body follows. The tracker is described in `docs/agents/issue-tracker.md`. When it says to use `/code-review`, the fixed point is `<hash>`. Commit with `<ticket ref>` in the message. Then invoke the `close-ticket` skill on `<ticket ref>` with that commit hash. Report back the commit hash and the close result (done, or the unmet criteria verbatim, or that a criterion needs a human), or the exact failure: a red suite after your remediation attempts, a conflict, a step you could not take.
>
> <ticket body>

- **Done**: post `<ref> <title> done · <hash> · <n>/<total>`. Take the next frontier ticket.
- **Committed, still open**: handle as in step 2.
- **Failed, nothing committed**: check the worktree is clean (step 1.2 rule); then relaunch the same ticket once, with the previous report pasted into the task. A second failure relabels `needs-triage` with the reason as a comment: post `<ref> needs triage: <one-line reason>` and carry on with the rest of the frontier.

A ticket blocked by a `ready-for-human` or `needs-triage` ticket is not frontier. When nothing is frontier and something is `ready-for-human` or `needs-triage`, this pass ends: post the list, notify, and say what releases each one. Under `/loop`, keep ticking and re-read the labels each tick; otherwise a rerun resumes from the same place.

Completion: every ticket is done, or the only open tickets are `ready-for-human`, `needs-triage`, or blocked by one of those.

## 4. Ship the branch

Every ticket is done. Invoke the `ship` skill on the spec. Ship rebases onto the trunk, runs the full suite, pushes, and opens the PR. Relay ship's report.

- **Shipped**: notify `Spec <spec> shipped: <PR url>`.
- **Red**: ship stopped before the push. Report the failing test. Notify `Spec <spec> red: <test>`. The branch stays as it is; the human fixes it in the dispatch worktree and reruns `/ship`.

The human merges the PR and runs `/cleanup` afterwards.

## Status

Post a status line to the conversation on every ticket outcome and end every pass on the ledger:

`<spec> · <n>/<total> done · <driving <ref> | ready-for-human: <ref> | needs-triage: <ref> | shipped: <PR url>>`

The conversation is the primary channel. Push a notification only when the run needs the human and they may be elsewhere: a checkpoint, a ticket that needs triage, a red suite, a shipped PR. Under `/loop`, report a noop only when the ledger is identical to the last tick's, and wake slowly — 1800 seconds or more — while the only thing outstanding is a human release.
