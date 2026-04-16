/// Explains why the final output label differs from the raw model label.
enum OverwriteReason {
  /// The final output matches the model prediction.
  none,

  /// The model score was too low, so the prediction fell back to a generic label.
  lowConfidence,

  /// The label was remapped by the model configuration overwrite map.
  overwriteMap,
}
