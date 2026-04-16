import 'content_type_info.dart';
import 'overwrite_reason.dart';
import 'status.dart';

class MagikaPrediction {
  const MagikaPrediction({
    required this.dl,
    required this.output,
    required this.score,
    this.overwriteReason = OverwriteReason.none,
  });

  final ContentTypeInfo dl;
  final ContentTypeInfo output;
  final double score;
  final OverwriteReason overwriteReason;
}

class MagikaResult {
  const MagikaResult({
    required this.path,
    required this.status,
    required this.prediction,
  });

  final String path;
  final MagikaStatus status;
  final MagikaPrediction prediction;
}
