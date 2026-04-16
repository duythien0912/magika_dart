## Original Requirement
Create TODO/roadmap.

## Context
This repository is a newly scaffolded Dart package for Magika bindings. The immediate need is a lightweight planning artifact that captures the next implementation milestones so development can proceed in a structured way.

## Scope
- Create a repository-local TODO/roadmap artifact.
- Capture near-term milestones for Magika Dart package development.
- Keep the roadmap aligned with the current scaffold and README direction.

## Out of Scope
- Implementing the real Magika backend.
- Adding CI/CD.
- Publishing to pub.dev.
- Writing a full design document.

## Behavioral AC
1. A roadmap file exists in the repository with clearly labeled phases.
2. The roadmap includes near-term work for public API, backend architecture, model/runtime integration, and testing.
3. The roadmap distinguishes immediate scaffold tasks from later production tasks.
4. The roadmap is readable as a developer checklist, not only as prose.

## Failure Modes
- The roadmap is too vague to guide implementation.
- The roadmap duplicates README content without actionable next steps.
- The roadmap assumes a backend choice that has not yet been made.

## Test Strategy
- Verify the roadmap file exists at the intended path.
- Verify it contains actionable checklist items grouped by phase.
- Verify the tasks reflect the current Dart package scaffold.

## Key Files
- `README.md` — source of current implementation direction.
- `pubspec.yaml` — confirms this is currently a Dart package.
- `lib/magika_dart.dart` — current public API entrypoint.
- `lib/src/magika.dart` — current Magika stub API.
- `TODO.md` — proposed roadmap output.

## AI Complexity Estimate
Routine — one new planning file plus alignment with existing repo direction.
