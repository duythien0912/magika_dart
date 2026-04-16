class ContentTypeInfo {
  const ContentTypeInfo({
    required this.label,
    required this.description,
    required this.mimeType,
    required this.group,
    required this.isText,
    this.extensions = const <String>[],
  });

  final String label;
  final String description;
  final String mimeType;
  final String group;
  final bool isText;
  final List<String> extensions;
}
