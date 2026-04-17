import 'package:flutter_test/flutter_test.dart';
import 'package:weel_app/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const WeelApp());
    await tester.pumpAndSettle();
    expect(find.byType(WeelApp), findsOneWidget);
  });
}
