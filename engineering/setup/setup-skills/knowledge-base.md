# Knowledge Base

Where this repo's **devnotes** live — the dated, frozen per-session records of what changed, why, what was decided, and what bit us. Written by `/devnote`, read by `/team-report`.

Devnotes are one of three durable artifacts, and each fact belongs in exactly one:

| Artifact | Answers | Lifetime |
|---|---|---|
| `CONTEXT.md` | what do our words mean | living — edited in place |
| `docs/adr/` | why is the design this way | living — appended |
| devnote | what changed, why now, what bit us | frozen — dated snapshot |

## Location

<!-- Fill one of the three shapes below; delete the others. -->

**Separate repo, nested inside the product repo:**

- Path: `<DIR>/` at the product repo root
- Devnotes subdir: `<DIR>/<SUBDIR>/`
- Its own git remote: `<owner/repo>`
- The product repo's `.gitignore` excludes `<DIR>/`, so writing there never touches this repo's CI or commits

**In-repo:**

- Devnotes subdir: `docs/devnotes/`
- Committed with the code, under this repo's normal branch and PR rules

**None:** this repo has no knowledge base. `/devnote` should say so and offer a one-off file instead of writing; `/team-report` should run without the devnote source and say the "why" is missing.

## Commit posture

<!-- Separate-repo KBs: direct commits to main are usually correct — a generated log is not reviewed code. In-repo KBs: follow the repo's branch/PR rules; never push to a protected main. -->

`<direct commits to the KB's main | normal branch + PR flow>`

## Search index

<!-- The command that makes a new devnote findable, or "None". -->

`<qmd update && qmd embed | None>` — run from the repo root.

Config is **repo-local** (`.qmd/index.yml`, gitignored), not the global `~/.config/qmd/index.yml`. One collection per source so queries can be scoped:

- `<repo>-devnotes` → the devnotes dir
- `<repo>-adr` → `docs/adr/`

`qmd status` lists the registered collections. A collection missing from that output means its `path` doesn't resolve — fix the path, don't re-add the collection.

## Audience

<!-- Who reads /team-report output. Drives its voice: mixed audiences get plain-language-first bullets with an italic technical anchor; engineers-only leads with the mechanism. -->

`<mixed: non-technical stakeholders + engineers | engineers only | ...>`

## Issue references

Deferred items in a devnote must carry an issue reference or the explicit *(accept if forgotten)* marker. The reference syntax comes from `docs/agents/issue-tracker.md`.
