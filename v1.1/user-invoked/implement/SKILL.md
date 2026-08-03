---
name: implement
description: "Implement a spec or set of tickets — each ticket built as a gated slice and committed straight to the feature branch."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

**One spec → one worktree → one feature branch → one gated commit per ticket.** Two units:

- **worktree** — the parallel unit. One per spec, worked alongside other specs.
- **feature branch** — the only branch. Cut once off the trunk; every ticket lands on it as one commit through the slice gate below. It first reaches origin when `/spec-done` opens its PR — nothing is pushed before that.

Ticket N+1 starts after ticket N's commit landed, so the blocking edges from `/to-tickets` are held by the commit history — nothing has to be unlocked, and no rebase cascades.

**Light mode — work too small for a spec.** Skip the worktree: cut one branch (`<type>/<slug>`) off the trunk in the primary checkout, run the same slice loop, then end it yourself — `git push -u origin <branch> && gh pr create --base <trunk>` — and **stop**; merging is the user's call. No `/spec-done`, no `/cleanup`.

## Step 0 — Enter the spec

Done **once per spec**, not per ticket. It leaves you standing in a provisioned worktree on a fresh feature branch.

- **No worktree yet** — create one off the trunk, on the feature branch:

  ```bash
  git fetch origin
  git worktree add ../<repo>-<feature> -b <type>/<feature> origin/<trunk>
  ```

  Fetch first so the branch cuts from the current trunk. Don't push — the branch stays local until `/spec-done`.

- **Worktree exists** — `git worktree list` names it. Move there; `git log <trunk>..<type>/<feature>` shows which tickets already landed.

**Provision — once, here.** A fresh checkout lacks what a worktree needs, and everything provisioned at this step is **shared by every ticket in the spec**: env files, dev-server ports, dev DB. `/cleanup` reclaims it all at the end.

**Prefer the repo's provisioner:** if `scripts/provision.sh` exists, run it — it owns this repo's worktree setup and is expected to be idempotent. **Otherwise** copy every gitignored env file from the primary checkout (the `git worktree list` entry whose `.git` is a directory, not a file) into the same path here — `.env`, `.env.*`, and any nested ones.

**Migration guard.** About to add a DB migration while the worktree still shares the primary's dev DB? Isolate the DB first, or divergent migrations across branches corrupt the shared schema. If the repo ships `scripts/provision.sh` with a per-worktree-DB mode (e.g. `scripts/provision.sh db`), run that; otherwise follow the repo's own convention for an isolated dev DB before migrating. One DB per **worktree**, not per ticket.

Completion: you are standing in the spec's worktree, provisioned, with the feature branch cut off the trunk.

## Step 1 — The slice loop

Run once per ticket, directly on the feature branch. It is a **ritual** — pre-approved, run start to finish without asking permission between steps.

Build **one ticket per pass** — the ticket is already sized for one fresh context window, so don't subdivide. If a ticket turns out genuinely too large for one reviewable commit, split the *ticket* on the tracker, rather than quietly stretching one commit to cover both.

1. **Build** — use /tdd where possible, at the seams the spec pre-agreed.
   Completion: every acceptance criterion on the ticket demonstrably works.

2. **Gate — fire all three passes from a SINGLE turn.** The slice's diff is the uncommitted working tree (`git diff` / `git diff --name-only`); gather the check commands first — **mirror the repo's own checks, don't invent them** (`.github/workflows/*` first, then manifest scripts, run through the package manager the lockfile names), scoped to the diff's **blast radius**: the files this ticket touched plus their callers. Then dispatch the `Explore` sub-agent and every check command together — they run in the background — and invoke `/simplify` inline in the same turn while they execute:

   - **Cold-read** — a fresh `Explore` agent with NO context beyond the changed-file list. Its brief is the **residue** of the edit — what the change left behind, not the code's overall quality: naming drift, half-applied renames, discriminants collapsed to `string`, dead fallbacks, orphaned callers.
   - **Simplify** — `/simplify` scoped to the slice's diff. Quality, not residue: reuse, needless indirection, wrong altitude. It cannot see duplication *against other tickets* — that stays `/spec-done`'s job. The full suite is also `/spec-done`'s — one run, at the boundary that can act on it.
   - **Checks** — the scoped commands.

   Completion: all three have reported, dispatched from one turn.

3. **Triage** — fix the real cold-read flags and apply the simplify cleanups; dismiss false positives with a reason. Fix check failures **this ticket caused**; pre-existing failures get reported, never fixed silently. If a fix touched logic, re-run the checks that cover it.
   Completion: every flag fixed or dismissed with a reason, every check green or attributed (this-ticket → fixed, pre-existing → reported).

4. **Commit — one commit, full body.** With no per-ticket PR, the commit message *is* the ticket's record; `/spec-done` walks it for traceability and assembles the spec PR from it. Summary line in the repo's log style, then:

   ```
   <short present-tense summary>

   Stories: <the spec's user-story numbers this ticket satisfies>
   Decisions: <judgement calls a reader can't recover from the diff — a seam
   chosen, an alternative rejected, a constraint discovered. Omit if none.>

   Ticket: #<issue>
   ```

   Completion: working tree clean, one commit for the ticket on the feature branch.

5. **Close the ticket issue** — the tracker `/setup-skills` recorded is the single source of truth; update it and nothing else. GitHub/Linear/Jira: take `ready-for-agent` off, then `gh issue close <n> --reason completed --comment "Landed on <feature-branch> in <commit>."` Local markdown: tick the acceptance-criteria checkboxes, set **Status** to `done`. The ticket closes **here**, at the commit — the moment its work is available to build on, which is what resolves the blocking edge; shipping is the spec's closure (`/cleanup`), a different altitude.
   Completion: the tracker shows this ticket closed, updated in exactly one place.

6. **Report** — one line: ticket · check results · cold-read findings and disposition · simplify cleanups · commit hash · issue closed · next ticket, or "last ticket → /spec-done".

Then **clear context** (or `/handoff`) and start the next ticket's slice loop fresh.

## Close out

`/spec-done` is user-invoked — you can't fire it. When the last ticket's commit lands, **prompt the user to run /spec-done**: it walks traceability, rebases onto the trunk, runs the full suite and cross-ticket simplify, reviews against the spec, then pushes the branch and opens its PR — where the user verifies in the worktree and merges by hand.
