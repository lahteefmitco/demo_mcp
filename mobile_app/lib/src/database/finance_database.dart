import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'finance_database.g.dart';

enum SyncStatus { pending, synced, failed }

class Categories extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get color => text()();
  TextColumn get icon => text()();
  IntColumn get syncStatus => intEnum<SyncStatus>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {uuid};
}

class Accounts extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  RealColumn get initialBalance => real()();
  RealColumn get currentBalance => real()();
  TextColumn get color => text()();
  TextColumn get icon => text()();
  TextColumn get notes => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get syncStatus => intEnum<SyncStatus>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {uuid};
}

class Expenses extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  IntColumn get categoryId => integer()();
  TextColumn get categoryUuid => text().references(Categories, #uuid)();
  IntColumn get accountId => integer()();
  TextColumn get accountUuid => text().references(Accounts, #uuid)();
  DateTimeColumn get spentOn => dateTime()();
  TextColumn get notes => text()();
  IntColumn get syncStatus => intEnum<SyncStatus>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {uuid};
}

class Incomes extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  IntColumn get categoryId => integer()();
  TextColumn get categoryUuid => text().references(Categories, #uuid)();
  IntColumn get accountId => integer()();
  TextColumn get accountUuid => text().references(Accounts, #uuid)();
  DateTimeColumn get receivedOn => dateTime()();
  TextColumn get notes => text()();
  IntColumn get syncStatus => intEnum<SyncStatus>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {uuid};
}

class Budgets extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get period => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get notes => text()();
  IntColumn get categoryId => integer().nullable()();
  TextColumn get categoryUuid =>
      text().nullable().references(Categories, #uuid)();
  IntColumn get syncStatus => intEnum<SyncStatus>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {uuid};
}

class Transfers extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable()();
  IntColumn get fromAccountId => integer()();
  TextColumn get fromAccountUuid => text().references(Accounts, #uuid)();
  IntColumn get toAccountId => integer()();
  TextColumn get toAccountUuid => text().references(Accounts, #uuid)();
  RealColumn get amount => real()();
  TextColumn get notes => text()();
  IntColumn get syncStatus => intEnum<SyncStatus>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DriftDatabase(
  tables: [Categories, Accounts, Expenses, Incomes, Budgets, Transfers],
)
class FinanceDatabase extends _$FinanceDatabase {
  FinanceDatabase._internal() : super(_openConnection());

  static final FinanceDatabase _instance = FinanceDatabase._internal();
  factory FinanceDatabase() => _instance;

  @override
  int get schemaVersion => 1;

  // Categories
  Future<List<Category>> getAllCategories() => select(categories).get();

  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  Future<bool> updateCategory(CategoriesCompanion category) =>
      update(categories).replace(category);

  Future<int> deleteCategory(String uuid) =>
      (delete(categories)..where((t) => t.uuid.equals(uuid))).go();

  Stream<List<Category>> watchCategories() => select(categories).watch();

  // Accounts
  Future<List<Account>> getAllAccounts() => select(accounts).get();

  Future<int> insertAccount(AccountsCompanion account) =>
      into(accounts).insert(account);

  Future<bool> updateAccount(AccountsCompanion account) =>
      update(accounts).replace(account);

  Future<int> deleteAccount(String uuid) =>
      (delete(accounts)..where((t) => t.uuid.equals(uuid))).go();

  Stream<List<Account>> watchAccounts() => select(accounts).watch();

  // Expenses
  Future<List<Expense>> getAllExpenses() => select(expenses).get();

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) =>
      (select(
        expenses,
      )..where((t) => t.spentOn.isBetweenValues(start, end))).get();

  Future<int> insertExpense(ExpensesCompanion expense) =>
      into(expenses).insert(expense);

  Future<bool> updateExpense(ExpensesCompanion expense) =>
      update(expenses).replace(expense);

  Future<int> deleteExpense(String uuid) =>
      (delete(expenses)..where((t) => t.uuid.equals(uuid))).go();

  Stream<List<Expense>> watchExpenses() => select(expenses).watch();

  // Incomes
  Future<List<Income>> getAllIncomes() => select(incomes).get();

  Future<int> insertIncome(IncomesCompanion income) =>
      into(incomes).insert(income);

  Future<bool> updateIncome(IncomesCompanion income) =>
      update(incomes).replace(income);

  Future<int> deleteIncome(String uuid) =>
      (delete(incomes)..where((t) => t.uuid.equals(uuid))).go();

  Stream<List<Income>> watchIncomes() => select(incomes).watch();

  // Budgets
  Future<List<Budget>> getAllBudgets() => select(budgets).get();

  Future<int> insertBudget(BudgetsCompanion budget) =>
      into(budgets).insert(budget);

  Future<bool> updateBudget(BudgetsCompanion budget) =>
      update(budgets).replace(budget);

  Future<int> deleteBudget(String uuid) =>
      (delete(budgets)..where((t) => t.uuid.equals(uuid))).go();

  Stream<List<Budget>> watchBudgets() => select(budgets).watch();

  // Transfers
  Future<List<Transfer>> getAllTransfers() => select(transfers).get();

  Future<int> insertTransfer(TransfersCompanion transfer) =>
      into(transfers).insert(transfer);

  Future<bool> updateTransfer(TransfersCompanion transfer) =>
      update(transfers).replace(transfer);

  Future<int> deleteTransfer(String uuid) =>
      (delete(transfers)..where((t) => t.uuid.equals(uuid))).go();

  Stream<List<Transfer>> watchTransfers() => select(transfers).watch();

  // Pending sync items
  Future<List<Expense>> getPendingExpenses() => (select(
    expenses,
  )..where((t) => t.syncStatus.equals(SyncStatus.pending.index))).get();

  Future<List<Income>> getPendingIncomes() => (select(
    incomes,
  )..where((t) => t.syncStatus.equals(SyncStatus.pending.index))).get();

  Future<List<Category>> getPendingCategories() => (select(
    categories,
  )..where((t) => t.syncStatus.equals(SyncStatus.pending.index))).get();

  Future<List<Account>> getPendingAccounts() => (select(
    accounts,
  )..where((t) => t.syncStatus.equals(SyncStatus.pending.index))).get();

  Future<List<Budget>> getPendingBudgets() => (select(
    budgets,
  )..where((t) => t.syncStatus.equals(SyncStatus.pending.index))).get();

  Future<List<Transfer>> getPendingTransfers() => (select(
    transfers,
  )..where((t) => t.syncStatus.equals(SyncStatus.pending.index))).get();

  // Clear all data
  Future<void> clearAllData() async {
    await delete(transfers).go();
    await delete(budgets).go();
    await delete(incomes).go();
    await delete(expenses).go();
    await delete(accounts).go();
    await delete(categories).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'finance_data.db'));
    return NativeDatabase.createInBackground(file);
  });
}
