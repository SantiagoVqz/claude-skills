---
name: wizard
description: "Write an interactive bash wizard that walks a human through the steps only they can do: get credentials or API keys from a dashboard, set CI secrets, provision a third-party service, or run a one-off migration or cutover. Use when the user runs /wizard, or when work stops on a manual step that the agent cannot do."
argument-hint: "[what to set up or migrate]"
---

# Wizard

A wizard is a bash script that walks a human through a manual procedure, one stage at a time. It opens each URL, says what to click and copy, captures each value, and writes the value where it belongs: `.env`, a GitHub secret or a GitHub variable. You write the script. The human runs it, so their secrets never enter your context.

Write a wizard in place of numbered steps in chat. Steps in chat scroll away, and a script fails visibly when a step goes stale.

[`template.sh`](template.sh) holds the UX: progress, confirm gates, URL opening on macOS, Linux and WSL, hidden secret entry, idempotent `.env` writes, `gh secret` and `gh variable` writes, and a closing summary. The library above the `STAGES` marker is the same in every wizard. Copy it unchanged. Your work is to scope the procedure and write the stages.

## 1. Scope the procedure

Read the repo before you ask the user anything:

- Setup: `.env`, `.env.example`, `.env.*`, the README, `docker-compose*`, the framework config and `.github/workflows/*`. Each `secrets.*` or `vars.*` reference is a value that the wizard must produce. A value that `.env` already holds needs no stage.
- Migration or cutover: the current state, the target state, and each irreversible action between them.

For each captured value, record three facts:

- Source: where the human gets it.
- Destination: from the table below.
- Secret or public: a secret gets hidden entry.

| Destination | When |
|---|---|
| `.env` only | Local dev needs it, and CI does not. |
| GitHub secret | CI reads it, and it is sensitive. |
| GitHub variable | CI reads it, and it is public. |
| `.env` and a GitHub secret | Local dev and CI both need it. |
| Nowhere | The stage is an action only, such as a switch or a plan upgrade. |

Show the user the ordered stages and the values of each stage. The user can add, drop or reorder stages. Write no script before the user confirms.

Completion: the user confirmed the stage list, and each value has its source, destination and secret flag.

## 2. Map each stage

For each stage, write the exact path that a stranger follows. Example: "Dashboard → Developers → API keys → Reveal test key → copy". When you do not know the current UI or the exact command, check the vendor docs or ask the user. Each click in the script comes from the docs, the user or the code.

Completion: each stage has concrete instructions, each with a known source.

## 3. Write the script

1. Copy `template.sh` to the target path. A one-off wizard goes to the scratchpad or `scripts/`. A setup path that the next person needs goes to `scripts/`.
2. Replace the example stage with one `stage` for each step, in dependency order.
3. Set `TOTAL_STAGES` to the number of stages.
4. Set the `banner` title.

Use the library helpers: `stage`, `say`, `step`, `note`, `warn`, `open_url`, `ask`, `ask_secret`, `write_env`, `set_secret`, `set_var`, `pause` and `confirm`.

Each stage follows these rules:

- It does one focused task that fits one screen, because `stage` clears the terminal.
- It calls `open_url` before it asks for a value from that page.
- It reads each secret with `ask_secret`.
- It calls `write_env` for each value that `.env` keeps.
- It calls `set_secret` only for the values that CI reads.
- It puts `confirm` before each irreversible action.

Keep every stage inside `run_wizard`, and keep the last line of the file as it is. Bash then parses the whole file before the first prompt.

Completion: each value from step 1 has a capture call and a write call to its destination.

## 4. Check and hand off

1. Run `bash -n <script>`, and run `shellcheck <script>` when it is installed.
2. Run `chmod +x <script>`.
3. Trace the script statically. Do not run it, because it opens browsers and waits for human input. Check that each value lands at its destination from step 1. Check that each `set_secret` name matches a `secrets.*` reference in CI.
4. Give the user the command to run it. Tell the user that Ctrl-C and a re-run is safe, because `ask` offers each saved `.env` value as the default.

A wizard is for one run by default. Delete it after the run. Commit it only when the user wants a repeatable setup path, and link it from the README.

Completion: the script passes `bash -n`, the trace finds no gap, and the user has the run command.
