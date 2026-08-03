---
name: ticket-done
description: "Close out one ticket — a cold-read and scoped checks fired in parallel, commit, publish (its own PR where stacked), open the next. The tight per-ticket gate."
disable-model-invocation: true
---

# ticket-done — seal one ticket

Run this **once per ticket**, then start the next — or hand to `/feature-done` when the ticket was the feature's last.

The ticket is sized for exactly this: `/to-tickets` cuts each one to a vertical slice that fits a single fresh context window, which is the same thing as a PR someone reads in one sitting.

**Two shapes**, decided by the delivery shape `/setup-skills` recorded, and every publish step below branches on it:

- **Stack** (stacked PRs enabled) — **one ticket = one layer = one PR.** Each ticket seals as its own branch and becomes reviewable the moment it does.
- **Solo** (not enabled) — **one feature = one branch = one PR.** Tickets are commits on it; the feature's single PR is opened at the end by `/ship`. You trade per-ticket review for needing no extension — that trade *is* what stacking buys, so if reviewing tickets one at a time matters, enabling stacked PRs is the fix, not a workaround here.

This gate is **tight** — scoped, parallel, no human in it. It runs on every ticket, so anything that scales with the *feature* rather than the *diff* belongs to `/feature-done` instead: the full suite, `/simplify`, spec conformance. Here you verify the slice you just wrote and get it in front of a reviewer.

It is a **ritual** — pre-approved, run start to finish. Do NOT ask for permission between steps; skipping the asking is the reason it exists.

**It is also a context checkpoint.** Every step runs against the ticket's bounded diff or hands off to a fresh sub-agent, so the ritual costs the main window very little — and once it returns, the ticket is committed, verified, and pushed (stacked, already its own PR). That's durable state outside your context. Clear or `/handoff` right after it returns and pick up the next ticket from where the branch left off.

## Steps

1. **Load the gun** — the two verification passes are independent, so gather both their inputs before either runs. Neither costs anything to prepare:

   - **The changed-file list** — `git diff --name-only <ticket-base>`. This is the cold-read's entire brief.
   - **The check commands** — the repo already defines what "green" means; **mirror its own checks, don't invent them.** Find them in order of authority: `.github/workflows/*` first (the source of truth), then manifest scripts (`package.json`, `Makefile`/`justfile`, `pyproject.toml`), run through the package manager the lockfile names.

     Scope each to **the diff's blast radius**: the files this ticket touched plus their callers. Typecheck and lint the changed paths; run the test files that cover them. The full suite is `/feature-done`'s job — one run, at the boundary that can act on it.

   Completion: you can state the changed-file list and the exact command line for every check, with neither dispatched yet.

2. **Fire both passes in a SINGLE message.** Put the `Explore` sub-agent call and every check command from step 1 in **one assistant turn**, so the cold-read reads while the checks run. They share no inputs and neither can inform the other, so a turn spent waiting on one before starting the other is wall-clock added to a gate that fires on every ticket — this overlap is the reason the gate is cheap enough to keep.

   The **cold-read** is a fresh `Explore` agent with NO context beyond the changed-file list. Its brief is the **residue** of the edit — what the change left behind, not the code's overall quality: naming drift, half-applied renames, discriminants collapsed to `string`, dead fallbacks, orphaned callers.

   Completion: both passes have reported, dispatched from one turn.

3. **Triage** — fix the real cold-read flags, dismiss false positives with a reason. Fix check failures **this ticket caused**; pre-existing failures get reported, never fixed silently. If a fix touched logic, re-run the checks that cover it.
   Completion: every flag is fixed or explicitly dismissed, and every check result is green or attributed (this-ticket → fixed, pre-existing → reported).

4. **Commit** on this ticket's branch: short present-tense summary matching the repo's log style, one logical change per commit.
   Completion: working tree clean; each commit is a single logical change.

5. **Publish** — get the work off the machine.

   **Stack** — `gh stack submit --auto --open`. This pushes every active branch and creates or updates one PR per layer, linked into the stack on GitHub. `--open` marks it ready for review immediately: a layer becomes reviewable the moment it seals, and a draft isn't. The stack already exists — `/implement` initialised it when it entered the feature — so there is nothing to set up here, only a layer to publish.

   The PR body carries, for *this layer's* change only:

   <pr-body>

   ## What this delivers

   The end-to-end behaviour this ticket makes work, from the user's perspective.

   ## Decisions

   Every judgement call made while building that a reviewer can't recover from the diff — a seam chosen, an alternative rejected, a constraint discovered. Skip the section entirely when there were none; don't manufacture entries.

   Closes #<issue>

   </pr-body>

   **Solo** — `git push` the feature branch (`-u` on its first run). No PR yet; `/ship` opens the feature's single one at the end. The Decisions the stacked shape puts in a PR body still need somewhere to live, so record them in the commit body instead — that is what `/ship` will gather when it writes the PR.

   Completion: this ticket's work exists on the remote — as its own open PR (stack) or as pushed commits on the feature branch (solo).

6. **Mark the ticket done on the configured tracker** — whichever `/setup-skills` recorded is the single source of truth; update it and nothing else.

   **GitHub / Linear / Jira** — take `ready-for-agent` off the issue first, in either shape, so nothing grabs it twice. Don't also write a local file. Then:

   - **Stack** — **close the issue**, linking the layer's PR from the closing comment. On GitHub: `gh issue close <n> --reason completed --comment "Built in <PR url>."` The layer is sealed, so the ticket is *built*; that is the state worth tracking here.
   - **Solo** — **leave it open.** There is no per-ticket PR yet, so nothing about this ticket is reviewable or separately revertible. The feature's single PR closes them all at the end.

   **Local markdown** — tick the ticket file's acceptance-criteria checkboxes and set its **Status** to `done`. There is no issue to close, so this file *is* the record.

   **Why the stacked shape closes early.** There are two "done"s and a tracker gives you one bit. A ticket is **built** when its layer seals, and **landed** when it merges — and stacking pulls those far apart, because nothing merges until the whole stack lands bottom-up after `/ship`. Track *landed* and the board shows nothing for the entire build, then flips every issue at once. Track *built* and it moves with the work.

   It also makes the blocking edges honest. Layer N+1 sits on layer N's commits, so the next ticket is buildable the moment this one seals — closing here is what makes a native blocked-by edge read as **buildable** rather than merely *merged*.

   Keep `Closes #<issue>` in the PR body regardless (step 5). Against an already-closed issue it is a no-op, and it is the recovery path if a layer gets rejected and its issue reopened.

   Completion: the configured tracker shows this ticket as no longer grabbable — closed where stacked, open-but-unlabelled where solo — updated in exactly one place.

7. **Open the next ticket.**

   - **Stack** — `gh stack add <next-branch>`. This layer is now sealed and the next builds on top of it.
   - **Solo** — stay on the feature branch; the next ticket is the next commit.

   No next ticket → hand to `/feature-done`.

   **Branch naming.** Stack: `<type>/<feature>-<NN>-<ticket-slug>` — `feat/checkout-01-cart-schema`, `feat/checkout-02-payment-api`. The shared `<type>/<feature>` stem is what makes the stack legible in `gh stack view` and in the GitHub stack map; the number is what makes the order obvious without reading the diff. Solo: just the stem, `feat/checkout`.

   Completion: you are standing on the branch the next ticket will be written on, or on the last one with `/feature-done` next.

8. **Report** — one line: ticket · check results · cold-read findings and disposition · commit hash(es) · PR URL or "pushed, solo" · tracker updated · next branch, or "last ticket → /feature-done".

## Review lands on a sealed layer

*Stack only.* A reviewer commenting on layer 1 while you're building layer 3 doesn't strand anything. Amend layer 1, then `gh stack sync` — it cascade-rebases every layer above and retargets each PR, so approvals travel with them. That ripple is what stacking buys; it is the normal case, not an incident.
