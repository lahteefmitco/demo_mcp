// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SyncStatus>($CategoriesTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    serverId,
    name,
    kind,
    color,
    icon,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
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
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
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
      syncStatus: $CategoriesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class Category extends DataClass implements Insertable<Category> {
  final String uuid;
  final int? serverId;
  final String name;
  final String kind;
  final String color;
  final String icon;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Category({
    required this.uuid,
    this.serverId,
    required this.name,
    required this.kind,
    required this.color,
    required this.icon,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['color'] = Variable<String>(color);
    map['icon'] = Variable<String>(icon);
    {
      map['sync_status'] = Variable<int>(
        $CategoriesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      uuid: Value(uuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      name: Value(name),
      kind: Value(kind),
      color: Value(color),
      icon: Value(icon),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      uuid: serializer.fromJson<String>(json['uuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      color: serializer.fromJson<String>(json['color']),
      icon: serializer.fromJson<String>(json['icon']),
      syncStatus: $CategoriesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'serverId': serializer.toJson<int?>(serverId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'color': serializer.toJson<String>(color),
      'icon': serializer.toJson<String>(icon),
      'syncStatus': serializer.toJson<int>(
        $CategoriesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Category copyWith({
    String? uuid,
    Value<int?> serverId = const Value.absent(),
    String? name,
    String? kind,
    String? color,
    String? icon,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Category(
    uuid: uuid ?? this.uuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    serverId,
    name,
    kind,
    color,
    icon,
    syncStatus,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.uuid == this.uuid &&
          other.serverId == this.serverId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> uuid;
  final Value<int?> serverId;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> color;
  final Value<String> icon;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.uuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String uuid,
    this.serverId = const Value.absent(),
    required String name,
    required String kind,
    required String color,
    required String icon,
    required SyncStatus syncStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       name = Value(name),
       kind = Value(kind),
       color = Value(color),
       icon = Value(icon),
       syncStatus = Value(syncStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Category> custom({
    Expression<String>? uuid,
    Expression<int>? serverId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? uuid,
    Value<int?>? serverId,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? color,
    Value<String>? icon,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      uuid: uuid ?? this.uuid,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $CategoriesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
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
    requiredDuringInsert: true,
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
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SyncStatus>($AccountsTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    serverId,
    name,
    type,
    initialBalance,
    currentBalance,
    color,
    icon,
    notes,
    isActive,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
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
    } else if (isInserting) {
      context.missing(_notesMeta);
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
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
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
      syncStatus: $AccountsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class Account extends DataClass implements Insertable<Account> {
  final String uuid;
  final int? serverId;
  final String name;
  final String type;
  final double initialBalance;
  final double currentBalance;
  final String color;
  final String icon;
  final String notes;
  final bool isActive;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Account({
    required this.uuid,
    this.serverId,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.currentBalance,
    required this.color,
    required this.icon,
    required this.notes,
    required this.isActive,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['initial_balance'] = Variable<double>(initialBalance);
    map['current_balance'] = Variable<double>(currentBalance);
    map['color'] = Variable<String>(color);
    map['icon'] = Variable<String>(icon);
    map['notes'] = Variable<String>(notes);
    map['is_active'] = Variable<bool>(isActive);
    {
      map['sync_status'] = Variable<int>(
        $AccountsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      uuid: Value(uuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      name: Value(name),
      type: Value(type),
      initialBalance: Value(initialBalance),
      currentBalance: Value(currentBalance),
      color: Value(color),
      icon: Value(icon),
      notes: Value(notes),
      isActive: Value(isActive),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      uuid: serializer.fromJson<String>(json['uuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      initialBalance: serializer.fromJson<double>(json['initialBalance']),
      currentBalance: serializer.fromJson<double>(json['currentBalance']),
      color: serializer.fromJson<String>(json['color']),
      icon: serializer.fromJson<String>(json['icon']),
      notes: serializer.fromJson<String>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncStatus: $AccountsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'serverId': serializer.toJson<int?>(serverId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'initialBalance': serializer.toJson<double>(initialBalance),
      'currentBalance': serializer.toJson<double>(currentBalance),
      'color': serializer.toJson<String>(color),
      'icon': serializer.toJson<String>(icon),
      'notes': serializer.toJson<String>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'syncStatus': serializer.toJson<int>(
        $AccountsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Account copyWith({
    String? uuid,
    Value<int?> serverId = const Value.absent(),
    String? name,
    String? type,
    double? initialBalance,
    double? currentBalance,
    String? color,
    String? icon,
    String? notes,
    bool? isActive,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Account(
    uuid: uuid ?? this.uuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    name: name ?? this.name,
    type: type ?? this.type,
    initialBalance: initialBalance ?? this.initialBalance,
    currentBalance: currentBalance ?? this.currentBalance,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    notes: notes ?? this.notes,
    isActive: isActive ?? this.isActive,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
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
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    serverId,
    name,
    type,
    initialBalance,
    currentBalance,
    color,
    icon,
    notes,
    isActive,
    syncStatus,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.uuid == this.uuid &&
          other.serverId == this.serverId &&
          other.name == this.name &&
          other.type == this.type &&
          other.initialBalance == this.initialBalance &&
          other.currentBalance == this.currentBalance &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> uuid;
  final Value<int?> serverId;
  final Value<String> name;
  final Value<String> type;
  final Value<double> initialBalance;
  final Value<double> currentBalance;
  final Value<String> color;
  final Value<String> icon;
  final Value<String> notes;
  final Value<bool> isActive;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.uuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String uuid,
    this.serverId = const Value.absent(),
    required String name,
    required String type,
    required double initialBalance,
    required double currentBalance,
    required String color,
    required String icon,
    required String notes,
    this.isActive = const Value.absent(),
    required SyncStatus syncStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       name = Value(name),
       type = Value(type),
       initialBalance = Value(initialBalance),
       currentBalance = Value(currentBalance),
       color = Value(color),
       icon = Value(icon),
       notes = Value(notes),
       syncStatus = Value(syncStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Account> custom({
    Expression<String>? uuid,
    Expression<int>? serverId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? initialBalance,
    Expression<double>? currentBalance,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? uuid,
    Value<int?>? serverId,
    Value<String>? name,
    Value<String>? type,
    Value<double>? initialBalance,
    Value<double>? currentBalance,
    Value<String>? color,
    Value<String>? icon,
    Value<String>? notes,
    Value<bool>? isActive,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      uuid: uuid ?? this.uuid,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $AccountsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (uuid)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (uuid)',
    ),
  );
  static const VerificationMeta _spentOnMeta = const VerificationMeta(
    'spentOn',
  );
  @override
  late final GeneratedColumn<DateTime> spentOn = GeneratedColumn<DateTime>(
    'spent_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SyncStatus>($ExpensesTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    serverId,
    title,
    amount,
    categoryId,
    categoryUuid,
    accountId,
    accountUuid,
    spentOn,
    notes,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
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
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
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
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
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
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      categoryUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_uuid'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      accountUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_uuid'],
      )!,
      spentOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}spent_on'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      syncStatus: $ExpensesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class Expense extends DataClass implements Insertable<Expense> {
  final String uuid;
  final int? serverId;
  final String title;
  final double amount;
  final int categoryId;
  final String categoryUuid;
  final int accountId;
  final String accountUuid;
  final DateTime spentOn;
  final String notes;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Expense({
    required this.uuid,
    this.serverId,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.categoryUuid,
    required this.accountId,
    required this.accountUuid,
    required this.spentOn,
    required this.notes,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['category_id'] = Variable<int>(categoryId);
    map['category_uuid'] = Variable<String>(categoryUuid);
    map['account_id'] = Variable<int>(accountId);
    map['account_uuid'] = Variable<String>(accountUuid);
    map['spent_on'] = Variable<DateTime>(spentOn);
    map['notes'] = Variable<String>(notes);
    {
      map['sync_status'] = Variable<int>(
        $ExpensesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      uuid: Value(uuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      title: Value(title),
      amount: Value(amount),
      categoryId: Value(categoryId),
      categoryUuid: Value(categoryUuid),
      accountId: Value(accountId),
      accountUuid: Value(accountUuid),
      spentOn: Value(spentOn),
      notes: Value(notes),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      uuid: serializer.fromJson<String>(json['uuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      categoryUuid: serializer.fromJson<String>(json['categoryUuid']),
      accountId: serializer.fromJson<int>(json['accountId']),
      accountUuid: serializer.fromJson<String>(json['accountUuid']),
      spentOn: serializer.fromJson<DateTime>(json['spentOn']),
      notes: serializer.fromJson<String>(json['notes']),
      syncStatus: $ExpensesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'serverId': serializer.toJson<int?>(serverId),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'categoryId': serializer.toJson<int>(categoryId),
      'categoryUuid': serializer.toJson<String>(categoryUuid),
      'accountId': serializer.toJson<int>(accountId),
      'accountUuid': serializer.toJson<String>(accountUuid),
      'spentOn': serializer.toJson<DateTime>(spentOn),
      'notes': serializer.toJson<String>(notes),
      'syncStatus': serializer.toJson<int>(
        $ExpensesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Expense copyWith({
    String? uuid,
    Value<int?> serverId = const Value.absent(),
    String? title,
    double? amount,
    int? categoryId,
    String? categoryUuid,
    int? accountId,
    String? accountUuid,
    DateTime? spentOn,
    String? notes,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Expense(
    uuid: uuid ?? this.uuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    categoryId: categoryId ?? this.categoryId,
    categoryUuid: categoryUuid ?? this.categoryUuid,
    accountId: accountId ?? this.accountId,
    accountUuid: accountUuid ?? this.accountUuid,
    spentOn: spentOn ?? this.spentOn,
    notes: notes ?? this.notes,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryUuid: data.categoryUuid.present
          ? data.categoryUuid.value
          : this.categoryUuid,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      accountUuid: data.accountUuid.present
          ? data.accountUuid.value
          : this.accountUuid,
      spentOn: data.spentOn.present ? data.spentOn.value : this.spentOn,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('accountId: $accountId, ')
          ..write('accountUuid: $accountUuid, ')
          ..write('spentOn: $spentOn, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    serverId,
    title,
    amount,
    categoryId,
    categoryUuid,
    accountId,
    accountUuid,
    spentOn,
    notes,
    syncStatus,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.uuid == this.uuid &&
          other.serverId == this.serverId &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.categoryUuid == this.categoryUuid &&
          other.accountId == this.accountId &&
          other.accountUuid == this.accountUuid &&
          other.spentOn == this.spentOn &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> uuid;
  final Value<int?> serverId;
  final Value<String> title;
  final Value<double> amount;
  final Value<int> categoryId;
  final Value<String> categoryUuid;
  final Value<int> accountId;
  final Value<String> accountUuid;
  final Value<DateTime> spentOn;
  final Value<String> notes;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.uuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryUuid = const Value.absent(),
    this.accountId = const Value.absent(),
    this.accountUuid = const Value.absent(),
    this.spentOn = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String uuid,
    this.serverId = const Value.absent(),
    required String title,
    required double amount,
    required int categoryId,
    required String categoryUuid,
    required int accountId,
    required String accountUuid,
    required DateTime spentOn,
    required String notes,
    required SyncStatus syncStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       title = Value(title),
       amount = Value(amount),
       categoryId = Value(categoryId),
       categoryUuid = Value(categoryUuid),
       accountId = Value(accountId),
       accountUuid = Value(accountUuid),
       spentOn = Value(spentOn),
       notes = Value(notes),
       syncStatus = Value(syncStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Expense> custom({
    Expression<String>? uuid,
    Expression<int>? serverId,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<int>? categoryId,
    Expression<String>? categoryUuid,
    Expression<int>? accountId,
    Expression<String>? accountUuid,
    Expression<DateTime>? spentOn,
    Expression<String>? notes,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (serverId != null) 'server_id': serverId,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryUuid != null) 'category_uuid': categoryUuid,
      if (accountId != null) 'account_id': accountId,
      if (accountUuid != null) 'account_uuid': accountUuid,
      if (spentOn != null) 'spent_on': spentOn,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? uuid,
    Value<int?>? serverId,
    Value<String>? title,
    Value<double>? amount,
    Value<int>? categoryId,
    Value<String>? categoryUuid,
    Value<int>? accountId,
    Value<String>? accountUuid,
    Value<DateTime>? spentOn,
    Value<String>? notes,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      uuid: uuid ?? this.uuid,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      accountId: accountId ?? this.accountId,
      accountUuid: accountUuid ?? this.accountUuid,
      spentOn: spentOn ?? this.spentOn,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (categoryUuid.present) {
      map['category_uuid'] = Variable<String>(categoryUuid.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (accountUuid.present) {
      map['account_uuid'] = Variable<String>(accountUuid.value);
    }
    if (spentOn.present) {
      map['spent_on'] = Variable<DateTime>(spentOn.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $ExpensesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('accountId: $accountId, ')
          ..write('accountUuid: $accountUuid, ')
          ..write('spentOn: $spentOn, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomesTable extends Incomes with TableInfo<$IncomesTable, Income> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (uuid)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (uuid)',
    ),
  );
  static const VerificationMeta _receivedOnMeta = const VerificationMeta(
    'receivedOn',
  );
  @override
  late final GeneratedColumn<DateTime> receivedOn = GeneratedColumn<DateTime>(
    'received_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SyncStatus>($IncomesTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    serverId,
    title,
    amount,
    categoryId,
    categoryUuid,
    accountId,
    accountUuid,
    receivedOn,
    notes,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incomes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Income> instance, {
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
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
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
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
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
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Income map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Income(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      categoryUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_uuid'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      accountUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_uuid'],
      )!,
      receivedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_on'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      syncStatus: $IncomesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $IncomesTable createAlias(String alias) {
    return $IncomesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class Income extends DataClass implements Insertable<Income> {
  final String uuid;
  final int? serverId;
  final String title;
  final double amount;
  final int categoryId;
  final String categoryUuid;
  final int accountId;
  final String accountUuid;
  final DateTime receivedOn;
  final String notes;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Income({
    required this.uuid,
    this.serverId,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.categoryUuid,
    required this.accountId,
    required this.accountUuid,
    required this.receivedOn,
    required this.notes,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['category_id'] = Variable<int>(categoryId);
    map['category_uuid'] = Variable<String>(categoryUuid);
    map['account_id'] = Variable<int>(accountId);
    map['account_uuid'] = Variable<String>(accountUuid);
    map['received_on'] = Variable<DateTime>(receivedOn);
    map['notes'] = Variable<String>(notes);
    {
      map['sync_status'] = Variable<int>(
        $IncomesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  IncomesCompanion toCompanion(bool nullToAbsent) {
    return IncomesCompanion(
      uuid: Value(uuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      title: Value(title),
      amount: Value(amount),
      categoryId: Value(categoryId),
      categoryUuid: Value(categoryUuid),
      accountId: Value(accountId),
      accountUuid: Value(accountUuid),
      receivedOn: Value(receivedOn),
      notes: Value(notes),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Income.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Income(
      uuid: serializer.fromJson<String>(json['uuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      categoryUuid: serializer.fromJson<String>(json['categoryUuid']),
      accountId: serializer.fromJson<int>(json['accountId']),
      accountUuid: serializer.fromJson<String>(json['accountUuid']),
      receivedOn: serializer.fromJson<DateTime>(json['receivedOn']),
      notes: serializer.fromJson<String>(json['notes']),
      syncStatus: $IncomesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'serverId': serializer.toJson<int?>(serverId),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'categoryId': serializer.toJson<int>(categoryId),
      'categoryUuid': serializer.toJson<String>(categoryUuid),
      'accountId': serializer.toJson<int>(accountId),
      'accountUuid': serializer.toJson<String>(accountUuid),
      'receivedOn': serializer.toJson<DateTime>(receivedOn),
      'notes': serializer.toJson<String>(notes),
      'syncStatus': serializer.toJson<int>(
        $IncomesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Income copyWith({
    String? uuid,
    Value<int?> serverId = const Value.absent(),
    String? title,
    double? amount,
    int? categoryId,
    String? categoryUuid,
    int? accountId,
    String? accountUuid,
    DateTime? receivedOn,
    String? notes,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Income(
    uuid: uuid ?? this.uuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    categoryId: categoryId ?? this.categoryId,
    categoryUuid: categoryUuid ?? this.categoryUuid,
    accountId: accountId ?? this.accountId,
    accountUuid: accountUuid ?? this.accountUuid,
    receivedOn: receivedOn ?? this.receivedOn,
    notes: notes ?? this.notes,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Income copyWithCompanion(IncomesCompanion data) {
    return Income(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryUuid: data.categoryUuid.present
          ? data.categoryUuid.value
          : this.categoryUuid,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      accountUuid: data.accountUuid.present
          ? data.accountUuid.value
          : this.accountUuid,
      receivedOn: data.receivedOn.present
          ? data.receivedOn.value
          : this.receivedOn,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Income(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('accountId: $accountId, ')
          ..write('accountUuid: $accountUuid, ')
          ..write('receivedOn: $receivedOn, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    serverId,
    title,
    amount,
    categoryId,
    categoryUuid,
    accountId,
    accountUuid,
    receivedOn,
    notes,
    syncStatus,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Income &&
          other.uuid == this.uuid &&
          other.serverId == this.serverId &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.categoryUuid == this.categoryUuid &&
          other.accountId == this.accountId &&
          other.accountUuid == this.accountUuid &&
          other.receivedOn == this.receivedOn &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class IncomesCompanion extends UpdateCompanion<Income> {
  final Value<String> uuid;
  final Value<int?> serverId;
  final Value<String> title;
  final Value<double> amount;
  final Value<int> categoryId;
  final Value<String> categoryUuid;
  final Value<int> accountId;
  final Value<String> accountUuid;
  final Value<DateTime> receivedOn;
  final Value<String> notes;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const IncomesCompanion({
    this.uuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryUuid = const Value.absent(),
    this.accountId = const Value.absent(),
    this.accountUuid = const Value.absent(),
    this.receivedOn = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomesCompanion.insert({
    required String uuid,
    this.serverId = const Value.absent(),
    required String title,
    required double amount,
    required int categoryId,
    required String categoryUuid,
    required int accountId,
    required String accountUuid,
    required DateTime receivedOn,
    required String notes,
    required SyncStatus syncStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       title = Value(title),
       amount = Value(amount),
       categoryId = Value(categoryId),
       categoryUuid = Value(categoryUuid),
       accountId = Value(accountId),
       accountUuid = Value(accountUuid),
       receivedOn = Value(receivedOn),
       notes = Value(notes),
       syncStatus = Value(syncStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Income> custom({
    Expression<String>? uuid,
    Expression<int>? serverId,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<int>? categoryId,
    Expression<String>? categoryUuid,
    Expression<int>? accountId,
    Expression<String>? accountUuid,
    Expression<DateTime>? receivedOn,
    Expression<String>? notes,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (serverId != null) 'server_id': serverId,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryUuid != null) 'category_uuid': categoryUuid,
      if (accountId != null) 'account_id': accountId,
      if (accountUuid != null) 'account_uuid': accountUuid,
      if (receivedOn != null) 'received_on': receivedOn,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomesCompanion copyWith({
    Value<String>? uuid,
    Value<int?>? serverId,
    Value<String>? title,
    Value<double>? amount,
    Value<int>? categoryId,
    Value<String>? categoryUuid,
    Value<int>? accountId,
    Value<String>? accountUuid,
    Value<DateTime>? receivedOn,
    Value<String>? notes,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return IncomesCompanion(
      uuid: uuid ?? this.uuid,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      accountId: accountId ?? this.accountId,
      accountUuid: accountUuid ?? this.accountUuid,
      receivedOn: receivedOn ?? this.receivedOn,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (categoryUuid.present) {
      map['category_uuid'] = Variable<String>(categoryUuid.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (accountUuid.present) {
      map['account_uuid'] = Variable<String>(accountUuid.value);
    }
    if (receivedOn.present) {
      map['received_on'] = Variable<DateTime>(receivedOn.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $IncomesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('accountId: $accountId, ')
          ..write('accountUuid: $accountUuid, ')
          ..write('receivedOn: $receivedOn, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (uuid)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SyncStatus>($BudgetsTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    serverId,
    name,
    amount,
    period,
    startDate,
    endDate,
    notes,
    categoryId,
    categoryUuid,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
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
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
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
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
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
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      categoryUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_uuid'],
      ),
      syncStatus: $BudgetsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class Budget extends DataClass implements Insertable<Budget> {
  final String uuid;
  final int? serverId;
  final String name;
  final double amount;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final String notes;
  final int? categoryId;
  final String? categoryUuid;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Budget({
    required this.uuid,
    this.serverId,
    required this.name,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.notes,
    this.categoryId,
    this.categoryUuid,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['period'] = Variable<String>(period);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || categoryUuid != null) {
      map['category_uuid'] = Variable<String>(categoryUuid);
    }
    {
      map['sync_status'] = Variable<int>(
        $BudgetsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      uuid: Value(uuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      name: Value(name),
      amount: Value(amount),
      period: Value(period),
      startDate: Value(startDate),
      endDate: Value(endDate),
      notes: Value(notes),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      categoryUuid: categoryUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryUuid),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      uuid: serializer.fromJson<String>(json['uuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      period: serializer.fromJson<String>(json['period']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      notes: serializer.fromJson<String>(json['notes']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      categoryUuid: serializer.fromJson<String?>(json['categoryUuid']),
      syncStatus: $BudgetsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'serverId': serializer.toJson<int?>(serverId),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'period': serializer.toJson<String>(period),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'notes': serializer.toJson<String>(notes),
      'categoryId': serializer.toJson<int?>(categoryId),
      'categoryUuid': serializer.toJson<String?>(categoryUuid),
      'syncStatus': serializer.toJson<int>(
        $BudgetsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Budget copyWith({
    String? uuid,
    Value<int?> serverId = const Value.absent(),
    String? name,
    double? amount,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    Value<int?> categoryId = const Value.absent(),
    Value<String?> categoryUuid = const Value.absent(),
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Budget(
    uuid: uuid ?? this.uuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    period: period ?? this.period,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    notes: notes ?? this.notes,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    categoryUuid: categoryUuid.present ? categoryUuid.value : this.categoryUuid,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      period: data.period.present ? data.period.value : this.period,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryUuid: data.categoryUuid.present
          ? data.categoryUuid.value
          : this.categoryUuid,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notes: $notes, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    serverId,
    name,
    amount,
    period,
    startDate,
    endDate,
    notes,
    categoryId,
    categoryUuid,
    syncStatus,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.uuid == this.uuid &&
          other.serverId == this.serverId &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.period == this.period &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.notes == this.notes &&
          other.categoryId == this.categoryId &&
          other.categoryUuid == this.categoryUuid &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> uuid;
  final Value<int?> serverId;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> period;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> notes;
  final Value<int?> categoryId;
  final Value<String?> categoryUuid;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.uuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.period = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryUuid = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String uuid,
    this.serverId = const Value.absent(),
    required String name,
    required double amount,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
    required String notes,
    this.categoryId = const Value.absent(),
    this.categoryUuid = const Value.absent(),
    required SyncStatus syncStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       name = Value(name),
       amount = Value(amount),
       period = Value(period),
       startDate = Value(startDate),
       endDate = Value(endDate),
       notes = Value(notes),
       syncStatus = Value(syncStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Budget> custom({
    Expression<String>? uuid,
    Expression<int>? serverId,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? period,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? notes,
    Expression<int>? categoryId,
    Expression<String>? categoryUuid,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (period != null) 'period': period,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (notes != null) 'notes': notes,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryUuid != null) 'category_uuid': categoryUuid,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? uuid,
    Value<int?>? serverId,
    Value<String>? name,
    Value<double>? amount,
    Value<String>? period,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<String>? notes,
    Value<int?>? categoryId,
    Value<String?>? categoryUuid,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      uuid: uuid ?? this.uuid,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      categoryId: categoryId ?? this.categoryId,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      syncStatus: syncStatus ?? this.syncStatus,
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
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (categoryUuid.present) {
      map['category_uuid'] = Variable<String>(categoryUuid.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $BudgetsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notes: $notes, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryUuid: $categoryUuid, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransfersTable extends Transfers
    with TableInfo<$TransfersTable, Transfer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransfersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _fromAccountIdMeta = const VerificationMeta(
    'fromAccountId',
  );
  @override
  late final GeneratedColumn<int> fromAccountId = GeneratedColumn<int>(
    'from_account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (uuid)',
    ),
  );
  static const VerificationMeta _toAccountIdMeta = const VerificationMeta(
    'toAccountId',
  );
  @override
  late final GeneratedColumn<int> toAccountId = GeneratedColumn<int>(
    'to_account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (uuid)',
    ),
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
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<SyncStatus>($TransfersTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    serverId,
    fromAccountId,
    fromAccountUuid,
    toAccountId,
    toAccountUuid,
    amount,
    notes,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transfers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transfer> instance, {
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
    if (data.containsKey('from_account_id')) {
      context.handle(
        _fromAccountIdMeta,
        fromAccountId.isAcceptableOrUnknown(
          data['from_account_id']!,
          _fromAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromAccountIdMeta);
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
    if (data.containsKey('to_account_id')) {
      context.handle(
        _toAccountIdMeta,
        toAccountId.isAcceptableOrUnknown(
          data['to_account_id']!,
          _toAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toAccountIdMeta);
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
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Transfer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transfer(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      fromAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_account_id'],
      )!,
      fromAccountUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_account_uuid'],
      )!,
      toAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_account_id'],
      )!,
      toAccountUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_account_uuid'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      syncStatus: $TransfersTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TransfersTable createAlias(String alias) {
    return $TransfersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class Transfer extends DataClass implements Insertable<Transfer> {
  final String uuid;
  final int? serverId;
  final int fromAccountId;
  final String fromAccountUuid;
  final int toAccountId;
  final String toAccountUuid;
  final double amount;
  final String notes;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Transfer({
    required this.uuid,
    this.serverId,
    required this.fromAccountId,
    required this.fromAccountUuid,
    required this.toAccountId,
    required this.toAccountUuid,
    required this.amount,
    required this.notes,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['from_account_id'] = Variable<int>(fromAccountId);
    map['from_account_uuid'] = Variable<String>(fromAccountUuid);
    map['to_account_id'] = Variable<int>(toAccountId);
    map['to_account_uuid'] = Variable<String>(toAccountUuid);
    map['amount'] = Variable<double>(amount);
    map['notes'] = Variable<String>(notes);
    {
      map['sync_status'] = Variable<int>(
        $TransfersTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TransfersCompanion toCompanion(bool nullToAbsent) {
    return TransfersCompanion(
      uuid: Value(uuid),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      fromAccountId: Value(fromAccountId),
      fromAccountUuid: Value(fromAccountUuid),
      toAccountId: Value(toAccountId),
      toAccountUuid: Value(toAccountUuid),
      amount: Value(amount),
      notes: Value(notes),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Transfer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transfer(
      uuid: serializer.fromJson<String>(json['uuid']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      fromAccountId: serializer.fromJson<int>(json['fromAccountId']),
      fromAccountUuid: serializer.fromJson<String>(json['fromAccountUuid']),
      toAccountId: serializer.fromJson<int>(json['toAccountId']),
      toAccountUuid: serializer.fromJson<String>(json['toAccountUuid']),
      amount: serializer.fromJson<double>(json['amount']),
      notes: serializer.fromJson<String>(json['notes']),
      syncStatus: $TransfersTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'serverId': serializer.toJson<int?>(serverId),
      'fromAccountId': serializer.toJson<int>(fromAccountId),
      'fromAccountUuid': serializer.toJson<String>(fromAccountUuid),
      'toAccountId': serializer.toJson<int>(toAccountId),
      'toAccountUuid': serializer.toJson<String>(toAccountUuid),
      'amount': serializer.toJson<double>(amount),
      'notes': serializer.toJson<String>(notes),
      'syncStatus': serializer.toJson<int>(
        $TransfersTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Transfer copyWith({
    String? uuid,
    Value<int?> serverId = const Value.absent(),
    int? fromAccountId,
    String? fromAccountUuid,
    int? toAccountId,
    String? toAccountUuid,
    double? amount,
    String? notes,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Transfer(
    uuid: uuid ?? this.uuid,
    serverId: serverId.present ? serverId.value : this.serverId,
    fromAccountId: fromAccountId ?? this.fromAccountId,
    fromAccountUuid: fromAccountUuid ?? this.fromAccountUuid,
    toAccountId: toAccountId ?? this.toAccountId,
    toAccountUuid: toAccountUuid ?? this.toAccountUuid,
    amount: amount ?? this.amount,
    notes: notes ?? this.notes,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Transfer copyWithCompanion(TransfersCompanion data) {
    return Transfer(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      fromAccountId: data.fromAccountId.present
          ? data.fromAccountId.value
          : this.fromAccountId,
      fromAccountUuid: data.fromAccountUuid.present
          ? data.fromAccountUuid.value
          : this.fromAccountUuid,
      toAccountId: data.toAccountId.present
          ? data.toAccountId.value
          : this.toAccountId,
      toAccountUuid: data.toAccountUuid.present
          ? data.toAccountUuid.value
          : this.toAccountUuid,
      amount: data.amount.present ? data.amount.value : this.amount,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transfer(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('fromAccountId: $fromAccountId, ')
          ..write('fromAccountUuid: $fromAccountUuid, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('toAccountUuid: $toAccountUuid, ')
          ..write('amount: $amount, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    serverId,
    fromAccountId,
    fromAccountUuid,
    toAccountId,
    toAccountUuid,
    amount,
    notes,
    syncStatus,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transfer &&
          other.uuid == this.uuid &&
          other.serverId == this.serverId &&
          other.fromAccountId == this.fromAccountId &&
          other.fromAccountUuid == this.fromAccountUuid &&
          other.toAccountId == this.toAccountId &&
          other.toAccountUuid == this.toAccountUuid &&
          other.amount == this.amount &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransfersCompanion extends UpdateCompanion<Transfer> {
  final Value<String> uuid;
  final Value<int?> serverId;
  final Value<int> fromAccountId;
  final Value<String> fromAccountUuid;
  final Value<int> toAccountId;
  final Value<String> toAccountUuid;
  final Value<double> amount;
  final Value<String> notes;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TransfersCompanion({
    this.uuid = const Value.absent(),
    this.serverId = const Value.absent(),
    this.fromAccountId = const Value.absent(),
    this.fromAccountUuid = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.toAccountUuid = const Value.absent(),
    this.amount = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransfersCompanion.insert({
    required String uuid,
    this.serverId = const Value.absent(),
    required int fromAccountId,
    required String fromAccountUuid,
    required int toAccountId,
    required String toAccountUuid,
    required double amount,
    required String notes,
    required SyncStatus syncStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       fromAccountId = Value(fromAccountId),
       fromAccountUuid = Value(fromAccountUuid),
       toAccountId = Value(toAccountId),
       toAccountUuid = Value(toAccountUuid),
       amount = Value(amount),
       notes = Value(notes),
       syncStatus = Value(syncStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Transfer> custom({
    Expression<String>? uuid,
    Expression<int>? serverId,
    Expression<int>? fromAccountId,
    Expression<String>? fromAccountUuid,
    Expression<int>? toAccountId,
    Expression<String>? toAccountUuid,
    Expression<double>? amount,
    Expression<String>? notes,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (serverId != null) 'server_id': serverId,
      if (fromAccountId != null) 'from_account_id': fromAccountId,
      if (fromAccountUuid != null) 'from_account_uuid': fromAccountUuid,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (toAccountUuid != null) 'to_account_uuid': toAccountUuid,
      if (amount != null) 'amount': amount,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransfersCompanion copyWith({
    Value<String>? uuid,
    Value<int?>? serverId,
    Value<int>? fromAccountId,
    Value<String>? fromAccountUuid,
    Value<int>? toAccountId,
    Value<String>? toAccountUuid,
    Value<double>? amount,
    Value<String>? notes,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TransfersCompanion(
      uuid: uuid ?? this.uuid,
      serverId: serverId ?? this.serverId,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      fromAccountUuid: fromAccountUuid ?? this.fromAccountUuid,
      toAccountId: toAccountId ?? this.toAccountId,
      toAccountUuid: toAccountUuid ?? this.toAccountUuid,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (fromAccountId.present) {
      map['from_account_id'] = Variable<int>(fromAccountId.value);
    }
    if (fromAccountUuid.present) {
      map['from_account_uuid'] = Variable<String>(fromAccountUuid.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<int>(toAccountId.value);
    }
    if (toAccountUuid.present) {
      map['to_account_uuid'] = Variable<String>(toAccountUuid.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $TransfersTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransfersCompanion(')
          ..write('uuid: $uuid, ')
          ..write('serverId: $serverId, ')
          ..write('fromAccountId: $fromAccountId, ')
          ..write('fromAccountUuid: $fromAccountUuid, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('toAccountUuid: $toAccountUuid, ')
          ..write('amount: $amount, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
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
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $IncomesTable incomes = $IncomesTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $TransfersTable transfers = $TransfersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    accounts,
    expenses,
    incomes,
    budgets,
    transfers,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String uuid,
      Value<int?> serverId,
      required String name,
      required String kind,
      required String color,
      required String icon,
      required SyncStatus syncStatus,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> uuid,
      Value<int?> serverId,
      Value<String> name,
      Value<String> kind,
      Value<String> color,
      Value<String> icon,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$FinanceDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$FinanceDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: $_aliasNameGenerator(
      db.categories.uuid,
      db.expenses.categoryUuid,
    ),
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses).filter(
      (f) => f.categoryUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IncomesTable, List<Income>> _incomesRefsTable(
    _$FinanceDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.incomes,
    aliasName: $_aliasNameGenerator(
      db.categories.uuid,
      db.incomes.categoryUuid,
    ),
  );

  $$IncomesTableProcessedTableManager get incomesRefs {
    final manager = $$IncomesTableTableManager($_db, $_db.incomes).filter(
      (f) => f.categoryUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_incomesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BudgetsTable, List<Budget>> _budgetsRefsTable(
    _$FinanceDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.budgets,
    aliasName: $_aliasNameGenerator(
      db.categories.uuid,
      db.budgets.categoryUuid,
    ),
  );

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager($_db, $_db.budgets).filter(
      (f) => f.categoryUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$FinanceDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.categoryUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incomesRefs(
    Expression<bool> Function($$IncomesTableFilterComposer f) f,
  ) {
    final $$IncomesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.categoryUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableFilterComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetsRefs(
    Expression<bool> Function($$BudgetsTableFilterComposer f) f,
  ) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.categoryUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableFilterComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$FinanceDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$FinanceDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.categoryUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> incomesRefs<T extends Object>(
    Expression<T> Function($$IncomesTableAnnotationComposer a) f,
  ) {
    final $$IncomesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.categoryUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableAnnotationComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> budgetsRefs<T extends Object>(
    Expression<T> Function($$BudgetsTableAnnotationComposer a) f,
  ) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.categoryUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$FinanceDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({
            bool expensesRefs,
            bool incomesRefs,
            bool budgetsRefs,
          })
        > {
  $$CategoriesTableTableManager(_$FinanceDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                uuid: uuid,
                serverId: serverId,
                name: name,
                kind: kind,
                color: color,
                icon: icon,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                Value<int?> serverId = const Value.absent(),
                required String name,
                required String kind,
                required String color,
                required String icon,
                required SyncStatus syncStatus,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                uuid: uuid,
                serverId: serverId,
                name: name,
                kind: kind,
                color: color,
                icon: icon,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                expensesRefs = false,
                incomesRefs = false,
                budgetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (expensesRefs) db.expenses,
                    if (incomesRefs) db.incomes,
                    if (budgetsRefs) db.budgets,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (expensesRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryUuid == item.uuid,
                              ),
                          typedResults: items,
                        ),
                      if (incomesRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Income
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._incomesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).incomesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryUuid == item.uuid,
                              ),
                          typedResults: items,
                        ),
                      if (budgetsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Budget
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._budgetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryUuid == item.uuid,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$FinanceDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({
        bool expensesRefs,
        bool incomesRefs,
        bool budgetsRefs,
      })
    >;
typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      required String uuid,
      Value<int?> serverId,
      required String name,
      required String type,
      required double initialBalance,
      required double currentBalance,
      required String color,
      required String icon,
      required String notes,
      Value<bool> isActive,
      required SyncStatus syncStatus,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> uuid,
      Value<int?> serverId,
      Value<String> name,
      Value<String> type,
      Value<double> initialBalance,
      Value<double> currentBalance,
      Value<String> color,
      Value<String> icon,
      Value<String> notes,
      Value<bool> isActive,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$AccountsTableReferences
    extends BaseReferences<_$FinanceDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$FinanceDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: $_aliasNameGenerator(db.accounts.uuid, db.expenses.accountUuid),
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses).filter(
      (f) => f.accountUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IncomesTable, List<Income>> _incomesRefsTable(
    _$FinanceDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.incomes,
    aliasName: $_aliasNameGenerator(db.accounts.uuid, db.incomes.accountUuid),
  );

  $$IncomesTableProcessedTableManager get incomesRefs {
    final manager = $$IncomesTableTableManager($_db, $_db.incomes).filter(
      (f) => f.accountUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_incomesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$FinanceDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.accountUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incomesRefs(
    Expression<bool> Function($$IncomesTableFilterComposer f) f,
  ) {
    final $$IncomesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.accountUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableFilterComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$FinanceDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
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

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$FinanceDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.accountUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> incomesRefs<T extends Object>(
    Expression<T> Function($$IncomesTableAnnotationComposer a) f,
  ) {
    final $$IncomesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.accountUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableAnnotationComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$FinanceDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, $$AccountsTableReferences),
          Account,
          PrefetchHooks Function({bool expensesRefs, bool incomesRefs})
        > {
  $$AccountsTableTableManager(_$FinanceDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> initialBalance = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                uuid: uuid,
                serverId: serverId,
                name: name,
                type: type,
                initialBalance: initialBalance,
                currentBalance: currentBalance,
                color: color,
                icon: icon,
                notes: notes,
                isActive: isActive,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                Value<int?> serverId = const Value.absent(),
                required String name,
                required String type,
                required double initialBalance,
                required double currentBalance,
                required String color,
                required String icon,
                required String notes,
                Value<bool> isActive = const Value.absent(),
                required SyncStatus syncStatus,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                uuid: uuid,
                serverId: serverId,
                name: name,
                type: type,
                initialBalance: initialBalance,
                currentBalance: currentBalance,
                color: color,
                icon: icon,
                notes: notes,
                isActive: isActive,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({expensesRefs = false, incomesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (expensesRefs) db.expenses,
                if (incomesRefs) db.incomes,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData<Account, $AccountsTable, Expense>(
                      currentTable: table,
                      referencedTable: $$AccountsTableReferences
                          ._expensesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AccountsTableReferences(db, table, p0).expensesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.accountUuid == item.uuid,
                          ),
                      typedResults: items,
                    ),
                  if (incomesRefs)
                    await $_getPrefetchedData<Account, $AccountsTable, Income>(
                      currentTable: table,
                      referencedTable: $$AccountsTableReferences
                          ._incomesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AccountsTableReferences(db, table, p0).incomesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.accountUuid == item.uuid,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$FinanceDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, $$AccountsTableReferences),
      Account,
      PrefetchHooks Function({bool expensesRefs, bool incomesRefs})
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      required String uuid,
      Value<int?> serverId,
      required String title,
      required double amount,
      required int categoryId,
      required String categoryUuid,
      required int accountId,
      required String accountUuid,
      required DateTime spentOn,
      required String notes,
      required SyncStatus syncStatus,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<String> uuid,
      Value<int?> serverId,
      Value<String> title,
      Value<double> amount,
      Value<int> categoryId,
      Value<String> categoryUuid,
      Value<int> accountId,
      Value<String> accountUuid,
      Value<DateTime> spentOn,
      Value<String> notes,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ExpensesTableReferences
    extends BaseReferences<_$FinanceDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryUuidTable(_$FinanceDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.expenses.categoryUuid, db.categories.uuid),
      );

  $$CategoriesTableProcessedTableManager get categoryUuid {
    final $_column = $_itemColumn<String>('category_uuid')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountUuidTable(_$FinanceDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.expenses.accountUuid, db.accounts.uuid),
      );

  $$AccountsTableProcessedTableManager get accountUuid {
    final $_column = $_itemColumn<String>('account_uuid')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$FinanceDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get spentOn => $composableBuilder(
    column: $table.spentOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryUuid {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryUuid,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountUuid {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountUuid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$FinanceDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get spentOn => $composableBuilder(
    column: $table.spentOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryUuid {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryUuid,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountUuid {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountUuid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$FinanceDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
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

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<DateTime> get spentOn =>
      $composableBuilder(column: $table.spentOn, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryUuid {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryUuid,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountUuid {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountUuid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$FinanceDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({bool categoryUuid, bool accountUuid})
        > {
  $$ExpensesTableTableManager(_$FinanceDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> categoryUuid = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<String> accountUuid = const Value.absent(),
                Value<DateTime> spentOn = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                uuid: uuid,
                serverId: serverId,
                title: title,
                amount: amount,
                categoryId: categoryId,
                categoryUuid: categoryUuid,
                accountId: accountId,
                accountUuid: accountUuid,
                spentOn: spentOn,
                notes: notes,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                Value<int?> serverId = const Value.absent(),
                required String title,
                required double amount,
                required int categoryId,
                required String categoryUuid,
                required int accountId,
                required String accountUuid,
                required DateTime spentOn,
                required String notes,
                required SyncStatus syncStatus,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                uuid: uuid,
                serverId: serverId,
                title: title,
                amount: amount,
                categoryId: categoryId,
                categoryUuid: categoryUuid,
                accountId: accountId,
                accountUuid: accountUuid,
                spentOn: spentOn,
                notes: notes,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryUuid = false, accountUuid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryUuid,
                                referencedTable: $$ExpensesTableReferences
                                    ._categoryUuidTable(db),
                                referencedColumn: $$ExpensesTableReferences
                                    ._categoryUuidTable(db)
                                    .uuid,
                              )
                              as T;
                    }
                    if (accountUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountUuid,
                                referencedTable: $$ExpensesTableReferences
                                    ._accountUuidTable(db),
                                referencedColumn: $$ExpensesTableReferences
                                    ._accountUuidTable(db)
                                    .uuid,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$FinanceDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({bool categoryUuid, bool accountUuid})
    >;
typedef $$IncomesTableCreateCompanionBuilder =
    IncomesCompanion Function({
      required String uuid,
      Value<int?> serverId,
      required String title,
      required double amount,
      required int categoryId,
      required String categoryUuid,
      required int accountId,
      required String accountUuid,
      required DateTime receivedOn,
      required String notes,
      required SyncStatus syncStatus,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$IncomesTableUpdateCompanionBuilder =
    IncomesCompanion Function({
      Value<String> uuid,
      Value<int?> serverId,
      Value<String> title,
      Value<double> amount,
      Value<int> categoryId,
      Value<String> categoryUuid,
      Value<int> accountId,
      Value<String> accountUuid,
      Value<DateTime> receivedOn,
      Value<String> notes,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$IncomesTableReferences
    extends BaseReferences<_$FinanceDatabase, $IncomesTable, Income> {
  $$IncomesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryUuidTable(_$FinanceDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.incomes.categoryUuid, db.categories.uuid),
      );

  $$CategoriesTableProcessedTableManager get categoryUuid {
    final $_column = $_itemColumn<String>('category_uuid')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountUuidTable(_$FinanceDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.incomes.accountUuid, db.accounts.uuid),
      );

  $$AccountsTableProcessedTableManager get accountUuid {
    final $_column = $_itemColumn<String>('account_uuid')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IncomesTableFilterComposer
    extends Composer<_$FinanceDatabase, $IncomesTable> {
  $$IncomesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedOn => $composableBuilder(
    column: $table.receivedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryUuid {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryUuid,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountUuid {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountUuid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomesTableOrderingComposer
    extends Composer<_$FinanceDatabase, $IncomesTable> {
  $$IncomesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedOn => $composableBuilder(
    column: $table.receivedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryUuid {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryUuid,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountUuid {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountUuid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomesTableAnnotationComposer
    extends Composer<_$FinanceDatabase, $IncomesTable> {
  $$IncomesTableAnnotationComposer({
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

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedOn => $composableBuilder(
    column: $table.receivedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryUuid {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryUuid,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountUuid {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountUuid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomesTableTableManager
    extends
        RootTableManager<
          _$FinanceDatabase,
          $IncomesTable,
          Income,
          $$IncomesTableFilterComposer,
          $$IncomesTableOrderingComposer,
          $$IncomesTableAnnotationComposer,
          $$IncomesTableCreateCompanionBuilder,
          $$IncomesTableUpdateCompanionBuilder,
          (Income, $$IncomesTableReferences),
          Income,
          PrefetchHooks Function({bool categoryUuid, bool accountUuid})
        > {
  $$IncomesTableTableManager(_$FinanceDatabase db, $IncomesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> categoryUuid = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<String> accountUuid = const Value.absent(),
                Value<DateTime> receivedOn = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomesCompanion(
                uuid: uuid,
                serverId: serverId,
                title: title,
                amount: amount,
                categoryId: categoryId,
                categoryUuid: categoryUuid,
                accountId: accountId,
                accountUuid: accountUuid,
                receivedOn: receivedOn,
                notes: notes,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                Value<int?> serverId = const Value.absent(),
                required String title,
                required double amount,
                required int categoryId,
                required String categoryUuid,
                required int accountId,
                required String accountUuid,
                required DateTime receivedOn,
                required String notes,
                required SyncStatus syncStatus,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => IncomesCompanion.insert(
                uuid: uuid,
                serverId: serverId,
                title: title,
                amount: amount,
                categoryId: categoryId,
                categoryUuid: categoryUuid,
                accountId: accountId,
                accountUuid: accountUuid,
                receivedOn: receivedOn,
                notes: notes,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IncomesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryUuid = false, accountUuid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryUuid,
                                referencedTable: $$IncomesTableReferences
                                    ._categoryUuidTable(db),
                                referencedColumn: $$IncomesTableReferences
                                    ._categoryUuidTable(db)
                                    .uuid,
                              )
                              as T;
                    }
                    if (accountUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountUuid,
                                referencedTable: $$IncomesTableReferences
                                    ._accountUuidTable(db),
                                referencedColumn: $$IncomesTableReferences
                                    ._accountUuidTable(db)
                                    .uuid,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IncomesTableProcessedTableManager =
    ProcessedTableManager<
      _$FinanceDatabase,
      $IncomesTable,
      Income,
      $$IncomesTableFilterComposer,
      $$IncomesTableOrderingComposer,
      $$IncomesTableAnnotationComposer,
      $$IncomesTableCreateCompanionBuilder,
      $$IncomesTableUpdateCompanionBuilder,
      (Income, $$IncomesTableReferences),
      Income,
      PrefetchHooks Function({bool categoryUuid, bool accountUuid})
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      required String uuid,
      Value<int?> serverId,
      required String name,
      required double amount,
      required String period,
      required DateTime startDate,
      required DateTime endDate,
      required String notes,
      Value<int?> categoryId,
      Value<String?> categoryUuid,
      required SyncStatus syncStatus,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> uuid,
      Value<int?> serverId,
      Value<String> name,
      Value<double> amount,
      Value<String> period,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<String> notes,
      Value<int?> categoryId,
      Value<String?> categoryUuid,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$BudgetsTableReferences
    extends BaseReferences<_$FinanceDatabase, $BudgetsTable, Budget> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryUuidTable(_$FinanceDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.budgets.categoryUuid, db.categories.uuid),
      );

  $$CategoriesTableProcessedTableManager? get categoryUuid {
    final $_column = $_itemColumn<String>('category_uuid');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BudgetsTableFilterComposer
    extends Composer<_$FinanceDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
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

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryUuid {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryUuid,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$FinanceDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryUuid {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryUuid,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$FinanceDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryUuid {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryUuid,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$FinanceDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, $$BudgetsTableReferences),
          Budget,
          PrefetchHooks Function({bool categoryUuid})
        > {
  $$BudgetsTableTableManager(_$FinanceDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> categoryUuid = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                uuid: uuid,
                serverId: serverId,
                name: name,
                amount: amount,
                period: period,
                startDate: startDate,
                endDate: endDate,
                notes: notes,
                categoryId: categoryId,
                categoryUuid: categoryUuid,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                Value<int?> serverId = const Value.absent(),
                required String name,
                required double amount,
                required String period,
                required DateTime startDate,
                required DateTime endDate,
                required String notes,
                Value<int?> categoryId = const Value.absent(),
                Value<String?> categoryUuid = const Value.absent(),
                required SyncStatus syncStatus,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                uuid: uuid,
                serverId: serverId,
                name: name,
                amount: amount,
                period: period,
                startDate: startDate,
                endDate: endDate,
                notes: notes,
                categoryId: categoryId,
                categoryUuid: categoryUuid,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryUuid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryUuid,
                                referencedTable: $$BudgetsTableReferences
                                    ._categoryUuidTable(db),
                                referencedColumn: $$BudgetsTableReferences
                                    ._categoryUuidTable(db)
                                    .uuid,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$FinanceDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, $$BudgetsTableReferences),
      Budget,
      PrefetchHooks Function({bool categoryUuid})
    >;
typedef $$TransfersTableCreateCompanionBuilder =
    TransfersCompanion Function({
      required String uuid,
      Value<int?> serverId,
      required int fromAccountId,
      required String fromAccountUuid,
      required int toAccountId,
      required String toAccountUuid,
      required double amount,
      required String notes,
      required SyncStatus syncStatus,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TransfersTableUpdateCompanionBuilder =
    TransfersCompanion Function({
      Value<String> uuid,
      Value<int?> serverId,
      Value<int> fromAccountId,
      Value<String> fromAccountUuid,
      Value<int> toAccountId,
      Value<String> toAccountUuid,
      Value<double> amount,
      Value<String> notes,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TransfersTableReferences
    extends BaseReferences<_$FinanceDatabase, $TransfersTable, Transfer> {
  $$TransfersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _fromAccountUuidTable(_$FinanceDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.transfers.fromAccountUuid, db.accounts.uuid),
      );

  $$AccountsTableProcessedTableManager get fromAccountUuid {
    final $_column = $_itemColumn<String>('from_account_uuid')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromAccountUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _toAccountUuidTable(_$FinanceDatabase db) =>
      db.accounts.createAlias(
        $_aliasNameGenerator(db.transfers.toAccountUuid, db.accounts.uuid),
      );

  $$AccountsTableProcessedTableManager get toAccountUuid {
    final $_column = $_itemColumn<String>('to_account_uuid')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toAccountUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransfersTableFilterComposer
    extends Composer<_$FinanceDatabase, $TransfersTable> {
  $$TransfersTableFilterComposer({
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

  ColumnFilters<int> get fromAccountId => $composableBuilder(
    column: $table.fromAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
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

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get fromAccountUuid {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromAccountUuid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get toAccountUuid {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountUuid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransfersTableOrderingComposer
    extends Composer<_$FinanceDatabase, $TransfersTable> {
  $$TransfersTableOrderingComposer({
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

  ColumnOrderings<int> get fromAccountId => $composableBuilder(
    column: $table.fromAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
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

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get fromAccountUuid {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromAccountUuid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get toAccountUuid {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountUuid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransfersTableAnnotationComposer
    extends Composer<_$FinanceDatabase, $TransfersTable> {
  $$TransfersTableAnnotationComposer({
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

  GeneratedColumn<int> get fromAccountId => $composableBuilder(
    column: $table.fromAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get fromAccountUuid {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromAccountUuid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get toAccountUuid {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountUuid,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransfersTableTableManager
    extends
        RootTableManager<
          _$FinanceDatabase,
          $TransfersTable,
          Transfer,
          $$TransfersTableFilterComposer,
          $$TransfersTableOrderingComposer,
          $$TransfersTableAnnotationComposer,
          $$TransfersTableCreateCompanionBuilder,
          $$TransfersTableUpdateCompanionBuilder,
          (Transfer, $$TransfersTableReferences),
          Transfer,
          PrefetchHooks Function({bool fromAccountUuid, bool toAccountUuid})
        > {
  $$TransfersTableTableManager(_$FinanceDatabase db, $TransfersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int> fromAccountId = const Value.absent(),
                Value<String> fromAccountUuid = const Value.absent(),
                Value<int> toAccountId = const Value.absent(),
                Value<String> toAccountUuid = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransfersCompanion(
                uuid: uuid,
                serverId: serverId,
                fromAccountId: fromAccountId,
                fromAccountUuid: fromAccountUuid,
                toAccountId: toAccountId,
                toAccountUuid: toAccountUuid,
                amount: amount,
                notes: notes,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                Value<int?> serverId = const Value.absent(),
                required int fromAccountId,
                required String fromAccountUuid,
                required int toAccountId,
                required String toAccountUuid,
                required double amount,
                required String notes,
                required SyncStatus syncStatus,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TransfersCompanion.insert(
                uuid: uuid,
                serverId: serverId,
                fromAccountId: fromAccountId,
                fromAccountUuid: fromAccountUuid,
                toAccountId: toAccountId,
                toAccountUuid: toAccountUuid,
                amount: amount,
                notes: notes,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransfersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({fromAccountUuid = false, toAccountUuid = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (fromAccountUuid) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.fromAccountUuid,
                                    referencedTable: $$TransfersTableReferences
                                        ._fromAccountUuidTable(db),
                                    referencedColumn: $$TransfersTableReferences
                                        ._fromAccountUuidTable(db)
                                        .uuid,
                                  )
                                  as T;
                        }
                        if (toAccountUuid) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.toAccountUuid,
                                    referencedTable: $$TransfersTableReferences
                                        ._toAccountUuidTable(db),
                                    referencedColumn: $$TransfersTableReferences
                                        ._toAccountUuidTable(db)
                                        .uuid,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$TransfersTableProcessedTableManager =
    ProcessedTableManager<
      _$FinanceDatabase,
      $TransfersTable,
      Transfer,
      $$TransfersTableFilterComposer,
      $$TransfersTableOrderingComposer,
      $$TransfersTableAnnotationComposer,
      $$TransfersTableCreateCompanionBuilder,
      $$TransfersTableUpdateCompanionBuilder,
      (Transfer, $$TransfersTableReferences),
      Transfer,
      PrefetchHooks Function({bool fromAccountUuid, bool toAccountUuid})
    >;

class $FinanceDatabaseManager {
  final _$FinanceDatabase _db;
  $FinanceDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$IncomesTableTableManager get incomes =>
      $$IncomesTableTableManager(_db, _db.incomes);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$TransfersTableTableManager get transfers =>
      $$TransfersTableTableManager(_db, _db.transfers);
}
