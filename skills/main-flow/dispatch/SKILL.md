---
name: dispatch
description: "Drive one spec end to end: run each ticket in its own subagent on the spec branch, close each ticket as it commits, then hand the branch back green. Run as `/dispatch <spec>`, or under `/loop` when the spec has hitl checkpoints."
disable-model-invocation: true
argument-hint: [spec]
---

# dispatch — one spec, ticket by ticket

`/dispatch <spec>` drives one spec to a green branch. The spec is an issue number or a `.scratch/<slug>` path, resolved through the configured tracker (`docs/agents/issue-tracker.md`).

One spec = one worktree, one branch off the trunk. Every ticket commits to that branch, so the work is sequential by construction and there is nothing to integrate at the end. Dispatch opens no PR and merges nothing. It closes each ticket as it lands and hands the branch back; landing it is the human's.

Each ticket runs in its own subagent, so implementation context never enters this session and each ticket starts from a clean slate, sized for one context window as `/to-tickets` cut it. What comes back is the agent's report: a commit hash, or a failure.

**Run it under `/loop` when the spec carries hitl checkpoints** — `/loop /dispatch <spec>` — so the session outlasts the wait for the human. A spec with no checkpoints finishes in one pass and needs no loop.

Every pass reads what is committed from `git log`, so dispatch resumes where the last one stopped. Rerunning `/dispatch <spec>` after a checkpoint, a park, or a crash is the normal way to carry on.

## Vocabulary

- **Trunk**: the branch the repo merges into (`develop` on a git-flow repo, `main` otherwise); same rule as `/cleanup`.
- **Spec worktree**: `.claude/worktrees/<spec-slug>` on branch `<type>/<spec-number>-<spec-slug>`, created by `/implement` on the first ticket.
- **Committed**: a commit on the spec branch references the ticket (`#<n>`, or `NN-<slug>` on a local tracker). The commit is what closes it.
- **Frontier**: tickets whose blockers are all committed, that are themselves not committed, not parked, not hitl-held.
- **hitl**: a ticket carrying a `hitl` label (or `hitl` on its Status line) is a checkpoint. Dispatch stops before it. The human releases it by removing that label, so the release survives the session and any rerun picks the ticket up as ordinary frontier work.
- **Parked**: a ticket dispatch has stopped touching. Parked tickets are the human's; they unpark by saying so in the session.
- **Ledger**: the one line every pass ends on. It is what makes a live run tell itself apart from a dead one.

## 1. Read the state

Run `git fetch --all --prune`. From the tracker, list the spec's tickets in dependency order with their blocking edges. From `git log <trunk>..<spec-branch>`, mark which tickets are committed.

Completion: every ticket carries exactly one state — committed, frontier, blocked, hitl-held, or parked.

**The spec resolves to no tickets: say `Spec <spec> has no tickets` and stop.** A mistyped spec, a tracker `/setup-skills` never configured, and a spec whose tickets live somewhere else all look the same from here. Stopping loudly is the only way the human learns which one it is.

## 2. Drive the frontier

Take frontier tickets one at a time, in dependency order. Dispatch one subagent per ticket and **wait for its report before starting the next**; two agents on one branch collide.

> Work in the spec worktree `<path>` on branch `<spec-branch>`; create and provision it per the implement skill's Worktree step if it does not exist. Invoke the `implement` skill on ticket `<ticket>`. Commit with `<ticket ref>` in the message. Report back the commit hash, or the exact failure: a red suite after your remediation attempts, a conflict, a step you could not take.

- **Committed**: close the ticket — `gh issue close <n> --reason completed`, or set its Status to `done` on a local tracker — and post one status line to the conversation: `#<Y> <title> closed · <hash> · <n>/<total>`. Take the next frontier ticket.
- **Failed**: relaunch the same ticket once, with the previous report pasted into the task. A second failure parks it: post `#<Y> parked: <one-line reason>` and carry on with the rest of the frontier.
- **hitl**: post `#<Y> waiting for you (hitl)` naming what the human has to do, notify, and stop driving. Say that removing the `hitl` label releases it. Under `/loop`, keep ticking and re-read the label each tick; otherwise this pass ends here and a rerun resumes from the same place.

Completion: every frontier ticket is committed and closed, parked, or hitl-held.

## 3. Hand the branch back

Every ticket is committed or parked, and none is hitl-held. In the worktree, `git rebase <trunk>`. On conflict run `/resolving-merge-conflicts` there; finish the operation, and park the spec if it cannot finish. Run the full suite.

- **Green, nothing parked**: close the spec issue, push the branch, and report: branch name, ticket count, the suite result, and that the branch is ready to land. Notify `Spec <spec> ready: <branch>`.
- **Green, tickets parked**: push, leave the spec issue open, and report which tickets are parked and why. Notify `Spec <spec> blocked: <n> parked`.
- **Red**: park the spec with the failing test named in the report. Notify `Spec <spec> red: <test>`.

The human lands the branch and runs `/cleanup` afterwards.

## Status

Post a status line to the conversation on every ticket outcome and end every pass on the ledger:

`<spec> · <n>/<total> closed · <driving #Y | hitl #Y | parked: #Z | ready: <branch>>`

The conversation is the primary channel. Push a notification only when the run needs the human and they may be elsewhere: an hitl checkpoint, a parked spec, a red suite, a branch ready to land. Under `/loop`, report a noop only when the ledger is identical to the last tick's, and wake slowly — 1800 seconds or more — while the only thing outstanding is an hitl release.
