# quick-task-to-pr workflow

`/quick-task-to-pr [TASK-DESC]` runs this local-only workflow.

All workflow artifacts live under:

- `.claude/skills/quick-task-to-pr/outputs/task-brief.md`
- `.claude/skills/quick-task-to-pr/outputs/flutter-test-definitions.md`
- `.claude/skills/quick-task-to-pr/outputs/pr-summary.md`
- `.claude/skills/quick-task-to-pr/outputs/review-notes.md`

## Step-by-step flow

1. Read task and write Behavioral AC via `task-brief-agent`
2. Write Flutter test definitions from ACs via `flutter-test-definition-writer`
3. Run AC coverage review loop via `ac-coverage-reviewer` (max 3)
4. Implement via a local quick-execution flow inspired by GSD quick mode
5. Run build + unit test gate deterministically
6. Run AC-only Flutter tests locally if configured (max 5)
7. Run Flutter test enhancer loop via `flutter-test-enhancer` (max 3)
8. Run the full Flutter test suite locally if configured (max 3)
9. Create PR deterministically when git + GitHub are available
10. Run severity-aware code review loop via `code-review-fixer` (max 10)
11. Merge PR deterministically when all gates pass

## Repo policy

- No Jira.
- No worktrees.
- The task source is only the provided `[TASK-DESC]` and the current local repo state.
- If no runnable Flutter test harness exists yet, Steps 2-3 still produce usable definitions/specs, while Steps 6-8 must clearly report that Flutter test execution is not configured.
- If the repo is not a git repo or there is no GitHub remote, Steps 9 and 11 must stop with a clear explanation.
- Step 4 uses a local quick-execution pattern inspired by GSD quick mode: actionable brief check, direct implementation by default, optional focused delegation, and artifact-driven status/blocker tracking.
- Step 4 does not introduce `gsd-sdk`, `.planning/quick/`, `STATE.md`, subcommands, or external GSD workflow dependencies.
