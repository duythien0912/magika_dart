---
name: quick-task-to-pr
description: Turn a freeform task description into local artifacts, implementation, verification, PR, review loop, and merge when the repo environment supports it.
argument-hint: <task-description>
user-invocable: true
---

# quick-task-to-pr

You are the project-local orchestrator for `/quick-task-to-pr [TASK-DESC]`.

The user invoked this skill with:

`$ARGUMENTS`

## Inputs

- Task description: `$ARGUMENTS`
- Repo root: current working directory

If `$ARGUMENTS` is empty, stop immediately and ask the user for a task description.

## Output artifacts

Create and use this local output folder:

- `.claude/skills/quick-task-to-pr/outputs/`

Use these files consistently:

- `.claude/skills/quick-task-to-pr/outputs/task-brief.md`
- `.claude/skills/quick-task-to-pr/outputs/flutter-test-definitions.md`
- `.claude/skills/quick-task-to-pr/outputs/pr-summary.md`
- `.claude/skills/quick-task-to-pr/outputs/review-notes.md`

Create the outputs directory if it does not exist.

## Workflow

### Step 1 — Task brief
- Reads: `$ARGUMENTS`, relevant repo files, optional `CLAUDE.md`
- Writes: `outputs/task-brief.md`
- Agent: `task-brief-agent`
- Stop when: the task is too ambiguous to make binary ACs
- Skip when: never

### Step 2 — Flutter test definitions
- Reads: `outputs/task-brief.md`, existing Flutter test patterns if any
- Writes: `outputs/flutter-test-definitions.md` or runnable Flutter test files if the repo already has a harness
- Agent: `flutter-test-definition-writer`
- Stop when: Step 1 failed
- Skip when: never

### Step 3 — AC coverage review loop
- Reads: `outputs/task-brief.md`, `outputs/flutter-test-definitions.md` and/or generated Flutter test files
- Writes: updates to `outputs/flutter-test-definitions.md` or missing Flutter test files
- Agent: `ac-coverage-reviewer`
- Loop: max 3 rounds
- Stop when: Step 2 failed
- Skip when: never

### Step 4 — Quick execution
- Reads: `outputs/task-brief.md`, relevant source files
- Writes: source code changes in the repo, plus implementation status in `outputs/pr-summary.md` and blockers/notes in `outputs/review-notes.md`
- Mode: local-only quick execution inspired by GSD quick mode, using the current repo plus the canonical output artifacts
- Execution pattern:
  - first confirm the task brief is actionable enough to implement without a separate planning system
  - implement directly for simple, well-bounded changes
  - use a focused implementation agent only when the change is multi-file or clearly benefits from delegation
  - capture what changed, what remains, and any blockers in the output artifacts so later steps can continue deterministically
- Stop when: task brief is not actionable
- Skip when: never

### Step 5 — Build + unit test gate
- Reads: repo files and detected commands
- Writes: no artifact required, but summarize results in `outputs/pr-summary.md`
- Command: `.claude/skills/quick-task-to-pr/scripts/run-gate.sh`
- Stop when: no gate commands are detected or the gate fails
- Skip when: only if the repo truly has no detectable Dart/Flutter project structure, and this is reported explicitly

### Step 6 — AC-only Flutter test execution
- Reads: detected Flutter test commands plus AC definitions/specs
- Writes: append status to `outputs/pr-summary.md`
- Command: `.claude/skills/quick-task-to-pr/scripts/run-flutter-tests.sh <repo> ac`
- Loop: max 5 attempts
- Stop when: runnable Flutter tests exist and keep failing after max attempts
- Skip when: no Flutter test command is detected; report `Flutter test execution not configured`

### Step 7 — Flutter test enhancement loop
- Reads: changed source files, Flutter test files/definitions
- Writes: improved Flutter test files/definitions and notes in `outputs/review-notes.md`
- Agent: `flutter-test-enhancer`
- Loop: max 3 rounds
- Stop when: Step 6 is blocked by persistent runnable Flutter test failures
- Skip when: Flutter test execution is not configured and only definitions exist

### Step 8 — Full Flutter test execution
- Reads: detected Flutter test commands and full Flutter test suite
- Writes: append status to `outputs/pr-summary.md`
- Command: `.claude/skills/quick-task-to-pr/scripts/run-flutter-tests.sh <repo> all`
- Loop: max 3 attempts
- Stop when: runnable Flutter tests exist and keep failing after max attempts
- Skip when: no Flutter test command is detected; report `Flutter test execution not configured`

### Step 9 — Create PR
- Reads: repo git state, `outputs/pr-summary.md`
- Writes: PR on GitHub when supported
- Command path: `gh pr create`
- Stop when: repo is not git, branch is not ready, or GitHub remote is unavailable
- Skip when: environment does not support PR creation; report clearly

### Step 10 — Code review loop
- Reads: changed files and prior review notes
- Writes: `outputs/review-notes.md`
- Agent: `code-review-fixer`
- Loop: max 10 rounds
- Stop when: critical/high bugs keep appearing and do not converge
- Skip when: no code changed

### Step 11 — Merge PR
- Reads: PR status and prior gate results
- Writes: merged PR on GitHub when supported
- Command path: `gh pr merge`
- Stop when: any required gate failed or no PR exists
- Skip when: environment does not support merge

## Hard rules

- No Jira.
- No worktrees.
- Use only the local repo state plus the provided task description.
- Do not hide blockers; report exactly which step stopped or was skipped and why.
- Do not merge when any required gate failed.
- If no runnable Flutter test harness exists, still produce useful Flutter test definitions and clearly mark execution steps as skipped.
- Step 4 reuses the intent of GSD quick mode locally, but does not require `gsd-sdk`, `.planning/quick/`, `STATE.md`, subcommands, or any external GSD workflow files.

## Agent naming

Use these agent names exactly:
- `task-brief-agent`
- `flutter-test-definition-writer`
- `ac-coverage-reviewer`
- `flutter-test-enhancer`
- `code-review-fixer`

## Final report

At the end, report:
- completed steps
- stopped/skipped steps with reasons
- files created/updated
- build/test results
- PR status
- merge status
