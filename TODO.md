# TODO / Roadmap

## Phase 1 — Package and metadata cleanup
- [x] Replace placeholder README content with project-specific documentation grounded in upstream Magika references.
- [x] Add repository metadata to `pubspec.yaml`.
- [x] Add contribution and support links that point at the existing GitHub repo and issue tracker.
- [x] Convert the plain Dart package into Flutter package scaffolding using `flutter create --template=package` while preserving the current library API.

## Phase 2 — Public API alignment with Magika concepts
- [x] Finalize the public `Magika` API shape.
- [x] Expand `MagikaResult` and metadata models to reflect upstream concepts such as `output`, model/direct labels, score, and fallback behavior.
- [x] Define how `unknown`, generic text/binary fallbacks, and unsupported/runtime-not-configured states are surfaced to callers.
- [x] Confirm prediction mode naming and semantics against upstream `high-confidence`, `medium-confidence`, and `best-guess` behavior.

## Phase 3 — Backend architecture
- [ ] Replace the current stub backend with an explicit backend interface.
- [ ] Decide the first production backend strategy: pure Dart experiment, native/FFI bridge, or model-runtime integration.
- [ ] Define where model files, thresholds, and label metadata live and how they are loaded.
- [ ] Decide whether the package should support offline bundled assets, externally downloaded models, or both.

## Phase 4 — Classifier parity spike
- [ ] Reproduce upstream feature extraction behavior for a small sample.
- [ ] Validate label and MIME/output mapping against upstream Magika examples.
- [ ] Measure whether Dart can preserve Magika's near-constant runtime by sampling only selected byte regions instead of scanning whole files.
- [ ] Compare Dart-side outputs against known upstream examples for text, binary, empty, and ambiguous files.

## Phase 5 — Bindings and UX scope
- [ ] Decide whether this repo should remain a library-first package or also grow a Dart CLI.
- [ ] Evaluate whether stream-based identification belongs in the first stable API, mirroring upstream bindings.
- [ ] Decide how recursive directory scanning or batch identification should map into Dart ergonomics.

## Phase 6 — Testing and examples
- [ ] Add richer unit tests for result objects and backend behavior.
- [ ] Replace the placeholder example with a Magika-oriented usage example that clearly documents current stub behavior.
- [ ] Add fixture-based tests once real detection logic exists.
- [ ] Add cross-check tests using a small corpus of files with expected upstream-style labels.

## Phase 7 — Automation workflow
- [ ] Make `/quick-task-to-pr` execute artifact creation more directly.
- [ ] Add sample outputs for task brief, review notes, and PR summary.
- [ ] Validate PR/review flow on a real feature branch.
