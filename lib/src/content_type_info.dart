/// Metadata describing a content type label emitted by Magika.
class ContentTypeInfo {
  const ContentTypeInfo({
    required this.label,
    required this.description,
    required this.mimeType,
    required this.group,
    required this.isText,
    this.extensions = const <String>[],
  });

  /// Builds a content type from the bundled Magika metadata schema.
  ///
  /// Missing fields fall back to conservative defaults so partially defined
  /// metadata can still be loaded.
  factory ContentTypeInfo.fromJson(String label, Map<String, dynamic> json) {
    return ContentTypeInfo(
      label: label,
      description: (json['description'] as String?) ?? label,
      mimeType: (json['mime_type'] as String?) ?? 'application/octet-stream',
      group: (json['group'] as String?) ?? 'unknown',
      isText: (json['is_text'] as bool?) ?? false,
      extensions: ((json['extensions'] as List<dynamic>?) ?? const <dynamic>[])
          .map((dynamic extension) => extension.toString())
          .toList(growable: false),
    );
  }

  /// Short Magika label such as `txt` or `json`.
  final String label;

  /// Human-readable description of the detected content type.
  final String description;

  /// Default MIME type for this content type.
  final String mimeType;

  /// High-level Magika group for this label.
  final String group;

  /// Whether this content type should be treated as text.
  final bool isText;

  /// Common filename extensions associated with this content type.
  final List<String> extensions;
}
