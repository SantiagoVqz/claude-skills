---
name: setup-skills
description: Configure this repo for the engineering skills — set up its issue tracker, triage label vocabulary, domain doc layout, and optional worktree provisioner. Run once before first use of the other engineering skills.
disable-model-invocation: true
---

# Setup Skills

Scaffold the per-repo configuration that the engineering skills assume:

- **Issue tracker** — where issues live (GitHub by default; local markdown is also supported out of the box)
- **Triage labels** — the strings used for the five canonical triage roles
- **Domain docs** — where `CONTEXT.md` and ADRs live, and the consumer rules for reading them
- **Worktree provisioning** — an optional `scripts/provision.sh` that `implement` runs to set up a fresh worktree (env, dev-server ports, per-worktree DB); skipped for repos with no dev servers or DB
- **Knowledge base** — where dated devnotes live, and who reads them; skipped for repos that don't keep one

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Process

### 1. Explore

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

- `git remote -v` and `.git/config` — is this a GitHub repo? Which one?
- `AGENTS.md` and `CLAUDE.md` at the repo root — does either exist? Is there already an `## Agent skills` section in either?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root
- `docs/adr/` and any `src/*/docs/adr/` directories
- `docs/agents/` — does this skill's prior output already exist?
- `.scratch/` — sign that a local-markdown issue tracker convention is already in use
- `scripts/provision.sh` — does the worktree provisioner already exist? The repo's shape for Section D: a `frontend`/`backend` split, the env vars carrying each server's URL to the other, a `DATABASE_URL` in a backend env file, a migration tool (Alembic `migrations/`, Prisma, etc.)
- Signs of an existing knowledge base for Section E: a nested directory with its own `.git` (check `.gitignore` for it), `docs/devnotes/`, `docs/handouts/`, or a folder of dated `YYYY-MM-DD-*.md` files anywhere in the repo. **Verify the directory actually exists on disk at the path `.gitignore` names** — a KB that was renamed or moved leaves every reference pointing at nothing, and the skills that consume it fail silently.

### 2. Present findings and ask

Summarise what's present and what's missing. Then walk the user through the five decisions **one at a time** — present a section, get the user's answer, then move to the next. Don't dump them all at once. Section D may be skipped outright for repos with no dev servers and no dev DB.

Assume the user does not know what these terms mean. Each section starts with a short explainer (what it is, why these skills need it, what changes if they pick differently). Then show the choices and the default.

**Section A — Issue tracker.**

> Explainer: The "issue tracker" is where issues live for this repo. Skills like `to-tickets`, `triage`, `to-spec`, and `qa` read from and write to it — they need to know whether to call `gh issue create`, write a markdown file under `.scratch/`, or follow some other workflow you describe. Pick the place you actually track work for this repo.

Default posture: these skills were designed for GitHub. If a `git remote` points at GitHub, propose that. If a `git remote` points at GitLab (`gitlab.com` or a self-hosted host), propose GitLab. Otherwise (or if the user prefers), offer:

- **GitHub** — issues live in the repo's GitHub Issues (uses the `gh` CLI)
- **GitLab** — issues live in the repo's GitLab Issues (uses the [`glab`](https://gitlab.com/gitlab-org/cli) CLI)
- **Local markdown** — issues live as files under `.scratch/<feature>/` in this repo (good for solo projects or repos without a remote)
- **Other** (Jira, Linear, etc.) — ask the user to describe the workflow in one paragraph; the skill will record it as freeform prose

If — and only if — the user picked **GitHub** or **GitLab**, ask one follow-up:

> Explainer: Open-source repos often receive feature requests as pull requests, not just issues — a PR is an issue with attached code. If you turn this on, `/triage` pulls *external* PRs into the same queue and runs them through the same labels and states as issues (collaborators' in-flight PRs are left alone). Leave it off if PRs aren't a request surface for you.

- **PRs as a request surface** — yes / no (default: no). Record the answer in `docs/agents/issue-tracker.md`. For local-markdown and other trackers, skip this question — there are no PRs.

**Section B — Triage label vocabulary.**

> Explainer: When the `triage` skill processes an incoming issue, it moves it through a state machine — needs evaluation, waiting on reporter, ready for an AFK agent to pick up, ready for a human, or won't fix. To do that, it needs to apply labels (or the equivalent in your issue tracker) that match strings *you've actually configured*. If your repo already uses different label names (e.g. `bug:triage` instead of `needs-triage`), map them here so the skill applies the right ones instead of creating duplicates.

The five canonical roles:

- `needs-triage` — maintainer needs to evaluate
- `needs-info` — waiting on reporter
- `ready-for-agent` — fully specified, AFK-ready (an agent can pick it up with no human context)
- `ready-for-human` — needs human implementation
- `wontfix` — will not be actioned

Default: each role's string equals its name. Ask the user if they want to override any. If their issue tracker has no existing labels, the defaults are fine.

**Section C — Domain docs.**

> Explainer: Some skills (`improve-codebase-architecture`, `diagnosing-bugs`, `tdd`) read a `CONTEXT.md` file to learn the project's domain language, and `docs/adr/` for past architectural decisions. They need to know whether the repo has one global context or multiple (e.g. a monorepo with separate frontend/backend contexts) so they look in the right place.

Confirm the layout:

- **Single-context** — one `CONTEXT.md` + `docs/adr/` at the repo root. Most repos are this.
- **Multi-context** — `CONTEXT-MAP.md` at the root pointing to per-context `CONTEXT.md` files (typically a monorepo).

**Section D — Worktree provisioning.**

> Explainer: When you run several branches in parallel git worktrees (e.g. the multi-agent view's `.claude/worktrees/`), each fresh worktree lacks the gitignored env files a checkout needs, and two of them running dev servers or sharing one dev DB will collide. The `implement` skill's preflight already looks for a repo-local `scripts/provision.sh` and runs it to set the worktree up — this section writes that script from a seed. Skip it for a repo with no dev servers and no dev DB: there a fresh worktree needs only its env files, which `implement`'s fallback already copies.

The seed is [provision.sh](./provision.sh) — a fixed engine (worktree detect, primary guard, env copy, free-port scan) plus a small CONFIG block that is the only per-repo edit. Detect the repo's shape from step 1 (or ask when unsure), then fill that block — the seed's own `PORTING TO A NEW REPO` header names its three touch points:

- **Dev-server ports** — needs a `frontend`/`backend` split and the env vars carrying each server's URL to the other. Set the two `*_PORT_BASE` values and `stamp_ports()`; leave the bases empty if the repo runs no dev servers.
- **Per-worktree DB** — needs a `DATABASE_URL` in a backend env file plus a migration tool. Present ⇒ fill `clone_db()` (its DB engine and migrate-to-head command); absent ⇒ delete the whole function.

**Section E — Knowledge base.**

> Explainer: A "devnote" is a dated, frozen record of one work session — what changed, why, the decisions made, the gotchas hit, what got deferred. `/devnote` writes them; `/team-report` reads them back to rebuild what shipped and why. It's the third durable artifact alongside the two in Section C: `CONTEXT.md` says what your words mean, an ADR says why the design is the way it is, and a devnote says what happened on a given day. Skip this if you don't want per-session records — the skills will simply say so instead of writing.

Ask for four things (each has a sane default — only the first really needs thought):

- **Location** — where devnotes go. Three shapes:
  - **Separate repo nested in this one** (e.g. `DEVNOTES/` with its own remote, gitignored by the product repo) — devnotes never touch this repo's CI, diffs, or review load. Best when they're generated frequently.
  - **In-repo** (`docs/devnotes/`) — versioned and reviewed with the code. Simpler; costs you noise in every PR.
  - **None** — no knowledge base.
- **Commit posture** — for a separate repo, direct commits to its `main` are normally right (it's a generated log, not reviewed code) and worth calling out explicitly as an exception to any no-commit-to-main rule you have. For in-repo, the repo's normal branch/PR flow.
- **Search index** — whether devnotes are semantically searchable, and how. If the user runs [`qmd`](https://github.com/tobi/qmd), set up a **repo-local** index (see below). Default: none.
- **Audience** — who reads `/team-report`. Default: mixed (non-technical stakeholders + engineers), which makes it write plain-language-first bullets. "Engineers only" makes it lead with the mechanism.

If a KB already exists on disk, confirm the path resolves and its recorded name matches reality before writing — a stale path is worse than no config, because the consuming skills fail quietly.

**Search index — one config per repo, never the global one.** `qmd` reads a project-local `.qmd/index.yml` when run from inside the repo, and falls back to `~/.config/qmd/index.yml` otherwise. Always write the repo-local file. Do **not** append this repo's collections to the global config: collections there are searched together, so one shared file means every query in one project surfaces hits from all the others. The global config is for genuinely cross-repo collections only.

Give the repo one collection per durable doc source — typically devnotes and ADRs, kept **separate** so a query can be scoped to either:

```yaml
collections:
  <repo>-devnotes:
    path: /absolute/path/to/<kb>/<subdir>
    pattern: "**/*.md"
    context:
      "": "<what this project is, and what these notes contain — one dense sentence; qmd uses it to disambiguate>"
  <repo>-adr:
    path: /absolute/path/to/docs/adr
    pattern: "**/*.md"
    context:
      "": "<project> Architecture Decision Records: reviewed, versioned decisions in the product repo."
models:
  # copy the models: block from ~/.config/qmd/index.yml if one exists; omit to use qmd's defaults
```

Paths must be absolute, and the index DB is machine-local — so `.qmd/` goes in `.gitignore`, with a comment saying why. Refresh command for `knowledge-base.md` is then `qmd update && qmd embed`, run from the repo root.

### 3. Confirm and edit

Show the user a draft of:

- The `## Agent skills` block to add to whichever of `CLAUDE.md` / `AGENTS.md` is being edited (see step 4 for selection rules)
- The contents of `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md`, and — if Section E applies — `docs/agents/knowledge-base.md`
- If Section D applies, the filled CONFIG block of `scripts/provision.sh`

Let them edit before writing.

### 4. Write

**Pick the file to edit:**

- If `CLAUDE.md` exists, edit it.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create — don't pick for them.

Never create `AGENTS.md` when `CLAUDE.md` already exists (or vice versa) — always edit the one that's already there.

If an `## Agent skills` block already exists in the chosen file, update its contents in-place rather than appending a duplicate. Don't overwrite user edits to the surrounding sections.

The block:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked, plus whether external PRs are a triage surface]. See `docs/agents/issue-tracker.md`.

### Triage labels

[one-line summary of the label vocabulary]. See `docs/agents/triage-labels.md`.

### Domain docs

[one-line summary of layout — "single-context" or "multi-context"]. See `docs/agents/domain.md`.

### Knowledge base

[one-line summary — where devnotes live and whether it's a separate repo]. See `docs/agents/knowledge-base.md`.
```

Omit the Knowledge base heading entirely if Section E was skipped.

Then write the docs files using the seed templates in this skill folder as a starting point:

- [issue-tracker-github.md](./issue-tracker-github.md) — GitHub issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md) — GitLab issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md) — local-markdown issue tracker
- [triage-labels.md](./triage-labels.md) — label mapping
- [domain.md](./domain.md) — domain doc consumer rules + layout
- [knowledge-base.md](./knowledge-base.md) — devnote location, commit posture, index, audience

For "other" issue trackers, write `docs/agents/issue-tracker.md` from scratch using the user's description.

**Worktree provisioner (Section D).** If it applies, copy the seed to `<repo>/scripts/provision.sh`, fill its CONFIG block for this repo, `chmod +x`, and confirm `bash -n` is clean. It needs no `## Agent skills` entry — `implement` discovers it by path. Completion: the script parses clean and its CONFIG names this repo's actual env files, ports, and (if any) DB — or, for a repo with no dev servers/DB, no script was written and you told the user why.

**Knowledge base (Section E).** If the user chose the separate-repo shape and the directory doesn't exist yet, clone or create it, add its path to the product repo's `.gitignore`, and give it a `README.md` stating that it's a separate repo, what lives in it, and that ADRs live in the *product* repo — not here.

If a search index was chosen, write `<repo>/.qmd/index.yml` with the per-source collections, add `.qmd/` to `.gitignore`, and run `qmd update && qmd embed` once to verify the collections register. `qmd status` should list every collection you defined — a collection whose `path` doesn't exist is silently absent from that output, which is the fastest way to catch a wrong path.

Verify every path in `knowledge-base.md` and `.qmd/index.yml` resolves on disk before finishing.

### 5. Done

Tell the user the setup is complete and which engineering skills will now read from these files — and, if Section D ran, that `implement` will run `scripts/provision.sh` whenever it works in a worktree. Mention they can edit `docs/agents/*.md` and `scripts/provision.sh` directly later — re-running this skill is only necessary if they want to switch issue trackers or restart from scratch.
