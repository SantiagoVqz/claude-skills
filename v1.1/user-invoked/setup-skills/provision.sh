#!/usr/bin/env bash
#
# provision.sh — provision the git worktree you're standing in.
#
#   scripts/provision.sh [db]
#
# Layout-agnostic: works inside a harness worktree (.claude/worktrees/*) or any
# git worktree — it never creates a worktree, it sets up the one you're in.
# Idempotent (safe to re-run; won't clobber an already-stamped/repointed file).
#
#   • Copies gitignored env files from the primary checkout (a fresh worktree
#     has none).
#   • Stamps a dev-server port pair so parallel worktrees don't collide.
#   • With `db`: clones the shared dev DB per-worktree so divergent migrations
#     can't corrupt the shared schema.
#
# ── PORTING TO A NEW REPO ────────────────────────────────────────────────────
# Edit only the CONFIG block below — three touch points:
#   1. *_PORT_BASE   — two-digit port bases (leave BOTH empty ⇒ skip ports)
#   2. stamp_ports() — your port-dependent env vars (empty body ⇒ no-op)
#   3. clone_db()    — your per-worktree DB clone (DELETE it ⇒ no DB support)
# The ENGINE below is repo-independent — leave it alone.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

say()  { printf '\033[1;36m▸\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m! %s\033[0m\n' "$*" >&2; }
die()  { printf '\033[1;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

set_env() {   # set KEY="VAL" in an env file: replace an uncommented line or append
  local file="$1" key="$2" val="$3"
  mkdir -p "$(dirname "$file")"; touch "$file"
  if grep -qE "^[[:space:]]*${key}=" "$file"; then
    sed -i '' -E "s|^[[:space:]]*${key}=.*|${key}=\"${val}\"|" "$file"
  else
    printf '%s="%s"\n' "$key" "$val" >>"$file"
  fi
}

# ============================================================================
# CONFIG — the only part you edit per repo.
# ============================================================================

# 1. Port bases (two digits each). Final ports are ${BASE}${NN}, where NN comes
#    from the branch. Leave BOTH empty ("") for a repo with no dev servers —
#    port stamping is then skipped entirely.
BE_PORT_BASE="80"
FE_PORT_BASE="51"

# 2. Stamp this repo's port-dependent env vars. Runs with $BE_PORT / $FE_PORT and
#    $WT (worktree root) set. Use set_env <file> <KEY> <VAL>. Empty body = no-op.
stamp_ports() {
  set_env "$WT/frontend/.env" PUBLIC_API_URL "http://localhost:$BE_PORT"
  set_env "$WT/backend/.env"  FRONTEND_URL   "http://localhost:$FE_PORT"   # backend CORS origin
}

# 3. Clone a per-worktree dev DB (only on `provision.sh db`). DELETE THIS WHOLE
#    FUNCTION for a repo with no dev DB — the engine detects its absence.
#    Reference impl below is Postgres + Alembic; edit the two ← marked lines.
#    NOTE: if the DB is only reachable INSIDE a container (e.g. OrbStack/Docker
#    with no host psql route), wrap the psql/pg_dump/createdb calls below in
#    `docker exec <db-container> ...`.
clone_db() {
  local be_env="$WT/backend/.env"                                   # ← env file holding DATABASE_URL
  local url
  url="$(grep -E '^[[:space:]]*DATABASE_URL=' "$be_env" | head -1 | cut -d= -f2- \
           | tr -d '"'"'"' ' | sed 's/postgresql+asyncpg:/postgresql:/')"
  [[ -n "$url" ]] || die "DATABASE_URL not found in $be_env"
  eval "$(python3 - "$url" <<'PY'
import sys, urllib.parse as u
p = u.urlparse(sys.argv[1])
print(f'export PGHOST={p.hostname}')
print(f'export PGPORT={p.port or 5432}')
print(f'export PGUSER={p.username}')
print(f'export PGPASSWORD={u.unquote(p.password or "")!r}')
print(f'SRC_DB={(p.path or "/").lstrip("/")}')
PY
)"
  local dest="${SRC_DB}_${BRANCH//[^a-zA-Z0-9]/_}"; dest="${dest:0:63}"
  if [[ "$SRC_DB" == "$dest" ]]; then say "Already on cloned DB $dest — skipping"; DB_NAME="$dest"; return; fi
  say "Cloning dev DB  $SRC_DB → $dest  (host $PGHOST)"
  if ! psql -d postgres -c "CREATE DATABASE \"$dest\" TEMPLATE \"$SRC_DB\";" 2>/dev/null; then
    warn "TEMPLATE clone failed (source has active connections) — using pg_dump copy"
    createdb "$dest"
    pg_dump "$SRC_DB" | psql -q -d "$dest"
  fi
  sed -i '' -E "s#/${SRC_DB}([?\"'[:space:]]|\$)#/${dest}\1#" "$be_env"
  say "Bringing $dest to head"
  ( cd "$WT/backend" && uv run alembic upgrade head )                # ← your migrate-to-head command
  DB_NAME="$dest"
}

# ============================================================================
# ENGINE — repo-independent. Leave alone.
# ============================================================================

CLONE_DB=0
for arg in "$@"; do [[ "$arg" == "db" ]] && CLONE_DB=1; done

# must be inside a worktree, not the primary
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not inside a git repo"
GIT_DIR="$(git rev-parse --absolute-git-dir)"                     # worktree: …/.git/worktrees/<id>
COMMON="$(git rev-parse --path-format=absolute --git-common-dir)" # primary:  …/.git
[[ "$GIT_DIR" != "$COMMON" ]] || die "this is the primary checkout — run provision.sh inside a worktree"
WT="$(git rev-parse --show-toplevel)"
PRIMARY="$(dirname "$COMMON")"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
say "Provisioning worktree $WT  (branch $BRANCH, primary $PRIMARY)"

# copy gitignored env files (first run only; don't clobber stamps)
copied=0
while IFS= read -r rel; do
  [[ -z "$rel" ]] && continue
  dest="$WT/$rel"
  [[ -e "$dest" ]] && continue
  mkdir -p "$(dirname "$dest")"
  cp "$PRIMARY/$rel" "$dest"; ((++copied))
done < <(git -C "$PRIMARY" ls-files --others --ignored --exclude-standard \
           | grep -E '(^|/)\.env(\..*)?$' || true)
say "Copied $copied env file(s) from primary"

# port pair + stamp
BE_PORT=""; FE_PORT=""
if [[ -n "$BE_PORT_BASE$FE_PORT_BASE" ]]; then
  digits="$(printf '%s' "$BRANCH" | grep -oE '[0-9]+' | tail -1 || true)"
  NN="00"; [[ -n "$digits" ]] && NN="$(printf '%02d' $((10#${digits: -2})))"
  port_busy() { lsof -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1; }
  tries=0
  while port_busy "$BE_PORT_BASE$NN" || port_busy "$FE_PORT_BASE$NN"; do
    NN="$(printf '%02d' $(( (10#$NN + 1) % 100 )))"
    (( ++tries > 99 )) && die "no free port pair found"
  done
  BE_PORT="$BE_PORT_BASE$NN"; FE_PORT="$FE_PORT_BASE$NN"
  stamp_ports
  say "Stamped ports  backend:$BE_PORT  frontend:$FE_PORT"
fi

# optional per-worktree dev DB
DB_NAME=""
if (( CLONE_DB )); then
  if declare -f clone_db >/dev/null; then clone_db
  else warn "'db' requested but this repo's provision.sh defines no clone_db — skipping"; fi
fi

# report
cat <<EOF

$(say "Worktree provisioned.")

  branch    $BRANCH${BE_PORT:+
  backend   http://localhost:$BE_PORT}${FE_PORT:+
  frontend  http://localhost:$FE_PORT}
  dev DB    ${DB_NAME:-shared (pass 'db' if this work adds migrations)}
EOF
