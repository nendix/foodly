import 'package:flutter_test/flutter_test.dart';
import 'package:foodly/main.dart';

void main() {
  testWidgets('foodly app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('foodly'), findsWidgets);
  });
}
