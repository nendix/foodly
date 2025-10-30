import 'package:flutter_test/flutter_test.dart';
import 'package:foodly/main.dart';

void main() {
  testWidgets('Foodly app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Foodly'), findsWidgets);
  });
}
