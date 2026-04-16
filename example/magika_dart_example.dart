import 'package:magika_dart/magika_dart.dart';

Future<void> main() async {
  final magika = await Magika.create();
  final result = await magika.identifyBytes(<int>[1, 2, 3]);
  print(result.prediction.output.label);
}
