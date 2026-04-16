# magika_dart

`magika_dart` is a Flutter package that brings Google's [Magika](https://github.com/google/magika) file-type identification model to Dart and Flutter using a real bundled ONNX runtime backend.

This package ships the real Magika model assets, loads them from bundled package assets, and runs inference through `flutter_onnxruntime`. It supports byte-based and path-based classification APIs, and the repository includes end-to-end Android/iOS integration coverage through the example host app.

---

> Magika is a novel AI-powered file type detection tool that relies on the recent advance of deep learning to provide accurate detection. Under the hood, Magika employs a custom, highly optimized model that only weighs about a few MBs, and enables precise file identification within milliseconds, even when running on a single CPU. Magika has been trained and evaluated on a dataset of ~100M samples across 200+ content types (covering both binary and textual file formats), and it achieves an average ~99% accuracy on our test set.

Here is an example of what Magika output looks like:

<div style="display: flex; justify-content: center; align-items: center; gap: 10px; flex-wrap: wrap;">
    <img src="https://github.com/duythien0912/magika_dart/blob/main/images/demo-ios.png?raw=true" width="200">
    <img src="https://github.com/duythien0912/magika_dart/blob/main/images/demo-android.png?raw=true" width="220">
    <img src="https://github.com/duythien0912/magika_dart/blob/main/images/demo-cli.png?raw=true" width="500">
</div>
<br/>
Magika is used at scale to help improve Google users' safety by routing Gmail, Drive, and Safe Browsing files to the proper security and content policy scanners, processing hundreds billions samples on a weekly basis.
<br/>

## Features

- Real Magika model inference through `Magika.create()`
- Bundled offline assets for the model, config, and label metadata
- `identifyBytes(List<int>)` for in-memory content classification
- `identifyPath(String)` for real filesystem-path classification
- Structured outputs with:
  - model label
  - output label
  - confidence score
  - overwrite reason
  - fallback metadata
- Prediction modes aligned with upstream Magika concepts:
  - `PredictionMode.highConfidence`
  - `PredictionMode.mediumConfidence`
  - `PredictionMode.bestGuess`
- Verified mobile integration coverage on Android and iOS

## Installation

Add the package to your Flutter project:

```yaml
dependencies:
  magika_dart: ^0.1.0
```

Then import it:

```dart
import 'package:magika_dart/magika_dart.dart';
```

## Usage

### Identify bytes

```dart
import 'package:magika_dart/magika_dart.dart';

Future<void> main() async {
  final magika = await Magika.create(
    predictionMode: PredictionMode.highConfidence,
  );

  final result = await magika.identifyBytes('Hello, Magika!'.codeUnits);

  print(result.status); // MagikaStatus.ok
  print(result.prediction.model.label);
  print(result.prediction.output.label);
  print(result.prediction.score);
}
```

### Identify a file path

```dart
import 'package:magika_dart/magika_dart.dart';

Future<void> main() async {
  final magika = await Magika.create(
    predictionMode: PredictionMode.bestGuess,
  );

  final result = await magika.identifyPath('/path/to/file.pdf');

  print(result.path);
  print(result.status);
  print(result.prediction.output.label);
}
```

## Result model

`MagikaResult` includes:

- `path`
- `status`
- `prediction`

`MagikaPrediction` includes:

- `model`
- `direct`
- `output`
- `score`
- `overwriteReason`
- `didFallback`

## Status values

The package currently surfaces these statuses:

- `MagikaStatus.ok`
- `MagikaStatus.unsupported`
- `MagikaStatus.runtimeNotConfigured`
- `MagikaStatus.error`

## Example app

The repository includes a real mobile example host app under `example/`.

That example app can:
- initialize the real backend
- let you pick a file from the device
- classify the selected file with `identifyPath()`
- show the resulting path, model label, output label, and score

## Testing

The repository includes:

- unit tests at `test/`
- mobile integration tests at `example/integration_test/`
- real fixtures under `example/integration_test/fixtures/`

Android and iOS integration tests are run from `example/` with `flutter drive`.

## Notes

- This package currently focuses on the Android/iOS production path.
- The repository also keeps the backend abstraction in place so runtime strategy can evolve if needed later.
- The bundled assets are part of the package, so the package can work offline once installed.

## Development

Useful commands:

```bash
flutter analyze
flutter test
cd example
flutter test test
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d <device>
```

## Repository

- Repository: https://github.com/duythien0912/magika_dart
- Issue tracker: https://github.com/duythien0912/magika_dart/issues
- Upstream Magika: https://github.com/google/magika
