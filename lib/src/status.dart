/// Describes whether identification completed successfully.
enum MagikaStatus {
  /// Identification completed and produced a prediction.
  ok,

  /// The active backend cannot classify the input.
  unsupported,

  /// The backend was used before it finished initialization.
  runtimeNotConfigured,

  /// An unexpected runtime failure happened during identification.
  error,
}
