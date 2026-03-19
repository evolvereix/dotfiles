#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Mise Runtime Upgrade
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon ⚙️
# @raycast.packageName System

# Documentation:
# @raycast.description Upgrade Dev Tools via mise
# @raycast.author zen
# @raycast.authorURL https://raycast.com/zen

set -u
set -o pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

LOCK_DIR="/tmp/mise-runtime-upgrade.lock"
LOCK_PID_FILE="$LOCK_DIR/pid"
LOG_DIR="$HOME/Library/Logs/Raycast"
LOG_FILE="$LOG_DIR/mise-runtime-upgrade.log"

mkdir -p "$LOG_DIR"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

notify() {
  local message="$1"
  local title="${2:-Mise Runtime Upgrade}"
  /usr/bin/osascript -e "display notification \"${message//\"/\\\"}\" with title \"${title//\"/\\\"}\""
}

cleanup() {
  rm -rf "$LOCK_DIR"
}

acquire_lock() {
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "$$" > "$LOCK_PID_FILE"
    return 0
  fi

  if [[ -f "$LOCK_PID_FILE" ]]; then
    local lock_pid
    local lock_command
    read -r lock_pid < "$LOCK_PID_FILE"

    if [[ "$lock_pid" =~ ^[0-9]+$ ]]; then
      lock_command="$(ps -p "$lock_pid" -o command= 2>/dev/null || true)"
      if [[ -n "$lock_command" && "$lock_command" == *"$(basename "$0")"* ]]; then
        log "Another mise upgrade job is already running (pid $lock_pid)."
        notify "Another mise upgrade job is already running."
        return 10
      fi
    fi
  fi

  log "Found a stale lock, removing it."
  rm -rf "$LOCK_DIR"

  if mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "$$" > "$LOCK_PID_FILE"
    return 0
  fi

  log "Failed to acquire lock."
  notify "Failed to acquire mise upgrade lock."
  return 1
}

run_logged() {
  log "Running: $*"
  "$@" 2>&1 | tee -a "$LOG_FILE"
  return ${PIPESTATUS[0]}
}

run_upgrade() {
  run_logged mise upgrade -y go node pnpm
}

trap cleanup EXIT

if ! acquire_lock; then
  LOCK_EXIT=$?
  if [[ $LOCK_EXIT -eq 10 ]]; then
    exit 0
  fi
  exit $LOCK_EXIT
fi

if ! command -v mise >/dev/null 2>&1; then
  log "mise is not installed or not found in PATH."
  notify "mise is not installed or not found in PATH."
  exit 1
fi

log "===== START mise runtime upgrade ====="
log "Upgrade go/pnpm to latest and node to latest v22 from mise config"

run_logged mise ls go node pnpm
LS_BEFORE_EXIT=$?

if [[ $LS_BEFORE_EXIT -ne 0 ]]; then
  log "mise ls failed with exit code $LS_BEFORE_EXIT"
fi

run_upgrade
UPGRADE_EXIT=$?

if [[ $UPGRADE_EXIT -ne 0 ]]; then
  log "mise upgrade failed with exit code $UPGRADE_EXIT"
  notify "mise upgrade failed (exit $UPGRADE_EXIT)"
  exit $UPGRADE_EXIT
fi

run_logged mise prune --tools -y go node pnpm
PRUNE_EXIT=$?

if [[ $PRUNE_EXIT -ne 0 ]]; then
  log "mise prune failed with exit code $PRUNE_EXIT"
  notify "mise upgrade succeeded, but prune failed (exit $PRUNE_EXIT)"
else
  log "mise prune succeeded"
fi

run_logged mise ls go node pnpm
LS_AFTER_EXIT=$?

if [[ $LS_AFTER_EXIT -ne 0 ]]; then
  log "mise ls after upgrade failed with exit code $LS_AFTER_EXIT"
fi

log "mise upgrade exit code: $UPGRADE_EXIT"
log "mise prune exit code: $PRUNE_EXIT"
log "===== END mise runtime upgrade ====="

if [[ $PRUNE_EXIT -ne 0 ]]; then
  exit $PRUNE_EXIT
fi

notify "go, node@22, pnpm upgrade completed successfully"
exit 0
