import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:magika_dart/magika_dart.dart';

class FakeMagikaBackend implements MagikaBackend {
  FakeMagikaBackend({
    this.identifyBytesResult = const MagikaResult(
      path: '-',
      status: MagikaStatus.ok,
      prediction: MagikaPredictions.genericTextFallback,
    ),
    this.identifyPathResult = const MagikaResult(
      path: 'fake-path',
      status: MagikaStatus.ok,
      prediction: MagikaPredictions.genericBinaryFallback,
    ),
  });

  final MagikaResult identifyBytesResult;
  final MagikaResult identifyPathResult;
  PredictionMode? initializedWith;
  List<int>? lastBytes;
  String? lastPath;

  @override
  Future<void> initialize({PredictionMode predictionMode = PredictionMode.highConfidence}) async {
    initializedWith = predictionMode;
  }

  @override
  Future<MagikaResult> identifyBytes(List<int> bytes) async {
    lastBytes = bytes;
    return identifyBytesResult;
  }

  @override
  Future<MagikaResult> identifyPath(String path) async {
    lastPath = path;
    return identifyPathResult;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Magika.create exposes configured prediction mode and default FFI strategy', () async {
    final magika = await Magika.create(
      predictionMode: PredictionMode.mediumConfidence,
      backend: StubMagikaBackend(),
    );

    expect(magika, isA<Magika>());
    expect(magika.predictionMode, PredictionMode.mediumConfidence);
    expect(
      magika.backendConfig.productionStrategy,
      ProductionBackendStrategy.nativeFfiBridge,
    );
    expect(magika.backendConfig.nativeFfiBridge.libraryPath, isNull);
    expect(magika.backendConfig.nativeFfiBridge.libraryName, isNull);
    expect(magika.backendConfig.nativeFfiBridge.modelAsset.source, ModelAssetSource.bundled);
    expect(magika.backendConfig.nativeFfiBridge.modelAsset.modelPath, isNull);
    expect(magika.backendConfig.nativeFfiBridge.modelAsset.modelVersion, isNull);
    expect(
      magika.backendConfig.nativeFfiBridge.modelAsset.bundledAssetKey,
      FfiModelAssetConfig.defaultBundledModelAssetKey,
    );
    expect(
      magika.backendConfig.nativeFfiBridge.modelAsset.bundledPackage,
      FfiModelAssetConfig.defaultBundledAssetPackage,
    );
    expect(magika.backendConfig.nativeFfiBridge.thresholds.highConfidence, 0.9);
    expect(magika.backendConfig.nativeFfiBridge.thresholds.mediumConfidence, 0.5);
    expect(magika.backendConfig.nativeFfiBridge.labelMetadata.metadataPath, isNull);
    expect(magika.backendConfig.nativeFfiBridge.labelMetadata.metadataVersion, isNull);
    expect(
      magika.backendConfig.nativeFfiBridge.labelMetadata.bundledAssetKey,
      LabelMetadataConfig.defaultBundledMetadataAssetKey,
    );
    expect(
      magika.backendConfig.nativeFfiBridge.labelMetadata.bundledPackage,
      FfiModelAssetConfig.defaultBundledAssetPackage,
    );
  });

  test('stub backend returns generic text fallback for text bytes', () async {
    final magika = await Magika.create(backend: StubMagikaBackend());
    final result = await magika.identifyBytes('hello world'.codeUnits);

    expect(result.status, MagikaStatus.unsupported);
    expect(result.prediction.model.label, 'unknown');
    expect(result.prediction.direct?.label, 'txt');
    expect(result.prediction.output.label, 'txt');
    expect(result.prediction.didFallback, isTrue);
    expect(result.prediction.overwriteReason, OverwriteReason.lowConfidence);
    expect(result.isUnsupported, isTrue);
  });

  test('stub backend returns generic binary fallback for binary bytes', () async {
    final magika = await Magika.create(backend: StubMagikaBackend());
    final result = await magika.identifyBytes(<int>[0, 159, 146, 150]);

    expect(result.status, MagikaStatus.unsupported);
    expect(result.prediction.direct?.label, 'unknown_binary');
    expect(result.prediction.output.label, 'unknown_binary');
    expect(result.prediction.didFallback, isTrue);
  });

  test('stub backend surfaces runtime not configured before initialization', () async {
    final backend = StubMagikaBackend();
    final result = await backend.identifyBytes('hello'.codeUnits);

    expect(result.status, MagikaStatus.runtimeNotConfigured);
    expect(result.isRuntimeNotConfigured, isTrue);
    expect(result.prediction.output.label, 'unknown');
  });

  test('identifyPath preserves the requested path', () async {
    final file = File('test_identify_path_fixture.txt');
    await file.writeAsString('fixture');
    addTearDown(() async {
      if (await file.exists()) {
        await file.delete();
      }
    });

    final magika = await Magika.create(backend: StubMagikaBackend());
    final result = await magika.identifyPath(file.path);

    expect(result.path, file.path);
  });

  test('Magika.create initializes an injected backend and preserves explicit FFI config', () async {
    final backend = FakeMagikaBackend();
    const backendConfig = MagikaBackendConfig(
      productionStrategy: ProductionBackendStrategy.nativeFfiBridge,
      nativeFfiBridge: NativeFfiBridgeConfig(
        libraryPath: '/tmp/libmagika.dylib',
        libraryName: 'magika',
        modelAsset: FfiModelAssetConfig(
          source: ModelAssetSource.bundled,
          modelPath: '/tmp/magika/model.onnx',
          modelVersion: 'v1',
          bundledAssetKey: 'assets/custom/model-v1.onnx',
          bundledPackage: 'custom_pkg',
        ),
        thresholds: MagikaThresholdConfig(
          highConfidence: 0.95,
          mediumConfidence: 0.6,
        ),
        labelMetadata: LabelMetadataConfig(
          metadataPath: '/tmp/magika/labels.json',
          metadataVersion: '2026-04',
          bundledAssetKey: 'assets/custom/content-types-v1.min.json',
          bundledPackage: 'custom_pkg',
        ),
      ),
    );

    final magika = await Magika.create(
      predictionMode: PredictionMode.bestGuess,
      backend: backend,
      backendConfig: backendConfig,
    );

    expect(magika.predictionMode, PredictionMode.bestGuess);
    expect(magika.backendConfig, same(backendConfig));
    expect(magika.backendConfig.nativeFfiBridge.libraryPath, '/tmp/libmagika.dylib');
    expect(magika.backendConfig.nativeFfiBridge.libraryName, 'magika');
    expect(magika.backendConfig.nativeFfiBridge.modelAsset.source, ModelAssetSource.bundled);
    expect(magika.backendConfig.nativeFfiBridge.modelAsset.modelPath, '/tmp/magika/model.onnx');
    expect(magika.backendConfig.nativeFfiBridge.modelAsset.modelVersion, 'v1');
    expect(
      magika.backendConfig.nativeFfiBridge.modelAsset.bundledAssetKey,
      'assets/custom/model-v1.onnx',
    );
    expect(magika.backendConfig.nativeFfiBridge.modelAsset.bundledPackage, 'custom_pkg');
    expect(magika.backendConfig.nativeFfiBridge.thresholds.highConfidence, 0.95);
    expect(magika.backendConfig.nativeFfiBridge.thresholds.mediumConfidence, 0.6);
    expect(magika.backendConfig.nativeFfiBridge.labelMetadata.metadataPath, '/tmp/magika/labels.json');
    expect(magika.backendConfig.nativeFfiBridge.labelMetadata.metadataVersion, '2026-04');
    expect(
      magika.backendConfig.nativeFfiBridge.labelMetadata.bundledAssetKey,
      'assets/custom/content-types-v1.min.json',
    );
    expect(magika.backendConfig.nativeFfiBridge.labelMetadata.bundledPackage, 'custom_pkg');
    expect(backend.initializedWith, PredictionMode.bestGuess);
  });

  test('Magika delegates identify methods through the backend interface', () async {
    final backend = FakeMagikaBackend();
    final magika = Magika(
      backend: backend,
      backendConfig: const MagikaBackendConfig(
        nativeFfiBridge: NativeFfiBridgeConfig(libraryName: 'magika'),
      ),
    );

    final bytesResult = await magika.identifyBytes(<int>[1, 2, 3]);
    final pathResult = await magika.identifyPath('fixture.bin');

    expect(backend.lastBytes, <int>[1, 2, 3]);
    expect(backend.lastPath, 'fixture.bin');
    expect(bytesResult, same(backend.identifyBytesResult));
    expect(pathResult, same(backend.identifyPathResult));
  });
}
