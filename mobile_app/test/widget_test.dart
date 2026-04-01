import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/src/app.dart';

void main() {
  testWidgets('renders app shell', (tester) async {
    await tester.pumpWidget(const ExpenseMobileApp());

    expect(find.text('Expense Mobile'), findsOneWidget);
  });
}
