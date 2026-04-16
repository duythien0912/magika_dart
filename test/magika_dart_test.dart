import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magika_dart/magika_dart.dart';

Future<void> _writeTextFile(String path, String contents) {
  return File(path).writeAsString(contents);
}

Future<void> _writeAssetToFile(String assetKey, String path) async {
  final data = await rootBundle.load(assetKey);
  await File(path).writeAsBytes(data.buffer.asUint8List());
}

Future<String> _loadAssetString(String assetKey) {
  return rootBundle.loadString(assetKey);
}

Future<Directory> _createFilesystemBackendFixture({
  Map<String, dynamic> Function(Map<String, dynamic>)? modelConfigUpdate,
  bool includeMetadata = true,
}) async {
  final directory = await Directory.systemTemp.createTemp('magika_backend_fixture_');
  final modelPath = '${directory.path}/model.onnx';
  final metadataPath = '${directory.path}/content_types.json';
  final rawConfig = jsonDecode(await _loadAssetString('assets/magika/config.min.json')) as Map<String, dynamic>;
  final config = modelConfigUpdate == null
      ? rawConfig
      : modelConfigUpdate(Map<String, dynamic>.from(rawConfig));

  await _writeAssetToFile('assets/magika/model.onnx', modelPath);
  await _writeTextFile('$modelPath.json', jsonEncode(config));
  if (includeMetadata) {
    await _writeAssetToFile('assets/magika/content_types_kb.min.json', metadataPath);
  }
  return directory;
}

MagikaBackendConfig _filesystemBackendConfig({
  required String modelPath,
  String? metadataPath,
}) {
  return MagikaBackendConfig(
    nativeFfiBridge: NativeFfiBridgeConfig(
      modelAsset: FfiModelAssetConfig(
        source: ModelAssetSource.filesystem,
        modelPath: modelPath,
      ),
      labelMetadata: LabelMetadataConfig(metadataPath: metadataPath),
    ),
  );
}

String _tempFilePath(Directory directory, String name) => '${directory.path}/$name';

void _expectConfigError(Object error, String containsMessage) {
  expect(error, isA<MagikaConfigurationException>());
  expect(error.toString(), contains(containsMessage));
}

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

    expect(magika.predictionMode, PredictionMode.mediumConfidence);
    expect(magika.backendConfig.productionStrategy, ProductionBackendStrategy.nativeFfiBridge);
    expect(magika.backendConfig.nativeFfiBridge.modelAsset.source, ModelAssetSource.bundled);
    expect(magika.backendConfig.nativeFfiBridge.modelAsset.modelPath, isNull);
    expect(magika.backendConfig.nativeFfiBridge.modelAsset.modelVersion, isNull);
    expect(magika.backendConfig.nativeFfiBridge.thresholds.highConfidence, 0.9);
    expect(magika.backendConfig.nativeFfiBridge.thresholds.mediumConfidence, 0.5);
    expect(magika.backendConfig.nativeFfiBridge.labelMetadata.metadataPath, isNull);
    expect(magika.backendConfig.nativeFfiBridge.labelMetadata.metadataVersion, isNull);
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
  });

  test('stub backend returns generic binary fallback for binary bytes', () async {
    final magika = await Magika.create(backend: StubMagikaBackend());
    final result = await magika.identifyBytes(<int>[0, 159, 146, 150]);

    expect(result.status, MagikaStatus.unsupported);
    expect(result.prediction.output.label, 'unknown_binary');
    expect(result.prediction.didFallback, isTrue);
  });

  test('stub backend surfaces runtime not configured before initialization', () async {
    final backend = StubMagikaBackend();
    final result = await backend.identifyBytes('hello'.codeUnits);

    expect(result.status, MagikaStatus.runtimeNotConfigured);
    expect(result.prediction.output.label, 'unknown');
  });

  test('Magika delegates identifyBytes through the backend interface', () async {
    final backend = FakeMagikaBackend();
    final magika = Magika(backend: backend);

    final bytesResult = await magika.identifyBytes(<int>[1, 2, 3]);

    expect(backend.lastBytes, <int>[1, 2, 3]);
    expect(bytesResult, same(backend.identifyBytesResult));
  });

  test('Magika delegates identifyPath through the backend interface', () async {
    final backend = FakeMagikaBackend();
    final magika = Magika(backend: backend);

    final pathResult = await magika.identifyPath('fixture.bin');

    expect(backend.lastPath, 'fixture.bin');
    expect(pathResult, same(backend.identifyPathResult));
  });

  test('Magika delegates identifyString through the backend interface', () async {
    final backend = FakeMagikaBackend();
    final magika = Magika(backend: backend);

    final result = await magika.identifyString('hello');

    expect(backend.lastBytes, 'hello'.codeUnits);
    expect(result, same(backend.identifyBytesResult));
  });

  test('Magika delegates identifyFile through the backend interface', () async {
    final backend = FakeMagikaBackend();
    final magika = Magika(backend: backend);
    final file = File('fixture.bin');

    final result = await magika.identifyFile(file);

    expect(backend.lastPath, file.path);
    expect(result, same(backend.identifyPathResult));
  });

  test('filesystem backend requires non-empty modelPath', () async {
    try {
      await Magika.create(
        backendConfig: const MagikaBackendConfig(
          nativeFfiBridge: NativeFfiBridgeConfig(
            modelAsset: FfiModelAssetConfig(source: ModelAssetSource.filesystem),
          ),
        ),
      );
      fail('Expected MagikaConfigurationException');
    } catch (error) {
      _expectConfigError(error, 'requires a non-empty modelPath');
    }
  });

  test('filesystem backend fails when model config sidecar is missing', () async {
    try {
      await Magika.create(
        backendConfig: _filesystemBackendConfig(modelPath: '/tmp/does-not-exist-model.onnx'),
      );
      fail('Expected MagikaConfigurationException');
    } catch (error) {
      _expectConfigError(error, 'Model config file not found');
    }
  });

  test('filesystem backend fails when metadata path is missing', () async {
    final directory = await _createFilesystemBackendFixture(includeMetadata: false);
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    try {
      await Magika.create(
        backendConfig: _filesystemBackendConfig(
          modelPath: _tempFilePath(directory, 'model.onnx'),
          metadataPath: _tempFilePath(directory, 'content_types.json'),
        ),
      );
      fail('Expected MagikaConfigurationException');
    } catch (error) {
      _expectConfigError(error, 'Metadata file not found');
    }
  });

  test('remote model source fails fast with clear error', () async {
    try {
      await Magika.create(
        backendConfig: const MagikaBackendConfig(
          nativeFfiBridge: NativeFfiBridgeConfig(
            modelAsset: FfiModelAssetConfig(source: ModelAssetSource.remote),
          ),
        ),
      );
      fail('Expected MagikaConfigurationException');
    } catch (error) {
      _expectConfigError(error, 'ModelAssetSource.remote is not implemented yet');
    }
  });

  test('unsupported use_inputs_at_offsets fails during initialization', () async {
    final directory = await _createFilesystemBackendFixture(
      modelConfigUpdate: (json) {
        json['use_inputs_at_offsets'] = true;
        return json;
      },
    );
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    try {
      await Magika.create(
        backendConfig: _filesystemBackendConfig(
          modelPath: _tempFilePath(directory, 'model.onnx'),
          metadataPath: _tempFilePath(directory, 'content_types.json'),
        ),
      );
      fail('Expected MagikaConfigurationException');
    } catch (error) {
      _expectConfigError(error, 'use_inputs_at_offsets=true is not supported');
    }
  });

  test('unsupported mid_size fails during initialization', () async {
    final directory = await _createFilesystemBackendFixture(
      modelConfigUpdate: (json) {
        json['mid_size'] = 16;
        return json;
      },
    );
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    try {
      await Magika.create(
        backendConfig: _filesystemBackendConfig(
          modelPath: _tempFilePath(directory, 'model.onnx'),
          metadataPath: _tempFilePath(directory, 'content_types.json'),
        ),
      );
      fail('Expected MagikaConfigurationException');
    } catch (error) {
      _expectConfigError(error, 'mid_size=16 is not supported');
    }
  });
}
