import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import 'src/app.dart';
import 'src/database/finance_database_holder.dart';
import 'src/database/finance_database.dart';
import 'src/di/service_locator.dart';
import 'src/sync/background_sync.dart';
import 'src/utils/app_bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  FinanceDatabaseHolder.instance = FinanceDatabase();
  Bloc.observer = AppBlocObserver();
  await setupServiceLocator();
  await BackgroundSync.initialize();
  runApp(
    Sizer(
      builder: (context, orientation, screenType) {
        return const ExpenseMobileApp();
      },
    ),
  );
}
