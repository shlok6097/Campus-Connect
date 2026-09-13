import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect/main.dart';

void main() {
  testWidgets('Campus Connect app launch and unified login presentation test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CampusConnectApp());
    expect(find.text('Campus Connect'), findsWidgets);

    // Settle splash timer
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify Unified Login Screen is presented matching Stitch design
    expect(find.text('Campus Connect'), findsWidgets);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Email or Student ID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create Student Account'), findsOneWidget);

    // Verify manual role selection tabs are NOT present
    expect(find.text('Student Portal'), findsNothing);
    expect(find.text('Club Organizer'), findsNothing);
  });
}
