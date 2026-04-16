import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example app renders primary actions while initializing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MagikaExampleApp());
    await tester.pump();

    expect(find.byKey(const Key('pick-file-button')), findsOneWidget);
    expect(find.byKey(const Key('sample-text-button')), findsOneWidget);
    expect(find.byKey(const Key('magika-loading')), findsOneWidget);
  });
}
