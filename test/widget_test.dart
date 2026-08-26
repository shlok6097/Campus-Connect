import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect/main.dart';

void main() {
  testWidgets('Campus Connect app launch and login test', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusConnectApp());
    expect(find.text('Campus Connect'), findsWidgets);

    // Settle splash timer
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify Login Screen is presented
    expect(find.text('Welcome to Campus Connect'), findsOneWidget);
    expect(find.text('Student Portal'), findsOneWidget);
    expect(find.text('Club Organizer'), findsOneWidget);
  });
}
