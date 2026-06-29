#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
STATE_FILE="$ROOT/loop/state.md"
PID_FILE="$ROOT/loop/loop.pid"
LOG_FILE="$ROOT/loop/loop.log"

mkdir -p "$ROOT/loop"

seconds_until_midnight() {
  python3 - <<'PY'
from datetime import datetime, timedelta
import os

tz_name = os.environ.get("LOOP_TIMEZONE", "UTC")
try:
    from zoneinfo import ZoneInfo
    now = datetime.now(ZoneInfo(tz_name))
except Exception:
    now = datetime.utcnow()

midnight = (now + timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0)
print(int((midnight - now).total_seconds()))
PY
}

run_refresh() {
  node "$ROOT/scripts/refresh-articles.mjs" "$@"
}

stop_loop() {
  if [[ -f "$PID_FILE" ]]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null || true
    rm -f "$PID_FILE"
    echo "Stopped daily article loop."
  else
    echo "No active loop found."
  fi
}

status_loop() {
  if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "Loop running (pid $(cat "$PID_FILE"))."
    tail -n 5 "$STATE_FILE" 2>/dev/null || true
  else
    echo "Loop is not running."
  fi
}

start_loop() {
  if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "Loop already running (pid $(cat "$PID_FILE"))."
    exit 0
  fi

  (
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Daily article loop started." >> "$STATE_FILE"
    while true; do
      run_refresh >> "$LOG_FILE" 2>&1 || echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Refresh failed." >> "$STATE_FILE"
      sleep "$(seconds_until_midnight)"
    done
  ) >> "$LOG_FILE" 2>&1 &

  echo $! > "$PID_FILE"
  echo "Daily article loop started (pid $(cat "$PID_FILE"))."
  echo "Schedule: refresh at 00:00 (${LOOP_TIMEZONE:-UTC})."
  echo "State: $STATE_FILE"
}

case "${1:-start}" in
  start) start_loop ;;
  stop) stop_loop ;;
  status) status_loop ;;
  once) run_refresh "${@:2}" ;;
  *)
    echo "Usage: $0 {start|stop|status|once [--force]}"
    exit 1
    ;;
esac
