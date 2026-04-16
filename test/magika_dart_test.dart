import 'package:magika_dart/magika_dart.dart';
import 'package:test/test.dart';

void main() {
  test('Magika.create returns an instance', () async {
    final magika = await Magika.create();
    expect(magika, isA<Magika>());
  });
}
