import 'content_type_info.dart';
import 'magika_result.dart';
import 'overwrite_reason.dart';
import 'prediction_mode.dart';
import 'status.dart';

class StubMagikaBackend {
  Future<void> initialize({PredictionMode predictionMode = PredictionMode.highConfidence}) async {}

  Future<MagikaResult> identifyBytes(List<int> bytes) async {
    return MagikaResult(
      path: '-',
      status: MagikaStatus.unsupported,
      prediction: const MagikaPrediction(
        dl: ContentTypeInfo(
          label: 'undefined',
          description: 'Undefined',
          mimeType: 'application/octet-stream',
          group: 'unknown',
          isText: false,
        ),
        output: ContentTypeInfo(
          label: 'unknown',
          description: 'Unknown binary data',
          mimeType: 'application/octet-stream',
          group: 'unknown',
          isText: false,
        ),
        score: 0,
        overwriteReason: OverwriteReason.none,
      ),
    );
  }

  Future<MagikaResult> identifyPath(String path) async {
    return identifyBytes(const <int>[]);
  }
}
