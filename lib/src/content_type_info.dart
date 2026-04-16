class ContentTypeInfo {
  const ContentTypeInfo({
    required this.label,
    required this.description,
    required this.mimeType,
    required this.group,
    required this.isText,
    this.extensions = const <String>[],
  });

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

  final String label;
  final String description;
  final String mimeType;
  final String group;
  final bool isText;
  final List<String> extensions;
}
