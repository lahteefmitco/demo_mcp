import 'package:get_it/get_it.dart';

import '../api/auth_api.dart';
import '../auth/auth_storage.dart';
import '../database/finance_database_holder.dart';
import '../repository/finance_repository.dart';
import '../settings/app_preferences_storage.dart';

final GetIt sl = GetIt.instance;

/// Dependency injection bootstrap.
///
/// Keep this graph small and explicit:
/// - repositories encapsulate API + local DB
/// - cubits depend on repositories and storages
Future<void> setupServiceLocator() async {
  sl
    ..registerLazySingleton<AuthStorage>(AuthStorage.new)
    ..registerLazySingleton<AppPreferencesStorage>(AppPreferencesStorage.new)
    ..registerLazySingleton<AuthApi>(AuthApi.new);

  // Repository depends on token, so it's registered as a factory.
  sl.registerFactoryParam<FinanceRepository, String, void>(
    (token, _) => FinanceRepository(
      database: FinanceDatabaseHolder.instance,
      token: token,
    ),
  );
}

