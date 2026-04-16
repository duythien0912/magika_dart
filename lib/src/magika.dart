import 'magika_result.dart';
import 'prediction_mode.dart';
import 'magika_dart_base.dart';

class Magika {
  Magika._(this._backend, this.predictionMode);

  factory Magika({
    required MagikaBackend backend,
    PredictionMode predictionMode = PredictionMode.highConfidence,
  }) {
    return Magika._(backend, predictionMode);
  }

  final MagikaBackend _backend;
  final PredictionMode predictionMode;

  static Future<Magika> create({
    PredictionMode predictionMode = PredictionMode.highConfidence,
    MagikaBackend? backend,
  }) async {
    final resolvedBackend = backend ?? StubMagikaBackend();
    await resolvedBackend.initialize(predictionMode: predictionMode);
    return Magika._(resolvedBackend, predictionMode);
  }

  Future<MagikaResult> identifyBytes(List<int> bytes) {
    return _backend.identifyBytes(bytes);
  }

  Future<MagikaResult> identifyPath(String path) {
    return _backend.identifyPath(path);
  }
}
