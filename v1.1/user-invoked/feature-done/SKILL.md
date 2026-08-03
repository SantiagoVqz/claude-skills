---
name: feature-done
description: "Close out a whole feature once its last ticket seals — simplify the full diff, run the full suite, review it against the spec, then hand to /ship. The boundary gate before trunk."
disable-model-invocation: true
---

# feature-done — the spec gate

Run this **once per feature**, after `/ticket-done` sealed the last layer. Everything here scales with the **feature**, not the diff, which is exactly why it doesn't run per ticket: a full suite on a 40-line slice is waste, and there is no spec to conform to until the last slice exists.

The question this gate answers is **conformance** — does the stack, taken whole, deliver the spec? Each layer was verified against itself; nothing has yet asked whether they add up.

It is a **ritual** — pre-approved, run start to finish. Do NOT ask for permission between steps.

## Steps

1. **Frontier check** — every ticket in the spec is sealed. **Stack:** `gh stack view --json` lists the layers, and each should map to one ticket. **Solo:** `git log <trunk>..HEAD` lists the commits, and the tracker's tickets should all be marked done. Either way a ticket with nothing behind it means the feature isn't done — stop and name it.
   Completion: every ticket in the spec is accounted for by a layer (stack) or a commit (solo), and nothing built maps to no ticket.

2. **Simplify** — invoke `/simplify` over the whole feature diff (`git diff <trunk>...HEAD`). This is the first time the feature is visible as one shape, so it is the first time duplication *across* tickets is visible: the helper written twice in layers 1 and 3, the type that wants to be shared.
   Completion: `/simplify` has run over the full diff and its cleanups are applied, or it found nothing.

3. **Full suite** — run the repo's checks whole, not scoped. `.github/workflows/*` is the source of truth for what "whole" means here; this run is the one that has to match CI.
   Completion: the full suite has run, and each result is green or attributed (this-feature → fixed, pre-existing → reported).

4. **Review against the spec** — invoke `/code-review` with the trunk as the fixed point and the spec as the spec source. Its **Spec** axis is the conformance check: requirements the spec asked for that are missing or partial, behaviour nobody asked for, requirements implemented wrong. Its **Standards** axis catches what the per-ticket cold-reads couldn't see from inside one slice.
   Completion: both axes have reported.

5. **Triage the findings.**

   **Stack** — a finding belongs to whichever layer introduced it; fix it there, not on top. Amend that layer, then `gh stack sync` to cascade-rebase everything above it and retarget each PR. A finding that spans layers, or that no existing layer owns, becomes a new layer on top (`gh stack add`) rather than a smeared amend.

   **Solo** — nothing is published yet, so fix on top of the branch as ordinary commits. Rewriting history to place each fix in its originating commit buys nothing once the whole branch lands as one PR.

   Either way, a finding that reveals the *spec* was wrong stops here: it's the user's call, not a fix.
   Completion: every finding is fixed where its shape puts it, or escalated to the user with a reason.

6. **Hand to `/ship`** — stacked, it syncs against the trunk and republishes every layer; solo, it opens the feature's one PR. Merging stays the human's call.

7. **Report** — one block: shape (stack of N / solo) · simplify cleanups · full-suite result · Standards findings and disposition · Spec findings and disposition · anything escalated · handed to `/ship`.
