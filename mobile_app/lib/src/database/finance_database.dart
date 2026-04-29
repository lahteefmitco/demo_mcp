import 'package:drift/drift.dart';
import 'drift_executor.dart';

part 'finance_database.g.dart';

@DataClassName('LocalAccountRow')
class LocalAccounts extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
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
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get color => text()();
  TextColumn get icon => text()();
  TextColumn get parentId => text().nullable()();
  IntColumn get level => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('LocalExpenseRow')
class LocalExpenses extends Table {
  TextColumn get uuid => text()();
  IntColumn get serverId => integer().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get categoryUuid => text()();
  TextColumn get accountUuid => text()();
  TextColumn get categoryName => text().withDefault(const Constant(''))();
  TextColumn get categoryColor =>
      text().withDefault(const Constant('#0E7490'))();
  TextColumn get accountName => text().withDefault(const Constant(''))();
  TextColumn get accountColor =>
      text().withDefault(const Constant('#10B981'))();
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
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get categoryUuid => text()();
  TextColumn get accountUuid => text()();
  TextColumn get categoryName => text().withDefault(const Constant(''))();
  TextColumn get categoryColor =>
      text().withDefault(const Constant('#0E7490'))();
  TextColumn get accountName => text().withDefault(const Constant(''))();
  TextColumn get accountColor =>
      text().withDefault(const Constant('#10B981'))();
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
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
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
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
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
  FinanceDatabase([QueryExecutor? executor])
    : super(executor ?? openFinanceExecutor());

  /// In-memory database for tests.
  FinanceDatabase.memory() : super(openInMemoryExecutor());

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

  /// [spentOn] is stored as DD-MM-YYYY. Normalized to ISO (YYYY-MM-DD) in SQL for comparisons.
  static const _spentOnAsIsoSql =
      "(substr(spent_on, 7, 4) || '-' || substr(spent_on, 4, 2) || '-' || substr(spent_on, 1, 2))";

  static String _ddMmYyyyToIso(String ddMmYyyy) {
    final parts = ddMmYyyy.split('-');
    if (parts.length != 3) {
      return ddMmYyyy;
    }
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  /// Date-range query in SQLite (filter + sort + optional LIMIT) to avoid loading all rows in Dart.
  Future<List<LocalExpenseRow>> listLocalExpensesInDateRangeOrderedDesc({
    required String fromDdMmYyyy,
    required String toDdMmYyyy,
    int? limit,
  }) async {
    final fromIso = _ddMmYyyyToIso(fromDdMmYyyy);
    final toIso = _ddMmYyyyToIso(toDdMmYyyy);
    final buffer = StringBuffer()
      ..write('SELECT * FROM local_expenses WHERE ')
      ..write(_spentOnAsIsoSql)
      ..write(' >= ? AND ')
      ..write(_spentOnAsIsoSql)
      ..write(' <= ? ORDER BY ')
      ..write(_spentOnAsIsoSql)
      ..write(' DESC, uuid DESC');
    final lim = limit;
    if (lim != null && lim > 0) {
      buffer.write(' LIMIT $lim');
    }
    return customSelect(
      buffer.toString(),
      variables: [Variable<String>(fromIso), Variable<String>(toIso)],
      readsFrom: {localExpenses},
    ).map(_localExpenseRowFromQueryRow).get();
  }

  static LocalExpenseRow _localExpenseRowFromQueryRow(QueryRow row) {
    return LocalExpenseRow(
      uuid: row.read<String>('uuid'),
      serverId: row.readNullable<int>('server_id'),
      isSynced: row.read<bool>('is_synced'),
      title: row.read<String>('title'),
      amount: row.read<double>('amount'),
      categoryUuid: row.read<String>('category_uuid'),
      accountUuid: row.read<String>('account_uuid'),
      categoryName: row.read<String>('category_name'),
      categoryColor: row.read<String>('category_color'),
      accountName: row.read<String>('account_name'),
      accountColor: row.read<String>('account_color'),
      spentOn: row.read<String>('spent_on'),
      notes: row.read<String>('notes'),
      createdAt: row.readNullable<String>('created_at'),
      updatedAt: row.readNullable<String>('updated_at'),
    );
  }

  static const _eSortIso =
      "(substr(e.spent_on, 7, 4) || '-' || substr(e.spent_on, 4, 2) || '-' || substr(e.spent_on, 1, 2))";

  static const _iSortIso =
      "(substr(i.received_on, 7, 4) || '-' || substr(i.received_on, 4, 2) || '-' || substr(i.received_on, 1, 2))";

  /// Strips characters that would break a simple LIKE match.
  static String sanitizeLikeContains(String raw) {
    return raw.replaceAll(RegExp(r'[%_\\]'), '');
  }

  static String get _ledgerExpenseSelect =>
      '''
SELECT
  'expense' AS tx_kind,
  e.uuid AS uuid,
  e.server_id AS server_id,
  e.is_synced AS is_synced,
  e.title AS title,
  e.amount AS amount,
  e.category_uuid AS category_uuid,
  e.account_uuid AS account_uuid,
  e.category_name AS category_name,
  e.category_color AS category_color,
  e.account_name AS account_name,
  e.account_color AS account_color,
  e.spent_on AS tx_date,
  e.notes AS notes,
  e.created_at AS created_at,
  e.updated_at AS updated_at,
  $_eSortIso AS sort_iso
FROM local_expenses e
WHERE e.account_uuid = ?
  AND $_eSortIso >= ?
  AND $_eSortIso <= ?
''';

  static String get _ledgerIncomeSelect =>
      '''
SELECT
  'income' AS tx_kind,
  i.uuid AS uuid,
  i.server_id AS server_id,
  i.is_synced AS is_synced,
  i.title AS title,
  i.amount AS amount,
  i.category_uuid AS category_uuid,
  i.account_uuid AS account_uuid,
  i.category_name AS category_name,
  i.category_color AS category_color,
  i.account_name AS account_name,
  i.account_color AS account_color,
  i.received_on AS tx_date,
  i.notes AS notes,
  i.created_at AS created_at,
  i.updated_at AS updated_at,
  $_iSortIso AS sort_iso
FROM local_incomes i
WHERE i.account_uuid = ?
  AND $_iSortIso >= ?
  AND $_iSortIso <= ?
''';

  /// Merged expenses + incomes for one account, newest first. Uses SQL LIMIT when set.
  ///
  /// [includeExpenses] / [includeIncomes] implement type filter. When both true, results
  /// are merged with [UNION ALL] and sorted in SQLite.
  Future<List<QueryRow>> listLocalAccountLedgerRows({
    required String accountUuid,
    required String fromDdMmYyyy,
    required String toDdMmYyyy,
    required bool includeExpenses,
    required bool includeIncomes,
    String searchLikePattern = '',
    int? limit,
  }) async {
    assert(includeExpenses || includeIncomes);
    final fromIso = _ddMmYyyyToIso(fromDdMmYyyy);
    final toIso = _ddMmYyyyToIso(toDdMmYyyy);
    final hasSearch = searchLikePattern.isNotEmpty;
    final lim = limit;
    final limSql = (lim != null && lim > 0) ? ' LIMIT $lim' : '';

    final variables = <Variable<Object>>[];

    if (includeExpenses && !includeIncomes) {
      final buf = StringBuffer(_ledgerExpenseSelect);
      if (hasSearch) {
        buf.write('''
 AND (
  e.title LIKE ? OR e.notes LIKE ? OR e.category_name LIKE ? OR CAST(e.amount AS TEXT) LIKE ?
)''');
      }
      buf.write(' ORDER BY sort_iso DESC, e.uuid DESC$limSql');
      variables
        ..add(Variable<String>(accountUuid))
        ..add(Variable<String>(fromIso))
        ..add(Variable<String>(toIso));
      if (hasSearch) {
        for (var i = 0; i < 4; i++) {
          variables.add(Variable<String>(searchLikePattern));
        }
      }
      return customSelect(
        buf.toString(),
        variables: variables,
        readsFrom: {localExpenses},
      ).get();
    }

    if (!includeExpenses && includeIncomes) {
      final buf = StringBuffer(_ledgerIncomeSelect);
      if (hasSearch) {
        buf.write('''
 AND (
  i.title LIKE ? OR i.notes LIKE ? OR i.category_name LIKE ? OR CAST(i.amount AS TEXT) LIKE ?
)''');
      }
      buf.write(' ORDER BY sort_iso DESC, i.uuid DESC$limSql');
      variables
        ..add(Variable<String>(accountUuid))
        ..add(Variable<String>(fromIso))
        ..add(Variable<String>(toIso));
      if (hasSearch) {
        for (var i = 0; i < 4; i++) {
          variables.add(Variable<String>(searchLikePattern));
        }
      }
      return customSelect(
        buf.toString(),
        variables: variables,
        readsFrom: {localIncomes},
      ).get();
    }

    final inner = StringBuffer()
      ..write('SELECT * FROM ( ')
      ..write(_ledgerExpenseSelect)
      ..write(' UNION ALL ')
      ..write(_ledgerIncomeSelect)
      ..write(' ) AS u');
    variables
      ..add(Variable<String>(accountUuid))
      ..add(Variable<String>(fromIso))
      ..add(Variable<String>(toIso))
      ..add(Variable<String>(accountUuid))
      ..add(Variable<String>(fromIso))
      ..add(Variable<String>(toIso));

    if (hasSearch) {
      inner.write('''
 WHERE (
  u.title LIKE ? OR u.notes LIKE ? OR u.category_name LIKE ? OR CAST(u.amount AS TEXT) LIKE ?
)''');
      for (var i = 0; i < 4; i++) {
        variables.add(Variable<String>(searchLikePattern));
      }
    }
    inner.write(' ORDER BY u.sort_iso DESC, u.uuid DESC$limSql');

    return customSelect(
      inner.toString(),
      variables: variables,
      readsFrom: {localExpenses, localIncomes},
    ).get();
  }
}
