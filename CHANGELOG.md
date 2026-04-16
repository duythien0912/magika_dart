## 0.1.2
- Update desc

## 0.1.1
- Ship `identifyString` , `identifyFile`
- Update desc

## 0.1.0

- Ship the real bundled Magika model, config, and metadata assets.
- Add a real ONNX-backed backend using `flutter_onnxruntime`.
- Make `Magika.create()` use the real backend by default.
- Support real filesystem path classification via `identifyPath()`.
- Add Android/iOS example host apps with end-to-end mobile integration coverage.
- Add fixture-based integration coverage for bytes, paths, empty input, whitespace-trimmed text, and prediction-mode behavior.
- Update the example app to let users pick a file and classify it with Magika.
