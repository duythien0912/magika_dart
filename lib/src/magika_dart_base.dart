import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

import 'content_type_info.dart';
import 'magika_result.dart';
import 'overwrite_reason.dart';
import 'prediction_mode.dart';
import 'status.dart';

const _whitespaceBytes = <int>{9, 10, 11, 12, 13, 32};

String _packageAssetKey(String assetKey, String package) {
  return 'packages/$package/$assetKey';
}

String _bundledOrPackageAssetKey(String assetKey, String package) {
  if (package.isEmpty) {
    return assetKey;
  }
  if (assetKey.startsWith('packages/')) {
    return assetKey;
  }
  return _packageAssetKey(assetKey, package);
}

Future<String> _loadBundledStringAsset(String assetKey, String package) async {
  final packageAssetKey = _bundledOrPackageAssetKey(assetKey, package);
  try {
    return await rootBundle.loadString(packageAssetKey);
  } catch (_) {
    return rootBundle.loadString(assetKey);
  }
}

class _SampleFeatures {
  const _SampleFeatures({
    required this.beginning,
    required this.middle,
    required this.end,
  });

  final List<int> beginning;
  final List<int> middle;
  final List<int> end;
}

class _MagikaModelConfig {
  const _MagikaModelConfig({
    required this.beginSize,
    required this.midSize,
    required this.endSize,
    required this.useInputsAtOffsets,
    required this.mediumConfidenceThreshold,
    required this.minFileSizeForDl,
    required this.paddingToken,
    required this.blockSize,
    required this.targetLabelsSpace,
    required this.thresholds,
    required this.overwriteMap,
  });

  factory _MagikaModelConfig.fromJson(Map<String, dynamic> json) {
    return _MagikaModelConfig(
      beginSize: json['beg_size'] as int,
      midSize: json['mid_size'] as int,
      endSize: json['end_size'] as int,
      useInputsAtOffsets: json['use_inputs_at_offsets'] as bool,
      mediumConfidenceThreshold: (json['medium_confidence_threshold'] as num).toDouble(),
      minFileSizeForDl: json['min_file_size_for_dl'] as int,
      paddingToken: json['padding_token'] as int,
      blockSize: json['block_size'] as int,
      targetLabelsSpace: ((json['target_labels_space'] as List<dynamic>)
          .map((dynamic label) => label.toString())
          .toList(growable: false)),
      thresholds: (json['thresholds'] as Map<String, dynamic>).map(
        (String key, dynamic value) => MapEntry(key, (value as num).toDouble()),
      ),
      overwriteMap: (json['overwrite_map'] as Map<String, dynamic>).map(
        (String key, dynamic value) => MapEntry(key, value.toString()),
      ),
    );
  }

  final int beginSize;
  final int midSize;
  final int endSize;
  final bool useInputsAtOffsets;
  final double mediumConfidenceThreshold;
  final int minFileSizeForDl;
  final int paddingToken;
  final int blockSize;
  final List<String> targetLabelsSpace;
  final Map<String, double> thresholds;
  final Map<String, String> overwriteMap;
}

class RealMagikaBackend implements MagikaBackend {
  RealMagikaBackend({
    required this.backendConfig,
    OnnxRuntime? runtime,
  }) : _runtime = runtime ?? OnnxRuntime();

  final MagikaBackendConfig backendConfig;
  final OnnxRuntime _runtime;

  OrtSession? _session;
  _MagikaModelConfig? _modelConfig;
  Map<String, ContentTypeInfo>? _contentTypes;
  PredictionMode _predictionMode = PredictionMode.highConfidence;

  @override
  Future<void> initialize({PredictionMode predictionMode = PredictionMode.highConfidence}) async {
    _predictionMode = predictionMode;
    final modelAsset = backendConfig.nativeFfiBridge.modelAsset;
    final metadataAsset = backendConfig.nativeFfiBridge.labelMetadata;
    try {
      _modelConfig = _MagikaModelConfig.fromJson(
        jsonDecode(
              await _loadBundledStringAsset(
                'assets/magika/config.min.json',
                modelAsset.bundledPackage,
              ),
            )
            as Map<String, dynamic>,
      );
      _contentTypes = _loadContentTypes(
        jsonDecode(
              await _loadBundledStringAsset(
                metadataAsset.bundledAssetKey,
                metadataAsset.bundledPackage,
              ),
            )
            as Map<String, dynamic>,
      );
      _session = await _runtime.createSessionFromAsset(
        _bundledOrPackageAssetKey(modelAsset.bundledAssetKey, modelAsset.bundledPackage),
      );
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<MagikaResult> identifyBytes(List<int> bytes) async {
    if (_session == null || _modelConfig == null || _contentTypes == null) {
      return const MagikaResult(
        path: '-',
        status: MagikaStatus.runtimeNotConfigured,
        prediction: MagikaPredictions.unsupported,
      );
    }

    final content = Uint8List.fromList(bytes);
    if (content.isEmpty) {
      return const MagikaResult(
        path: '-',
        status: MagikaStatus.ok,
        prediction: MagikaPrediction(
          model: MagikaContentTypes.unknown,
          output: MagikaContentTypes.unknown,
          score: 1,
        ),
      );
    }

    final sample = _extractFeatures(content, _modelConfig!);
    final inputBytes = <int>[
      ...sample.beginning,
      ...sample.middle,
      ...sample.end,
    ];
    final inputTensor = await OrtValue.fromList(<List<int>>[inputBytes], [1, inputBytes.length]);
    try {
      final outputs = await _session!.run({'bytes': inputTensor});
      final outputTensor = outputs.values.first;
      final rawScores = await outputTensor.asList();
      final scores = (rawScores.first as List<dynamic>)
          .map((dynamic value) => (value as num).toDouble())
          .toList(growable: false);
      final prediction = _buildPrediction(scores, _modelConfig!, _contentTypes!, _predictionMode);
      await outputTensor.dispose();
      return MagikaResult(path: '-', status: MagikaStatus.ok, prediction: prediction);
    } catch (_) {
      return const MagikaResult(
        path: '-',
        status: MagikaStatus.error,
        prediction: MagikaPredictions.unsupported,
      );
    } finally {
      await inputTensor.dispose();
    }
  }

  @override
  Future<MagikaResult> identifyPath(String path) async {
    final bytes = await File(path).readAsBytes();
    final result = await identifyBytes(bytes);
    return MagikaResult(path: path, status: result.status, prediction: result.prediction);
  }

  Map<String, ContentTypeInfo> _loadContentTypes(Map<String, dynamic> json) {
    return json.map(
      (String label, dynamic value) => MapEntry(
        label,
        ContentTypeInfo.fromJson(label, value as Map<String, dynamic>),
      ),
    );
  }

  _SampleFeatures _extractFeatures(Uint8List content, _MagikaModelConfig config) {
    if (config.useInputsAtOffsets) {
      throw UnsupportedError('use_inputs_at_offsets is not supported yet');
    }
    if (config.midSize != 0) {
      throw UnsupportedError('mid_size is not supported yet');
    }

    final bytesToRead = content.length < config.blockSize ? content.length : config.blockSize;
    final beginning = _normalizeBeginning(content.sublist(0, bytesToRead), config.beginSize, config.paddingToken);
    final endStart = content.length - bytesToRead;
    final end = _normalizeEnd(content.sublist(endStart, content.length), config.endSize, config.paddingToken);
    return _SampleFeatures(beginning: beginning, middle: const <int>[], end: end);
  }

  List<int> _normalizeBeginning(List<int> bytes, int size, int paddingToken) {
    final trimmed = bytes.skipWhile(_whitespaceBytes.contains).toList(growable: false);
    final slice = trimmed.length > size ? trimmed.sublist(0, size) : trimmed;
    if (slice.length == size) {
      return slice;
    }
    return <int>[...slice, ...List<int>.filled(size - slice.length, paddingToken)];
  }

  List<int> _normalizeEnd(List<int> bytes, int size, int paddingToken) {
    var endIndex = bytes.length;
    while (endIndex > 0 && _whitespaceBytes.contains(bytes[endIndex - 1])) {
      endIndex -= 1;
    }
    final trimmed = bytes.sublist(0, endIndex);
    final slice = trimmed.length > size ? trimmed.sublist(trimmed.length - size) : trimmed;
    if (slice.length == size) {
      return slice;
    }
    return <int>[...List<int>.filled(size - slice.length, paddingToken), ...slice];
  }

  MagikaPrediction _buildPrediction(
    List<double> scores,
    _MagikaModelConfig config,
    Map<String, ContentTypeInfo> contentTypes,
    PredictionMode predictionMode,
  ) {
    var maxIndex = 0;
    for (var index = 1; index < scores.length; index += 1) {
      if (scores[index] > scores[maxIndex]) {
        maxIndex = index;
      }
    }
    final modelLabel = config.targetLabelsSpace[maxIndex];
    final modelInfo = MagikaContentTypes.fromLabel(modelLabel, contentTypes);
    final overwrittenLabel = config.overwriteMap[modelLabel] ?? modelLabel;
    var overwriteReason = overwrittenLabel == modelLabel ? OverwriteReason.none : OverwriteReason.overwriteMap;
    final score = scores[maxIndex];

    final threshold = config.thresholds[modelLabel] ?? config.mediumConfidenceThreshold;
    final keepModelPrediction = switch (predictionMode) {
      PredictionMode.bestGuess => true,
      PredictionMode.mediumConfidence => score >= config.mediumConfidenceThreshold,
      PredictionMode.highConfidence => score >= threshold,
    };

    final outputLabel = keepModelPrediction
        ? overwrittenLabel
        : (MagikaContentTypes.fromLabel(overwrittenLabel, contentTypes).isText ? 'txt' : 'unknown');
    if (!keepModelPrediction) {
      overwriteReason = outputLabel == overwrittenLabel ? OverwriteReason.none : OverwriteReason.lowConfidence;
    }
    final outputInfo = MagikaContentTypes.fromLabel(outputLabel, contentTypes);
    final directInfo = outputLabel == modelLabel ? null : outputInfo;

    return MagikaPrediction(
      model: modelInfo,
      direct: directInfo,
      output: outputInfo,
      score: score,
      overwriteReason: overwriteReason,
      didFallback: !keepModelPrediction,
    );
  }
}

class StubMagikaBackend implements MagikaBackend {
  bool _initialized = false;

  @override
  Future<void> initialize({PredictionMode predictionMode = PredictionMode.highConfidence}) async {
    _initialized = true;
  }

  @override
  Future<MagikaResult> identifyBytes(List<int> bytes) async {
    if (!_initialized) {
      return const MagikaResult(
        path: '-',
        status: MagikaStatus.runtimeNotConfigured,
        prediction: MagikaPredictions.unsupported,
      );
    }

    return MagikaResult(
      path: '-',
      status: MagikaStatus.unsupported,
      prediction: _predictionForBytes(bytes),
    );
  }

  @override
  Future<MagikaResult> identifyPath(String path) async {
    final result = await identifyBytes(const <int>[]);
    return MagikaResult(
      path: path,
      status: result.status,
      prediction: result.prediction,
    );
  }

  MagikaPrediction _predictionForBytes(List<int> bytes) {
    if (bytes.isEmpty) {
      return MagikaPredictions.unsupported;
    }

    final isText = bytes.every((byte) => byte == 9 || byte == 10 || byte == 13 || (byte >= 32 && byte <= 126));
    if (isText) {
      return MagikaPredictions.genericTextFallback;
    }

    return MagikaPredictions.genericBinaryFallback;
  }
}

enum ProductionBackendStrategy {
  nativeFfiBridge,
}

enum ModelAssetSource {
  bundled,
  filesystem,
  remote,
}

class FfiModelAssetConfig {
  const FfiModelAssetConfig({
    this.source = ModelAssetSource.bundled,
    this.modelPath,
    this.modelVersion,
    this.bundledAssetKey = defaultBundledModelAssetKey,
    this.bundledPackage = defaultBundledAssetPackage,
  });

  static const String defaultBundledModelAssetKey = 'assets/magika/model.onnx';
  static const String defaultBundledAssetPackage = 'magika_dart';

  final ModelAssetSource source;
  final String? modelPath;
  final String? modelVersion;
  final String bundledAssetKey;
  final String bundledPackage;
}

class MagikaThresholdConfig {
  const MagikaThresholdConfig({
    this.highConfidence = 0.9,
    this.mediumConfidence = 0.5,
  });

  final double highConfidence;
  final double mediumConfidence;
}

class LabelMetadataConfig {
  const LabelMetadataConfig({
    this.metadataPath,
    this.metadataVersion,
    this.bundledAssetKey = defaultBundledMetadataAssetKey,
    this.bundledPackage = FfiModelAssetConfig.defaultBundledAssetPackage,
  });

  static const String defaultBundledMetadataAssetKey = 'assets/magika/content_types_kb.min.json';

  final String? metadataPath;
  final String? metadataVersion;
  final String bundledAssetKey;
  final String bundledPackage;
}

class NativeFfiBridgeConfig {
  const NativeFfiBridgeConfig({
    this.libraryPath,
    this.libraryName,
    this.modelAsset = const FfiModelAssetConfig(),
    this.thresholds = const MagikaThresholdConfig(),
    this.labelMetadata = const LabelMetadataConfig(),
  });

  final String? libraryPath;
  final String? libraryName;
  final FfiModelAssetConfig modelAsset;
  final MagikaThresholdConfig thresholds;
  final LabelMetadataConfig labelMetadata;
}

class MagikaBackendConfig {
  const MagikaBackendConfig({
    this.productionStrategy = ProductionBackendStrategy.nativeFfiBridge,
    this.nativeFfiBridge = const NativeFfiBridgeConfig(),
  });

  final ProductionBackendStrategy productionStrategy;
  final NativeFfiBridgeConfig nativeFfiBridge;
}

abstract interface class MagikaBackend {
  Future<void> initialize({PredictionMode predictionMode = PredictionMode.highConfidence});

  Future<MagikaResult> identifyBytes(List<int> bytes);

  Future<MagikaResult> identifyPath(String path);
}
