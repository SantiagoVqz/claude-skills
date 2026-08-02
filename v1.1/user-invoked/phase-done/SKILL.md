---
name: phase-done
description: "End-of-phase ritual for multi-phase work — /simplify, run the repo's own checks, commit, cold-read by a fresh agent, then open the next phase. In a stack, each phase becomes its own pull request."
disable-model-invocation: true
---

# phase-done — close out a phase

Run this **once per phase**, then continue to the next — or hand to `/ship` when there is no next.

A **phase** is one PR-sized chunk of work: the largest piece someone can review in one sitting. Most tickets are a single phase, and that's the common case — run this once, then `/ship`. Split into more phases only when one PR would genuinely be unpleasant to review; **don't invent phases to have phases.** Where the repo has stacked PRs enabled, each phase becomes its own **stack layer** with its own PR, reviewable the moment it closes.

Either way this is the last gate before work leaves the machine, so it always runs — a one-phase ticket gets the same verification a five-phase one does.

It is a **ritual** — pre-approved, run start to finish. Do NOT ask for permission between steps; skipping the asking is the reason it exists.

**It is also a context checkpoint.** Every step below either runs against a bounded diff or hands off to a fresh sub-agent, so the ritual costs the main window very little — and once it completes, the phase is committed, verified, and (stacked) already a PR. That's durable state outside your context. Approaching the smart zone mid-ticket? Clear or `/handoff` right after this skill returns, and pick up the next phase from the branch.

## Steps

1. **Simplify** — invoke `/simplify` on this phase's changed code.
   Completion: `/simplify` has run and its cleanups are applied, or it found nothing.

2. **Checks** — the repo already defines what "green" means; **mirror its own checks, don't invent them.** Find them, in order of authority, and run only what the phase touched:
   - **CI** — `.github/workflows/*` names the authoritative commands. Read it first; it is the source of truth.
   - **Manifest scripts** — `package.json` (`check`/`lint`/`typecheck`/`test`), `Makefile`/`justfile` targets, `pyproject.toml` (ruff, the configured type checker, pytest). Run via the repo's package manager (pick pnpm/yarn/npm from the lockfile).
   - Scope tests to affected modules when the full suite is slow; run it whole only at the last phase.

   Fix failures **this phase caused** before proceeding. Pre-existing failures get reported, never fixed silently.
   Completion: every check the repo defines has run, and each result is green or attributed (this-phase → fixed, pre-existing → reported).

3. **Commit** on this phase's branch: short present-tense summary matching the repo's log style, one logical change per commit.
   Completion: working tree clean; each commit is a single logical change.

4. **Cold-read** — spawn a fresh `Explore` agent with NO context beyond the list of files changed this phase. Its brief is the **residue** of this phase's edit — what the change left behind, not the code's overall quality: naming drift, half-applied renames, discriminants collapsed to `string`, dead fallbacks, orphaned callers. Triage every flag: fix the real ones now (amend or commit), dismiss false positives with a reason.
   Completion: every flagged item is either fixed or explicitly dismissed.

5. **Open the next phase.**
   - **Stacked** — `gh stack add <next-phase-branch>`. This phase is now a sealed layer and the next one builds on top of it. If this was the feature's first phase, `gh stack init -b <trunk> <this-phase-branch>` before adding.
   - **Not stacked** — stay on the branch and keep building.

   **Branch naming:** `<type>/<feature>-phase-<n>` — `feat/checkout-phase-1`, `feat/checkout-phase-2`, `fix/…`, `chore/…`. The shared `<type>/<feature>` stem is what makes a stack legible in `gh stack view` and in the GitHub stack map; the trailing number is what makes the order obvious without reading the diff.

   Publishing the layers belongs to `/ship`, run once at the end; a `gh stack submit` here fragments the PR set mid-build.
   Completion: you are standing on the branch the next phase will be written on.

6. **Report** — one block: what the phase delivered · check results · commit hash(es) · cold-read findings and their disposition · next branch, or "last phase". Then continue to the next phase, or `/ship`.
