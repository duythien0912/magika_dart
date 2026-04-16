#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-$(pwd)}"
MODE="${2:-ac}"
DETECT_SCRIPT="$REPO_ROOT/.claude/skills/quick-task-to-pr/scripts/detect-commands.sh"

if [[ ! -x "$DETECT_SCRIPT" ]]; then
  chmod +x "$DETECT_SCRIPT"
fi

eval "$($DETECT_SCRIPT "$REPO_ROOT")"

case "$MODE" in
  ac)
    CMD="$E2E_AC_CMD"
    ;;
  all)
    CMD="$E2E_ALL_CMD"
    ;;
  *)
    echo "Unknown mode: $MODE" >&2
    exit 1
    ;;
esac

if [[ -z "$CMD" ]]; then
  echo "NO_E2E_COMMAND_DETECTED"
  exit 3
fi

cd "$REPO_ROOT"
echo ">>> $CMD"
eval "$CMD"
