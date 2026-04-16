# magika_dart

`magika_dart` is an early-stage Flutter package and Dart port of [Magika](https://github.com/google/magika), Google's AI-powered file type identification project.

Upstream Magika combines a compact deep-learning model with file-content sampling to classify 200+ content types with near-constant inference time, even on CPU-only environments. This repository does **not** ship that classifier yet; it currently exposes a Dart-friendly API scaffold that is intended to evolve toward real Magika-compatible behavior.

## Current status

Today this package is a scaffold, not a production detector:
- the public `Magika` API exists
- prediction mode configuration is exposed during initialization
- identification calls currently go through a stub backend
- results currently report unsupported or unknown content instead of real model-backed predictions
- the repo now has Flutter package scaffolding so it can evolve toward broader package/plugin integration

If you integrate this package now, treat it as an API and architecture starting point rather than a drop-in replacement for upstream Magika.

## What upstream Magika provides

According to the Google Magika docs and repository, the upstream project offers:
- AI-based file type identification across 200+ content types
- a compact model measured in a few MB
- inference in milliseconds after model load, even on a single CPU
- near-constant inference time because it only inspects selected portions of file content
- per-content-type trust thresholds that can fall back to generic outputs such as "Generic text document" or "Unknown binary data"
- configurable prediction modes including `high-confidence`, `medium-confidence`, and `best-guess`
- multiple bindings and distribution formats, including CLI, Python, JavaScript/TypeScript, Rust, and Go work

Those upstream characteristics are the target shape for this Dart/Flutter port, but they are not fully implemented here yet.

## Current package features

- Async package entrypoint via `Magika.create()`
- Byte-based identification with `identifyBytes`
- Path-based identification with `identifyPath`
- Structured result objects with status and content-type metadata
- Prediction mode enum aligned with upstream concepts and ready for backend integration

## Getting started

Add the package to your project, then import the library entrypoint:

```dart
import 'package:magika_dart/magika_dart.dart';
```

This package currently targets Dart SDK `^3.11.3` and now includes Flutter package scaffolding.

## Usage

```dart
import 'package:magika_dart/magika_dart.dart';

Future<void> main() async {
  final magika = await Magika.create(
    predictionMode: PredictionMode.highConfidence,
  );

  final bytesResult = await magika.identifyBytes('Hello, world!'.codeUnits);
  print(bytesResult.status);
  print(bytesResult.prediction.output.label);

  final pathResult = await magika.identifyPath('example.txt');
  print(pathResult.path);
}
```

## API overview

`magika_dart` currently exports:
- `Magika` for client creation and identification calls
- `MagikaResult` and `MagikaPrediction` for result inspection
- `ContentTypeInfo` for content-type metadata
- `PredictionMode`, `OverwriteReason`, and `MagikaStatus` enums

## Roadmap themes

The next major steps for this repository are:
- replace the stub backend with a real classifier backend abstraction
- decide whether the first working backend should be pure Dart, FFI-backed, or model-runtime based
- reproduce upstream feature extraction and output mapping behavior
- align result metadata and fallback behavior with upstream Magika concepts
- add fixture-based validation against known upstream-style examples

See `TODO.md` for the current roadmap.

## Development

The repository now uses Flutter package scaffolding with the existing Dart library preserved under `lib/src/`. If you change the implementation, keep this README aligned with the code that actually ships.

## Contributing and support

- Repository: https://github.com/duythien0912/magika_dart
- Issue tracker: https://github.com/duythien0912/magika_dart/issues

There is not yet a dedicated contribution guide in this repository, so issues and pull requests should currently flow through GitHub.

## References

- Google Magika docs: https://securityresearch.google/magika/introduction/overview/
- Upstream repository: https://github.com/google/magika
- Research paper and citation index: https://securityresearch.google/magika/additional-resources/research-papers-and-citation/

## Additional information

This repository still needs richer package metadata, contribution guidance, and a real backend implementation. Until then, prefer describing it as an early Dart/Flutter port scaffold rather than a finished Magika implementation.
