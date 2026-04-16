import 'package:flutter_test/flutter_test.dart';
import 'package:magika_dart/magika_dart.dart';

void main() {
  test('Magika.create returns an instance', () async {
    final magika = await Magika.create();
    expect(magika, isA<Magika>());
  });
}
