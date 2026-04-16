import 'dart:io';

import 'package:example/main.dart' as app;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:magika_dart/magika_dart.dart';

Future<List<int>> _loadFixture(String assetKey) async {
  final bytes = await rootBundle.load(assetKey);
  return bytes.buffer.asUint8List();
}

Future<MagikaResult> _identifyFixture(Magika magika, String assetKey) async {
  final bytes = await _loadFixture(assetKey);
  return magika.identifyBytes(bytes);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  app.main();

  group('bundled Magika model', () {
    testWidgets('classifies real bundled fixtures', (tester) async {
      final magika = await Magika.create(
        predictionMode: PredictionMode.bestGuess,
      );

      final cases = <({
        String assetKey,
        Set<String> expectedOutputs,
      })>[
        (
          assetKey: 'integration_test/fixtures/hello.txt',
          expectedOutputs: <String>{'txt'},
        ),
        (
          assetKey: 'integration_test/fixtures/sample.json',
          expectedOutputs: <String>{'json', 'txt'},
        ),
        (
          assetKey: 'integration_test/fixtures/tiny.png',
          expectedOutputs: <String>{'png'},
        ),
        (
          assetKey: 'integration_test/fixtures/tiny.pdf',
          expectedOutputs: <String>{'pdf'},
        ),
        (
          assetKey: 'integration_test/fixtures/tiny.zip',
          expectedOutputs: <String>{'zip'},
        ),
      ];

      await tester.pumpAndSettle();

      for (final testCase in cases) {
        final result = await _identifyFixture(magika, testCase.assetKey);

        expect(result.status, MagikaStatus.ok,
            reason: 'unexpected status for ${testCase.assetKey}: ${result.status.name}');
        expect(result.prediction.score, inInclusiveRange(0.0, 1.0),
            reason: 'score must be normalized for ${testCase.assetKey}');
        expect(
          testCase.expectedOutputs,
          contains(result.prediction.output.label),
          reason:
              'unexpected label for ${testCase.assetKey}: '
              '${result.prediction.output.label} (model=${result.prediction.model.label}, score=${result.prediction.score})',
        );
      }
    });

    testWidgets('returns unknown for empty bytes without runtime error', (tester) async {
      final magika = await Magika.create(
        predictionMode: PredictionMode.bestGuess,
      );

      final result = await magika.identifyBytes(const <int>[]);

      expect(result.status, MagikaStatus.ok);
      expect(result.prediction.model.label, 'unknown');
      expect(result.prediction.output.label, 'unknown');
      expect(result.prediction.score, 1);
      expect(result.prediction.didFallback, isFalse);
    });

    testWidgets('trims surrounding whitespace for text classification', (tester) async {
      final magika = await Magika.create(
        predictionMode: PredictionMode.bestGuess,
      );

      final result = await magika.identifyBytes('   \n\t  hello magika  \n'.codeUnits);

      expect(result.status, MagikaStatus.ok);
      expect(result.prediction.output.isText, isTrue);
      expect(result.prediction.output.label, 'txt');
    });

    testWidgets('identifyPath reads a real filesystem file', (tester) async {
      final magika = await Magika.create(
        predictionMode: PredictionMode.bestGuess,
      );
      final directory = await Directory.systemTemp.createTemp('magika_example_it_');
      final file = File('${directory.path}/sample.json');
      await file.writeAsString('{"path":true}\n');
      addTearDown(() async {
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      });

      final result = await magika.identifyPath(file.path);

      expect(result.path, file.path);
      expect(result.status, MagikaStatus.ok);
      expect(<String>{'json', 'txt'}, contains(result.prediction.output.label));
    });

    testWidgets('higher confidence modes never produce stronger output than best guess', (tester) async {
      final bestGuess = await Magika.create(
        predictionMode: PredictionMode.bestGuess,
      );
      final highConfidence = await Magika.create();
      final bytes = await _loadFixture('integration_test/fixtures/sample.json');

      final bestGuessResult = await bestGuess.identifyBytes(bytes);
      final highConfidenceResult = await highConfidence.identifyBytes(bytes);

      expect(bestGuessResult.status, MagikaStatus.ok);
      expect(highConfidenceResult.status, MagikaStatus.ok);
      expect(bestGuessResult.prediction.score, highConfidenceResult.prediction.score);
      if (highConfidenceResult.prediction.didFallback) {
        expect(bestGuessResult.prediction.didFallback, isFalse);
      }
    });
  });
}
