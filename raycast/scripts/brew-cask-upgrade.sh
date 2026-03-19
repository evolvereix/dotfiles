#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Brew Cask Upgrade
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🎯
# @raycast.packageName System

# Documentation:
# @raycast.description Upgrade all casks via brew cu -f -a -y
# @raycast.author zen
# @raycast.authorURL https://raycast.com/zen

set -u

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

LOCK_DIR="/tmp/brew-cu.lock"
LOCK_PID_FILE="$LOCK_DIR/pid"
LOG_DIR="$HOME/Library/Logs/Raycast"
LOG_FILE="$LOG_DIR/brew-cu.log"
DOWNLOADS_DIR="$HOME/Library/Caches/Homebrew/downloads"

mkdir -p "$LOG_DIR"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

notify() {
  local message="$1"
  local title="${2:-Brew Cask Upgrade}"
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
        log "Another brew-cu job is already running (pid $lock_pid)."
        notify "Another brew-cu job is already running."
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
  notify "Failed to acquire brew-cu lock."
  return 1
}

clean_incomplete() {
  log "Cleaning .incomplete files in $DOWNLOADS_DIR"
  rm -f "$DOWNLOADS_DIR"/*.incomplete
}

run_brew_cu() {
  log "Running: gtimeout -k 10 1800 brew cu -f -a -y"
  gtimeout -k 10 1800 brew cu -f -a -y 2>&1 | tee -a "$LOG_FILE"
  return ${PIPESTATUS[0]}
}

trap cleanup EXIT

if ! acquire_lock; then
  LOCK_EXIT=$?
  if [[ $LOCK_EXIT -eq 10 ]]; then
    exit 0
  fi
  exit $LOCK_EXIT
fi

log "===== START brew-cu ====="

STUCK_PIDS=$(pgrep -f "brew.*fetch --cask|brew cu|brew upgrade --cask")
if [[ -n "$STUCK_PIDS" ]]; then
  log "Found existing brew-related processes:"
  echo "$STUCK_PIDS" | tee -a "$LOG_FILE"
fi

log "Running: brew update"
brew update 2>&1 | tee -a "$LOG_FILE"
UPDATE_EXIT=${PIPESTATUS[0]}

if [[ $UPDATE_EXIT -ne 0 ]]; then
  log "brew update failed with exit code $UPDATE_EXIT"
  notify "brew update failed (exit $UPDATE_EXIT)"
  exit $UPDATE_EXIT
fi

# 第一次执行前先清理 .incomplete
clean_incomplete

log "Running: brew-cu attempt 1"
run_brew_cu
CU_EXIT=$?

if [[ $CU_EXIT -eq 124 ]]; then
  log "brew-cu attempt 1 timed out after 1800 seconds"
fi

if [[ $CU_EXIT -ne 0 ]]; then
  log "brew-cu attempt 1 failed with exit code $CU_EXIT"
  notify "brew-cu failed (exit $CU_EXIT), cleaning .incomplete and retrying..."

  clean_incomplete
  sleep 5

  log "Running: brew-cu attempt 2"
  run_brew_cu
  CU_EXIT=$?

  if [[ $CU_EXIT -eq 124 ]]; then
    log "brew-cu attempt 2 timed out after 1800 seconds"
  fi

  if [[ $CU_EXIT -ne 0 ]]; then
    log "brew-cu retry failed with exit code $CU_EXIT"
    notify "brew-cu retry failed (exit $CU_EXIT)"
  else
    log "brew-cu retry succeeded"
    notify "brew-cu retry succeeded"
  fi
else
  notify "brew-cu succeeded"
fi

log "Running: brew upgrade"
brew upgrade 2>&1 | tee -a "$LOG_FILE"
UPGRADE_EXIT=${PIPESTATUS[0]}

log "Running: brew cleanup"
brew cleanup 2>&1 | tee -a "$LOG_FILE"
CLEANUP_EXIT=${PIPESTATUS[0]}

log "brew-cu exit code: $CU_EXIT"
log "brew upgrade exit code: $UPGRADE_EXIT"
log "brew cleanup exit code: $CLEANUP_EXIT"
log "===== END brew-cu ====="

if [[ $CU_EXIT -ne 0 ]]; then
  exit $CU_EXIT
fi

notify "All brew upgrade tasks completed successfully"
exit 0
