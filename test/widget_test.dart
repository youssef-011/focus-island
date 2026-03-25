import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:focus_island/main.dart';

void main() {
  testWidgets('Focus Island app renders intro flow', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const FocusIslandApp(showOnboarding: true));
    await tester.pumpAndSettle();

    expect(find.text('Focus Island'), findsOneWidget);
    expect(find.text('Create New Account'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
  });
}
