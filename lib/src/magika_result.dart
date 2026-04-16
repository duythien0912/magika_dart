import 'content_type_info.dart';
import 'overwrite_reason.dart';
import 'status.dart';

class MagikaPrediction {
  const MagikaPrediction({
    required this.model,
    required this.output,
    required this.score,
    this.direct,
    this.overwriteReason = OverwriteReason.none,
    this.didFallback = false,
  });

  final ContentTypeInfo model;
  final ContentTypeInfo? direct;
  final ContentTypeInfo output;
  final double score;
  final OverwriteReason overwriteReason;
  final bool didFallback;
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

  bool get isOk => status == MagikaStatus.ok;
  bool get isUnsupported => status == MagikaStatus.unsupported;
  bool get isRuntimeNotConfigured => status == MagikaStatus.runtimeNotConfigured;
}

class MagikaContentTypes {
  const MagikaContentTypes._();

  static const unknown = ContentTypeInfo(
    label: 'unknown',
    description: 'Unknown binary data',
    mimeType: 'application/octet-stream',
    group: 'unknown',
    isText: false,
  );

  static const genericText = ContentTypeInfo(
    label: 'txt',
    description: 'Generic text document',
    mimeType: 'text/plain',
    group: 'text',
    isText: true,
  );

  static const genericBinary = ContentTypeInfo(
    label: 'unknown_binary',
    description: 'Unknown binary data',
    mimeType: 'application/octet-stream',
    group: 'unknown',
    isText: false,
  );

  static ContentTypeInfo fromLabel(
    String label,
    Map<String, ContentTypeInfo> contentTypes,
  ) {
    if (label == genericBinary.label) {
      return genericBinary;
    }
    return contentTypes[label] ?? unknown;
  }
}

class MagikaPredictions {
  const MagikaPredictions._();

  static const unsupported = MagikaPrediction(
    model: MagikaContentTypes.unknown,
    output: MagikaContentTypes.unknown,
    score: 0,
  );

  static const genericTextFallback = MagikaPrediction(
    model: MagikaContentTypes.unknown,
    direct: MagikaContentTypes.genericText,
    output: MagikaContentTypes.genericText,
    score: 0,
    overwriteReason: OverwriteReason.lowConfidence,
    didFallback: true,
  );

  static const genericBinaryFallback = MagikaPrediction(
    model: MagikaContentTypes.unknown,
    direct: MagikaContentTypes.genericBinary,
    output: MagikaContentTypes.genericBinary,
    score: 0,
    overwriteReason: OverwriteReason.lowConfidence,
    didFallback: true,
  );
}
