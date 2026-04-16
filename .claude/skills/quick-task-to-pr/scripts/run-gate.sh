#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-$(pwd)}"
DETECT_SCRIPT="$REPO_ROOT/.claude/skills/quick-task-to-pr/scripts/detect-commands.sh"

if [[ ! -x "$DETECT_SCRIPT" ]]; then
  chmod +x "$DETECT_SCRIPT"
fi

eval "$($DETECT_SCRIPT "$REPO_ROOT")"

if [[ -z "$ANALYZE_CMD" && -z "$UNIT_TEST_CMD" ]]; then
  echo "NO_GATE_COMMANDS_DETECTED"
  exit 2
fi

cd "$REPO_ROOT"

if [[ -n "$ANALYZE_CMD" ]]; then
  echo ">>> $ANALYZE_CMD"
  eval "$ANALYZE_CMD"
fi

if [[ -n "$UNIT_TEST_CMD" ]]; then
  echo ">>> $UNIT_TEST_CMD"
  eval "$UNIT_TEST_CMD"
fi
