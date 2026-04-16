---
description: Execute a local task from brief to validation with the best available workflow for this repo.
argument-hint: <task-description>
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, Agent]
---

# quick-task-to-pr

The user only needs to do this:

`/quick-task-to-pr [TASK-DESC]`

Your job is to take that task description and do the best end-to-end local workflow automatically.

## Core behavior

When invoked:

1. Understand the task.
2. Create/update local workflow artifacts.
3. Generate a task brief and acceptance criteria.
4. Generate Flutter test definitions if useful.
5. Implement the task when implementation is needed.
6. Run validation commands when available.
7. Review/fix when relevant.
8. Create PR / merge only when the task and environment call for it.
9. Return a short, useful summary of what happened.

The user should not need to know about your internal steps, files, or agent structure unless something fails.

## Inputs

- Task description: `$ARGUMENTS`
- Repo root: current working directory

If `$ARGUMENTS` is empty, stop immediately and ask for the task description.

## Automatic setup

At the start of every run:

1. Run `.claude/skills/quick-task-to-pr/scripts/bootstrap-outputs.sh <repo-root>`.
2. Use these canonical artifact files for the run:
   - `.claude/skills/quick-task-to-pr/outputs/task-brief.md`
   - `.claude/skills/quick-task-to-pr/outputs/flutter-test-definitions.md`
   - `.claude/skills/quick-task-to-pr/outputs/pr-summary.md`
   - `.claude/skills/quick-task-to-pr/outputs/review-notes.md`
3. Overwrite stale artifact content from earlier runs so the files reflect the current task.

## Hidden internal workflow

Use this internal workflow automatically. Do not burden the user with these details unless needed.

### 1. Task brief
- Spawn `task-brief-agent`.
- Write the result to `task-brief.md`.
- If the task is too ambiguous to make binary ACs, stop and ask the user.

### 2. Flutter test definitions
- Spawn `flutter-test-definition-writer`.
- Write the result to `flutter-test-definitions.md` when no runnable Flutter test placement is clear.
- If the repo has a runnable Flutter test harness, allow real Flutter test files instead.

### 3. AC coverage review
- Spawn `ac-coverage-reviewer`.
- Run up to 3 rounds.
- Stop if acceptable coverage cannot be reached, unless the task is doc-only and the definitions are already sufficient.

### 4. Quick execution
- If the task needs implementation, run a compact local execution flow inspired by GSD quick mode.
- Use `task-brief.md` as the source of truth, confirm the brief is actionable, then implement directly unless a focused implementation agent would clearly help.
- Record implementation status, remaining work, and blockers in the canonical output artifacts instead of introducing separate quick-task state directories.
- If the task is doc-only or planning-only, create the requested artifact and do not overreach.

### 5. Validation
- Run `.claude/skills/quick-task-to-pr/scripts/run-gate.sh` when commands are detectable.
- Stop before PR creation if validation fails.

### 6. Flutter test execution
- Run `.claude/skills/quick-task-to-pr/scripts/run-flutter-tests.sh <repo> ac` and `all` only when Flutter test execution is actually configured.
- Otherwise mark Flutter test execution as skipped and explain briefly.

### 7. Flutter test enhancement
- Spawn `flutter-test-enhancer` only when it is useful.
- Up to 3 rounds.

### 8. PR creation
- Create a PR only when:
  - the task resulted in meaningful code changes, and
  - the repo/git/GitHub environment supports it, and
  - the user’s request implies PR behavior.
- Skip PR creation for simple local-only planning/doc tasks.

### 9. Code review
- Spawn `code-review-fixer` only when source changes were made.
- Up to 10 rounds.

### 10. Merge
- Merge only when:
  - a PR exists,
  - validation passed,
  - and the user’s request/environment support merge.

## Decision rules

- No Jira.
- No worktrees.
- Use only the local repo state plus the provided task description.
- Prefer doing the right amount of work for the task:
  - small task → finish simply
  - real feature task → run the fuller workflow
- Do not force PR/merge for a task that is fully satisfied locally.
- Do not hide blockers. If something stops the workflow, say exactly what and why.
- If no runnable Flutter test harness exists, still produce useful Flutter test definitions and continue where reasonable.

## Agent map

Use these exact agent names internally:
- `task-brief-agent`
- `flutter-test-definition-writer`
- `ac-coverage-reviewer`
- `flutter-test-enhancer`
- `code-review-fixer`

## What to tell the user at the end

Keep the final response simple and practical:
- what you completed
- what files changed
- validation result
- what was skipped and why
- PR/merge status if relevant

Do not dump the full internal workflow unless the user asks.
