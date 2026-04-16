# TODO / Roadmap

## Phase 1 — Package cleanup
- [ ] Replace placeholder README content with project-specific documentation.
- [ ] Add repository metadata to `pubspec.yaml`.
- [ ] Decide whether this package remains pure Dart first or becomes a federated Flutter plugin later.

## Phase 2 — Public API refinement
- [ ] Finalize the public `Magika` API shape.
- [ ] Expand `MagikaResult` and metadata models to match upstream concepts more closely.
- [ ] Define what unsupported/runtime-not-configured states look like for callers.

## Phase 3 — Backend architecture
- [ ] Replace the current stub backend with an explicit backend interface.
- [ ] Decide the first production backend strategy: native/FFI vs pure Dart experiment.
- [ ] Define where model files/configs live and how they are loaded.

## Phase 4 — Magika integration spike
- [ ] Reproduce upstream feature extraction behavior for a small sample.
- [ ] Validate label/output mapping against upstream Magika examples.
- [ ] Measure platform/runtime constraints for Dart usage.

## Phase 5 — Testing and examples
- [ ] Add richer unit tests for result objects and backend behavior.
- [ ] Replace the placeholder example with a meaningful Magika usage example.
- [ ] Add fixture-based tests once real detection logic exists.

## Phase 6 — Automation workflow
- [ ] Make `/quick-task-to-pr` execute artifact creation more directly.
- [ ] Add sample outputs for task brief, review notes, and PR summary.
- [ ] Validate PR/review flow on a real feature branch.
