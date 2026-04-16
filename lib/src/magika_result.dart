import 'content_type_info.dart';
import 'overwrite_reason.dart';
import 'status.dart';

/// Describes the raw and final labels chosen for a classification.
class MagikaPrediction {
  const MagikaPrediction({
    required this.model,
    required this.output,
    required this.score,
    this.direct,
    this.overwriteReason = OverwriteReason.none,
    this.didFallback = false,
  });

  /// Label returned by the model before overwrite or fallback rules are applied.
  final ContentTypeInfo model;

  /// Final label when it differs from [model], otherwise `null`.
  final ContentTypeInfo? direct;

  /// Final label exposed to callers after overwrite and confidence rules run.
  final ContentTypeInfo output;

  /// Confidence score associated with [model].
  final double score;

  /// Why [output] differs from [model].
  final OverwriteReason overwriteReason;

  /// Whether the result fell back to a generic label.
  final bool didFallback;
}

/// Result returned by Magika for a single input.
class MagikaResult {
  const MagikaResult({
    required this.path,
    required this.status,
    required this.prediction,
  });

  /// Source path for file-based identification, or `-` for in-memory input.
  final String path;

  /// Overall execution status of the identification request.
  final MagikaStatus status;

  /// Prediction payload for the input.
  final MagikaPrediction prediction;

  /// Whether identification completed successfully.
  bool get isOk => status == MagikaStatus.ok;

  /// Whether the active backend reported that this input is unsupported.
  bool get isUnsupported => status == MagikaStatus.unsupported;

  /// Whether the backend was used before initialization completed.
  bool get isRuntimeNotConfigured =>
      status == MagikaStatus.runtimeNotConfigured;
}

/// Shared built-in content type descriptors used by fallback logic.
class MagikaContentTypes {
  const MagikaContentTypes._();

  /// Default label used when no better content type is known.
  static const unknown = ContentTypeInfo(
    label: 'unknown',
    description: 'Unknown binary data',
    mimeType: 'application/octet-stream',
    group: 'unknown',
    isText: false,
  );

  /// Generic text fallback used when Magika only knows the input is text.
  static const genericText = ContentTypeInfo(
    label: 'txt',
    description: 'Generic text document',
    mimeType: 'text/plain',
    group: 'text',
    isText: true,
  );

  /// Generic binary fallback used when Magika only knows the input is binary.
  static const genericBinary = ContentTypeInfo(
    label: 'unknown_binary',
    description: 'Unknown binary data',
    mimeType: 'application/octet-stream',
    group: 'unknown',
    isText: false,
  );

  /// Resolves a label from metadata, preserving built-in fallback labels.
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

/// Reusable prediction constants for unsupported and fallback cases.
class MagikaPredictions {
  const MagikaPredictions._();

  /// Default prediction used when no classification could be performed.
  static const unsupported = MagikaPrediction(
    model: MagikaContentTypes.unknown,
    output: MagikaContentTypes.unknown,
    score: 0,
  );

  /// Fallback prediction for inputs that can only be identified as text.
  static const genericTextFallback = MagikaPrediction(
    model: MagikaContentTypes.unknown,
    direct: MagikaContentTypes.genericText,
    output: MagikaContentTypes.genericText,
    score: 0,
    overwriteReason: OverwriteReason.lowConfidence,
    didFallback: true,
  );

  /// Fallback prediction for inputs that can only be identified as binary.
  static const genericBinaryFallback = MagikaPrediction(
    model: MagikaContentTypes.unknown,
    direct: MagikaContentTypes.genericBinary,
    output: MagikaContentTypes.genericBinary,
    score: 0,
    overwriteReason: OverwriteReason.lowConfidence,
    didFallback: true,
  );
}
