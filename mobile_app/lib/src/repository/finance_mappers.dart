import 'package:drift/drift.dart';

import '../database/finance_database.dart';

String? _s(dynamic v) => v?.toString();

double _n(dynamic v) {
  if (v is num) {
    return v.toDouble();
  }
  return double.tryParse(v?.toString() ?? '') ?? 0;
}

int? _i(dynamic v) {
  if (v == null) {
    return null;
  }
  if (v is int) {
    return v;
  }
  return int.tryParse(v.toString());
}

Map<String, dynamic> accountToUpsertJson(Map<String, dynamic> j) {
  final uuid = _s(j['uuid']);
  if (uuid == null || uuid.isEmpty) {
    throw StateError('Account missing uuid');
  }
  return {
    'uuid': uuid,
    'serverId': _i(j['id']),
    'name': j['name'] ?? '',
    'type': j['type'] ?? 'cash',
    'initialBalance': _n(j['initialBalance']),
    'currentBalance': _n(j['currentBalance']),
    'color': j['color'] ?? '#0E7490',
    'icon': j['icon'] ?? 'account_balance_wallet',
    'notes': j['notes'] ?? '',
    'isActive': j['isActive'] == true,
    'createdAt': _s(j['createdAt']),
    'updatedAt': _s(j['updatedAt']),
  };
}

LocalAccountsCompanion accountFromServerJson(Map<String, dynamic> j) {
  final m = accountToUpsertJson(j);
  return LocalAccountsCompanion(
    uuid: Value(m['uuid'] as String),
    serverId: Value(m['serverId'] as int?),
    isSynced: const Value(true),
    name: Value(m['name'] as String),
    type: Value(m['type'] as String),
    initialBalance: Value(m['initialBalance'] as double),
    currentBalance: Value(m['currentBalance'] as double),
    color: Value(m['color'] as String),
    icon: Value(m['icon'] as String),
    notes: Value(m['notes'] as String),
    isActive: Value(m['isActive'] as bool),
    createdAt: Value(m['createdAt'] as String?),
    updatedAt: Value(m['updatedAt'] as String?),
  );
}

LocalCategoriesCompanion categoryFromServerJson(Map<String, dynamic> j) {
  final uuid = _s(j['uuid']);
  if (uuid == null || uuid.isEmpty) {
    throw StateError('Category missing uuid');
  }
  return LocalCategoriesCompanion(
    uuid: Value(uuid),
    serverId: Value(_i(j['id'])),
    isSynced: const Value(true),
    name: Value(j['name']?.toString() ?? ''),
    kind: Value(j['kind']?.toString() ?? 'expense'),
    color: Value(j['color']?.toString() ?? '#0E7490'),
    icon: Value(j['icon']?.toString() ?? 'tag'),
    createdAt: Value(_s(j['createdAt'])),
    updatedAt: Value(_s(j['updatedAt'])),
  );
}

LocalExpensesCompanion expenseFromServerJson(
  Map<String, dynamic> j, {
  required String categoryUuid,
  required String accountUuid,
}) {
  final uuid = _s(j['uuid']);
  if (uuid == null || uuid.isEmpty) {
    throw StateError('Expense missing uuid');
  }
  return LocalExpensesCompanion(
    uuid: Value(uuid),
    serverId: Value(_i(j['id'])),
    isSynced: const Value(true),
    title: Value(j['title']?.toString() ?? ''),
    amount: Value(_n(j['amount'])),
    categoryUuid: Value(categoryUuid),
    accountUuid: Value(accountUuid),
    categoryName: Value(j['categoryName']?.toString() ?? ''),
    categoryColor: Value(j['categoryColor']?.toString() ?? '#0E7490'),
    accountName: Value(j['accountName']?.toString() ?? ''),
    accountColor: Value(j['accountColor']?.toString() ?? '#10B981'),
    spentOn: Value(j['spentOn']?.toString() ?? ''),
    notes: Value(j['notes']?.toString() ?? ''),
    createdAt: Value(_s(j['createdAt'])),
    updatedAt: Value(_s(j['updatedAt'])),
  );
}

LocalIncomesCompanion incomeFromServerJson(
  Map<String, dynamic> j, {
  required String categoryUuid,
  required String accountUuid,
}) {
  final uuid = _s(j['uuid']);
  if (uuid == null || uuid.isEmpty) {
    throw StateError('Income missing uuid');
  }
  return LocalIncomesCompanion(
    uuid: Value(uuid),
    serverId: Value(_i(j['id'])),
    isSynced: const Value(true),
    title: Value(j['title']?.toString() ?? ''),
    amount: Value(_n(j['amount'])),
    categoryUuid: Value(categoryUuid),
    accountUuid: Value(accountUuid),
    categoryName: Value(j['categoryName']?.toString() ?? ''),
    categoryColor: Value(j['categoryColor']?.toString() ?? '#0E7490'),
    accountName: Value(j['accountName']?.toString() ?? ''),
    accountColor: Value(j['accountColor']?.toString() ?? '#10B981'),
    receivedOn: Value(j['receivedOn']?.toString() ?? ''),
    notes: Value(j['notes']?.toString() ?? ''),
    createdAt: Value(_s(j['createdAt'])),
    updatedAt: Value(_s(j['updatedAt'])),
  );
}

LocalTransfersCompanion transferFromServerJson(
  Map<String, dynamic> j, {
  required String fromAccountUuid,
  required String toAccountUuid,
}) {
  final uuid = _s(j['uuid']);
  if (uuid == null || uuid.isEmpty) {
    throw StateError('Transfer missing uuid');
  }
  return LocalTransfersCompanion(
    uuid: Value(uuid),
    serverId: Value(_i(j['id'])),
    isSynced: const Value(true),
    fromAccountUuid: Value(fromAccountUuid),
    toAccountUuid: Value(toAccountUuid),
    fromAccountName: Value(j['fromAccountName']?.toString() ?? ''),
    toAccountName: Value(j['toAccountName']?.toString() ?? ''),
    amount: Value(_n(j['amount'])),
    notes: Value(j['notes']?.toString() ?? ''),
    createdAt: Value(_s(j['createdAt'])),
  );
}

LocalBudgetsCompanion budgetFromServerJson(
  Map<String, dynamic> j, {
  String? categoryUuid,
}) {
  final uuid = _s(j['uuid']);
  if (uuid == null || uuid.isEmpty) {
    throw StateError('Budget missing uuid');
  }
  return LocalBudgetsCompanion(
    uuid: Value(uuid),
    serverId: Value(_i(j['id'])),
    isSynced: const Value(true),
    name: Value(j['name']?.toString() ?? ''),
    amount: Value(_n(j['amount'])),
    period: Value(j['period']?.toString() ?? ''),
    startDate: Value(j['startDate']?.toString() ?? ''),
    endDate: Value(j['endDate']?.toString() ?? ''),
    notes: Value(j['notes']?.toString() ?? ''),
    categoryUuid: categoryUuid != null
        ? Value(categoryUuid)
        : const Value.absent(),
    categoryName: Value(j['categoryName']?.toString()),
    categoryColor: Value(j['categoryColor']?.toString()),
    spent: Value(_n(j['spent'])),
    remaining: Value(_n(j['remaining'])),
    createdAt: Value(_s(j['createdAt'])),
    updatedAt: Value(_s(j['updatedAt'])),
  );
}
