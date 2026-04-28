import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sizer/sizer.dart';

import 'src/app.dart';
import 'src/database/finance_database_holder.dart';
import 'src/database/finance_database.dart';
import 'src/di/service_locator.dart';
import 'src/sync/background_sync.dart';
import 'src/utils/app_bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  FinanceDatabaseHolder.instance = FinanceDatabase();
  Bloc.observer = AppBlocObserver();
  await setupServiceLocator();
  await BackgroundSync.initialize();
  await GoogleSignIn.instance.initialize(
    // iOS requires a native client id.
    // Android should use the Android OAuth client configured in Google Cloud for:
    // - package name: com.gulfon.finanace
    // - SHA-1: debug + release + (Play App Signing certificate SHA-1)
    // so we intentionally omit the Android clientId here.
    clientId:
        Platform.isIOS
            ? '615058378594-va499j21oce2qr8raeu6pnr9qo11uv8u.apps.googleusercontent.com'
            : '615058378594-eciila121uj1n8bm97f6odqkr42aarp8.apps.googleusercontent.com',
    // Web OAuth client id used by Android/iOS to mint an ID token for the backend.
    serverClientId: '615058378594-timl7n0gna9800pdai3gdl8p8ijb8ge5.apps.googleusercontent.com',
  );
  runApp(
    Sizer(
      builder: (context, orientation, screenType) {
        return const ExpenseMobileApp();
      },
    ),
  );
}
