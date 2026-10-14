#!/usr/bin/env bash
# SessionStart and PostToolUse(EnterWorktree): provision a linked worktree
# before any work, whoever created it. Idempotent: a provisioned worktree costs
# one no-op run. The primary checkout is never provisioned.
set -u
input="$(cat)"
field() { printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get(sys.argv[1], ""))' "$1"; }
event="$(field hook_event_name)"
cwd="$(field cwd)"
[[ -n "$cwd" && -x "$cwd/scripts/provision.sh" ]] || exit 0
git_dir="$(git -C "$cwd" rev-parse --absolute-git-dir 2>/dev/null)"
common="$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)"
[[ -n "$git_dir" && "$git_dir" != "$common" ]] || exit 0   # only a linked worktree

log="$(mktemp -t provision.XXXXXX)"
if ( cd "$cwd" && scripts/provision.sh ) >"$log" 2>&1; then
  msg="Worktree provisioned by scripts/provision.sh: $(tail -n 4 "$log" | tr '\n' ' ')"
else
  msg="scripts/provision.sh FAILED in $cwd. Fix before working: $(tail -n 8 "$log" | tr '\n' ' ')"
fi
rm -f "$log"

# SessionStart takes plain stdout as context; PostToolUse needs the JSON envelope.
if [[ "$event" == "PostToolUse" ]]; then
  python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":sys.argv[1]}}))' "$msg"
else
  printf '%s\n' "$msg"
fi
