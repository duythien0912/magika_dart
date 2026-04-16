import 'magika_result.dart';
import 'prediction_mode.dart';
import 'magika_dart_base.dart';

class Magika {
  Magika._(this._backend, this.predictionMode);

  final StubMagikaBackend _backend;
  final PredictionMode predictionMode;

  static Future<Magika> create({PredictionMode predictionMode = PredictionMode.highConfidence}) async {
    final backend = StubMagikaBackend();
    await backend.initialize(predictionMode: predictionMode);
    return Magika._(backend, predictionMode);
  }

  Future<MagikaResult> identifyBytes(List<int> bytes) {
    return _backend.identifyBytes(bytes);
  }

  Future<MagikaResult> identifyPath(String path) {
    return _backend.identifyPath(path);
  }
}
