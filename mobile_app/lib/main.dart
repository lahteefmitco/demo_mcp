import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/database/finance_database_holder.dart';
import 'src/database/finance_database.dart';
import 'src/sync/background_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FinanceDatabaseHolder.instance = FinanceDatabase();
  await BackgroundSync.initialize();
  runApp(const ExpenseMobileApp());
}
