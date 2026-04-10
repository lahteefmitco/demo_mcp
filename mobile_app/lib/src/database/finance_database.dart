import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'finance_database.g.dart';

@DataClassName('LocalAccountRow')
class LocalAccounts extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable()();
  BoolColumn get isSynced =>
      boolean().withDefault(const Constant(false))();
  TextColumn get name => text()();
  TextColumn get type => text()();
  RealColumn get initialBalance => real()();
  RealColumn get currentBalance => real()();
  TextColumn get color => text()();
  TextColumn get icon => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('LocalCategoryRow')
class LocalCategories extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable()();
  BoolColumn get isSynced =>
      boolean().withDefault(const Constant(false))();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get color => text()();
  TextColumn get icon => text()();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('LocalExpenseRow')
class LocalExpenses extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable()();
  BoolColumn get isSynced =>
      boolean().withDefault(const Constant(false))();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get categoryUuid => text()();
  TextColumn get accountUuid => text()();
  TextColumn get categoryName => text().withDefault(const Constant(''))();
  TextColumn get categoryColor => text().withDefault(const Constant('#0E7490'))();
  TextColumn get accountName => text().withDefault(const Constant(''))();
  TextColumn get accountColor => text().withDefault(const Constant('#10B981'))();
  TextColumn get spentOn => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('LocalIncomeRow')
class LocalIncomes extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable()();
  BoolColumn get isSynced =>
      boolean().withDefault(const Constant(false))();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get categoryUuid => text()();
  TextColumn get accountUuid => text()();
  TextColumn get categoryName => text().withDefault(const Constant(''))();
  TextColumn get categoryColor => text().withDefault(const Constant('#0E7490'))();
  TextColumn get accountName => text().withDefault(const Constant(''))();
  TextColumn get accountColor => text().withDefault(const Constant('#10B981'))();
  TextColumn get receivedOn => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('LocalTransferRow')
class LocalTransfers extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable()();
  BoolColumn get isSynced =>
      boolean().withDefault(const Constant(false))();
  TextColumn get fromAccountUuid => text()();
  TextColumn get toAccountUuid => text()();
  TextColumn get fromAccountName => text().withDefault(const Constant(''))();
  TextColumn get toAccountName => text().withDefault(const Constant(''))();
  RealColumn get amount => real()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get createdAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('LocalBudgetRow')
class LocalBudgets extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable()();
  BoolColumn get isSynced =>
      boolean().withDefault(const Constant(false))();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get period => text()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get categoryUuid => text().nullable()();
  TextColumn get categoryName => text().nullable()();
  TextColumn get categoryColor => text().nullable()();
  RealColumn get spent => real().withDefault(const Constant(0))();
  RealColumn get remaining => real().withDefault(const Constant(0))();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DriftDatabase(
  tables: [
    LocalAccounts,
    LocalCategories,
    LocalExpenses,
    LocalIncomes,
    LocalTransfers,
    LocalBudgets,
  ],
)
class FinanceDatabase extends _$FinanceDatabase {
  FinanceDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// In-memory database for tests.
  FinanceDatabase.memory() : super(NativeDatabase.memory());

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'finance.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  @override
  int get schemaVersion => 1;

  /// Removes all synced finance rows from this device (accounts, categories,
  /// expenses, incomes, transfers, budgets).
  Future<void> deleteAllLocalData() async {
    await transaction(() async {
      await delete(localExpenses).go();
      await delete(localIncomes).go();
      await delete(localTransfers).go();
      await delete(localBudgets).go();
      await delete(localCategories).go();
      await delete(localAccounts).go();
    });
  }
}
