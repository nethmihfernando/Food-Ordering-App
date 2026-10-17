// Basic smoke test for the FastBite app.
//
// The default Flutter template test (counter app) was replaced here
// since it doesn't apply to this project.

import 'package:flutter_test/flutter_test.dart';

import 'package:fastbite/main.dart';

void main() {
  testWidgets('App launches and shows the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodDeliveryApp());

    // The splash screen should be visible immediately on launch.
    expect(find.text('FastBite'), findsOneWidget);
    expect(find.text('Delicious food, delivered fast.'), findsOneWidget);
  });
}
