import 'package:flutter_test/flutter_test.dart';

import 'package:focus_island/main.dart';

void main() {
  testWidgets('Focus Island app renders intro flow', (WidgetTester tester) async {
    await tester.pumpWidget(const FocusIslandApp(showOnboarding: true));
    await tester.pumpAndSettle();

    expect(find.text('Focus Island'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
