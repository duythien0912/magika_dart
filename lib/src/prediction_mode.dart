/// Controls how aggressively model predictions are accepted.
enum PredictionMode {
  /// Keeps the model output only when it clears the per-label high-confidence threshold.
  highConfidence,

  /// Keeps the model output when it clears the runtime medium-confidence threshold.
  mediumConfidence,

  /// Always returns the model output even when confidence is low.
  bestGuess,
}
