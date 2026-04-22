import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../auth/auth_storage.dart';
import '../database/finance_database_holder.dart';
import '../repository/finance_repository.dart';

const _periodicTaskName = 'financeBackgroundSync';
const _uniqueTaskName = 'finance.sync.periodic';
const _oneOffUniqueName = 'finance.sync.oneoff';

/// Registers Workmanager and periodic finance sync (best-effort when OS allows).
class BackgroundSync {
  static Future<void> initialize() async {
    if (kIsWeb) return;
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> registerPeriodicSync() async {
    if (kIsWeb) return;
    await Workmanager().cancelByUniqueName(_uniqueTaskName);
    await Workmanager().registerPeriodicTask(
      _uniqueTaskName,
      _periodicTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  /// Runs once when online after a short delay (e.g. immediate sync left rows pending).
  static Future<void> scheduleDeferredSync() async {
    if (kIsWeb) return;
    await Workmanager().cancelByUniqueName(_oneOffUniqueName);
    await Workmanager().registerOneOffTask(
      _oneOffUniqueName,
      _periodicTaskName,
      initialDelay: const Duration(seconds: 20),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Future<void> cancelPeriodicSync() async {
    if (kIsWeb) return;
    await Workmanager().cancelByUniqueName(_uniqueTaskName);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    if (taskName != _periodicTaskName) {
      return Future.value(true);
    }
    try {
      final session = await AuthStorage().readSession();
      if (session == null) {
        return Future.value(true);
      }
      final repo = FinanceRepository(
        database: FinanceDatabaseHolder.instance,
        token: session.token,
      );
      await repo.pushUnsynced();
    } catch (_) {}
    return Future.value(true);
  });
}
