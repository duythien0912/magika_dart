import 'magika_result.dart';
import 'prediction_mode.dart';
import 'status.dart';

abstract interface class MagikaBackend {
  Future<void> initialize({PredictionMode predictionMode = PredictionMode.highConfidence});

  Future<MagikaResult> identifyBytes(List<int> bytes);

  Future<MagikaResult> identifyPath(String path);
}

class StubMagikaBackend implements MagikaBackend {
  bool _initialized = false;

  @override
  Future<void> initialize({PredictionMode predictionMode = PredictionMode.highConfidence}) async {
    _initialized = true;
  }

  @override
  Future<MagikaResult> identifyBytes(List<int> bytes) async {
    if (!_initialized) {
      return const MagikaResult(
        path: '-',
        status: MagikaStatus.runtimeNotConfigured,
        prediction: MagikaPredictions.unsupported,
      );
    }

    return MagikaResult(
      path: '-',
      status: MagikaStatus.unsupported,
      prediction: _predictionForBytes(bytes),
    );
  }

  @override
  Future<MagikaResult> identifyPath(String path) async {
    final result = await identifyBytes(const <int>[]);
    return MagikaResult(
      path: path,
      status: result.status,
      prediction: result.prediction,
    );
  }

  MagikaPrediction _predictionForBytes(List<int> bytes) {
    if (bytes.isEmpty) {
      return MagikaPredictions.unsupported;
    }

    final isText = bytes.every((byte) => byte == 9 || byte == 10 || byte == 13 || (byte >= 32 && byte <= 126));
    if (isText) {
      return MagikaPredictions.genericTextFallback;
    }

    return MagikaPredictions.genericBinaryFallback;
  }
}
