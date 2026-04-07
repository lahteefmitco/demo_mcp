import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/src/app.dart';
import 'package:mobile_app/src/database/finance_database_holder.dart';
import 'package:mobile_app/src/database/finance_database.dart';

void main() {
  testWidgets('app builds', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FinanceDatabaseHolder.instance = FinanceDatabase.memory();

    await tester.pumpWidget(const ExpenseMobileApp());
    await tester.pump();

    expect(find.byType(ExpenseMobileApp), findsOneWidget);
  });
}
