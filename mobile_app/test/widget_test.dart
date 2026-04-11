import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/src/app.dart';
import 'package:mobile_app/src/database/finance_database_holder.dart';
import 'package:mobile_app/src/database/finance_database.dart';
import 'package:mobile_app/src/di/service_locator.dart';
import 'package:sizer/sizer.dart';

void main() {
  setUp(() async {
    await sl.reset();
    await setupServiceLocator();
  });

  testWidgets('app builds', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FinanceDatabaseHolder.instance = FinanceDatabase.memory();

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, screenType) {
          return const ExpenseMobileApp();
        },
      ),
    );
    await tester.pump();

    expect(find.byType(ExpenseMobileApp), findsOneWidget);
  });
}
