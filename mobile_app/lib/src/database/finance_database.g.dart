// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_database.dart';

// ignore_for_file: type=lint
class $LocalAccountsTable extends LocalAccounts
    with TableInfo<$LocalAccountsTable, LocalAccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialBalanceMeta = const VerificationMeta(
    'initialBalance',
  );
  @override
  late final GeneratedColumn<double> initialBalance = GeneratedColumn<double>(
    'initial_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentBalanceMeta = const VerificationMeta(
    'currentBalance',
  );
  @override
  late final GeneratedColumn<double> currentBalance = GeneratedColumn<double>(
    'current_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    serverId,
    isSynced,
    name,
    type,
    initialBalance,
    currentBalance,
    color,
    icon,
    notes,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('initial_balance')) {
      context.handle(
        _initialBalanceMeta,
        initialBalance.isAcceptableOrUnknown(
          data['initial_balance']!,
          _initialBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialBalanceMeta);
    }
    if (data.containsKey('current_balance')) {
      context.handle(
        _currentBalanceMeta,
        currentBalance.isAcceptableOrUnknown(
          data['current_balance']!,
          _currentBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentBalanceMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  LocalAccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAccountRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      initialBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_balance'],
      )!,
      currentBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_balance'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LocalAccountsTable createAlias(String alias) {
    return $LocalAccountsTable(attachedDatabase, alias);
  }
}

class LocalAccountRow extends DataClass implements Insertable<LocalAccountRow> {
  final String uuid;
  final int? serverId;
  final bool isSynced;
  final String name;
  final String type;
  final double initialBalance;
  final double currentBalance;
  final String color;
  final String icon;
  final String notes;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  const LocalAccountRow({
    required this.uuid,
    this.serverId,
    required this.isSynced,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.currentBalance,
    required this.color,
    required this.icon,
    required this.notes,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['initial_balance'] = Variable<double>(initialBalance);
    map['current_balance'] = Variable<double>(currentBalance);
    map['color'] = Variable<String>(color);
    map['icon'] = Variable<String>(icon);
    map['notes'] = Variable<String>(notes);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  LocalAccountsCompanion toCompanion(bool nullToAbsent) {
    return LocalAccountsCompanion(
      uuid: Value(uuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      isSynced: Value(isSynced),
      name: Value(name),
      type: Value(type),
      initialBalance: Value(initialBalance),
      currentBalance: Value(currentBalance),
      color: Value(color),
      icon: Value(icon),
      notes: Value(notes),
      isActive: Value(isActive),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalAccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAccountRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      initialBalance: serializer.fromJson<double>(json['initialBalance']),
      currentBalance: serializer.fromJson<double>(json['currentBalance']),
      color: serializer.fromJson<String>(json['color']),
      icon: serializer.fromJson<String>(json['icon']),
      notes: serializer.fromJson<String>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'serverId': serializer.toJson<int?>(serverId),
      'isSynced': serializer.toJson<bool>(isSynced),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'initialBalance': serializer.toJson<double>(initialBalance),
      'currentBalance': serializer.toJson<double>(currentBalance),
      'color': serializer.toJson<String>(color),
      'icon': serializer.toJson<String>(icon),
      'notes': serializer.toJson<String>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  LocalAccountRow copyWith({
    String? uuid,
    Value<int?> serverId = const Value.absent(),
    bool? isSynced,
    String? name,
    String? type,
    double? initialBalance,
    double? currentBalance,
    String? color,
    String? icon,
    String? notes,
    bool? isActive,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => LocalAccountRow(
    uuid: uuid ?? this.uuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    isSynced: isSynced ?? this.isSynced,
    name: name ?? this.name,
    type: type ?? this.type,
    initialBalance: initialBalance ?? this.initialBalance,
    currentBalance: currentBalance ?? this.currentBalance,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    notes: notes ?? this.notes,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  LocalAccountRow copyWithCompanion(LocalAccountsCompanion data) {
    return LocalAccountRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      initialBalance: data.initialBalance.present
          ? data.initialBalance.value
          : this.initialBalance,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccountRow(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('isSynced: $isSynced, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    serverId,
    isSynced,
    name,
    type,
    initialBalance,
    currentBalance,
    color,
    icon,
    notes,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAccountRow &&
          other.uuid == this.uuid &&
          other.serverId == this.serverId &&
          other.isSynced == this.isSynced &&
          other.name == this.name &&
          other.type == this.type &&
          other.initialBalance == this.initialBalance &&
          other.currentBalance == this.currentBalance &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalAccountsCompanion extends UpdateCompanion<LocalAccountRow> {
  final Value<String> uuid;
  final Value<int?> serverId;
  final Value<bool> isSynced;
  final Value<String> name;
  final Value<String> type;
  final Value<double> initialBalance;
  final Value<double> currentBalance;
  final Value<String> color;
  final Value<String> icon;
  final Value<String> notes;
  final Value<bool> isActive;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const LocalAccountsCompanion({
    this.uuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAccountsCompanion.insert({
    required String uuid,
    this.serverId = const Value.absent(),
    this.isSynced = const Value.absent(),
    required String name,
    required String type,
    required double initialBalance,
    required double currentBalance,
    required String color,
    required String icon,
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       name = Value(name),
       type = Value(type),
       initialBalance = Value(initialBalance),
       currentBalance = Value(currentBalance),
       color = Value(color),
       icon = Value(icon);
  static Insertable<LocalAccountRow> custom({
    Expression<String>? uuid,
    Expression<int>? serverId,
    Expression<bool>? isSynced,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? initialBalance,
    Expression<double>? currentBalance,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (serverId != null) 'server_id': serverId,
      if (isSynced != null) 'is_synced': isSynced,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAccountsCompanion copyWith({
    Value<String>? uuid,
    Value<int?>? serverId,
    Value<bool>? isSynced,
    Value<String>? name,
    Value<String>? type,
    Value<double>? initialBalance,
    Value<double>? currentBalance,
    Value<String>? color,
    Value<String>? icon,
    Value<String>? notes,
    Value<bool>? isActive,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalAccountsCompanion(
      uuid: uuid ?? this.uuid,
      serverId: serverId ?? this.serverId,
      isSynced: isSynced ?? this.isSynced,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (initialBalance.present) {
      map['initial_balance'] = Variable<double>(initialBalance.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<double>(currentBalance.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccountsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('isSynced: $isSynced, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCategoriesTable extends LocalCategories
    with TableInfo<$LocalCategoriesTable, LocalCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    serverId,
    isSynced,
    name,
    kind,
    color,
    icon,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  LocalCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCategoryRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LocalCategoriesTable createAlias(String alias) {
    return $LocalCategoriesTable(attachedDatabase, alias);
  }
}

class LocalCategoryRow extends DataClass
    implements Insertable<LocalCategoryRow> {
  final String uuid;
  final int? serverId;
  final bool isSynced;
  final String name;
  final String kind;
  final String color;
  final String icon;
  final String? createdAt;
  final String? updatedAt;
  const LocalCategoryRow({
    required this.uuid,
    this.serverId,
    required this.isSynced,
    required this.name,
    required this.kind,
    required this.color,
    required this.icon,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['color'] = Variable<String>(color);
    map['icon'] = Variable<String>(icon);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  LocalCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LocalCategoriesCompanion(
      uuid: Value(uuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      isSynced: Value(isSynced),
      name: Value(name),
      kind: Value(kind),
      color: Value(color),
      icon: Value(icon),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCategoryRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      color: serializer.fromJson<String>(json['color']),
      icon: serializer.fromJson<String>(json['icon']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'serverId': serializer.toJson<int?>(serverId),
      'isSynced': serializer.toJson<bool>(isSynced),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'color': serializer.toJson<String>(color),
      'icon': serializer.toJson<String>(icon),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  LocalCategoryRow copyWith({
    String? uuid,
    Value<int?> serverId = const Value.absent(),
    bool? isSynced,
    String? name,
    String? kind,
    String? color,
    String? icon,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => LocalCategoryRow(
    uuid: uuid ?? this.uuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    isSynced: isSynced ?? this.isSynced,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  LocalCategoryRow copyWithCompanion(LocalCategoriesCompanion data) {
    return LocalCategoryRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategoryRow(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('isSynced: $isSynced, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    serverId,
    isSynced,
    name,
    kind,
    color,
    icon,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCategoryRow &&
          other.uuid == this.uuid &&
          other.serverId == this.serverId &&
          other.isSynced == this.isSynced &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalCategoriesCompanion extends UpdateCompanion<LocalCategoryRow> {
  final Value<String> uuid;
  final Value<int?> serverId;
  final Value<bool> isSynced;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> color;
  final Value<String> icon;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const LocalCategoriesCompanion({
    this.uuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCategoriesCompanion.insert({
    required String uuid,
    this.serverId = const Value.absent(),
    this.isSynced = const Value.absent(),
    required String name,
    required String kind,
    required String color,
    required String icon,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       name = Value(name),
       kind = Value(kind),
       color = Value(color),
       icon = Value(icon);
  static Insertable<LocalCategoryRow> custom({
    Expression<String>? uuid,
    Expression<int>? serverId,
    Expression<bool>? isSynced,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (serverId != null) 'server_id': serverId,
      if (isSynced != null) 'is_synced': isSynced,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCategoriesCompanion copyWith({
    Value<String>? uuid,
    Value<int?>? serverId,
    Value<bool>? isSynced,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? color,
    Value<String>? icon,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalCategoriesCompanion(
      uuid: uuid ?? this.uuid,
      serverId: serverId ?? this.serverId,
      isSynced: isSynced ?? this.isSynced,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategoriesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('isSynced: $isSynced, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalExpensesTable extends LocalExpenses
    with TableInfo<$LocalExpensesTable, LocalExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryUuidMeta = const VerificationMeta(
    'categoryUuid',
  );
  @override
  late final GeneratedColumn<String> categoryUuid = GeneratedColumn<String>(
    'category_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountUuidMeta = const VerificationMeta(
    'accountUuid',
  );
  @override
  late final GeneratedColumn<String> accountUuid = GeneratedColumn<String>(
    'account_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryColorMeta = const VerificationMeta(
    'categoryColor',
  );
  @override
  late final GeneratedColumn<String> categoryColor = GeneratedColumn<String>(
    'category_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#0E7490'),
  );
  static const VerificationMeta _accountNameMeta = const VerificationMeta(
    'accountName',
  );
  @override
  late final GeneratedColumn<String> accountName = GeneratedColumn<String>(
    'account_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _accountColorMeta = const VerificationMeta(
    'accountColor',
  );
  @override
  late final GeneratedColumn<String> accountColor = GeneratedColumn<String>(
    'account_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#10B981'),
  );
  static const VerificationMeta _spentOnMeta = const VerificationMeta(
    'spentOn',
  );
  @override
  late final GeneratedColumn<String> spentOn = GeneratedColumn<String>(
    'spent_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    serverId,
    isSynced,
    title,
    amount,
    categoryUuid,
    accountUuid,
    categoryName,
    categoryColor,
    accountName,
    accountColor,
    spentOn,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_uuid')) {
      context.handle(
        _categoryUuidMeta,
        categoryUuid.isAcceptableOrUnknown(
          data['category_uuid']!,
          _categoryUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryUuidMeta);
    }
    if (data.containsKey('account_uuid')) {
      context.handle(
        _accountUuidMeta,
        accountUuid.isAcceptableOrUnknown(
          data['account_uuid']!,
          _accountUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountUuidMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    }
    if (data.containsKey('category_color')) {
      context.handle(
        _categoryColorMeta,
        categoryColor.isAcceptableOrUnknown(
          data['category_color']!,
          _categoryColorMeta,
        ),
      );
    }
    if (data.containsKey('account_name')) {
      context.handle(
        _accountNameMeta,
        accountName.isAcceptableOrUnknown(
          data['account_name']!,
          _accountNameMeta,
        ),
      );
    }
    if (data.containsKey('account_color')) {
      context.handle(
        _accountColorMeta,
        accountColor.isAcceptableOrUnknown(
          data['account_color']!,
          _accountColorMeta,
        ),
      );
    }
    if (data.containsKey('spent_on')) {
      context.handle(
        _spentOnMeta,
        spentOn.isAcceptableOrUnknown(data['spent_on']!, _spentOnMeta),
      );
    } else if (isInserting) {
      context.missing(_spentOnMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  LocalExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalExpenseRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      categoryUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_uuid'],
      )!,
      accountUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_uuid'],
      )!,
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      )!,
      categoryColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_color'],
      )!,
      accountName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_name'],
      )!,
      accountColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_color'],
      )!,
      spentOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spent_on'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LocalExpensesTable createAlias(String alias) {
    return $LocalExpensesTable(attachedDatabase, alias);
  }
}

class LocalExpenseRow extends DataClass implements Insertable<LocalExpenseRow> {
  final String uuid;
  final int? serverId;
  final bool isSynced;
  final String title;
  final double amount;
  final String categoryUuid;
  final String accountUuid;
  final String categoryName;
  final String categoryColor;
  final String accountName;
  final String accountColor;
  final String spentOn;
  final String notes;
  final String? createdAt;
  final String? updatedAt;
  const LocalExpenseRow({
    required this.uuid,
    this.serverId,
    required this.isSynced,
    required this.title,
    required this.amount,
    required this.categoryUuid,
    required this.accountUuid,
    required this.categoryName,
    required this.categoryColor,
    required this.accountName,
    required this.accountColor,
    required this.spentOn,
    required this.notes,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['category_uuid'] = Variable<String>(categoryUuid);
    map['account_uuid'] = Variable<String>(accountUuid);
    map['category_name'] = Variable<String>(categoryName);
    map['category_color'] = Variable<String>(categoryColor);
    map['account_name'] = Variable<String>(accountName);
    map['account_color'] = Variable<String>(accountColor);
    map['spent_on'] = Variable<String>(spentOn);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  LocalExpensesCompanion toCompanion(bool nullToAbsent) {
    return LocalExpensesCompanion(
      uuid: Value(uuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      isSynced: Value(isSynced),
      title: Value(title),
      amount: Value(amount),
      categoryUuid: Value(categoryUuid),
      accountUuid: Value(accountUuid),
      categoryName: Value(categoryName),
      categoryColor: Value(categoryColor),
      accountName: Value(accountName),
      accountColor: Value(accountColor),
      spentOn: Value(spentOn),
      notes: Value(notes),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalExpenseRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryUuid: serializer.fromJson<String>(json['categoryUuid']),
      accountUuid: serializer.fromJson<String>(json['accountUuid']),
      categoryName: serializer.fromJson<String>(json['categoryName']),
      categoryColor: serializer.fromJson<String>(json['categoryColor']),
      accountName: serializer.fromJson<String>(json['accountName']),
      accountColor: serializer.fromJson<String>(json['accountColor']),
      spentOn: serializer.fromJson<String>(json['spentOn']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'serverId': serializer.toJson<int?>(serverId),
      'isSynced': serializer.toJson<bool>(isSynced),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'categoryUuid': serializer.toJson<String>(categoryUuid),
      'accountUuid': serializer.toJson<String>(accountUuid),
      'categoryName': serializer.toJson<String>(categoryName),
      'categoryColor': serializer.toJson<String>(categoryColor),
      'accountName': serializer.toJson<String>(accountName),
      'accountColor': serializer.toJson<String>(accountColor),
      'spentOn': serializer.toJson<String>(spentOn),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  LocalExpenseRow copyWith({
    String? uuid,
    Value<int?> serverId = const Value.absent(),
    bool? isSynced,
    String? title,
    double? amount,
    String? categoryUuid,
    String? accountUuid,
    String? categoryName,
    String? categoryColor,
    String? accountName,
    String? accountColor,
    String? spentOn,
    String? notes,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => LocalExpenseRow(
    uuid: uuid ?? this.uuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    isSynced: isSynced ?? this.isSynced,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    categoryUuid: categoryUuid ?? this.categoryUuid,
    accountUuid: accountUuid ?? this.accountUuid,
    categoryName: categoryName ?? this.categoryName,
    categoryColor: categoryColor ?? this.categoryColor,
    accountName: accountName ?? this.accountName,
    accountColor: accountColor ?? this.accountColor,
    spentOn: spentOn ?? this.spentOn,
    notes: notes ?? this.notes,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  LocalExpenseRow copyWithCompanion(LocalExpensesCompanion data) {
    return LocalExpenseRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryUuid: data.categoryUuid.present
          ? data.categoryUuid.value
          : this.categoryUuid,
      accountUuid: data.accountUuid.present
          ? data.accountUuid.value
          : this.accountUuid,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      categoryColor: data.categoryColor.present
          ? data.categoryColor.value
          : this.categoryColor,
      accountName: data.accountName.present
          ? data.accountName.value
          : this.accountName,
      accountColor: data.accountColor.present
          ? data.accountColor.value
          : this.accountColor,
      spentOn: data.spentOn.present ? data.spentOn.value : this.spentOn,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalExpenseRow(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('isSynced: $isSynced, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('accountUuid: $accountUuid, ')
          ..write('categoryName: $categoryName, ')
          ..write('categoryColor: $categoryColor, ')
          ..write('accountName: $accountName, ')
          ..write('accountColor: $accountColor, ')
          ..write('spentOn: $spentOn, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    serverId,
    isSynced,
    title,
    amount,
    categoryUuid,
    accountUuid,
    categoryName,
    categoryColor,
    accountName,
    accountColor,
    spentOn,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalExpenseRow &&
          other.uuid == this.uuid &&
          other.serverId == this.serverId &&
          other.isSynced == this.isSynced &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.categoryUuid == this.categoryUuid &&
          other.accountUuid == this.accountUuid &&
          other.categoryName == this.categoryName &&
          other.categoryColor == this.categoryColor &&
          other.accountName == this.accountName &&
          other.accountColor == this.accountColor &&
          other.spentOn == this.spentOn &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalExpensesCompanion extends UpdateCompanion<LocalExpenseRow> {
  final Value<String> uuid;
  final Value<int?> serverId;
  final Value<bool> isSynced;
  final Value<String> title;
  final Value<double> amount;
  final Value<String> categoryUuid;
  final Value<String> accountUuid;
  final Value<String> categoryName;
  final Value<String> categoryColor;
  final Value<String> accountName;
  final Value<String> accountColor;
  final Value<String> spentOn;
  final Value<String> notes;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const LocalExpensesCompanion({
    this.uuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryUuid = const Value.absent(),
    this.accountUuid = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.categoryColor = const Value.absent(),
    this.accountName = const Value.absent(),
    this.accountColor = const Value.absent(),
    this.spentOn = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalExpensesCompanion.insert({
    required String uuid,
    this.serverId = const Value.absent(),
    this.isSynced = const Value.absent(),
    required String title,
    required double amount,
    required String categoryUuid,
    required String accountUuid,
    this.categoryName = const Value.absent(),
    this.categoryColor = const Value.absent(),
    this.accountName = const Value.absent(),
    this.accountColor = const Value.absent(),
    required String spentOn,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       title = Value(title),
       amount = Value(amount),
       categoryUuid = Value(categoryUuid),
       accountUuid = Value(accountUuid),
       spentOn = Value(spentOn);
  static Insertable<LocalExpenseRow> custom({
    Expression<String>? uuid,
    Expression<int>? serverId,
    Expression<bool>? isSynced,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<String>? categoryUuid,
    Expression<String>? accountUuid,
    Expression<String>? categoryName,
    Expression<String>? categoryColor,
    Expression<String>? accountName,
    Expression<String>? accountColor,
    Expression<String>? spentOn,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (serverId != null) 'server_id': serverId,
      if (isSynced != null) 'is_synced': isSynced,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (categoryUuid != null) 'category_uuid': categoryUuid,
      if (accountUuid != null) 'account_uuid': accountUuid,
      if (categoryName != null) 'category_name': categoryName,
      if (categoryColor != null) 'category_color': categoryColor,
      if (accountName != null) 'account_name': accountName,
      if (accountColor != null) 'account_color': accountColor,
      if (spentOn != null) 'spent_on': spentOn,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalExpensesCompanion copyWith({
    Value<String>? uuid,
    Value<int?>? serverId,
    Value<bool>? isSynced,
    Value<String>? title,
    Value<double>? amount,
    Value<String>? categoryUuid,
    Value<String>? accountUuid,
    Value<String>? categoryName,
    Value<String>? categoryColor,
    Value<String>? accountName,
    Value<String>? accountColor,
    Value<String>? spentOn,
    Value<String>? notes,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalExpensesCompanion(
      uuid: uuid ?? this.uuid,
      serverId: serverId ?? this.serverId,
      isSynced: isSynced ?? this.isSynced,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      accountUuid: accountUuid ?? this.accountUuid,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      accountName: accountName ?? this.accountName,
      accountColor: accountColor ?? this.accountColor,
      spentOn: spentOn ?? this.spentOn,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryUuid.present) {
      map['category_uuid'] = Variable<String>(categoryUuid.value);
    }
    if (accountUuid.present) {
      map['account_uuid'] = Variable<String>(accountUuid.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (categoryColor.present) {
      map['category_color'] = Variable<String>(categoryColor.value);
    }
    if (accountName.present) {
      map['account_name'] = Variable<String>(accountName.value);
    }
    if (accountColor.present) {
      map['account_color'] = Variable<String>(accountColor.value);
    }
    if (spentOn.present) {
      map['spent_on'] = Variable<String>(spentOn.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalExpensesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('isSynced: $isSynced, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('accountUuid: $accountUuid, ')
          ..write('categoryName: $categoryName, ')
          ..write('categoryColor: $categoryColor, ')
          ..write('accountName: $accountName, ')
          ..write('accountColor: $accountColor, ')
          ..write('spentOn: $spentOn, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalIncomesTable extends LocalIncomes
    with TableInfo<$LocalIncomesTable, LocalIncomeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalIncomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryUuidMeta = const VerificationMeta(
    'categoryUuid',
  );
  @override
  late final GeneratedColumn<String> categoryUuid = GeneratedColumn<String>(
    'category_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountUuidMeta = const VerificationMeta(
    'accountUuid',
  );
  @override
  late final GeneratedColumn<String> accountUuid = GeneratedColumn<String>(
    'account_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryColorMeta = const VerificationMeta(
    'categoryColor',
  );
  @override
  late final GeneratedColumn<String> categoryColor = GeneratedColumn<String>(
    'category_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#0E7490'),
  );
  static const VerificationMeta _accountNameMeta = const VerificationMeta(
    'accountName',
  );
  @override
  late final GeneratedColumn<String> accountName = GeneratedColumn<String>(
    'account_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _accountColorMeta = const VerificationMeta(
    'accountColor',
  );
  @override
  late final GeneratedColumn<String> accountColor = GeneratedColumn<String>(
    'account_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#10B981'),
  );
  static const VerificationMeta _receivedOnMeta = const VerificationMeta(
    'receivedOn',
  );
  @override
  late final GeneratedColumn<String> receivedOn = GeneratedColumn<String>(
    'received_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    serverId,
    isSynced,
    title,
    amount,
    categoryUuid,
    accountUuid,
    categoryName,
    categoryColor,
    accountName,
    accountColor,
    receivedOn,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_incomes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalIncomeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_uuid')) {
      context.handle(
        _categoryUuidMeta,
        categoryUuid.isAcceptableOrUnknown(
          data['category_uuid']!,
          _categoryUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryUuidMeta);
    }
    if (data.containsKey('account_uuid')) {
      context.handle(
        _accountUuidMeta,
        accountUuid.isAcceptableOrUnknown(
          data['account_uuid']!,
          _accountUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountUuidMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    }
    if (data.containsKey('category_color')) {
      context.handle(
        _categoryColorMeta,
        categoryColor.isAcceptableOrUnknown(
          data['category_color']!,
          _categoryColorMeta,
        ),
      );
    }
    if (data.containsKey('account_name')) {
      context.handle(
        _accountNameMeta,
        accountName.isAcceptableOrUnknown(
          data['account_name']!,
          _accountNameMeta,
        ),
      );
    }
    if (data.containsKey('account_color')) {
      context.handle(
        _accountColorMeta,
        accountColor.isAcceptableOrUnknown(
          data['account_color']!,
          _accountColorMeta,
        ),
      );
    }
    if (data.containsKey('received_on')) {
      context.handle(
        _receivedOnMeta,
        receivedOn.isAcceptableOrUnknown(data['received_on']!, _receivedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedOnMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  LocalIncomeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalIncomeRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      categoryUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_uuid'],
      )!,
      accountUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_uuid'],
      )!,
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      )!,
      categoryColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_color'],
      )!,
      accountName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_name'],
      )!,
      accountColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_color'],
      )!,
      receivedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_on'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LocalIncomesTable createAlias(String alias) {
    return $LocalIncomesTable(attachedDatabase, alias);
  }
}

class LocalIncomeRow extends DataClass implements Insertable<LocalIncomeRow> {
  final String uuid;
  final int? serverId;
  final bool isSynced;
  final String title;
  final double amount;
  final String categoryUuid;
  final String accountUuid;
  final String categoryName;
  final String categoryColor;
  final String accountName;
  final String accountColor;
  final String receivedOn;
  final String notes;
  final String? createdAt;
  final String? updatedAt;
  const LocalIncomeRow({
    required this.uuid,
    this.serverId,
    required this.isSynced,
    required this.title,
    required this.amount,
    required this.categoryUuid,
    required this.accountUuid,
    required this.categoryName,
    required this.categoryColor,
    required this.accountName,
    required this.accountColor,
    required this.receivedOn,
    required this.notes,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['category_uuid'] = Variable<String>(categoryUuid);
    map['account_uuid'] = Variable<String>(accountUuid);
    map['category_name'] = Variable<String>(categoryName);
    map['category_color'] = Variable<String>(categoryColor);
    map['account_name'] = Variable<String>(accountName);
    map['account_color'] = Variable<String>(accountColor);
    map['received_on'] = Variable<String>(receivedOn);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  LocalIncomesCompanion toCompanion(bool nullToAbsent) {
    return LocalIncomesCompanion(
      uuid: Value(uuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      isSynced: Value(isSynced),
      title: Value(title),
      amount: Value(amount),
      categoryUuid: Value(categoryUuid),
      accountUuid: Value(accountUuid),
      categoryName: Value(categoryName),
      categoryColor: Value(categoryColor),
      accountName: Value(accountName),
      accountColor: Value(accountColor),
      receivedOn: Value(receivedOn),
      notes: Value(notes),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalIncomeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalIncomeRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryUuid: serializer.fromJson<String>(json['categoryUuid']),
      accountUuid: serializer.fromJson<String>(json['accountUuid']),
      categoryName: serializer.fromJson<String>(json['categoryName']),
      categoryColor: serializer.fromJson<String>(json['categoryColor']),
      accountName: serializer.fromJson<String>(json['accountName']),
      accountColor: serializer.fromJson<String>(json['accountColor']),
      receivedOn: serializer.fromJson<String>(json['receivedOn']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'serverId': serializer.toJson<int?>(serverId),
      'isSynced': serializer.toJson<bool>(isSynced),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'categoryUuid': serializer.toJson<String>(categoryUuid),
      'accountUuid': serializer.toJson<String>(accountUuid),
      'categoryName': serializer.toJson<String>(categoryName),
      'categoryColor': serializer.toJson<String>(categoryColor),
      'accountName': serializer.toJson<String>(accountName),
      'accountColor': serializer.toJson<String>(accountColor),
      'receivedOn': serializer.toJson<String>(receivedOn),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  LocalIncomeRow copyWith({
    String? uuid,
    Value<int?> serverId = const Value.absent(),
    bool? isSynced,
    String? title,
    double? amount,
    String? categoryUuid,
    String? accountUuid,
    String? categoryName,
    String? categoryColor,
    String? accountName,
    String? accountColor,
    String? receivedOn,
    String? notes,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => LocalIncomeRow(
    uuid: uuid ?? this.uuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    isSynced: isSynced ?? this.isSynced,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    categoryUuid: categoryUuid ?? this.categoryUuid,
    accountUuid: accountUuid ?? this.accountUuid,
    categoryName: categoryName ?? this.categoryName,
    categoryColor: categoryColor ?? this.categoryColor,
    accountName: accountName ?? this.accountName,
    accountColor: accountColor ?? this.accountColor,
    receivedOn: receivedOn ?? this.receivedOn,
    notes: notes ?? this.notes,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  LocalIncomeRow copyWithCompanion(LocalIncomesCompanion data) {
    return LocalIncomeRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryUuid: data.categoryUuid.present
          ? data.categoryUuid.value
          : this.categoryUuid,
      accountUuid: data.accountUuid.present
          ? data.accountUuid.value
          : this.accountUuid,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      categoryColor: data.categoryColor.present
          ? data.categoryColor.value
          : this.categoryColor,
      accountName: data.accountName.present
          ? data.accountName.value
          : this.accountName,
      accountColor: data.accountColor.present
          ? data.accountColor.value
          : this.accountColor,
      receivedOn: data.receivedOn.present
          ? data.receivedOn.value
          : this.receivedOn,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalIncomeRow(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('isSynced: $isSynced, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('accountUuid: $accountUuid, ')
          ..write('categoryName: $categoryName, ')
          ..write('categoryColor: $categoryColor, ')
          ..write('accountName: $accountName, ')
          ..write('accountColor: $accountColor, ')
          ..write('receivedOn: $receivedOn, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    serverId,
    isSynced,
    title,
    amount,
    categoryUuid,
    accountUuid,
    categoryName,
    categoryColor,
    accountName,
    accountColor,
    receivedOn,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalIncomeRow &&
          other.uuid == this.uuid &&
          other.serverId == this.serverId &&
          other.isSynced == this.isSynced &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.categoryUuid == this.categoryUuid &&
          other.accountUuid == this.accountUuid &&
          other.categoryName == this.categoryName &&
          other.categoryColor == this.categoryColor &&
          other.accountName == this.accountName &&
          other.accountColor == this.accountColor &&
          other.receivedOn == this.receivedOn &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalIncomesCompanion extends UpdateCompanion<LocalIncomeRow> {
  final Value<String> uuid;
  final Value<int?> serverId;
  final Value<bool> isSynced;
  final Value<String> title;
  final Value<double> amount;
  final Value<String> categoryUuid;
  final Value<String> accountUuid;
  final Value<String> categoryName;
  final Value<String> categoryColor;
  final Value<String> accountName;
  final Value<String> accountColor;
  final Value<String> receivedOn;
  final Value<String> notes;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const LocalIncomesCompanion({
    this.uuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryUuid = const Value.absent(),
    this.accountUuid = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.categoryColor = const Value.absent(),
    this.accountName = const Value.absent(),
    this.accountColor = const Value.absent(),
    this.receivedOn = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalIncomesCompanion.insert({
    required String uuid,
    this.serverId = const Value.absent(),
    this.isSynced = const Value.absent(),
    required String title,
    required double amount,
    required String categoryUuid,
    required String accountUuid,
    this.categoryName = const Value.absent(),
    this.categoryColor = const Value.absent(),
    this.accountName = const Value.absent(),
    this.accountColor = const Value.absent(),
    required String receivedOn,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       title = Value(title),
       amount = Value(amount),
       categoryUuid = Value(categoryUuid),
       accountUuid = Value(accountUuid),
       receivedOn = Value(receivedOn);
  static Insertable<LocalIncomeRow> custom({
    Expression<String>? uuid,
    Expression<int>? serverId,
    Expression<bool>? isSynced,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<String>? categoryUuid,
    Expression<String>? accountUuid,
    Expression<String>? categoryName,
    Expression<String>? categoryColor,
    Expression<String>? accountName,
    Expression<String>? accountColor,
    Expression<String>? receivedOn,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (serverId != null) 'server_id': serverId,
      if (isSynced != null) 'is_synced': isSynced,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (categoryUuid != null) 'category_uuid': categoryUuid,
      if (accountUuid != null) 'account_uuid': accountUuid,
      if (categoryName != null) 'category_name': categoryName,
      if (categoryColor != null) 'category_color': categoryColor,
      if (accountName != null) 'account_name': accountName,
      if (accountColor != null) 'account_color': accountColor,
      if (receivedOn != null) 'received_on': receivedOn,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalIncomesCompanion copyWith({
    Value<String>? uuid,
    Value<int?>? serverId,
    Value<bool>? isSynced,
    Value<String>? title,
    Value<double>? amount,
    Value<String>? categoryUuid,
    Value<String>? accountUuid,
    Value<String>? categoryName,
    Value<String>? categoryColor,
    Value<String>? accountName,
    Value<String>? accountColor,
    Value<String>? receivedOn,
    Value<String>? notes,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalIncomesCompanion(
      uuid: uuid ?? this.uuid,
      serverId: serverId ?? this.serverId,
      isSynced: isSynced ?? this.isSynced,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      accountUuid: accountUuid ?? this.accountUuid,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      accountName: accountName ?? this.accountName,
      accountColor: accountColor ?? this.accountColor,
      receivedOn: receivedOn ?? this.receivedOn,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryUuid.present) {
      map['category_uuid'] = Variable<String>(categoryUuid.value);
    }
    if (accountUuid.present) {
      map['account_uuid'] = Variable<String>(accountUuid.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (categoryColor.present) {
      map['category_color'] = Variable<String>(categoryColor.value);
    }
    if (accountName.present) {
      map['account_name'] = Variable<String>(accountName.value);
    }
    if (accountColor.present) {
      map['account_color'] = Variable<String>(accountColor.value);
    }
    if (receivedOn.present) {
      map['received_on'] = Variable<String>(receivedOn.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalIncomesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('isSynced: $isSynced, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('accountUuid: $accountUuid, ')
          ..write('categoryName: $categoryName, ')
          ..write('categoryColor: $categoryColor, ')
          ..write('accountName: $accountName, ')
          ..write('accountColor: $accountColor, ')
          ..write('receivedOn: $receivedOn, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTransfersTable extends LocalTransfers
    with TableInfo<$LocalTransfersTable, LocalTransferRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTransfersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fromAccountUuidMeta = const VerificationMeta(
    'fromAccountUuid',
  );
  @override
  late final GeneratedColumn<String> fromAccountUuid = GeneratedColumn<String>(
    'from_account_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toAccountUuidMeta = const VerificationMeta(
    'toAccountUuid',
  );
  @override
  late final GeneratedColumn<String> toAccountUuid = GeneratedColumn<String>(
    'to_account_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromAccountNameMeta = const VerificationMeta(
    'fromAccountName',
  );
  @override
  late final GeneratedColumn<String> fromAccountName = GeneratedColumn<String>(
    'from_account_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _toAccountNameMeta = const VerificationMeta(
    'toAccountName',
  );
  @override
  late final GeneratedColumn<String> toAccountName = GeneratedColumn<String>(
    'to_account_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    serverId,
    isSynced,
    fromAccountUuid,
    toAccountUuid,
    fromAccountName,
    toAccountName,
    amount,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_transfers';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTransferRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('from_account_uuid')) {
      context.handle(
        _fromAccountUuidMeta,
        fromAccountUuid.isAcceptableOrUnknown(
          data['from_account_uuid']!,
          _fromAccountUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromAccountUuidMeta);
    }
    if (data.containsKey('to_account_uuid')) {
      context.handle(
        _toAccountUuidMeta,
        toAccountUuid.isAcceptableOrUnknown(
          data['to_account_uuid']!,
          _toAccountUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toAccountUuidMeta);
    }
    if (data.containsKey('from_account_name')) {
      context.handle(
        _fromAccountNameMeta,
        fromAccountName.isAcceptableOrUnknown(
          data['from_account_name']!,
          _fromAccountNameMeta,
        ),
      );
    }
    if (data.containsKey('to_account_name')) {
      context.handle(
        _toAccountNameMeta,
        toAccountName.isAcceptableOrUnknown(
          data['to_account_name']!,
          _toAccountNameMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  LocalTransferRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTransferRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      fromAccountUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_account_uuid'],
      )!,
      toAccountUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_account_uuid'],
      )!,
      fromAccountName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_account_name'],
      )!,
      toAccountName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_account_name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $LocalTransfersTable createAlias(String alias) {
    return $LocalTransfersTable(attachedDatabase, alias);
  }
}

class LocalTransferRow extends DataClass
    implements Insertable<LocalTransferRow> {
  final String uuid;
  final int? serverId;
  final bool isSynced;
  final String fromAccountUuid;
  final String toAccountUuid;
  final String fromAccountName;
  final String toAccountName;
  final double amount;
  final String notes;
  final String? createdAt;
  const LocalTransferRow({
    required this.uuid,
    this.serverId,
    required this.isSynced,
    required this.fromAccountUuid,
    required this.toAccountUuid,
    required this.fromAccountName,
    required this.toAccountName,
    required this.amount,
    required this.notes,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['from_account_uuid'] = Variable<String>(fromAccountUuid);
    map['to_account_uuid'] = Variable<String>(toAccountUuid);
    map['from_account_name'] = Variable<String>(fromAccountName);
    map['to_account_name'] = Variable<String>(toAccountName);
    map['amount'] = Variable<double>(amount);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    return map;
  }

  LocalTransfersCompanion toCompanion(bool nullToAbsent) {
    return LocalTransfersCompanion(
      uuid: Value(uuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      isSynced: Value(isSynced),
      fromAccountUuid: Value(fromAccountUuid),
      toAccountUuid: Value(toAccountUuid),
      fromAccountName: Value(fromAccountName),
      toAccountName: Value(toAccountName),
      amount: Value(amount),
      notes: Value(notes),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory LocalTransferRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTransferRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      fromAccountUuid: serializer.fromJson<String>(json['fromAccountUuid']),
      toAccountUuid: serializer.fromJson<String>(json['toAccountUuid']),
      fromAccountName: serializer.fromJson<String>(json['fromAccountName']),
      toAccountName: serializer.fromJson<String>(json['toAccountName']),
      amount: serializer.fromJson<double>(json['amount']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'serverId': serializer.toJson<int?>(serverId),
      'isSynced': serializer.toJson<bool>(isSynced),
      'fromAccountUuid': serializer.toJson<String>(fromAccountUuid),
      'toAccountUuid': serializer.toJson<String>(toAccountUuid),
      'fromAccountName': serializer.toJson<String>(fromAccountName),
      'toAccountName': serializer.toJson<String>(toAccountName),
      'amount': serializer.toJson<double>(amount),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<String?>(createdAt),
    };
  }

  LocalTransferRow copyWith({
    String? uuid,
    Value<int?> serverId = const Value.absent(),
    bool? isSynced,
    String? fromAccountUuid,
    String? toAccountUuid,
    String? fromAccountName,
    String? toAccountName,
    double? amount,
    String? notes,
    Value<String?> createdAt = const Value.absent(),
  }) => LocalTransferRow(
    uuid: uuid ?? this.uuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    isSynced: isSynced ?? this.isSynced,
    fromAccountUuid: fromAccountUuid ?? this.fromAccountUuid,
    toAccountUuid: toAccountUuid ?? this.toAccountUuid,
    fromAccountName: fromAccountName ?? this.fromAccountName,
    toAccountName: toAccountName ?? this.toAccountName,
    amount: amount ?? this.amount,
    notes: notes ?? this.notes,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  LocalTransferRow copyWithCompanion(LocalTransfersCompanion data) {
    return LocalTransferRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      fromAccountUuid: data.fromAccountUuid.present
          ? data.fromAccountUuid.value
          : this.fromAccountUuid,
      toAccountUuid: data.toAccountUuid.present
          ? data.toAccountUuid.value
          : this.toAccountUuid,
      fromAccountName: data.fromAccountName.present
          ? data.fromAccountName.value
          : this.fromAccountName,
      toAccountName: data.toAccountName.present
          ? data.toAccountName.value
          : this.toAccountName,
      amount: data.amount.present ? data.amount.value : this.amount,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransferRow(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('isSynced: $isSynced, ')
          ..write('fromAccountUuid: $fromAccountUuid, ')
          ..write('toAccountUuid: $toAccountUuid, ')
          ..write('fromAccountName: $fromAccountName, ')
          ..write('toAccountName: $toAccountName, ')
          ..write('amount: $amount, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    serverId,
    isSynced,
    fromAccountUuid,
    toAccountUuid,
    fromAccountName,
    toAccountName,
    amount,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTransferRow &&
          other.uuid == this.uuid &&
          other.serverId == this.serverId &&
          other.isSynced == this.isSynced &&
          other.fromAccountUuid == this.fromAccountUuid &&
          other.toAccountUuid == this.toAccountUuid &&
          other.fromAccountName == this.fromAccountName &&
          other.toAccountName == this.toAccountName &&
          other.amount == this.amount &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class LocalTransfersCompanion extends UpdateCompanion<LocalTransferRow> {
  final Value<String> uuid;
  final Value<int?> serverId;
  final Value<bool> isSynced;
  final Value<String> fromAccountUuid;
  final Value<String> toAccountUuid;
  final Value<String> fromAccountName;
  final Value<String> toAccountName;
  final Value<double> amount;
  final Value<String> notes;
  final Value<String?> createdAt;
  final Value<int> rowid;
  const LocalTransfersCompanion({
    this.uuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.fromAccountUuid = const Value.absent(),
    this.toAccountUuid = const Value.absent(),
    this.fromAccountName = const Value.absent(),
    this.toAccountName = const Value.absent(),
    this.amount = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTransfersCompanion.insert({
    required String uuid,
    this.serverId = const Value.absent(),
    this.isSynced = const Value.absent(),
    required String fromAccountUuid,
    required String toAccountUuid,
    this.fromAccountName = const Value.absent(),
    this.toAccountName = const Value.absent(),
    required double amount,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       fromAccountUuid = Value(fromAccountUuid),
       toAccountUuid = Value(toAccountUuid),
       amount = Value(amount);
  static Insertable<LocalTransferRow> custom({
    Expression<String>? uuid,
    Expression<int>? serverId,
    Expression<bool>? isSynced,
    Expression<String>? fromAccountUuid,
    Expression<String>? toAccountUuid,
    Expression<String>? fromAccountName,
    Expression<String>? toAccountName,
    Expression<double>? amount,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (serverId != null) 'server_id': serverId,
      if (isSynced != null) 'is_synced': isSynced,
      if (fromAccountUuid != null) 'from_account_uuid': fromAccountUuid,
      if (toAccountUuid != null) 'to_account_uuid': toAccountUuid,
      if (fromAccountName != null) 'from_account_name': fromAccountName,
      if (toAccountName != null) 'to_account_name': toAccountName,
      if (amount != null) 'amount': amount,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTransfersCompanion copyWith({
    Value<String>? uuid,
    Value<int?>? serverId,
    Value<bool>? isSynced,
    Value<String>? fromAccountUuid,
    Value<String>? toAccountUuid,
    Value<String>? fromAccountName,
    Value<String>? toAccountName,
    Value<double>? amount,
    Value<String>? notes,
    Value<String?>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalTransfersCompanion(
      uuid: uuid ?? this.uuid,
      serverId: serverId ?? this.serverId,
      isSynced: isSynced ?? this.isSynced,
      fromAccountUuid: fromAccountUuid ?? this.fromAccountUuid,
      toAccountUuid: toAccountUuid ?? this.toAccountUuid,
      fromAccountName: fromAccountName ?? this.fromAccountName,
      toAccountName: toAccountName ?? this.toAccountName,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (fromAccountUuid.present) {
      map['from_account_uuid'] = Variable<String>(fromAccountUuid.value);
    }
    if (toAccountUuid.present) {
      map['to_account_uuid'] = Variable<String>(toAccountUuid.value);
    }
    if (fromAccountName.present) {
      map['from_account_name'] = Variable<String>(fromAccountName.value);
    }
    if (toAccountName.present) {
      map['to_account_name'] = Variable<String>(toAccountName.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransfersCompanion(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('isSynced: $isSynced, ')
          ..write('fromAccountUuid: $fromAccountUuid, ')
          ..write('toAccountUuid: $toAccountUuid, ')
          ..write('fromAccountName: $fromAccountName, ')
          ..write('toAccountName: $toAccountName, ')
          ..write('amount: $amount, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalBudgetsTable extends LocalBudgets
    with TableInfo<$LocalBudgetsTable, LocalBudgetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryUuidMeta = const VerificationMeta(
    'categoryUuid',
  );
  @override
  late final GeneratedColumn<String> categoryUuid = GeneratedColumn<String>(
    'category_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryColorMeta = const VerificationMeta(
    'categoryColor',
  );
  @override
  late final GeneratedColumn<String> categoryColor = GeneratedColumn<String>(
    'category_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spentMeta = const VerificationMeta('spent');
  @override
  late final GeneratedColumn<double> spent = GeneratedColumn<double>(
    'spent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _remainingMeta = const VerificationMeta(
    'remaining',
  );
  @override
  late final GeneratedColumn<double> remaining = GeneratedColumn<double>(
    'remaining',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    serverId,
    isSynced,
    name,
    amount,
    period,
    startDate,
    endDate,
    notes,
    categoryUuid,
    categoryName,
    categoryColor,
    spent,
    remaining,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalBudgetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('category_uuid')) {
      context.handle(
        _categoryUuidMeta,
        categoryUuid.isAcceptableOrUnknown(
          data['category_uuid']!,
          _categoryUuidMeta,
        ),
      );
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    }
    if (data.containsKey('category_color')) {
      context.handle(
        _categoryColorMeta,
        categoryColor.isAcceptableOrUnknown(
          data['category_color']!,
          _categoryColorMeta,
        ),
      );
    }
    if (data.containsKey('spent')) {
      context.handle(
        _spentMeta,
        spent.isAcceptableOrUnknown(data['spent']!, _spentMeta),
      );
    }
    if (data.containsKey('remaining')) {
      context.handle(
        _remainingMeta,
        remaining.isAcceptableOrUnknown(data['remaining']!, _remainingMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  LocalBudgetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalBudgetRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      categoryUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_uuid'],
      ),
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      ),
      categoryColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_color'],
      ),
      spent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}spent'],
      )!,
      remaining: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}remaining'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LocalBudgetsTable createAlias(String alias) {
    return $LocalBudgetsTable(attachedDatabase, alias);
  }
}

class LocalBudgetRow extends DataClass implements Insertable<LocalBudgetRow> {
  final String uuid;
  final int? serverId;
  final bool isSynced;
  final String name;
  final double amount;
  final String period;
  final String startDate;
  final String endDate;
  final String notes;
  final String? categoryUuid;
  final String? categoryName;
  final String? categoryColor;
  final double spent;
  final double remaining;
  final String? createdAt;
  final String? updatedAt;
  const LocalBudgetRow({
    required this.uuid,
    this.serverId,
    required this.isSynced,
    required this.name,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.notes,
    this.categoryUuid,
    this.categoryName,
    this.categoryColor,
    required this.spent,
    required this.remaining,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['period'] = Variable<String>(period);
    map['start_date'] = Variable<String>(startDate);
    map['end_date'] = Variable<String>(endDate);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || categoryUuid != null) {
      map['category_uuid'] = Variable<String>(categoryUuid);
    }
    if (!nullToAbsent || categoryName != null) {
      map['category_name'] = Variable<String>(categoryName);
    }
    if (!nullToAbsent || categoryColor != null) {
      map['category_color'] = Variable<String>(categoryColor);
    }
    map['spent'] = Variable<double>(spent);
    map['remaining'] = Variable<double>(remaining);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  LocalBudgetsCompanion toCompanion(bool nullToAbsent) {
    return LocalBudgetsCompanion(
      uuid: Value(uuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      isSynced: Value(isSynced),
      name: Value(name),
      amount: Value(amount),
      period: Value(period),
      startDate: Value(startDate),
      endDate: Value(endDate),
      notes: Value(notes),
      categoryUuid: categoryUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryUuid),
      categoryName: categoryName == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryName),
      categoryColor: categoryColor == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryColor),
      spent: Value(spent),
      remaining: Value(remaining),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalBudgetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalBudgetRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      period: serializer.fromJson<String>(json['period']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String>(json['endDate']),
      notes: serializer.fromJson<String>(json['notes']),
      categoryUuid: serializer.fromJson<String?>(json['categoryUuid']),
      categoryName: serializer.fromJson<String?>(json['categoryName']),
      categoryColor: serializer.fromJson<String?>(json['categoryColor']),
      spent: serializer.fromJson<double>(json['spent']),
      remaining: serializer.fromJson<double>(json['remaining']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'serverId': serializer.toJson<int?>(serverId),
      'isSynced': serializer.toJson<bool>(isSynced),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'period': serializer.toJson<String>(period),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String>(endDate),
      'notes': serializer.toJson<String>(notes),
      'categoryUuid': serializer.toJson<String?>(categoryUuid),
      'categoryName': serializer.toJson<String?>(categoryName),
      'categoryColor': serializer.toJson<String?>(categoryColor),
      'spent': serializer.toJson<double>(spent),
      'remaining': serializer.toJson<double>(remaining),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  LocalBudgetRow copyWith({
    String? uuid,
    Value<int?> serverId = const Value.absent(),
    bool? isSynced,
    String? name,
    double? amount,
    String? period,
    String? startDate,
    String? endDate,
    String? notes,
    Value<String?> categoryUuid = const Value.absent(),
    Value<String?> categoryName = const Value.absent(),
    Value<String?> categoryColor = const Value.absent(),
    double? spent,
    double? remaining,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => LocalBudgetRow(
    uuid: uuid ?? this.uuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    isSynced: isSynced ?? this.isSynced,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    period: period ?? this.period,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    notes: notes ?? this.notes,
    categoryUuid: categoryUuid.present ? categoryUuid.value : this.categoryUuid,
    categoryName: categoryName.present ? categoryName.value : this.categoryName,
    categoryColor: categoryColor.present
        ? categoryColor.value
        : this.categoryColor,
    spent: spent ?? this.spent,
    remaining: remaining ?? this.remaining,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  LocalBudgetRow copyWithCompanion(LocalBudgetsCompanion data) {
    return LocalBudgetRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      period: data.period.present ? data.period.value : this.period,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      categoryUuid: data.categoryUuid.present
          ? data.categoryUuid.value
          : this.categoryUuid,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      categoryColor: data.categoryColor.present
          ? data.categoryColor.value
          : this.categoryColor,
      spent: data.spent.present ? data.spent.value : this.spent,
      remaining: data.remaining.present ? data.remaining.value : this.remaining,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalBudgetRow(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('isSynced: $isSynced, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notes: $notes, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('categoryName: $categoryName, ')
          ..write('categoryColor: $categoryColor, ')
          ..write('spent: $spent, ')
          ..write('remaining: $remaining, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    serverId,
    isSynced,
    name,
    amount,
    period,
    startDate,
    endDate,
    notes,
    categoryUuid,
    categoryName,
    categoryColor,
    spent,
    remaining,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalBudgetRow &&
          other.uuid == this.uuid &&
          other.serverId == this.serverId &&
          other.isSynced == this.isSynced &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.period == this.period &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.notes == this.notes &&
          other.categoryUuid == this.categoryUuid &&
          other.categoryName == this.categoryName &&
          other.categoryColor == this.categoryColor &&
          other.spent == this.spent &&
          other.remaining == this.remaining &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalBudgetsCompanion extends UpdateCompanion<LocalBudgetRow> {
  final Value<String> uuid;
  final Value<int?> serverId;
  final Value<bool> isSynced;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> period;
  final Value<String> startDate;
  final Value<String> endDate;
  final Value<String> notes;
  final Value<String?> categoryUuid;
  final Value<String?> categoryName;
  final Value<String?> categoryColor;
  final Value<double> spent;
  final Value<double> remaining;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const LocalBudgetsCompanion({
    this.uuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.period = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.categoryUuid = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.categoryColor = const Value.absent(),
    this.spent = const Value.absent(),
    this.remaining = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalBudgetsCompanion.insert({
    required String uuid,
    this.serverId = const Value.absent(),
    this.isSynced = const Value.absent(),
    required String name,
    required double amount,
    required String period,
    required String startDate,
    this.endDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.categoryUuid = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.categoryColor = const Value.absent(),
    this.spent = const Value.absent(),
    this.remaining = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       name = Value(name),
       amount = Value(amount),
       period = Value(period),
       startDate = Value(startDate);
  static Insertable<LocalBudgetRow> custom({
    Expression<String>? uuid,
    Expression<int>? serverId,
    Expression<bool>? isSynced,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? period,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? notes,
    Expression<String>? categoryUuid,
    Expression<String>? categoryName,
    Expression<String>? categoryColor,
    Expression<double>? spent,
    Expression<double>? remaining,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (serverId != null) 'server_id': serverId,
      if (isSynced != null) 'is_synced': isSynced,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (period != null) 'period': period,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (notes != null) 'notes': notes,
      if (categoryUuid != null) 'category_uuid': categoryUuid,
      if (categoryName != null) 'category_name': categoryName,
      if (categoryColor != null) 'category_color': categoryColor,
      if (spent != null) 'spent': spent,
      if (remaining != null) 'remaining': remaining,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalBudgetsCompanion copyWith({
    Value<String>? uuid,
    Value<int?>? serverId,
    Value<bool>? isSynced,
    Value<String>? name,
    Value<double>? amount,
    Value<String>? period,
    Value<String>? startDate,
    Value<String>? endDate,
    Value<String>? notes,
    Value<String?>? categoryUuid,
    Value<String?>? categoryName,
    Value<String?>? categoryColor,
    Value<double>? spent,
    Value<double>? remaining,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalBudgetsCompanion(
      uuid: uuid ?? this.uuid,
      serverId: serverId ?? this.serverId,
      isSynced: isSynced ?? this.isSynced,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      spent: spent ?? this.spent,
      remaining: remaining ?? this.remaining,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (categoryUuid.present) {
      map['category_uuid'] = Variable<String>(categoryUuid.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (categoryColor.present) {
      map['category_color'] = Variable<String>(categoryColor.value);
    }
    if (spent.present) {
      map['spent'] = Variable<double>(spent.value);
    }
    if (remaining.present) {
      map['remaining'] = Variable<double>(remaining.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalBudgetsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('isSynced: $isSynced, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notes: $notes, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('categoryName: $categoryName, ')
          ..write('categoryColor: $categoryColor, ')
          ..write('spent: $spent, ')
          ..write('remaining: $remaining, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FinanceDatabase extends GeneratedDatabase {
  _$FinanceDatabase(QueryExecutor e) : super(e);
  $FinanceDatabaseManager get managers => $FinanceDatabaseManager(this);
  late final $LocalAccountsTable localAccounts = $LocalAccountsTable(this);
  late final $LocalCategoriesTable localCategories = $LocalCategoriesTable(
    this,
  );
  late final $LocalExpensesTable localExpenses = $LocalExpensesTable(this);
  late final $LocalIncomesTable localIncomes = $LocalIncomesTable(this);
  late final $LocalTransfersTable localTransfers = $LocalTransfersTable(this);
  late final $LocalBudgetsTable localBudgets = $LocalBudgetsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localAccounts,
    localCategories,
    localExpenses,
    localIncomes,
    localTransfers,
    localBudgets,
  ];
}

typedef $$LocalAccountsTableCreateCompanionBuilder =
    LocalAccountsCompanion Function({
      required String uuid,
      Value<int?> serverId,
      Value<bool> isSynced,
      required String name,
      required String type,
      required double initialBalance,
      required double currentBalance,
      required String color,
      required String icon,
      Value<String> notes,
      Value<bool> isActive,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalAccountsTableUpdateCompanionBuilder =
    LocalAccountsCompanion Function({
      Value<String> uuid,
      Value<int?> serverId,
      Value<bool> isSynced,
      Value<String> name,
      Value<String> type,
      Value<double> initialBalance,
      Value<double> currentBalance,
      Value<String> color,
      Value<String> icon,
      Value<String> notes,
      Value<bool> isActive,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$LocalAccountsTableFilterComposer
    extends Composer<_$FinanceDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAccountsTableOrderingComposer
    extends Composer<_$FinanceDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAccountsTableAnnotationComposer
    extends Composer<_$FinanceDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalAccountsTableTableManager
    extends
        RootTableManager<
          _$FinanceDatabase,
          $LocalAccountsTable,
          LocalAccountRow,
          $$LocalAccountsTableFilterComposer,
          $$LocalAccountsTableOrderingComposer,
          $$LocalAccountsTableAnnotationComposer,
          $$LocalAccountsTableCreateCompanionBuilder,
          $$LocalAccountsTableUpdateCompanionBuilder,
          (
            LocalAccountRow,
            BaseReferences<
              _$FinanceDatabase,
              $LocalAccountsTable,
              LocalAccountRow
            >,
          ),
          LocalAccountRow,
          PrefetchHooks Function()
        > {
  $$LocalAccountsTableTableManager(
    _$FinanceDatabase db,
    $LocalAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> initialBalance = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAccountsCompanion(
                uuid: uuid,
                serverId: serverId,
                isSynced: isSynced,
                name: name,
                type: type,
                initialBalance: initialBalance,
                currentBalance: currentBalance,
                color: color,
                icon: icon,
                notes: notes,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                Value<int?> serverId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                required String name,
                required String type,
                required double initialBalance,
                required double currentBalance,
                required String color,
                required String icon,
                Value<String> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAccountsCompanion.insert(
                uuid: uuid,
                serverId: serverId,
                isSynced: isSynced,
                name: name,
                type: type,
                initialBalance: initialBalance,
                currentBalance: currentBalance,
                color: color,
                icon: icon,
                notes: notes,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$FinanceDatabase,
      $LocalAccountsTable,
      LocalAccountRow,
      $$LocalAccountsTableFilterComposer,
      $$LocalAccountsTableOrderingComposer,
      $$LocalAccountsTableAnnotationComposer,
      $$LocalAccountsTableCreateCompanionBuilder,
      $$LocalAccountsTableUpdateCompanionBuilder,
      (
        LocalAccountRow,
        BaseReferences<_$FinanceDatabase, $LocalAccountsTable, LocalAccountRow>,
      ),
      LocalAccountRow,
      PrefetchHooks Function()
    >;
typedef $$LocalCategoriesTableCreateCompanionBuilder =
    LocalCategoriesCompanion Function({
      required String uuid,
      Value<int?> serverId,
      Value<bool> isSynced,
      required String name,
      required String kind,
      required String color,
      required String icon,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalCategoriesTableUpdateCompanionBuilder =
    LocalCategoriesCompanion Function({
      Value<String> uuid,
      Value<int?> serverId,
      Value<bool> isSynced,
      Value<String> name,
      Value<String> kind,
      Value<String> color,
      Value<String> icon,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$LocalCategoriesTableFilterComposer
    extends Composer<_$FinanceDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCategoriesTableOrderingComposer
    extends Composer<_$FinanceDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCategoriesTableAnnotationComposer
    extends Composer<_$FinanceDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalCategoriesTableTableManager
    extends
        RootTableManager<
          _$FinanceDatabase,
          $LocalCategoriesTable,
          LocalCategoryRow,
          $$LocalCategoriesTableFilterComposer,
          $$LocalCategoriesTableOrderingComposer,
          $$LocalCategoriesTableAnnotationComposer,
          $$LocalCategoriesTableCreateCompanionBuilder,
          $$LocalCategoriesTableUpdateCompanionBuilder,
          (
            LocalCategoryRow,
            BaseReferences<
              _$FinanceDatabase,
              $LocalCategoriesTable,
              LocalCategoryRow
            >,
          ),
          LocalCategoryRow,
          PrefetchHooks Function()
        > {
  $$LocalCategoriesTableTableManager(
    _$FinanceDatabase db,
    $LocalCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCategoriesCompanion(
                uuid: uuid,
                serverId: serverId,
                isSynced: isSynced,
                name: name,
                kind: kind,
                color: color,
                icon: icon,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                Value<int?> serverId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                required String name,
                required String kind,
                required String color,
                required String icon,
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCategoriesCompanion.insert(
                uuid: uuid,
                serverId: serverId,
                isSynced: isSynced,
                name: name,
                kind: kind,
                color: color,
                icon: icon,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$FinanceDatabase,
      $LocalCategoriesTable,
      LocalCategoryRow,
      $$LocalCategoriesTableFilterComposer,
      $$LocalCategoriesTableOrderingComposer,
      $$LocalCategoriesTableAnnotationComposer,
      $$LocalCategoriesTableCreateCompanionBuilder,
      $$LocalCategoriesTableUpdateCompanionBuilder,
      (
        LocalCategoryRow,
        BaseReferences<
          _$FinanceDatabase,
          $LocalCategoriesTable,
          LocalCategoryRow
        >,
      ),
      LocalCategoryRow,
      PrefetchHooks Function()
    >;
typedef $$LocalExpensesTableCreateCompanionBuilder =
    LocalExpensesCompanion Function({
      required String uuid,
      Value<int?> serverId,
      Value<bool> isSynced,
      required String title,
      required double amount,
      required String categoryUuid,
      required String accountUuid,
      Value<String> categoryName,
      Value<String> categoryColor,
      Value<String> accountName,
      Value<String> accountColor,
      required String spentOn,
      Value<String> notes,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalExpensesTableUpdateCompanionBuilder =
    LocalExpensesCompanion Function({
      Value<String> uuid,
      Value<int?> serverId,
      Value<bool> isSynced,
      Value<String> title,
      Value<double> amount,
      Value<String> categoryUuid,
      Value<String> accountUuid,
      Value<String> categoryName,
      Value<String> categoryColor,
      Value<String> accountName,
      Value<String> accountColor,
      Value<String> spentOn,
      Value<String> notes,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$LocalExpensesTableFilterComposer
    extends Composer<_$FinanceDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryUuid => $composableBuilder(
    column: $table.categoryUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountUuid => $composableBuilder(
    column: $table.accountUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryColor => $composableBuilder(
    column: $table.categoryColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountColor => $composableBuilder(
    column: $table.accountColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spentOn => $composableBuilder(
    column: $table.spentOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalExpensesTableOrderingComposer
    extends Composer<_$FinanceDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryUuid => $composableBuilder(
    column: $table.categoryUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountUuid => $composableBuilder(
    column: $table.accountUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryColor => $composableBuilder(
    column: $table.categoryColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountColor => $composableBuilder(
    column: $table.accountColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spentOn => $composableBuilder(
    column: $table.spentOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalExpensesTableAnnotationComposer
    extends Composer<_$FinanceDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get categoryUuid => $composableBuilder(
    column: $table.categoryUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountUuid => $composableBuilder(
    column: $table.accountUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryColor => $composableBuilder(
    column: $table.categoryColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountColor => $composableBuilder(
    column: $table.accountColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spentOn =>
      $composableBuilder(column: $table.spentOn, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalExpensesTableTableManager
    extends
        RootTableManager<
          _$FinanceDatabase,
          $LocalExpensesTable,
          LocalExpenseRow,
          $$LocalExpensesTableFilterComposer,
          $$LocalExpensesTableOrderingComposer,
          $$LocalExpensesTableAnnotationComposer,
          $$LocalExpensesTableCreateCompanionBuilder,
          $$LocalExpensesTableUpdateCompanionBuilder,
          (
            LocalExpenseRow,
            BaseReferences<
              _$FinanceDatabase,
              $LocalExpensesTable,
              LocalExpenseRow
            >,
          ),
          LocalExpenseRow,
          PrefetchHooks Function()
        > {
  $$LocalExpensesTableTableManager(
    _$FinanceDatabase db,
    $LocalExpensesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> categoryUuid = const Value.absent(),
                Value<String> accountUuid = const Value.absent(),
                Value<String> categoryName = const Value.absent(),
                Value<String> categoryColor = const Value.absent(),
                Value<String> accountName = const Value.absent(),
                Value<String> accountColor = const Value.absent(),
                Value<String> spentOn = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExpensesCompanion(
                uuid: uuid,
                serverId: serverId,
                isSynced: isSynced,
                title: title,
                amount: amount,
                categoryUuid: categoryUuid,
                accountUuid: accountUuid,
                categoryName: categoryName,
                categoryColor: categoryColor,
                accountName: accountName,
                accountColor: accountColor,
                spentOn: spentOn,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                Value<int?> serverId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                required String title,
                required double amount,
                required String categoryUuid,
                required String accountUuid,
                Value<String> categoryName = const Value.absent(),
                Value<String> categoryColor = const Value.absent(),
                Value<String> accountName = const Value.absent(),
                Value<String> accountColor = const Value.absent(),
                required String spentOn,
                Value<String> notes = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExpensesCompanion.insert(
                uuid: uuid,
                serverId: serverId,
                isSynced: isSynced,
                title: title,
                amount: amount,
                categoryUuid: categoryUuid,
                accountUuid: accountUuid,
                categoryName: categoryName,
                categoryColor: categoryColor,
                accountName: accountName,
                accountColor: accountColor,
                spentOn: spentOn,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$FinanceDatabase,
      $LocalExpensesTable,
      LocalExpenseRow,
      $$LocalExpensesTableFilterComposer,
      $$LocalExpensesTableOrderingComposer,
      $$LocalExpensesTableAnnotationComposer,
      $$LocalExpensesTableCreateCompanionBuilder,
      $$LocalExpensesTableUpdateCompanionBuilder,
      (
        LocalExpenseRow,
        BaseReferences<_$FinanceDatabase, $LocalExpensesTable, LocalExpenseRow>,
      ),
      LocalExpenseRow,
      PrefetchHooks Function()
    >;
typedef $$LocalIncomesTableCreateCompanionBuilder =
    LocalIncomesCompanion Function({
      required String uuid,
      Value<int?> serverId,
      Value<bool> isSynced,
      required String title,
      required double amount,
      required String categoryUuid,
      required String accountUuid,
      Value<String> categoryName,
      Value<String> categoryColor,
      Value<String> accountName,
      Value<String> accountColor,
      required String receivedOn,
      Value<String> notes,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalIncomesTableUpdateCompanionBuilder =
    LocalIncomesCompanion Function({
      Value<String> uuid,
      Value<int?> serverId,
      Value<bool> isSynced,
      Value<String> title,
      Value<double> amount,
      Value<String> categoryUuid,
      Value<String> accountUuid,
      Value<String> categoryName,
      Value<String> categoryColor,
      Value<String> accountName,
      Value<String> accountColor,
      Value<String> receivedOn,
      Value<String> notes,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$LocalIncomesTableFilterComposer
    extends Composer<_$FinanceDatabase, $LocalIncomesTable> {
  $$LocalIncomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryUuid => $composableBuilder(
    column: $table.categoryUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountUuid => $composableBuilder(
    column: $table.accountUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryColor => $composableBuilder(
    column: $table.categoryColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountColor => $composableBuilder(
    column: $table.accountColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receivedOn => $composableBuilder(
    column: $table.receivedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalIncomesTableOrderingComposer
    extends Composer<_$FinanceDatabase, $LocalIncomesTable> {
  $$LocalIncomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryUuid => $composableBuilder(
    column: $table.categoryUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountUuid => $composableBuilder(
    column: $table.accountUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryColor => $composableBuilder(
    column: $table.categoryColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountColor => $composableBuilder(
    column: $table.accountColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivedOn => $composableBuilder(
    column: $table.receivedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalIncomesTableAnnotationComposer
    extends Composer<_$FinanceDatabase, $LocalIncomesTable> {
  $$LocalIncomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get categoryUuid => $composableBuilder(
    column: $table.categoryUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountUuid => $composableBuilder(
    column: $table.accountUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryColor => $composableBuilder(
    column: $table.categoryColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountColor => $composableBuilder(
    column: $table.accountColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receivedOn => $composableBuilder(
    column: $table.receivedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalIncomesTableTableManager
    extends
        RootTableManager<
          _$FinanceDatabase,
          $LocalIncomesTable,
          LocalIncomeRow,
          $$LocalIncomesTableFilterComposer,
          $$LocalIncomesTableOrderingComposer,
          $$LocalIncomesTableAnnotationComposer,
          $$LocalIncomesTableCreateCompanionBuilder,
          $$LocalIncomesTableUpdateCompanionBuilder,
          (
            LocalIncomeRow,
            BaseReferences<
              _$FinanceDatabase,
              $LocalIncomesTable,
              LocalIncomeRow
            >,
          ),
          LocalIncomeRow,
          PrefetchHooks Function()
        > {
  $$LocalIncomesTableTableManager(
    _$FinanceDatabase db,
    $LocalIncomesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalIncomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalIncomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalIncomesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> categoryUuid = const Value.absent(),
                Value<String> accountUuid = const Value.absent(),
                Value<String> categoryName = const Value.absent(),
                Value<String> categoryColor = const Value.absent(),
                Value<String> accountName = const Value.absent(),
                Value<String> accountColor = const Value.absent(),
                Value<String> receivedOn = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalIncomesCompanion(
                uuid: uuid,
                serverId: serverId,
                isSynced: isSynced,
                title: title,
                amount: amount,
                categoryUuid: categoryUuid,
                accountUuid: accountUuid,
                categoryName: categoryName,
                categoryColor: categoryColor,
                accountName: accountName,
                accountColor: accountColor,
                receivedOn: receivedOn,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                Value<int?> serverId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                required String title,
                required double amount,
                required String categoryUuid,
                required String accountUuid,
                Value<String> categoryName = const Value.absent(),
                Value<String> categoryColor = const Value.absent(),
                Value<String> accountName = const Value.absent(),
                Value<String> accountColor = const Value.absent(),
                required String receivedOn,
                Value<String> notes = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalIncomesCompanion.insert(
                uuid: uuid,
                serverId: serverId,
                isSynced: isSynced,
                title: title,
                amount: amount,
                categoryUuid: categoryUuid,
                accountUuid: accountUuid,
                categoryName: categoryName,
                categoryColor: categoryColor,
                accountName: accountName,
                accountColor: accountColor,
                receivedOn: receivedOn,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalIncomesTableProcessedTableManager =
    ProcessedTableManager<
      _$FinanceDatabase,
      $LocalIncomesTable,
      LocalIncomeRow,
      $$LocalIncomesTableFilterComposer,
      $$LocalIncomesTableOrderingComposer,
      $$LocalIncomesTableAnnotationComposer,
      $$LocalIncomesTableCreateCompanionBuilder,
      $$LocalIncomesTableUpdateCompanionBuilder,
      (
        LocalIncomeRow,
        BaseReferences<_$FinanceDatabase, $LocalIncomesTable, LocalIncomeRow>,
      ),
      LocalIncomeRow,
      PrefetchHooks Function()
    >;
typedef $$LocalTransfersTableCreateCompanionBuilder =
    LocalTransfersCompanion Function({
      required String uuid,
      Value<int?> serverId,
      Value<bool> isSynced,
      required String fromAccountUuid,
      required String toAccountUuid,
      Value<String> fromAccountName,
      Value<String> toAccountName,
      required double amount,
      Value<String> notes,
      Value<String?> createdAt,
      Value<int> rowid,
    });
typedef $$LocalTransfersTableUpdateCompanionBuilder =
    LocalTransfersCompanion Function({
      Value<String> uuid,
      Value<int?> serverId,
      Value<bool> isSynced,
      Value<String> fromAccountUuid,
      Value<String> toAccountUuid,
      Value<String> fromAccountName,
      Value<String> toAccountName,
      Value<double> amount,
      Value<String> notes,
      Value<String?> createdAt,
      Value<int> rowid,
    });

class $$LocalTransfersTableFilterComposer
    extends Composer<_$FinanceDatabase, $LocalTransfersTable> {
  $$LocalTransfersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromAccountUuid => $composableBuilder(
    column: $table.fromAccountUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toAccountUuid => $composableBuilder(
    column: $table.toAccountUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromAccountName => $composableBuilder(
    column: $table.fromAccountName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toAccountName => $composableBuilder(
    column: $table.toAccountName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTransfersTableOrderingComposer
    extends Composer<_$FinanceDatabase, $LocalTransfersTable> {
  $$LocalTransfersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromAccountUuid => $composableBuilder(
    column: $table.fromAccountUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toAccountUuid => $composableBuilder(
    column: $table.toAccountUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromAccountName => $composableBuilder(
    column: $table.fromAccountName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toAccountName => $composableBuilder(
    column: $table.toAccountName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTransfersTableAnnotationComposer
    extends Composer<_$FinanceDatabase, $LocalTransfersTable> {
  $$LocalTransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get fromAccountUuid => $composableBuilder(
    column: $table.fromAccountUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toAccountUuid => $composableBuilder(
    column: $table.toAccountUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromAccountName => $composableBuilder(
    column: $table.fromAccountName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toAccountName => $composableBuilder(
    column: $table.toAccountName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalTransfersTableTableManager
    extends
        RootTableManager<
          _$FinanceDatabase,
          $LocalTransfersTable,
          LocalTransferRow,
          $$LocalTransfersTableFilterComposer,
          $$LocalTransfersTableOrderingComposer,
          $$LocalTransfersTableAnnotationComposer,
          $$LocalTransfersTableCreateCompanionBuilder,
          $$LocalTransfersTableUpdateCompanionBuilder,
          (
            LocalTransferRow,
            BaseReferences<
              _$FinanceDatabase,
              $LocalTransfersTable,
              LocalTransferRow
            >,
          ),
          LocalTransferRow,
          PrefetchHooks Function()
        > {
  $$LocalTransfersTableTableManager(
    _$FinanceDatabase db,
    $LocalTransfersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String> fromAccountUuid = const Value.absent(),
                Value<String> toAccountUuid = const Value.absent(),
                Value<String> fromAccountName = const Value.absent(),
                Value<String> toAccountName = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTransfersCompanion(
                uuid: uuid,
                serverId: serverId,
                isSynced: isSynced,
                fromAccountUuid: fromAccountUuid,
                toAccountUuid: toAccountUuid,
                fromAccountName: fromAccountName,
                toAccountName: toAccountName,
                amount: amount,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                Value<int?> serverId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                required String fromAccountUuid,
                required String toAccountUuid,
                Value<String> fromAccountName = const Value.absent(),
                Value<String> toAccountName = const Value.absent(),
                required double amount,
                Value<String> notes = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTransfersCompanion.insert(
                uuid: uuid,
                serverId: serverId,
                isSynced: isSynced,
                fromAccountUuid: fromAccountUuid,
                toAccountUuid: toAccountUuid,
                fromAccountName: fromAccountName,
                toAccountName: toAccountName,
                amount: amount,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTransfersTableProcessedTableManager =
    ProcessedTableManager<
      _$FinanceDatabase,
      $LocalTransfersTable,
      LocalTransferRow,
      $$LocalTransfersTableFilterComposer,
      $$LocalTransfersTableOrderingComposer,
      $$LocalTransfersTableAnnotationComposer,
      $$LocalTransfersTableCreateCompanionBuilder,
      $$LocalTransfersTableUpdateCompanionBuilder,
      (
        LocalTransferRow,
        BaseReferences<
          _$FinanceDatabase,
          $LocalTransfersTable,
          LocalTransferRow
        >,
      ),
      LocalTransferRow,
      PrefetchHooks Function()
    >;
typedef $$LocalBudgetsTableCreateCompanionBuilder =
    LocalBudgetsCompanion Function({
      required String uuid,
      Value<int?> serverId,
      Value<bool> isSynced,
      required String name,
      required double amount,
      required String period,
      required String startDate,
      Value<String> endDate,
      Value<String> notes,
      Value<String?> categoryUuid,
      Value<String?> categoryName,
      Value<String?> categoryColor,
      Value<double> spent,
      Value<double> remaining,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalBudgetsTableUpdateCompanionBuilder =
    LocalBudgetsCompanion Function({
      Value<String> uuid,
      Value<int?> serverId,
      Value<bool> isSynced,
      Value<String> name,
      Value<double> amount,
      Value<String> period,
      Value<String> startDate,
      Value<String> endDate,
      Value<String> notes,
      Value<String?> categoryUuid,
      Value<String?> categoryName,
      Value<String?> categoryColor,
      Value<double> spent,
      Value<double> remaining,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$LocalBudgetsTableFilterComposer
    extends Composer<_$FinanceDatabase, $LocalBudgetsTable> {
  $$LocalBudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryUuid => $composableBuilder(
    column: $table.categoryUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryColor => $composableBuilder(
    column: $table.categoryColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get spent => $composableBuilder(
    column: $table.spent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalBudgetsTableOrderingComposer
    extends Composer<_$FinanceDatabase, $LocalBudgetsTable> {
  $$LocalBudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryUuid => $composableBuilder(
    column: $table.categoryUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryColor => $composableBuilder(
    column: $table.categoryColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get spent => $composableBuilder(
    column: $table.spent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalBudgetsTableAnnotationComposer
    extends Composer<_$FinanceDatabase, $LocalBudgetsTable> {
  $$LocalBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get categoryUuid => $composableBuilder(
    column: $table.categoryUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryColor => $composableBuilder(
    column: $table.categoryColor,
    builder: (column) => column,
  );

  GeneratedColumn<double> get spent =>
      $composableBuilder(column: $table.spent, builder: (column) => column);

  GeneratedColumn<double> get remaining =>
      $composableBuilder(column: $table.remaining, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalBudgetsTableTableManager
    extends
        RootTableManager<
          _$FinanceDatabase,
          $LocalBudgetsTable,
          LocalBudgetRow,
          $$LocalBudgetsTableFilterComposer,
          $$LocalBudgetsTableOrderingComposer,
          $$LocalBudgetsTableAnnotationComposer,
          $$LocalBudgetsTableCreateCompanionBuilder,
          $$LocalBudgetsTableUpdateCompanionBuilder,
          (
            LocalBudgetRow,
            BaseReferences<
              _$FinanceDatabase,
              $LocalBudgetsTable,
              LocalBudgetRow
            >,
          ),
          LocalBudgetRow,
          PrefetchHooks Function()
        > {
  $$LocalBudgetsTableTableManager(
    _$FinanceDatabase db,
    $LocalBudgetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String> endDate = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> categoryUuid = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<String?> categoryColor = const Value.absent(),
                Value<double> spent = const Value.absent(),
                Value<double> remaining = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalBudgetsCompanion(
                uuid: uuid,
                serverId: serverId,
                isSynced: isSynced,
                name: name,
                amount: amount,
                period: period,
                startDate: startDate,
                endDate: endDate,
                notes: notes,
                categoryUuid: categoryUuid,
                categoryName: categoryName,
                categoryColor: categoryColor,
                spent: spent,
                remaining: remaining,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                Value<int?> serverId = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                required String name,
                required double amount,
                required String period,
                required String startDate,
                Value<String> endDate = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> categoryUuid = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<String?> categoryColor = const Value.absent(),
                Value<double> spent = const Value.absent(),
                Value<double> remaining = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalBudgetsCompanion.insert(
                uuid: uuid,
                serverId: serverId,
                isSynced: isSynced,
                name: name,
                amount: amount,
                period: period,
                startDate: startDate,
                endDate: endDate,
                notes: notes,
                categoryUuid: categoryUuid,
                categoryName: categoryName,
                categoryColor: categoryColor,
                spent: spent,
                remaining: remaining,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalBudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$FinanceDatabase,
      $LocalBudgetsTable,
      LocalBudgetRow,
      $$LocalBudgetsTableFilterComposer,
      $$LocalBudgetsTableOrderingComposer,
      $$LocalBudgetsTableAnnotationComposer,
      $$LocalBudgetsTableCreateCompanionBuilder,
      $$LocalBudgetsTableUpdateCompanionBuilder,
      (
        LocalBudgetRow,
        BaseReferences<_$FinanceDatabase, $LocalBudgetsTable, LocalBudgetRow>,
      ),
      LocalBudgetRow,
      PrefetchHooks Function()
    >;

class $FinanceDatabaseManager {
  final _$FinanceDatabase _db;
  $FinanceDatabaseManager(this._db);
  $$LocalAccountsTableTableManager get localAccounts =>
      $$LocalAccountsTableTableManager(_db, _db.localAccounts);
  $$LocalCategoriesTableTableManager get localCategories =>
      $$LocalCategoriesTableTableManager(_db, _db.localCategories);
  $$LocalExpensesTableTableManager get localExpenses =>
      $$LocalExpensesTableTableManager(_db, _db.localExpenses);
  $$LocalIncomesTableTableManager get localIncomes =>
      $$LocalIncomesTableTableManager(_db, _db.localIncomes);
  $$LocalTransfersTableTableManager get localTransfers =>
      $$LocalTransfersTableTableManager(_db, _db.localTransfers);
  $$LocalBudgetsTableTableManager get localBudgets =>
      $$LocalBudgetsTableTableManager(_db, _db.localBudgets);
}
