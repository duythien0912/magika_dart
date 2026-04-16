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
- [x] Replace the current stub backend with an explicit backend interface.
- [x] Decide the first production backend strategy: native/FFI bridge.
- [x] Define where model files, thresholds, and label metadata live and how they are loaded.
- [x] package should support offline bundled assets.
- [x] Vendor the real upstream Magika model/config/metadata assets into the package.
- [x] Implement a real ONNX-backed backend with bundled asset loading and honest runtime failures.
- [x] Make `Magika.create()` use the real backend by default.
- [x] Support `identifyPath()` against real filesystem paths.

## Phase 4 — Mobile host app and end-to-end verification
- [x] Create a real Android/iOS example host app for running the package on device.
- [x] Add real integration fixtures inside `example/integration_test/fixtures/`.
- [x] Consolidate mobile integration coverage into `example/integration_test/`.
- [x] Verify the bundled model end-to-end on Android.
- [x] Verify the bundled model end-to-end on iOS.
- [x] Expand integration coverage for fixture classification, empty bytes, whitespace-trimmed text, `identifyPath()`, and confidence-mode invariants.
- [x] Update the example app to let users pick a file and classify it with Magika.

## Phase 5 — Docs and release polish
- [ ] Update README/example docs to describe the real backend, mobile host app, and file-picking example flow.
- [ ] Review package metadata and release notes for the first production-ready milestone.
- [ ] Prepare commit/PR for the completed mobile + integration work.

## Notes
- Android and iOS integration tests are run from `example/` with `flutter drive`.
- Real test coverage lives under `example/integration_test/`, not the repo root.
- The package now uses real production assets and should avoid fake/placeholder behavior.

## Next recommended step
- [ ] Finish Phase 5 docs/release polish.
