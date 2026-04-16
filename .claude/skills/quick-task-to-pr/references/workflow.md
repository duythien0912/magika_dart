# quick-task-to-pr workflow

`/quick-task-to-pr [TASK-DESC]` runs this local-only workflow.

All workflow artifacts live under:

- `.claude/skills/quick-task-to-pr/outputs/task-brief.md`
- `.claude/skills/quick-task-to-pr/outputs/e2e-definitions.md`
- `.claude/skills/quick-task-to-pr/outputs/pr-summary.md`
- `.claude/skills/quick-task-to-pr/outputs/review-notes.md`

## Step-by-step flow

1. Read task and write Behavioral AC via `task-brief-agent`
2. Write E2E test definitions from ACs via `e2e-definition-writer`
3. Run AC coverage review loop via `ac-coverage-reviewer` (max 3)
4. Implement via Claude-native full implementation flow
5. Run build + unit test gate deterministically
6. Run AC-only E2E locally if an E2E runner exists (max 5)
7. Run E2E enhancer loop via `e2e-enhancer` (max 3)
8. Run all E2E locally if an E2E runner exists (max 3)
9. Create PR deterministically when git + GitHub are available
10. Run severity-aware code review loop via `code-review-fixer` (max 10)
11. Merge PR deterministically when all gates pass

## Repo policy

- No Jira.
- No worktrees.
- The task source is only the provided `[TASK-DESC]` and the current local repo state.
- If no runnable E2E harness exists yet, Steps 2-3 still produce usable definitions/specs, while Steps 6-8 must clearly report that E2E execution is not configured.
- If the repo is not a git repo or there is no GitHub remote, Steps 9 and 11 must stop with a clear explanation.
- Step 4 is a future seam for `gsd-planner/executor`, but currently uses Claude-native planning + implementation.
