# magika_dart

`magika_dart` is an early-stage Dart package for Magika-inspired content-type identification.

The current repository provides the public package surface and a stub backend so applications can start integrating against the API shape before a production classifier backend is wired in.

## Current status

This package is still a scaffold:
- the public `Magika` API is available
- prediction mode configuration is exposed during initialization
- identification calls currently resolve through a stub backend
- results currently report unsupported/unknown content rather than real model-backed predictions

## Features

- Simple async package entrypoint via `Magika.create()`
- Byte-based identification with `identifyBytes`
- Path-based identification with `identifyPath`
- Structured result objects with status and content-type metadata
- Prediction mode enum ready for future backend integration

## Getting started

Add the package to your Dart project, then import the library entrypoint:

```dart
import 'package:magika_dart/magika_dart.dart';
```

This package currently targets Dart SDK `^3.11.3`.

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

## Notes for adopters

At the moment, this package is best treated as an integration scaffold rather than a finished file-type detection library. If you build against it today, expect the API surface to be more stable than the backend behavior.

## Development

The repository is a plain Dart package with `test` and `lints` configured in `pubspec.yaml`. If you extend the implementation, keep the README aligned with the currently shipped API and behavior.

## Additional information

No repository URL or issue tracker is configured in this repo yet, so project metadata and contribution links will need to be added later alongside the real backend implementation.
