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
    // iOS Client ID (ignored on Android, required on iOS)
    clientId: Platform.isIOS ? '615058378594-va499j21oce2qr8raeu6pnr9qo11uv8u.apps.googleusercontent.com' : '615058378594-1q5kj3k4gejecsm23i8nmd7ji413288b.apps.googleusercontent.com',
    // Hardcoded Web Client ID for both iOS and Web
    //clientId: '615058378594-1q5kj3k4gejecsm23i8nmd7ji413288b.apps.googleusercontent.com',
    // Hardcoded Web Client ID used by Android/iOS to generate the backend token
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
