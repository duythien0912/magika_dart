import 'package:flutter_test/flutter_test.dart';
import 'package:magika_dart/magika_dart.dart';
import 'package:magika_dart/src/magika_dart_base.dart';

void main() {
  test('Magika.create exposes configured prediction mode', () async {
    final magika = await Magika.create(
      predictionMode: PredictionMode.mediumConfidence,
    );

    expect(magika, isA<Magika>());
    expect(magika.predictionMode, PredictionMode.mediumConfidence);
  });

  test('stub backend returns generic text fallback for text bytes', () async {
    final magika = await Magika.create();
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
    final magika = await Magika.create();
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
    final magika = await Magika.create();
    final result = await magika.identifyPath('sample.txt');

    expect(result.path, 'sample.txt');
  });
}
