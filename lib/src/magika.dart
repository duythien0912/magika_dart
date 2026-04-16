import 'dart:io';

import 'magika_dart_base.dart';
import 'magika_result.dart';
import 'prediction_mode.dart';

/// High-level entry point for identifying file content with a configured backend.
class Magika {
  Magika._(this._backend, this.predictionMode, this.backendConfig);

  /// Creates a [Magika] instance around an already constructed backend.
  factory Magika({
    required MagikaBackend backend,
    PredictionMode predictionMode = PredictionMode.highConfidence,
    MagikaBackendConfig backendConfig = const MagikaBackendConfig(),
  }) {
    return Magika._(backend, predictionMode, backendConfig);
  }

  final MagikaBackend _backend;

  /// Confidence policy used when the backend was initialized.
  final PredictionMode predictionMode;

  /// Backend configuration associated with this instance.
  final MagikaBackendConfig backendConfig;

  /// Creates and initializes a backend before returning a ready-to-use instance.
  static Future<Magika> create({
    PredictionMode predictionMode = PredictionMode.highConfidence,
    MagikaBackend? backend,
    MagikaBackendConfig backendConfig = const MagikaBackendConfig(),
  }) async {
    final resolvedBackend =
        backend ?? RealMagikaBackend(backendConfig: backendConfig);
    await resolvedBackend.initialize(predictionMode: predictionMode);
    return Magika._(resolvedBackend, predictionMode, backendConfig);
  }

  /// Identifies the content type for raw bytes.
  Future<MagikaResult> identifyBytes(List<int> bytes) {
    return _backend.identifyBytes(bytes);
  }

  /// Identifies the content type for a Dart string.
  Future<MagikaResult> identifyString(String text) {
    return identifyBytes(text.codeUnits);
  }

  /// Reads and identifies the file at [path].
  Future<MagikaResult> identifyPath(String path) {
    return _backend.identifyPath(path);
  }

  /// Reads and identifies the provided [file].
  Future<MagikaResult> identifyFile(File file) {
    return identifyPath(file.path);
  }
}
