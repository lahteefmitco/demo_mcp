import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../auth/auth_storage.dart';
import '../database/finance_database_holder.dart';
import '../repository/finance_repository.dart';

const _periodicTaskName = 'financeBackgroundSync';
const _uniqueTaskName = 'finance.sync.periodic';

/// Registers Workmanager and periodic finance sync (best-effort when OS allows).
class BackgroundSync {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> registerPeriodicSync() async {
    await Workmanager().cancelByUniqueName(_uniqueTaskName);
    await Workmanager().registerPeriodicTask(
      _uniqueTaskName,
      _periodicTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> cancelPeriodicSync() async {
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
