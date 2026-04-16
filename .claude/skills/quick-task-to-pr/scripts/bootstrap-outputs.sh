#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-$(pwd)}"
OUTPUT_DIR="$REPO_ROOT/.claude/skills/quick-task-to-pr/outputs"

mkdir -p "$OUTPUT_DIR"

for file in task-brief.md flutter-test-definitions.md pr-summary.md review-notes.md; do
  if [[ ! -f "$OUTPUT_DIR/$file" ]]; then
    : > "$OUTPUT_DIR/$file"
  fi
done

printf 'OUTPUT_DIR=%s\n' "$OUTPUT_DIR"
printf 'TASK_BRIEF_PATH=%s\n' "$OUTPUT_DIR/task-brief.md"
printf 'FLUTTER_TEST_DEFINITIONS_PATH=%s\n' "$OUTPUT_DIR/flutter-test-definitions.md"
printf 'PR_SUMMARY_PATH=%s\n' "$OUTPUT_DIR/pr-summary.md"
printf 'REVIEW_NOTES_PATH=%s\n' "$OUTPUT_DIR/review-notes.md"
