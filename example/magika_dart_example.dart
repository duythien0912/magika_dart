import 'package:flutter/foundation.dart';
import 'package:magika_dart/magika_dart.dart';

Future<void> main() async {
  final magika = await Magika.create(
    predictionMode: PredictionMode.mediumConfidence,
  );
  final result = await magika.identifyBytes('hello'.codeUnits);
  debugPrint(magika.predictionMode.name);
  debugPrint(result.status.name);
  debugPrint(result.prediction.model.label);
  debugPrint(result.prediction.output.label);
}
