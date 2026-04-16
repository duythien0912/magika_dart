import 'package:example/main.dart' as app;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:magika_dart/magika_dart.dart';

Future<List<int>> _loadFixture(String assetKey) async {
  final bytes = await rootBundle.load(assetKey);
  return bytes.buffer.asUint8List();
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
        final bytes = await _loadFixture(testCase.assetKey);
        final result = await magika.identifyBytes(bytes);

        expect(result.status, MagikaStatus.ok,
            reason: 'unexpected status for ${testCase.assetKey}: ${result.status.name}');
        expect(
          testCase.expectedOutputs,
          contains(result.prediction.output.label),
          reason:
              'unexpected label for ${testCase.assetKey}: '
              '${result.prediction.output.label} (model=${result.prediction.model.label}, score=${result.prediction.score})',
        );
      }
    });
  });
}
