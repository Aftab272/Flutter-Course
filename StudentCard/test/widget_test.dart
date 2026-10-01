import 'package:flutter_test/flutter_test.dart';
import 'package:studentcard/main.dart';

void main() {
  testWidgets('Campus Dashboard renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StudentApp());

    // Verify that the Dashboard Title is displayed
    expect(find.text('Campus Dashboard'), findsOneWidget);

    // Verify that the Student Name is displayed
    expect(find.text('M Aftab Akram'), findsOneWidget);

    // Verify that Roll Number is displayed
    expect(find.text('Roll No: FA24-BSE-060'), findsOneWidget);
  });
}
