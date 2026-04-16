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
- `.claude/skills/quick-task-to-pr/outputs/e2e-definitions.md`
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

### Step 2 — E2E definitions
- Reads: `outputs/task-brief.md`, existing E2E patterns if any
- Writes: `outputs/e2e-definitions.md` or runnable E2E spec files if the repo already has a harness
- Agent: `e2e-definition-writer`
- Stop when: Step 1 failed
- Skip when: never

### Step 3 — AC coverage review loop
- Reads: `outputs/task-brief.md`, `outputs/e2e-definitions.md` and/or generated E2E specs
- Writes: updates to `outputs/e2e-definitions.md` or missing E2E spec files
- Agent: `ac-coverage-reviewer`
- Loop: max 3 rounds
- Stop when: Step 2 failed
- Skip when: never

### Step 4 — Implementation
- Reads: `outputs/task-brief.md`, relevant source files
- Writes: source code changes in the repo
- Agent use: optional; implementation can be done directly in the main conversation
- Stop when: task brief is not actionable
- Skip when: never

### Step 5 — Build + unit test gate
- Reads: repo files and detected commands
- Writes: no artifact required, but summarize results in `outputs/pr-summary.md`
- Command: `.claude/skills/quick-task-to-pr/scripts/run-gate.sh`
- Stop when: no gate commands are detected or the gate fails
- Skip when: only if the repo truly has no detectable Dart/Flutter project structure, and this is reported explicitly

### Step 6 — AC-only E2E execution
- Reads: detected E2E commands plus AC definitions/specs
- Writes: append status to `outputs/pr-summary.md`
- Command: `.claude/skills/quick-task-to-pr/scripts/run-e2e.sh <repo> ac`
- Loop: max 5 attempts
- Stop when: runnable E2E exists and keeps failing after max attempts
- Skip when: no E2E command is detected; report `E2E execution not configured`

### Step 7 — E2E enhancement loop
- Reads: changed source files, E2E specs/definitions
- Writes: improved E2E specs/definitions and notes in `outputs/review-notes.md`
- Agent: `e2e-enhancer`
- Loop: max 3 rounds
- Stop when: Step 6 is blocked by persistent runnable E2E failures
- Skip when: E2E execution is not configured and only definitions exist

### Step 8 — All E2E execution
- Reads: detected E2E commands and full E2E suite
- Writes: append status to `outputs/pr-summary.md`
- Command: `.claude/skills/quick-task-to-pr/scripts/run-e2e.sh <repo> all`
- Loop: max 3 attempts
- Stop when: runnable E2E exists and keeps failing after max attempts
- Skip when: no E2E command is detected; report `E2E execution not configured`

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
- If no runnable E2E harness exists, still produce useful E2E definitions and clearly mark execution steps as skipped.
- Step 4 is the future seam for `gsd-planner/executor`, but currently uses Claude-native implementation.

## Agent naming

Use these agent names exactly:
- `task-brief-agent`
- `e2e-definition-writer`
- `ac-coverage-reviewer`
- `e2e-enhancer`
- `code-review-fixer`

## Final report

At the end, report:
- completed steps
- stopped/skipped steps with reasons
- files created/updated
- build/test results
- PR status
- merge status
