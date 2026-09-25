// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foundation_database.dart';

// ignore_for_file: type=lint
class $OrganizationsTable extends Organizations
    with TableInfo<$OrganizationsTable, OrganizationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrganizationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _legalNameMeta = const VerificationMeta(
    'legalName',
  );
  @override
  late final GeneratedColumn<String> legalName = GeneratedColumn<String>(
    'legal_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMsMeta = const VerificationMeta(
    'createdAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcMs = GeneratedColumn<int>(
    'created_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    legalName,
    displayName,
    createdAtUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'organizations';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrganizationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('legal_name')) {
      context.handle(
        _legalNameMeta,
        legalName.isAcceptableOrUnknown(data['legal_name']!, _legalNameMeta),
      );
    } else if (isInserting) {
      context.missing(_legalNameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('created_at_utc_ms')) {
      context.handle(
        _createdAtUtcMsMeta,
        createdAtUtcMs.isAcceptableOrUnknown(
          data['created_at_utc_ms']!,
          _createdAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrganizationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrganizationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      legalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_name'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      createdAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_ms'],
      )!,
    );
  }

  @override
  $OrganizationsTable createAlias(String alias) {
    return $OrganizationsTable(attachedDatabase, alias);
  }
}

class OrganizationRow extends DataClass implements Insertable<OrganizationRow> {
  final String id;
  final String legalName;
  final String displayName;
  final int createdAtUtcMs;
  const OrganizationRow({
    required this.id,
    required this.legalName,
    required this.displayName,
    required this.createdAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['legal_name'] = Variable<String>(legalName);
    map['display_name'] = Variable<String>(displayName);
    map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs);
    return map;
  }

  OrganizationsCompanion toCompanion(bool nullToAbsent) {
    return OrganizationsCompanion(
      id: Value(id),
      legalName: Value(legalName),
      displayName: Value(displayName),
      createdAtUtcMs: Value(createdAtUtcMs),
    );
  }

  factory OrganizationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrganizationRow(
      id: serializer.fromJson<String>(json['id']),
      legalName: serializer.fromJson<String>(json['legalName']),
      displayName: serializer.fromJson<String>(json['displayName']),
      createdAtUtcMs: serializer.fromJson<int>(json['createdAtUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'legalName': serializer.toJson<String>(legalName),
      'displayName': serializer.toJson<String>(displayName),
      'createdAtUtcMs': serializer.toJson<int>(createdAtUtcMs),
    };
  }

  OrganizationRow copyWith({
    String? id,
    String? legalName,
    String? displayName,
    int? createdAtUtcMs,
  }) => OrganizationRow(
    id: id ?? this.id,
    legalName: legalName ?? this.legalName,
    displayName: displayName ?? this.displayName,
    createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
  );
  OrganizationRow copyWithCompanion(OrganizationsCompanion data) {
    return OrganizationRow(
      id: data.id.present ? data.id.value : this.id,
      legalName: data.legalName.present ? data.legalName.value : this.legalName,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      createdAtUtcMs: data.createdAtUtcMs.present
          ? data.createdAtUtcMs.value
          : this.createdAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationRow(')
          ..write('id: $id, ')
          ..write('legalName: $legalName, ')
          ..write('displayName: $displayName, ')
          ..write('createdAtUtcMs: $createdAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, legalName, displayName, createdAtUtcMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrganizationRow &&
          other.id == this.id &&
          other.legalName == this.legalName &&
          other.displayName == this.displayName &&
          other.createdAtUtcMs == this.createdAtUtcMs);
}

class OrganizationsCompanion extends UpdateCompanion<OrganizationRow> {
  final Value<String> id;
  final Value<String> legalName;
  final Value<String> displayName;
  final Value<int> createdAtUtcMs;
  final Value<int> rowid;
  const OrganizationsCompanion({
    this.id = const Value.absent(),
    this.legalName = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAtUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrganizationsCompanion.insert({
    required String id,
    required String legalName,
    required String displayName,
    required int createdAtUtcMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       legalName = Value(legalName),
       displayName = Value(displayName),
       createdAtUtcMs = Value(createdAtUtcMs);
  static Insertable<OrganizationRow> custom({
    Expression<String>? id,
    Expression<String>? legalName,
    Expression<String>? displayName,
    Expression<int>? createdAtUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (legalName != null) 'legal_name': legalName,
      if (displayName != null) 'display_name': displayName,
      if (createdAtUtcMs != null) 'created_at_utc_ms': createdAtUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrganizationsCompanion copyWith({
    Value<String>? id,
    Value<String>? legalName,
    Value<String>? displayName,
    Value<int>? createdAtUtcMs,
    Value<int>? rowid,
  }) {
    return OrganizationsCompanion(
      id: id ?? this.id,
      legalName: legalName ?? this.legalName,
      displayName: displayName ?? this.displayName,
      createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (legalName.present) {
      map['legal_name'] = Variable<String>(legalName.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (createdAtUtcMs.present) {
      map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationsCompanion(')
          ..write('id: $id, ')
          ..write('legalName: $legalName, ')
          ..write('displayName: $displayName, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BranchesTable extends Branches
    with TableInfo<$BranchesTable, BranchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BranchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<String> organizationId = GeneratedColumn<String>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id) ON DELETE RESTRICT',
    ),
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
  static const VerificationMeta _timeZoneMeta = const VerificationMeta(
    'timeZone',
  );
  @override
  late final GeneratedColumn<String> timeZone = GeneratedColumn<String>(
    'time_zone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMsMeta = const VerificationMeta(
    'createdAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcMs = GeneratedColumn<int>(
    'created_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organizationId,
    name,
    timeZone,
    locale,
    createdAtUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'branches';
  @override
  VerificationContext validateIntegrity(
    Insertable<BranchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('time_zone')) {
      context.handle(
        _timeZoneMeta,
        timeZone.isAcceptableOrUnknown(data['time_zone']!, _timeZoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timeZoneMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    if (data.containsKey('created_at_utc_ms')) {
      context.handle(
        _createdAtUtcMsMeta,
        createdAtUtcMs.isAcceptableOrUnknown(
          data['created_at_utc_ms']!,
          _createdAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, organizationId},
  ];
  @override
  BranchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BranchRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      timeZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      createdAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_ms'],
      )!,
    );
  }

  @override
  $BranchesTable createAlias(String alias) {
    return $BranchesTable(attachedDatabase, alias);
  }
}

class BranchRow extends DataClass implements Insertable<BranchRow> {
  final String id;
  final String organizationId;
  final String name;
  final String timeZone;
  final String locale;
  final int createdAtUtcMs;
  const BranchRow({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.timeZone,
    required this.locale,
    required this.createdAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    map['name'] = Variable<String>(name);
    map['time_zone'] = Variable<String>(timeZone);
    map['locale'] = Variable<String>(locale);
    map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs);
    return map;
  }

  BranchesCompanion toCompanion(bool nullToAbsent) {
    return BranchesCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      name: Value(name),
      timeZone: Value(timeZone),
      locale: Value(locale),
      createdAtUtcMs: Value(createdAtUtcMs),
    );
  }

  factory BranchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BranchRow(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      name: serializer.fromJson<String>(json['name']),
      timeZone: serializer.fromJson<String>(json['timeZone']),
      locale: serializer.fromJson<String>(json['locale']),
      createdAtUtcMs: serializer.fromJson<int>(json['createdAtUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'name': serializer.toJson<String>(name),
      'timeZone': serializer.toJson<String>(timeZone),
      'locale': serializer.toJson<String>(locale),
      'createdAtUtcMs': serializer.toJson<int>(createdAtUtcMs),
    };
  }

  BranchRow copyWith({
    String? id,
    String? organizationId,
    String? name,
    String? timeZone,
    String? locale,
    int? createdAtUtcMs,
  }) => BranchRow(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    name: name ?? this.name,
    timeZone: timeZone ?? this.timeZone,
    locale: locale ?? this.locale,
    createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
  );
  BranchRow copyWithCompanion(BranchesCompanion data) {
    return BranchRow(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      name: data.name.present ? data.name.value : this.name,
      timeZone: data.timeZone.present ? data.timeZone.value : this.timeZone,
      locale: data.locale.present ? data.locale.value : this.locale,
      createdAtUtcMs: data.createdAtUtcMs.present
          ? data.createdAtUtcMs.value
          : this.createdAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BranchRow(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('name: $name, ')
          ..write('timeZone: $timeZone, ')
          ..write('locale: $locale, ')
          ..write('createdAtUtcMs: $createdAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, organizationId, name, timeZone, locale, createdAtUtcMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BranchRow &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.name == this.name &&
          other.timeZone == this.timeZone &&
          other.locale == this.locale &&
          other.createdAtUtcMs == this.createdAtUtcMs);
}

class BranchesCompanion extends UpdateCompanion<BranchRow> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String> name;
  final Value<String> timeZone;
  final Value<String> locale;
  final Value<int> createdAtUtcMs;
  final Value<int> rowid;
  const BranchesCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.name = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.locale = const Value.absent(),
    this.createdAtUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BranchesCompanion.insert({
    required String id,
    required String organizationId,
    required String name,
    required String timeZone,
    required String locale,
    required int createdAtUtcMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       organizationId = Value(organizationId),
       name = Value(name),
       timeZone = Value(timeZone),
       locale = Value(locale),
       createdAtUtcMs = Value(createdAtUtcMs);
  static Insertable<BranchRow> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? name,
    Expression<String>? timeZone,
    Expression<String>? locale,
    Expression<int>? createdAtUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (name != null) 'name': name,
      if (timeZone != null) 'time_zone': timeZone,
      if (locale != null) 'locale': locale,
      if (createdAtUtcMs != null) 'created_at_utc_ms': createdAtUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BranchesCompanion copyWith({
    Value<String>? id,
    Value<String>? organizationId,
    Value<String>? name,
    Value<String>? timeZone,
    Value<String>? locale,
    Value<int>? createdAtUtcMs,
    Value<int>? rowid,
  }) {
    return BranchesCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      timeZone: timeZone ?? this.timeZone,
      locale: locale ?? this.locale,
      createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<String>(organizationId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (timeZone.present) {
      map['time_zone'] = Variable<String>(timeZone.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (createdAtUtcMs.present) {
      map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BranchesCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('name: $name, ')
          ..write('timeZone: $timeZone, ')
          ..write('locale: $locale, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FinancialPeriodsTable extends FinancialPeriods
    with TableInfo<$FinancialPeriodsTable, FinancialPeriodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialPeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<String> organizationId = GeneratedColumn<String>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES organizations (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsOnMeta = const VerificationMeta(
    'startsOn',
  );
  @override
  late final GeneratedColumn<String> startsOn = GeneratedColumn<String>(
    'starts_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsOnMeta = const VerificationMeta('endsOn');
  @override
  late final GeneratedColumn<String> endsOn = GeneratedColumn<String>(
    'ends_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMsMeta = const VerificationMeta(
    'createdAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcMs = GeneratedColumn<int>(
    'created_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organizationId,
    branchId,
    startsOn,
    endsOn,
    locked,
    createdAtUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<FinancialPeriodRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('starts_on')) {
      context.handle(
        _startsOnMeta,
        startsOn.isAcceptableOrUnknown(data['starts_on']!, _startsOnMeta),
      );
    } else if (isInserting) {
      context.missing(_startsOnMeta);
    }
    if (data.containsKey('ends_on')) {
      context.handle(
        _endsOnMeta,
        endsOn.isAcceptableOrUnknown(data['ends_on']!, _endsOnMeta),
      );
    } else if (isInserting) {
      context.missing(_endsOnMeta);
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    if (data.containsKey('created_at_utc_ms')) {
      context.handle(
        _createdAtUtcMsMeta,
        createdAtUtcMs.isAcceptableOrUnknown(
          data['created_at_utc_ms']!,
          _createdAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FinancialPeriodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialPeriodRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      startsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}starts_on'],
      )!,
      endsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ends_on'],
      )!,
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
      createdAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_ms'],
      )!,
    );
  }

  @override
  $FinancialPeriodsTable createAlias(String alias) {
    return $FinancialPeriodsTable(attachedDatabase, alias);
  }
}

class FinancialPeriodRow extends DataClass
    implements Insertable<FinancialPeriodRow> {
  final String id;
  final String organizationId;
  final String branchId;
  final String startsOn;
  final String endsOn;
  final bool locked;
  final int createdAtUtcMs;
  const FinancialPeriodRow({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.startsOn,
    required this.endsOn,
    required this.locked,
    required this.createdAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    map['branch_id'] = Variable<String>(branchId);
    map['starts_on'] = Variable<String>(startsOn);
    map['ends_on'] = Variable<String>(endsOn);
    map['locked'] = Variable<bool>(locked);
    map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs);
    return map;
  }

  FinancialPeriodsCompanion toCompanion(bool nullToAbsent) {
    return FinancialPeriodsCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      branchId: Value(branchId),
      startsOn: Value(startsOn),
      endsOn: Value(endsOn),
      locked: Value(locked),
      createdAtUtcMs: Value(createdAtUtcMs),
    );
  }

  factory FinancialPeriodRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancialPeriodRow(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      branchId: serializer.fromJson<String>(json['branchId']),
      startsOn: serializer.fromJson<String>(json['startsOn']),
      endsOn: serializer.fromJson<String>(json['endsOn']),
      locked: serializer.fromJson<bool>(json['locked']),
      createdAtUtcMs: serializer.fromJson<int>(json['createdAtUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'branchId': serializer.toJson<String>(branchId),
      'startsOn': serializer.toJson<String>(startsOn),
      'endsOn': serializer.toJson<String>(endsOn),
      'locked': serializer.toJson<bool>(locked),
      'createdAtUtcMs': serializer.toJson<int>(createdAtUtcMs),
    };
  }

  FinancialPeriodRow copyWith({
    String? id,
    String? organizationId,
    String? branchId,
    String? startsOn,
    String? endsOn,
    bool? locked,
    int? createdAtUtcMs,
  }) => FinancialPeriodRow(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    branchId: branchId ?? this.branchId,
    startsOn: startsOn ?? this.startsOn,
    endsOn: endsOn ?? this.endsOn,
    locked: locked ?? this.locked,
    createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
  );
  FinancialPeriodRow copyWithCompanion(FinancialPeriodsCompanion data) {
    return FinancialPeriodRow(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      startsOn: data.startsOn.present ? data.startsOn.value : this.startsOn,
      endsOn: data.endsOn.present ? data.endsOn.value : this.endsOn,
      locked: data.locked.present ? data.locked.value : this.locked,
      createdAtUtcMs: data.createdAtUtcMs.present
          ? data.createdAtUtcMs.value
          : this.createdAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialPeriodRow(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('branchId: $branchId, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('locked: $locked, ')
          ..write('createdAtUtcMs: $createdAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    organizationId,
    branchId,
    startsOn,
    endsOn,
    locked,
    createdAtUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialPeriodRow &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.branchId == this.branchId &&
          other.startsOn == this.startsOn &&
          other.endsOn == this.endsOn &&
          other.locked == this.locked &&
          other.createdAtUtcMs == this.createdAtUtcMs);
}

class FinancialPeriodsCompanion extends UpdateCompanion<FinancialPeriodRow> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String> branchId;
  final Value<String> startsOn;
  final Value<String> endsOn;
  final Value<bool> locked;
  final Value<int> createdAtUtcMs;
  final Value<int> rowid;
  const FinancialPeriodsCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.locked = const Value.absent(),
    this.createdAtUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancialPeriodsCompanion.insert({
    required String id,
    required String organizationId,
    required String branchId,
    required String startsOn,
    required String endsOn,
    this.locked = const Value.absent(),
    required int createdAtUtcMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       organizationId = Value(organizationId),
       branchId = Value(branchId),
       startsOn = Value(startsOn),
       endsOn = Value(endsOn),
       createdAtUtcMs = Value(createdAtUtcMs);
  static Insertable<FinancialPeriodRow> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? branchId,
    Expression<String>? startsOn,
    Expression<String>? endsOn,
    Expression<bool>? locked,
    Expression<int>? createdAtUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (branchId != null) 'branch_id': branchId,
      if (startsOn != null) 'starts_on': startsOn,
      if (endsOn != null) 'ends_on': endsOn,
      if (locked != null) 'locked': locked,
      if (createdAtUtcMs != null) 'created_at_utc_ms': createdAtUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancialPeriodsCompanion copyWith({
    Value<String>? id,
    Value<String>? organizationId,
    Value<String>? branchId,
    Value<String>? startsOn,
    Value<String>? endsOn,
    Value<bool>? locked,
    Value<int>? createdAtUtcMs,
    Value<int>? rowid,
  }) {
    return FinancialPeriodsCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      branchId: branchId ?? this.branchId,
      startsOn: startsOn ?? this.startsOn,
      endsOn: endsOn ?? this.endsOn,
      locked: locked ?? this.locked,
      createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<String>(organizationId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (startsOn.present) {
      map['starts_on'] = Variable<String>(startsOn.value);
    }
    if (endsOn.present) {
      map['ends_on'] = Variable<String>(endsOn.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    if (createdAtUtcMs.present) {
      map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinancialPeriodsCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('branchId: $branchId, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('locked: $locked, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetadataTable extends AppMetadata
    with TableInfo<$AppMetadataTable, AppMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetadataRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetadataTable createAlias(String alias) {
    return $AppMetadataTable(attachedDatabase, alias);
  }
}

class AppMetadataRow extends DataClass implements Insertable<AppMetadataRow> {
  final String key;
  final String value;
  const AppMetadataRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetadataCompanion toCompanion(bool nullToAbsent) {
    return AppMetadataCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetadataRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetadataRow copyWith({String? key, String? value}) =>
      AppMetadataRow(key: key ?? this.key, value: value ?? this.value);
  AppMetadataRow copyWithCompanion(AppMetadataCompanion data) {
    return AppMetadataRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetadataRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetadataCompanion extends UpdateCompanion<AppMetadataRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetadataCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetadataRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<String> roleId = GeneratedColumn<String>(
    'role_id',
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
  static const VerificationMeta _createdAtUtcMsMeta = const VerificationMeta(
    'createdAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcMs = GeneratedColumn<int>(
    'created_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    fullName,
    roleId,
    isActive,
    createdAtUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at_utc_ms')) {
      context.handle(
        _createdAtUtcMsMeta,
        createdAtUtcMs.isAcceptableOrUnknown(
          data['created_at_utc_ms']!,
          _createdAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_id'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_ms'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final String id;
  final String username;
  final String fullName;
  final String roleId;
  final bool isActive;
  final int createdAtUtcMs;
  const UserRow({
    required this.id,
    required this.username,
    required this.fullName,
    required this.roleId,
    required this.isActive,
    required this.createdAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    map['full_name'] = Variable<String>(fullName);
    map['role_id'] = Variable<String>(roleId);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      fullName: Value(fullName),
      roleId: Value(roleId),
      isActive: Value(isActive),
      createdAtUtcMs: Value(createdAtUtcMs),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      fullName: serializer.fromJson<String>(json['fullName']),
      roleId: serializer.fromJson<String>(json['roleId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAtUtcMs: serializer.fromJson<int>(json['createdAtUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'fullName': serializer.toJson<String>(fullName),
      'roleId': serializer.toJson<String>(roleId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAtUtcMs': serializer.toJson<int>(createdAtUtcMs),
    };
  }

  UserRow copyWith({
    String? id,
    String? username,
    String? fullName,
    String? roleId,
    bool? isActive,
    int? createdAtUtcMs,
  }) => UserRow(
    id: id ?? this.id,
    username: username ?? this.username,
    fullName: fullName ?? this.fullName,
    roleId: roleId ?? this.roleId,
    isActive: isActive ?? this.isActive,
    createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAtUtcMs: data.createdAtUtcMs.present
          ? data.createdAtUtcMs.value
          : this.createdAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('fullName: $fullName, ')
          ..write('roleId: $roleId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAtUtcMs: $createdAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, username, fullName, roleId, isActive, createdAtUtcMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.username == this.username &&
          other.fullName == this.fullName &&
          other.roleId == this.roleId &&
          other.isActive == this.isActive &&
          other.createdAtUtcMs == this.createdAtUtcMs);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<String> id;
  final Value<String> username;
  final Value<String> fullName;
  final Value<String> roleId;
  final Value<bool> isActive;
  final Value<int> createdAtUtcMs;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.fullName = const Value.absent(),
    this.roleId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAtUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String username,
    required String fullName,
    required String roleId,
    this.isActive = const Value.absent(),
    required int createdAtUtcMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       username = Value(username),
       fullName = Value(fullName),
       roleId = Value(roleId),
       createdAtUtcMs = Value(createdAtUtcMs);
  static Insertable<UserRow> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? fullName,
    Expression<String>? roleId,
    Expression<bool>? isActive,
    Expression<int>? createdAtUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (fullName != null) 'full_name': fullName,
      if (roleId != null) 'role_id': roleId,
      if (isActive != null) 'is_active': isActive,
      if (createdAtUtcMs != null) 'created_at_utc_ms': createdAtUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? username,
    Value<String>? fullName,
    Value<String>? roleId,
    Value<bool>? isActive,
    Value<int>? createdAtUtcMs,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      roleId: roleId ?? this.roleId,
      isActive: isActive ?? this.isActive,
      createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<String>(roleId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAtUtcMs.present) {
      map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('fullName: $fullName, ')
          ..write('roleId: $roleId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserCredentialsTable extends UserCredentials
    with TableInfo<$UserCredentialsTable, UserCredentialRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCredentialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<String> salt = GeneratedColumn<String>(
    'salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hashAlgorithmMeta = const VerificationMeta(
    'hashAlgorithm',
  );
  @override
  late final GeneratedColumn<String> hashAlgorithm = GeneratedColumn<String>(
    'hash_algorithm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iterationsMeta = const VerificationMeta(
    'iterations',
  );
  @override
  late final GeneratedColumn<int> iterations = GeneratedColumn<int>(
    'iterations',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recoveryKeyHashMeta = const VerificationMeta(
    'recoveryKeyHash',
  );
  @override
  late final GeneratedColumn<String> recoveryKeyHash = GeneratedColumn<String>(
    'recovery_key_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    passwordHash,
    salt,
    hashAlgorithm,
    iterations,
    recoveryKeyHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_credentials';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserCredentialRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    } else if (isInserting) {
      context.missing(_saltMeta);
    }
    if (data.containsKey('hash_algorithm')) {
      context.handle(
        _hashAlgorithmMeta,
        hashAlgorithm.isAcceptableOrUnknown(
          data['hash_algorithm']!,
          _hashAlgorithmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hashAlgorithmMeta);
    }
    if (data.containsKey('iterations')) {
      context.handle(
        _iterationsMeta,
        iterations.isAcceptableOrUnknown(data['iterations']!, _iterationsMeta),
      );
    } else if (isInserting) {
      context.missing(_iterationsMeta);
    }
    if (data.containsKey('recovery_key_hash')) {
      context.handle(
        _recoveryKeyHashMeta,
        recoveryKeyHash.isAcceptableOrUnknown(
          data['recovery_key_hash']!,
          _recoveryKeyHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recoveryKeyHashMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserCredentialRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCredentialRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salt'],
      )!,
      hashAlgorithm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash_algorithm'],
      )!,
      iterations: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}iterations'],
      )!,
      recoveryKeyHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recovery_key_hash'],
      )!,
    );
  }

  @override
  $UserCredentialsTable createAlias(String alias) {
    return $UserCredentialsTable(attachedDatabase, alias);
  }
}

class UserCredentialRow extends DataClass
    implements Insertable<UserCredentialRow> {
  final String userId;
  final String passwordHash;
  final String salt;
  final String hashAlgorithm;
  final int iterations;
  final String recoveryKeyHash;
  const UserCredentialRow({
    required this.userId,
    required this.passwordHash,
    required this.salt,
    required this.hashAlgorithm,
    required this.iterations,
    required this.recoveryKeyHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['password_hash'] = Variable<String>(passwordHash);
    map['salt'] = Variable<String>(salt);
    map['hash_algorithm'] = Variable<String>(hashAlgorithm);
    map['iterations'] = Variable<int>(iterations);
    map['recovery_key_hash'] = Variable<String>(recoveryKeyHash);
    return map;
  }

  UserCredentialsCompanion toCompanion(bool nullToAbsent) {
    return UserCredentialsCompanion(
      userId: Value(userId),
      passwordHash: Value(passwordHash),
      salt: Value(salt),
      hashAlgorithm: Value(hashAlgorithm),
      iterations: Value(iterations),
      recoveryKeyHash: Value(recoveryKeyHash),
    );
  }

  factory UserCredentialRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCredentialRow(
      userId: serializer.fromJson<String>(json['userId']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      salt: serializer.fromJson<String>(json['salt']),
      hashAlgorithm: serializer.fromJson<String>(json['hashAlgorithm']),
      iterations: serializer.fromJson<int>(json['iterations']),
      recoveryKeyHash: serializer.fromJson<String>(json['recoveryKeyHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'salt': serializer.toJson<String>(salt),
      'hashAlgorithm': serializer.toJson<String>(hashAlgorithm),
      'iterations': serializer.toJson<int>(iterations),
      'recoveryKeyHash': serializer.toJson<String>(recoveryKeyHash),
    };
  }

  UserCredentialRow copyWith({
    String? userId,
    String? passwordHash,
    String? salt,
    String? hashAlgorithm,
    int? iterations,
    String? recoveryKeyHash,
  }) => UserCredentialRow(
    userId: userId ?? this.userId,
    passwordHash: passwordHash ?? this.passwordHash,
    salt: salt ?? this.salt,
    hashAlgorithm: hashAlgorithm ?? this.hashAlgorithm,
    iterations: iterations ?? this.iterations,
    recoveryKeyHash: recoveryKeyHash ?? this.recoveryKeyHash,
  );
  UserCredentialRow copyWithCompanion(UserCredentialsCompanion data) {
    return UserCredentialRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      salt: data.salt.present ? data.salt.value : this.salt,
      hashAlgorithm: data.hashAlgorithm.present
          ? data.hashAlgorithm.value
          : this.hashAlgorithm,
      iterations: data.iterations.present
          ? data.iterations.value
          : this.iterations,
      recoveryKeyHash: data.recoveryKeyHash.present
          ? data.recoveryKeyHash.value
          : this.recoveryKeyHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCredentialRow(')
          ..write('userId: $userId, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('salt: $salt, ')
          ..write('hashAlgorithm: $hashAlgorithm, ')
          ..write('iterations: $iterations, ')
          ..write('recoveryKeyHash: $recoveryKeyHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    passwordHash,
    salt,
    hashAlgorithm,
    iterations,
    recoveryKeyHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCredentialRow &&
          other.userId == this.userId &&
          other.passwordHash == this.passwordHash &&
          other.salt == this.salt &&
          other.hashAlgorithm == this.hashAlgorithm &&
          other.iterations == this.iterations &&
          other.recoveryKeyHash == this.recoveryKeyHash);
}

class UserCredentialsCompanion extends UpdateCompanion<UserCredentialRow> {
  final Value<String> userId;
  final Value<String> passwordHash;
  final Value<String> salt;
  final Value<String> hashAlgorithm;
  final Value<int> iterations;
  final Value<String> recoveryKeyHash;
  final Value<int> rowid;
  const UserCredentialsCompanion({
    this.userId = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.salt = const Value.absent(),
    this.hashAlgorithm = const Value.absent(),
    this.iterations = const Value.absent(),
    this.recoveryKeyHash = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserCredentialsCompanion.insert({
    required String userId,
    required String passwordHash,
    required String salt,
    required String hashAlgorithm,
    required int iterations,
    required String recoveryKeyHash,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       passwordHash = Value(passwordHash),
       salt = Value(salt),
       hashAlgorithm = Value(hashAlgorithm),
       iterations = Value(iterations),
       recoveryKeyHash = Value(recoveryKeyHash);
  static Insertable<UserCredentialRow> custom({
    Expression<String>? userId,
    Expression<String>? passwordHash,
    Expression<String>? salt,
    Expression<String>? hashAlgorithm,
    Expression<int>? iterations,
    Expression<String>? recoveryKeyHash,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (salt != null) 'salt': salt,
      if (hashAlgorithm != null) 'hash_algorithm': hashAlgorithm,
      if (iterations != null) 'iterations': iterations,
      if (recoveryKeyHash != null) 'recovery_key_hash': recoveryKeyHash,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserCredentialsCompanion copyWith({
    Value<String>? userId,
    Value<String>? passwordHash,
    Value<String>? salt,
    Value<String>? hashAlgorithm,
    Value<int>? iterations,
    Value<String>? recoveryKeyHash,
    Value<int>? rowid,
  }) {
    return UserCredentialsCompanion(
      userId: userId ?? this.userId,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      hashAlgorithm: hashAlgorithm ?? this.hashAlgorithm,
      iterations: iterations ?? this.iterations,
      recoveryKeyHash: recoveryKeyHash ?? this.recoveryKeyHash,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (salt.present) {
      map['salt'] = Variable<String>(salt.value);
    }
    if (hashAlgorithm.present) {
      map['hash_algorithm'] = Variable<String>(hashAlgorithm.value);
    }
    if (iterations.present) {
      map['iterations'] = Variable<int>(iterations.value);
    }
    if (recoveryKeyHash.present) {
      map['recovery_key_hash'] = Variable<String>(recoveryKeyHash.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCredentialsCompanion(')
          ..write('userId: $userId, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('salt: $salt, ')
          ..write('hashAlgorithm: $hashAlgorithm, ')
          ..write('iterations: $iterations, ')
          ..write('recoveryKeyHash: $recoveryKeyHash, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RolesTable extends Roles with TableInfo<$RolesTable, RoleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _capabilitiesJsonMeta = const VerificationMeta(
    'capabilitiesJson',
  );
  @override
  late final GeneratedColumn<String> capabilitiesJson = GeneratedColumn<String>(
    'capabilities_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMsMeta = const VerificationMeta(
    'createdAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcMs = GeneratedColumn<int>(
    'created_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    capabilitiesJson,
    isSystem,
    createdAtUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('capabilities_json')) {
      context.handle(
        _capabilitiesJsonMeta,
        capabilitiesJson.isAcceptableOrUnknown(
          data['capabilities_json']!,
          _capabilitiesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_capabilitiesJsonMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('created_at_utc_ms')) {
      context.handle(
        _createdAtUtcMsMeta,
        createdAtUtcMs.isAcceptableOrUnknown(
          data['created_at_utc_ms']!,
          _createdAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      capabilitiesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capabilities_json'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      createdAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_ms'],
      )!,
    );
  }

  @override
  $RolesTable createAlias(String alias) {
    return $RolesTable(attachedDatabase, alias);
  }
}

class RoleRow extends DataClass implements Insertable<RoleRow> {
  final String id;
  final String name;
  final String capabilitiesJson;
  final bool isSystem;
  final int createdAtUtcMs;
  const RoleRow({
    required this.id,
    required this.name,
    required this.capabilitiesJson,
    required this.isSystem,
    required this.createdAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['capabilities_json'] = Variable<String>(capabilitiesJson);
    map['is_system'] = Variable<bool>(isSystem);
    map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs);
    return map;
  }

  RolesCompanion toCompanion(bool nullToAbsent) {
    return RolesCompanion(
      id: Value(id),
      name: Value(name),
      capabilitiesJson: Value(capabilitiesJson),
      isSystem: Value(isSystem),
      createdAtUtcMs: Value(createdAtUtcMs),
    );
  }

  factory RoleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoleRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      capabilitiesJson: serializer.fromJson<String>(json['capabilitiesJson']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      createdAtUtcMs: serializer.fromJson<int>(json['createdAtUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'capabilitiesJson': serializer.toJson<String>(capabilitiesJson),
      'isSystem': serializer.toJson<bool>(isSystem),
      'createdAtUtcMs': serializer.toJson<int>(createdAtUtcMs),
    };
  }

  RoleRow copyWith({
    String? id,
    String? name,
    String? capabilitiesJson,
    bool? isSystem,
    int? createdAtUtcMs,
  }) => RoleRow(
    id: id ?? this.id,
    name: name ?? this.name,
    capabilitiesJson: capabilitiesJson ?? this.capabilitiesJson,
    isSystem: isSystem ?? this.isSystem,
    createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
  );
  RoleRow copyWithCompanion(RolesCompanion data) {
    return RoleRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      capabilitiesJson: data.capabilitiesJson.present
          ? data.capabilitiesJson.value
          : this.capabilitiesJson,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      createdAtUtcMs: data.createdAtUtcMs.present
          ? data.createdAtUtcMs.value
          : this.createdAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoleRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('capabilitiesJson: $capabilitiesJson, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAtUtcMs: $createdAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, capabilitiesJson, isSystem, createdAtUtcMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoleRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.capabilitiesJson == this.capabilitiesJson &&
          other.isSystem == this.isSystem &&
          other.createdAtUtcMs == this.createdAtUtcMs);
}

class RolesCompanion extends UpdateCompanion<RoleRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> capabilitiesJson;
  final Value<bool> isSystem;
  final Value<int> createdAtUtcMs;
  final Value<int> rowid;
  const RolesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.capabilitiesJson = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.createdAtUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RolesCompanion.insert({
    required String id,
    required String name,
    required String capabilitiesJson,
    this.isSystem = const Value.absent(),
    required int createdAtUtcMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       capabilitiesJson = Value(capabilitiesJson),
       createdAtUtcMs = Value(createdAtUtcMs);
  static Insertable<RoleRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? capabilitiesJson,
    Expression<bool>? isSystem,
    Expression<int>? createdAtUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (capabilitiesJson != null) 'capabilities_json': capabilitiesJson,
      if (isSystem != null) 'is_system': isSystem,
      if (createdAtUtcMs != null) 'created_at_utc_ms': createdAtUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RolesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? capabilitiesJson,
    Value<bool>? isSystem,
    Value<int>? createdAtUtcMs,
    Value<int>? rowid,
  }) {
    return RolesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      capabilitiesJson: capabilitiesJson ?? this.capabilitiesJson,
      isSystem: isSystem ?? this.isSystem,
      createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (capabilitiesJson.present) {
      map['capabilities_json'] = Variable<String>(capabilitiesJson.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (createdAtUtcMs.present) {
      map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RolesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('capabilitiesJson: $capabilitiesJson, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<String> roleId = GeneratedColumn<String>(
    'role_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtUtcMsMeta = const VerificationMeta(
    'expiresAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> expiresAtUtcMs = GeneratedColumn<int>(
    'expires_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastActivityUtcMsMeta = const VerificationMeta(
    'lastActivityUtcMs',
  );
  @override
  late final GeneratedColumn<int> lastActivityUtcMs = GeneratedColumn<int>(
    'last_activity_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMsMeta = const VerificationMeta(
    'createdAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcMs = GeneratedColumn<int>(
    'created_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    username,
    roleId,
    branchId,
    token,
    expiresAtUtcMs,
    lastActivityUtcMs,
    isLocked,
    createdAtUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('expires_at_utc_ms')) {
      context.handle(
        _expiresAtUtcMsMeta,
        expiresAtUtcMs.isAcceptableOrUnknown(
          data['expires_at_utc_ms']!,
          _expiresAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expiresAtUtcMsMeta);
    }
    if (data.containsKey('last_activity_utc_ms')) {
      context.handle(
        _lastActivityUtcMsMeta,
        lastActivityUtcMs.isAcceptableOrUnknown(
          data['last_activity_utc_ms']!,
          _lastActivityUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastActivityUtcMsMeta);
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    }
    if (data.containsKey('created_at_utc_ms')) {
      context.handle(
        _createdAtUtcMsMeta,
        createdAtUtcMs.isAcceptableOrUnknown(
          data['created_at_utc_ms']!,
          _createdAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_id'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      )!,
      expiresAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at_utc_ms'],
      )!,
      lastActivityUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_activity_utc_ms'],
      )!,
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
      createdAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_ms'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final String userId;
  final String username;
  final String roleId;
  final String branchId;
  final String token;
  final int expiresAtUtcMs;
  final int lastActivityUtcMs;
  final bool isLocked;
  final int createdAtUtcMs;
  const SessionRow({
    required this.id,
    required this.userId,
    required this.username,
    required this.roleId,
    required this.branchId,
    required this.token,
    required this.expiresAtUtcMs,
    required this.lastActivityUtcMs,
    required this.isLocked,
    required this.createdAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['username'] = Variable<String>(username);
    map['role_id'] = Variable<String>(roleId);
    map['branch_id'] = Variable<String>(branchId);
    map['token'] = Variable<String>(token);
    map['expires_at_utc_ms'] = Variable<int>(expiresAtUtcMs);
    map['last_activity_utc_ms'] = Variable<int>(lastActivityUtcMs);
    map['is_locked'] = Variable<bool>(isLocked);
    map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      username: Value(username),
      roleId: Value(roleId),
      branchId: Value(branchId),
      token: Value(token),
      expiresAtUtcMs: Value(expiresAtUtcMs),
      lastActivityUtcMs: Value(lastActivityUtcMs),
      isLocked: Value(isLocked),
      createdAtUtcMs: Value(createdAtUtcMs),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      username: serializer.fromJson<String>(json['username']),
      roleId: serializer.fromJson<String>(json['roleId']),
      branchId: serializer.fromJson<String>(json['branchId']),
      token: serializer.fromJson<String>(json['token']),
      expiresAtUtcMs: serializer.fromJson<int>(json['expiresAtUtcMs']),
      lastActivityUtcMs: serializer.fromJson<int>(json['lastActivityUtcMs']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      createdAtUtcMs: serializer.fromJson<int>(json['createdAtUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'username': serializer.toJson<String>(username),
      'roleId': serializer.toJson<String>(roleId),
      'branchId': serializer.toJson<String>(branchId),
      'token': serializer.toJson<String>(token),
      'expiresAtUtcMs': serializer.toJson<int>(expiresAtUtcMs),
      'lastActivityUtcMs': serializer.toJson<int>(lastActivityUtcMs),
      'isLocked': serializer.toJson<bool>(isLocked),
      'createdAtUtcMs': serializer.toJson<int>(createdAtUtcMs),
    };
  }

  SessionRow copyWith({
    String? id,
    String? userId,
    String? username,
    String? roleId,
    String? branchId,
    String? token,
    int? expiresAtUtcMs,
    int? lastActivityUtcMs,
    bool? isLocked,
    int? createdAtUtcMs,
  }) => SessionRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    username: username ?? this.username,
    roleId: roleId ?? this.roleId,
    branchId: branchId ?? this.branchId,
    token: token ?? this.token,
    expiresAtUtcMs: expiresAtUtcMs ?? this.expiresAtUtcMs,
    lastActivityUtcMs: lastActivityUtcMs ?? this.lastActivityUtcMs,
    isLocked: isLocked ?? this.isLocked,
    createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      username: data.username.present ? data.username.value : this.username,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      token: data.token.present ? data.token.value : this.token,
      expiresAtUtcMs: data.expiresAtUtcMs.present
          ? data.expiresAtUtcMs.value
          : this.expiresAtUtcMs,
      lastActivityUtcMs: data.lastActivityUtcMs.present
          ? data.lastActivityUtcMs.value
          : this.lastActivityUtcMs,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      createdAtUtcMs: data.createdAtUtcMs.present
          ? data.createdAtUtcMs.value
          : this.createdAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('roleId: $roleId, ')
          ..write('branchId: $branchId, ')
          ..write('token: $token, ')
          ..write('expiresAtUtcMs: $expiresAtUtcMs, ')
          ..write('lastActivityUtcMs: $lastActivityUtcMs, ')
          ..write('isLocked: $isLocked, ')
          ..write('createdAtUtcMs: $createdAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    username,
    roleId,
    branchId,
    token,
    expiresAtUtcMs,
    lastActivityUtcMs,
    isLocked,
    createdAtUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.username == this.username &&
          other.roleId == this.roleId &&
          other.branchId == this.branchId &&
          other.token == this.token &&
          other.expiresAtUtcMs == this.expiresAtUtcMs &&
          other.lastActivityUtcMs == this.lastActivityUtcMs &&
          other.isLocked == this.isLocked &&
          other.createdAtUtcMs == this.createdAtUtcMs);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> username;
  final Value<String> roleId;
  final Value<String> branchId;
  final Value<String> token;
  final Value<int> expiresAtUtcMs;
  final Value<int> lastActivityUtcMs;
  final Value<bool> isLocked;
  final Value<int> createdAtUtcMs;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.roleId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.token = const Value.absent(),
    this.expiresAtUtcMs = const Value.absent(),
    this.lastActivityUtcMs = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.createdAtUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String userId,
    required String username,
    required String roleId,
    required String branchId,
    required String token,
    required int expiresAtUtcMs,
    required int lastActivityUtcMs,
    this.isLocked = const Value.absent(),
    required int createdAtUtcMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       username = Value(username),
       roleId = Value(roleId),
       branchId = Value(branchId),
       token = Value(token),
       expiresAtUtcMs = Value(expiresAtUtcMs),
       lastActivityUtcMs = Value(lastActivityUtcMs),
       createdAtUtcMs = Value(createdAtUtcMs);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? username,
    Expression<String>? roleId,
    Expression<String>? branchId,
    Expression<String>? token,
    Expression<int>? expiresAtUtcMs,
    Expression<int>? lastActivityUtcMs,
    Expression<bool>? isLocked,
    Expression<int>? createdAtUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (username != null) 'username': username,
      if (roleId != null) 'role_id': roleId,
      if (branchId != null) 'branch_id': branchId,
      if (token != null) 'token': token,
      if (expiresAtUtcMs != null) 'expires_at_utc_ms': expiresAtUtcMs,
      if (lastActivityUtcMs != null) 'last_activity_utc_ms': lastActivityUtcMs,
      if (isLocked != null) 'is_locked': isLocked,
      if (createdAtUtcMs != null) 'created_at_utc_ms': createdAtUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? username,
    Value<String>? roleId,
    Value<String>? branchId,
    Value<String>? token,
    Value<int>? expiresAtUtcMs,
    Value<int>? lastActivityUtcMs,
    Value<bool>? isLocked,
    Value<int>? createdAtUtcMs,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      roleId: roleId ?? this.roleId,
      branchId: branchId ?? this.branchId,
      token: token ?? this.token,
      expiresAtUtcMs: expiresAtUtcMs ?? this.expiresAtUtcMs,
      lastActivityUtcMs: lastActivityUtcMs ?? this.lastActivityUtcMs,
      isLocked: isLocked ?? this.isLocked,
      createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<String>(roleId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (expiresAtUtcMs.present) {
      map['expires_at_utc_ms'] = Variable<int>(expiresAtUtcMs.value);
    }
    if (lastActivityUtcMs.present) {
      map['last_activity_utc_ms'] = Variable<int>(lastActivityUtcMs.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (createdAtUtcMs.present) {
      map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('roleId: $roleId, ')
          ..write('branchId: $branchId, ')
          ..write('token: $token, ')
          ..write('expiresAtUtcMs: $expiresAtUtcMs, ')
          ..write('lastActivityUtcMs: $lastActivityUtcMs, ')
          ..write('isLocked: $isLocked, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditEventsTable extends AuditEvents
    with TableInfo<$AuditEventsTable, AuditEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorUserIdMeta = const VerificationMeta(
    'actorUserId',
  );
  @override
  late final GeneratedColumn<String> actorUserId = GeneratedColumn<String>(
    'actor_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorUsernameMeta = const VerificationMeta(
    'actorUsername',
  );
  @override
  late final GeneratedColumn<String> actorUsername = GeneratedColumn<String>(
    'actor_username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMsMeta = const VerificationMeta(
    'createdAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcMs = GeneratedColumn<int>(
    'created_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actorUserId,
    actorUsername,
    action,
    entityType,
    entityId,
    detailsJson,
    createdAtUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('actor_user_id')) {
      context.handle(
        _actorUserIdMeta,
        actorUserId.isAcceptableOrUnknown(
          data['actor_user_id']!,
          _actorUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actorUserIdMeta);
    }
    if (data.containsKey('actor_username')) {
      context.handle(
        _actorUsernameMeta,
        actorUsername.isAcceptableOrUnknown(
          data['actor_username']!,
          _actorUsernameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actorUsernameMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detailsJsonMeta);
    }
    if (data.containsKey('created_at_utc_ms')) {
      context.handle(
        _createdAtUtcMsMeta,
        createdAtUtcMs.isAcceptableOrUnknown(
          data['created_at_utc_ms']!,
          _createdAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      actorUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_user_id'],
      )!,
      actorUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_username'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      )!,
      createdAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_ms'],
      )!,
    );
  }

  @override
  $AuditEventsTable createAlias(String alias) {
    return $AuditEventsTable(attachedDatabase, alias);
  }
}

class AuditEventRow extends DataClass implements Insertable<AuditEventRow> {
  final String id;
  final String actorUserId;
  final String actorUsername;
  final String action;
  final String entityType;
  final String entityId;
  final String detailsJson;
  final int createdAtUtcMs;
  const AuditEventRow({
    required this.id,
    required this.actorUserId,
    required this.actorUsername,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.detailsJson,
    required this.createdAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['actor_user_id'] = Variable<String>(actorUserId);
    map['actor_username'] = Variable<String>(actorUsername);
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['details_json'] = Variable<String>(detailsJson);
    map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs);
    return map;
  }

  AuditEventsCompanion toCompanion(bool nullToAbsent) {
    return AuditEventsCompanion(
      id: Value(id),
      actorUserId: Value(actorUserId),
      actorUsername: Value(actorUsername),
      action: Value(action),
      entityType: Value(entityType),
      entityId: Value(entityId),
      detailsJson: Value(detailsJson),
      createdAtUtcMs: Value(createdAtUtcMs),
    );
  }

  factory AuditEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditEventRow(
      id: serializer.fromJson<String>(json['id']),
      actorUserId: serializer.fromJson<String>(json['actorUserId']),
      actorUsername: serializer.fromJson<String>(json['actorUsername']),
      action: serializer.fromJson<String>(json['action']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      detailsJson: serializer.fromJson<String>(json['detailsJson']),
      createdAtUtcMs: serializer.fromJson<int>(json['createdAtUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'actorUserId': serializer.toJson<String>(actorUserId),
      'actorUsername': serializer.toJson<String>(actorUsername),
      'action': serializer.toJson<String>(action),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'detailsJson': serializer.toJson<String>(detailsJson),
      'createdAtUtcMs': serializer.toJson<int>(createdAtUtcMs),
    };
  }

  AuditEventRow copyWith({
    String? id,
    String? actorUserId,
    String? actorUsername,
    String? action,
    String? entityType,
    String? entityId,
    String? detailsJson,
    int? createdAtUtcMs,
  }) => AuditEventRow(
    id: id ?? this.id,
    actorUserId: actorUserId ?? this.actorUserId,
    actorUsername: actorUsername ?? this.actorUsername,
    action: action ?? this.action,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    detailsJson: detailsJson ?? this.detailsJson,
    createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
  );
  AuditEventRow copyWithCompanion(AuditEventsCompanion data) {
    return AuditEventRow(
      id: data.id.present ? data.id.value : this.id,
      actorUserId: data.actorUserId.present
          ? data.actorUserId.value
          : this.actorUserId,
      actorUsername: data.actorUsername.present
          ? data.actorUsername.value
          : this.actorUsername,
      action: data.action.present ? data.action.value : this.action,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
      createdAtUtcMs: data.createdAtUtcMs.present
          ? data.createdAtUtcMs.value
          : this.createdAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditEventRow(')
          ..write('id: $id, ')
          ..write('actorUserId: $actorUserId, ')
          ..write('actorUsername: $actorUsername, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('createdAtUtcMs: $createdAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    actorUserId,
    actorUsername,
    action,
    entityType,
    entityId,
    detailsJson,
    createdAtUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditEventRow &&
          other.id == this.id &&
          other.actorUserId == this.actorUserId &&
          other.actorUsername == this.actorUsername &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.detailsJson == this.detailsJson &&
          other.createdAtUtcMs == this.createdAtUtcMs);
}

class AuditEventsCompanion extends UpdateCompanion<AuditEventRow> {
  final Value<String> id;
  final Value<String> actorUserId;
  final Value<String> actorUsername;
  final Value<String> action;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> detailsJson;
  final Value<int> createdAtUtcMs;
  final Value<int> rowid;
  const AuditEventsCompanion({
    this.id = const Value.absent(),
    this.actorUserId = const Value.absent(),
    this.actorUsername = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.createdAtUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditEventsCompanion.insert({
    required String id,
    required String actorUserId,
    required String actorUsername,
    required String action,
    required String entityType,
    required String entityId,
    required String detailsJson,
    required int createdAtUtcMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       actorUserId = Value(actorUserId),
       actorUsername = Value(actorUsername),
       action = Value(action),
       entityType = Value(entityType),
       entityId = Value(entityId),
       detailsJson = Value(detailsJson),
       createdAtUtcMs = Value(createdAtUtcMs);
  static Insertable<AuditEventRow> custom({
    Expression<String>? id,
    Expression<String>? actorUserId,
    Expression<String>? actorUsername,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? detailsJson,
    Expression<int>? createdAtUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actorUserId != null) 'actor_user_id': actorUserId,
      if (actorUsername != null) 'actor_username': actorUsername,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (detailsJson != null) 'details_json': detailsJson,
      if (createdAtUtcMs != null) 'created_at_utc_ms': createdAtUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? actorUserId,
    Value<String>? actorUsername,
    Value<String>? action,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? detailsJson,
    Value<int>? createdAtUtcMs,
    Value<int>? rowid,
  }) {
    return AuditEventsCompanion(
      id: id ?? this.id,
      actorUserId: actorUserId ?? this.actorUserId,
      actorUsername: actorUsername ?? this.actorUsername,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      detailsJson: detailsJson ?? this.detailsJson,
      createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (actorUserId.present) {
      map['actor_user_id'] = Variable<String>(actorUserId.value);
    }
    if (actorUsername.present) {
      map['actor_username'] = Variable<String>(actorUsername.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (createdAtUtcMs.present) {
      map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditEventsCompanion(')
          ..write('id: $id, ')
          ..write('actorUserId: $actorUserId, ')
          ..write('actorUsername: $actorUsername, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoginAttemptsTable extends LoginAttempts
    with TableInfo<$LoginAttemptsTable, LoginAttemptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoginAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _failedAttemptsMeta = const VerificationMeta(
    'failedAttempts',
  );
  @override
  late final GeneratedColumn<int> failedAttempts = GeneratedColumn<int>(
    'failed_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lockedUntilUtcMsMeta = const VerificationMeta(
    'lockedUntilUtcMs',
  );
  @override
  late final GeneratedColumn<int> lockedUntilUtcMs = GeneratedColumn<int>(
    'locked_until_utc_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    username,
    failedAttempts,
    lockedUntilUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'login_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoginAttemptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('failed_attempts')) {
      context.handle(
        _failedAttemptsMeta,
        failedAttempts.isAcceptableOrUnknown(
          data['failed_attempts']!,
          _failedAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('locked_until_utc_ms')) {
      context.handle(
        _lockedUntilUtcMsMeta,
        lockedUntilUtcMs.isAcceptableOrUnknown(
          data['locked_until_utc_ms']!,
          _lockedUntilUtcMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {username};
  @override
  LoginAttemptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoginAttemptRow(
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      failedAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_attempts'],
      )!,
      lockedUntilUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}locked_until_utc_ms'],
      ),
    );
  }

  @override
  $LoginAttemptsTable createAlias(String alias) {
    return $LoginAttemptsTable(attachedDatabase, alias);
  }
}

class LoginAttemptRow extends DataClass implements Insertable<LoginAttemptRow> {
  final String username;
  final int failedAttempts;
  final int? lockedUntilUtcMs;
  const LoginAttemptRow({
    required this.username,
    required this.failedAttempts,
    this.lockedUntilUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['username'] = Variable<String>(username);
    map['failed_attempts'] = Variable<int>(failedAttempts);
    if (!nullToAbsent || lockedUntilUtcMs != null) {
      map['locked_until_utc_ms'] = Variable<int>(lockedUntilUtcMs);
    }
    return map;
  }

  LoginAttemptsCompanion toCompanion(bool nullToAbsent) {
    return LoginAttemptsCompanion(
      username: Value(username),
      failedAttempts: Value(failedAttempts),
      lockedUntilUtcMs: lockedUntilUtcMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedUntilUtcMs),
    );
  }

  factory LoginAttemptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoginAttemptRow(
      username: serializer.fromJson<String>(json['username']),
      failedAttempts: serializer.fromJson<int>(json['failedAttempts']),
      lockedUntilUtcMs: serializer.fromJson<int?>(json['lockedUntilUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'username': serializer.toJson<String>(username),
      'failedAttempts': serializer.toJson<int>(failedAttempts),
      'lockedUntilUtcMs': serializer.toJson<int?>(lockedUntilUtcMs),
    };
  }

  LoginAttemptRow copyWith({
    String? username,
    int? failedAttempts,
    Value<int?> lockedUntilUtcMs = const Value.absent(),
  }) => LoginAttemptRow(
    username: username ?? this.username,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    lockedUntilUtcMs: lockedUntilUtcMs.present
        ? lockedUntilUtcMs.value
        : this.lockedUntilUtcMs,
  );
  LoginAttemptRow copyWithCompanion(LoginAttemptsCompanion data) {
    return LoginAttemptRow(
      username: data.username.present ? data.username.value : this.username,
      failedAttempts: data.failedAttempts.present
          ? data.failedAttempts.value
          : this.failedAttempts,
      lockedUntilUtcMs: data.lockedUntilUtcMs.present
          ? data.lockedUntilUtcMs.value
          : this.lockedUntilUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoginAttemptRow(')
          ..write('username: $username, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('lockedUntilUtcMs: $lockedUntilUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(username, failedAttempts, lockedUntilUtcMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoginAttemptRow &&
          other.username == this.username &&
          other.failedAttempts == this.failedAttempts &&
          other.lockedUntilUtcMs == this.lockedUntilUtcMs);
}

class LoginAttemptsCompanion extends UpdateCompanion<LoginAttemptRow> {
  final Value<String> username;
  final Value<int> failedAttempts;
  final Value<int?> lockedUntilUtcMs;
  final Value<int> rowid;
  const LoginAttemptsCompanion({
    this.username = const Value.absent(),
    this.failedAttempts = const Value.absent(),
    this.lockedUntilUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoginAttemptsCompanion.insert({
    required String username,
    this.failedAttempts = const Value.absent(),
    this.lockedUntilUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : username = Value(username);
  static Insertable<LoginAttemptRow> custom({
    Expression<String>? username,
    Expression<int>? failedAttempts,
    Expression<int>? lockedUntilUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (username != null) 'username': username,
      if (failedAttempts != null) 'failed_attempts': failedAttempts,
      if (lockedUntilUtcMs != null) 'locked_until_utc_ms': lockedUntilUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoginAttemptsCompanion copyWith({
    Value<String>? username,
    Value<int>? failedAttempts,
    Value<int?>? lockedUntilUtcMs,
    Value<int>? rowid,
  }) {
    return LoginAttemptsCompanion(
      username: username ?? this.username,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockedUntilUtcMs: lockedUntilUtcMs ?? this.lockedUntilUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (failedAttempts.present) {
      map['failed_attempts'] = Variable<int>(failedAttempts.value);
    }
    if (lockedUntilUtcMs.present) {
      map['locked_until_utc_ms'] = Variable<int>(lockedUntilUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoginAttemptsCompanion(')
          ..write('username: $username, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('lockedUntilUtcMs: $lockedUntilUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FoundationDatabase extends GeneratedDatabase {
  _$FoundationDatabase(QueryExecutor e) : super(e);
  $FoundationDatabaseManager get managers => $FoundationDatabaseManager(this);
  late final $OrganizationsTable organizations = $OrganizationsTable(this);
  late final $BranchesTable branches = $BranchesTable(this);
  late final $FinancialPeriodsTable financialPeriods = $FinancialPeriodsTable(
    this,
  );
  late final $AppMetadataTable appMetadata = $AppMetadataTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $UserCredentialsTable userCredentials = $UserCredentialsTable(
    this,
  );
  late final $RolesTable roles = $RolesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $AuditEventsTable auditEvents = $AuditEventsTable(this);
  late final $LoginAttemptsTable loginAttempts = $LoginAttemptsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    organizations,
    branches,
    financialPeriods,
    appMetadata,
    users,
    userCredentials,
    roles,
    sessions,
    auditEvents,
    loginAttempts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'users',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_credentials', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$OrganizationsTableCreateCompanionBuilder =
    OrganizationsCompanion Function({
      required String id,
      required String legalName,
      required String displayName,
      required int createdAtUtcMs,
      Value<int> rowid,
    });
typedef $$OrganizationsTableUpdateCompanionBuilder =
    OrganizationsCompanion Function({
      Value<String> id,
      Value<String> legalName,
      Value<String> displayName,
      Value<int> createdAtUtcMs,
      Value<int> rowid,
    });

final class $$OrganizationsTableReferences
    extends
        BaseReferences<
          _$FoundationDatabase,
          $OrganizationsTable,
          OrganizationRow
        > {
  $$OrganizationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$BranchesTable, List<BranchRow>>
  _branchesRefsTable(_$FoundationDatabase db) => MultiTypedResultKey.fromTable(
    db.branches,
    aliasName: 'organizations__id__branches__organization_id',
  );

  $$BranchesTableProcessedTableManager get branchesRefs {
    final manager = $$BranchesTableTableManager(
      $_db,
      $_db.branches,
    ).filter((f) => f.organizationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_branchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FinancialPeriodsTable, List<FinancialPeriodRow>>
  _financialPeriodsRefsTable(_$FoundationDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.financialPeriods,
        aliasName: 'organizations__id__financial_periods__organization_id',
      );

  $$FinancialPeriodsTableProcessedTableManager get financialPeriodsRefs {
    final manager = $$FinancialPeriodsTableTableManager(
      $_db,
      $_db.financialPeriods,
    ).filter((f) => f.organizationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _financialPeriodsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OrganizationsTableFilterComposer
    extends Composer<_$FoundationDatabase, $OrganizationsTable> {
  $$OrganizationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalName => $composableBuilder(
    column: $table.legalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> branchesRefs(
    Expression<bool> Function($$BranchesTableFilterComposer f) f,
  ) {
    final $$BranchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.branches,
      getReferencedColumn: (t) => t.organizationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BranchesTableFilterComposer(
            $db: $db,
            $table: $db.branches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> financialPeriodsRefs(
    Expression<bool> Function($$FinancialPeriodsTableFilterComposer f) f,
  ) {
    final $$FinancialPeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.financialPeriods,
      getReferencedColumn: (t) => t.organizationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FinancialPeriodsTableFilterComposer(
            $db: $db,
            $table: $db.financialPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrganizationsTableOrderingComposer
    extends Composer<_$FoundationDatabase, $OrganizationsTable> {
  $$OrganizationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalName => $composableBuilder(
    column: $table.legalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrganizationsTableAnnotationComposer
    extends Composer<_$FoundationDatabase, $OrganizationsTable> {
  $$OrganizationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get legalName =>
      $composableBuilder(column: $table.legalName, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => column,
  );

  Expression<T> branchesRefs<T extends Object>(
    Expression<T> Function($$BranchesTableAnnotationComposer a) f,
  ) {
    final $$BranchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.branches,
      getReferencedColumn: (t) => t.organizationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BranchesTableAnnotationComposer(
            $db: $db,
            $table: $db.branches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> financialPeriodsRefs<T extends Object>(
    Expression<T> Function($$FinancialPeriodsTableAnnotationComposer a) f,
  ) {
    final $$FinancialPeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.financialPeriods,
      getReferencedColumn: (t) => t.organizationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FinancialPeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.financialPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrganizationsTableTableManager
    extends
        RootTableManager<
          _$FoundationDatabase,
          $OrganizationsTable,
          OrganizationRow,
          $$OrganizationsTableFilterComposer,
          $$OrganizationsTableOrderingComposer,
          $$OrganizationsTableAnnotationComposer,
          $$OrganizationsTableCreateCompanionBuilder,
          $$OrganizationsTableUpdateCompanionBuilder,
          (OrganizationRow, $$OrganizationsTableReferences),
          OrganizationRow,
          PrefetchHooks Function({bool branchesRefs, bool financialPeriodsRefs})
        > {
  $$OrganizationsTableTableManager(
    _$FoundationDatabase db,
    $OrganizationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrganizationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrganizationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrganizationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> legalName = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> createdAtUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrganizationsCompanion(
                id: id,
                legalName: legalName,
                displayName: displayName,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String legalName,
                required String displayName,
                required int createdAtUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => OrganizationsCompanion.insert(
                id: id,
                legalName: legalName,
                displayName: displayName,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OrganizationsTable, OrganizationRow>(table),
                  $$OrganizationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({branchesRefs = false, financialPeriodsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (branchesRefs) db.branches,
                    if (financialPeriodsRefs) db.financialPeriods,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (branchesRefs)
                        await $_getPrefetchedData<
                          OrganizationRow,
                          $OrganizationsTable,
                          BranchRow
                        >(
                          currentTable: table,
                          referencedTable: $$OrganizationsTableReferences
                              ._branchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrganizationsTableReferences(
                                db,
                                table,
                                p0,
                              ).branchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.organizationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (financialPeriodsRefs)
                        await $_getPrefetchedData<
                          OrganizationRow,
                          $OrganizationsTable,
                          FinancialPeriodRow
                        >(
                          currentTable: table,
                          referencedTable: $$OrganizationsTableReferences
                              ._financialPeriodsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrganizationsTableReferences(
                                db,
                                table,
                                p0,
                              ).financialPeriodsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.organizationId == item.id,
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

typedef $$OrganizationsTableProcessedTableManager =
    ProcessedTableManager<
      _$FoundationDatabase,
      $OrganizationsTable,
      OrganizationRow,
      $$OrganizationsTableFilterComposer,
      $$OrganizationsTableOrderingComposer,
      $$OrganizationsTableAnnotationComposer,
      $$OrganizationsTableCreateCompanionBuilder,
      $$OrganizationsTableUpdateCompanionBuilder,
      (OrganizationRow, $$OrganizationsTableReferences),
      OrganizationRow,
      PrefetchHooks Function({bool branchesRefs, bool financialPeriodsRefs})
    >;
typedef $$BranchesTableCreateCompanionBuilder = BranchesCompanion Function({
  required String id,
  required String organizationId,
  required String name,
  required String timeZone,
  required String locale,
  required int createdAtUtcMs,
  Value<int> rowid,
});
typedef $$BranchesTableUpdateCompanionBuilder = BranchesCompanion Function({
  Value<String> id,
  Value<String> organizationId,
  Value<String> name,
  Value<String> timeZone,
  Value<String> locale,
  Value<int> createdAtUtcMs,
  Value<int> rowid,
});

final class $$BranchesTableReferences
    extends BaseReferences<_$FoundationDatabase, $BranchesTable, BranchRow> {
  $$BranchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrganizationsTable _organizationIdTable(_$FoundationDatabase db) => db
      .organizations
      .createAlias('branches__organization_id__organizations__id');

  $$OrganizationsTableProcessedTableManager get organizationId {
    final $_column = $_itemColumn<String>('organization_id')!;

    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_organizationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BranchesTableFilterComposer
    extends Composer<_$FoundationDatabase, $BranchesTable> {
  $$BranchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  $$OrganizationsTableFilterComposer get organizationId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BranchesTableOrderingComposer
    extends Composer<_$FoundationDatabase, $BranchesTable> {
  $$BranchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrganizationsTableOrderingComposer get organizationId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BranchesTableAnnotationComposer
    extends Composer<_$FoundationDatabase, $BranchesTable> {
  $$BranchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get timeZone =>
      $composableBuilder(column: $table.timeZone, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => column,
  );

  $$OrganizationsTableAnnotationComposer get organizationId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BranchesTableTableManager
    extends
        RootTableManager<
          _$FoundationDatabase,
          $BranchesTable,
          BranchRow,
          $$BranchesTableFilterComposer,
          $$BranchesTableOrderingComposer,
          $$BranchesTableAnnotationComposer,
          $$BranchesTableCreateCompanionBuilder,
          $$BranchesTableUpdateCompanionBuilder,
          (BranchRow, $$BranchesTableReferences),
          BranchRow,
          PrefetchHooks Function({bool organizationId})
        > {
  $$BranchesTableTableManager(_$FoundationDatabase db, $BranchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BranchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BranchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BranchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> organizationId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> timeZone = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<int> createdAtUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BranchesCompanion(
                id: id,
                organizationId: organizationId,
                name: name,
                timeZone: timeZone,
                locale: locale,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String organizationId,
                required String name,
                required String timeZone,
                required String locale,
                required int createdAtUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => BranchesCompanion.insert(
                id: id,
                organizationId: organizationId,
                name: name,
                timeZone: timeZone,
                locale: locale,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BranchesTable, BranchRow>(table),
                  $$BranchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({organizationId = false}) {
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
                    if (organizationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.organizationId,
                        referencedTable: $$BranchesTableReferences
                            ._organizationIdTable(db),
                        referencedColumn: $$BranchesTableReferences
                            ._organizationIdTable(db)
                            .id,
                      ) as T;
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

typedef $$BranchesTableProcessedTableManager =
    ProcessedTableManager<
      _$FoundationDatabase,
      $BranchesTable,
      BranchRow,
      $$BranchesTableFilterComposer,
      $$BranchesTableOrderingComposer,
      $$BranchesTableAnnotationComposer,
      $$BranchesTableCreateCompanionBuilder,
      $$BranchesTableUpdateCompanionBuilder,
      (BranchRow, $$BranchesTableReferences),
      BranchRow,
      PrefetchHooks Function({bool organizationId})
    >;
typedef $$FinancialPeriodsTableCreateCompanionBuilder =
    FinancialPeriodsCompanion Function({
      required String id,
      required String organizationId,
      required String branchId,
      required String startsOn,
      required String endsOn,
      Value<bool> locked,
      required int createdAtUtcMs,
      Value<int> rowid,
    });
typedef $$FinancialPeriodsTableUpdateCompanionBuilder =
    FinancialPeriodsCompanion Function({
      Value<String> id,
      Value<String> organizationId,
      Value<String> branchId,
      Value<String> startsOn,
      Value<String> endsOn,
      Value<bool> locked,
      Value<int> createdAtUtcMs,
      Value<int> rowid,
    });

final class $$FinancialPeriodsTableReferences
    extends
        BaseReferences<
          _$FoundationDatabase,
          $FinancialPeriodsTable,
          FinancialPeriodRow
        > {
  $$FinancialPeriodsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OrganizationsTable _organizationIdTable(_$FoundationDatabase db) => db
      .organizations
      .createAlias('financial_periods__organization_id__organizations__id');

  $$OrganizationsTableProcessedTableManager get organizationId {
    final $_column = $_itemColumn<String>('organization_id')!;

    final manager = $$OrganizationsTableTableManager(
      $_db,
      $_db.organizations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_organizationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FinancialPeriodsTableFilterComposer
    extends Composer<_$FoundationDatabase, $FinancialPeriodsTable> {
  $$FinancialPeriodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  $$OrganizationsTableFilterComposer get organizationId {
    final $$OrganizationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableFilterComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FinancialPeriodsTableOrderingComposer
    extends Composer<_$FoundationDatabase, $FinancialPeriodsTable> {
  $$FinancialPeriodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrganizationsTableOrderingComposer get organizationId {
    final $$OrganizationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableOrderingComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FinancialPeriodsTableAnnotationComposer
    extends Composer<_$FoundationDatabase, $FinancialPeriodsTable> {
  $$FinancialPeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get startsOn =>
      $composableBuilder(column: $table.startsOn, builder: (column) => column);

  GeneratedColumn<String> get endsOn =>
      $composableBuilder(column: $table.endsOn, builder: (column) => column);

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => column,
  );

  $$OrganizationsTableAnnotationComposer get organizationId {
    final $$OrganizationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.organizationId,
      referencedTable: $db.organizations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrganizationsTableAnnotationComposer(
            $db: $db,
            $table: $db.organizations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FinancialPeriodsTableTableManager
    extends
        RootTableManager<
          _$FoundationDatabase,
          $FinancialPeriodsTable,
          FinancialPeriodRow,
          $$FinancialPeriodsTableFilterComposer,
          $$FinancialPeriodsTableOrderingComposer,
          $$FinancialPeriodsTableAnnotationComposer,
          $$FinancialPeriodsTableCreateCompanionBuilder,
          $$FinancialPeriodsTableUpdateCompanionBuilder,
          (FinancialPeriodRow, $$FinancialPeriodsTableReferences),
          FinancialPeriodRow,
          PrefetchHooks Function({bool organizationId})
        > {
  $$FinancialPeriodsTableTableManager(
    _$FoundationDatabase db,
    $FinancialPeriodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinancialPeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinancialPeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinancialPeriodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> organizationId = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String> startsOn = const Value.absent(),
                Value<String> endsOn = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<int> createdAtUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FinancialPeriodsCompanion(
                id: id,
                organizationId: organizationId,
                branchId: branchId,
                startsOn: startsOn,
                endsOn: endsOn,
                locked: locked,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String organizationId,
                required String branchId,
                required String startsOn,
                required String endsOn,
                Value<bool> locked = const Value.absent(),
                required int createdAtUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => FinancialPeriodsCompanion.insert(
                id: id,
                organizationId: organizationId,
                branchId: branchId,
                startsOn: startsOn,
                endsOn: endsOn,
                locked: locked,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FinancialPeriodsTable, FinancialPeriodRow>(
                    table,
                  ),
                  $$FinancialPeriodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({organizationId = false}) {
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
                    if (organizationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.organizationId,
                        referencedTable: $$FinancialPeriodsTableReferences
                            ._organizationIdTable(db),
                        referencedColumn: $$FinancialPeriodsTableReferences
                            ._organizationIdTable(db)
                            .id,
                      ) as T;
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

typedef $$FinancialPeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$FoundationDatabase,
      $FinancialPeriodsTable,
      FinancialPeriodRow,
      $$FinancialPeriodsTableFilterComposer,
      $$FinancialPeriodsTableOrderingComposer,
      $$FinancialPeriodsTableAnnotationComposer,
      $$FinancialPeriodsTableCreateCompanionBuilder,
      $$FinancialPeriodsTableUpdateCompanionBuilder,
      (FinancialPeriodRow, $$FinancialPeriodsTableReferences),
      FinancialPeriodRow,
      PrefetchHooks Function({bool organizationId})
    >;
typedef $$AppMetadataTableCreateCompanionBuilder =
    AppMetadataCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetadataTableUpdateCompanionBuilder =
    AppMetadataCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetadataTableFilterComposer
    extends Composer<_$FoundationDatabase, $AppMetadataTable> {
  $$AppMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetadataTableOrderingComposer
    extends Composer<_$FoundationDatabase, $AppMetadataTable> {
  $$AppMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetadataTableAnnotationComposer
    extends Composer<_$FoundationDatabase, $AppMetadataTable> {
  $$AppMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetadataTableTableManager
    extends
        RootTableManager<
          _$FoundationDatabase,
          $AppMetadataTable,
          AppMetadataRow,
          $$AppMetadataTableFilterComposer,
          $$AppMetadataTableOrderingComposer,
          $$AppMetadataTableAnnotationComposer,
          $$AppMetadataTableCreateCompanionBuilder,
          $$AppMetadataTableUpdateCompanionBuilder,
          (
            AppMetadataRow,
            BaseReferences<
              _$FoundationDatabase,
              $AppMetadataTable,
              AppMetadataRow
            >,
          ),
          AppMetadataRow,
          PrefetchHooks Function()
        > {
  $$AppMetadataTableTableManager(
    _$FoundationDatabase db,
    $AppMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppMetadataCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppMetadataCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppMetadataTable, AppMetadataRow>(table),
                  BaseReferences<
                    _$FoundationDatabase,
                    $AppMetadataTable,
                    AppMetadataRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$FoundationDatabase,
      $AppMetadataTable,
      AppMetadataRow,
      $$AppMetadataTableFilterComposer,
      $$AppMetadataTableOrderingComposer,
      $$AppMetadataTableAnnotationComposer,
      $$AppMetadataTableCreateCompanionBuilder,
      $$AppMetadataTableUpdateCompanionBuilder,
      (
        AppMetadataRow,
        BaseReferences<_$FoundationDatabase, $AppMetadataTable, AppMetadataRow>,
      ),
      AppMetadataRow,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String username,
  required String fullName,
  required String roleId,
  Value<bool> isActive,
  required int createdAtUtcMs,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> username,
  Value<String> fullName,
  Value<String> roleId,
  Value<bool> isActive,
  Value<int> createdAtUtcMs,
  Value<int> rowid,
});

final class $$UsersTableReferences
    extends BaseReferences<_$FoundationDatabase, $UsersTable, UserRow> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserCredentialsTable, List<UserCredentialRow>>
  _userCredentialsRefsTable(_$FoundationDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.userCredentials,
        aliasName: 'users__id__user_credentials__user_id',
      );

  $$UserCredentialsTableProcessedTableManager get userCredentialsRefs {
    final manager = $$UserCredentialsTableTableManager(
      $_db,
      $_db.userCredentials,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userCredentialsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer
    extends Composer<_$FoundationDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleId => $composableBuilder(
    column: $table.roleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userCredentialsRefs(
    Expression<bool> Function($$UserCredentialsTableFilterComposer f) f,
  ) {
    final $$UserCredentialsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userCredentials,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserCredentialsTableFilterComposer(
            $db: $db,
            $table: $db.userCredentials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$FoundationDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleId => $composableBuilder(
    column: $table.roleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$FoundationDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get roleId =>
      $composableBuilder(column: $table.roleId, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => column,
  );

  Expression<T> userCredentialsRefs<T extends Object>(
    Expression<T> Function($$UserCredentialsTableAnnotationComposer a) f,
  ) {
    final $$UserCredentialsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userCredentials,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserCredentialsTableAnnotationComposer(
            $db: $db,
            $table: $db.userCredentials,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$FoundationDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, $$UsersTableReferences),
          UserRow,
          PrefetchHooks Function({bool userCredentialsRefs})
        > {
  $$UsersTableTableManager(_$FoundationDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> roleId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> createdAtUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                username: username,
                fullName: fullName,
                roleId: roleId,
                isActive: isActive,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String username,
                required String fullName,
                required String roleId,
                Value<bool> isActive = const Value.absent(),
                required int createdAtUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                username: username,
                fullName: fullName,
                roleId: roleId,
                isActive: isActive,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, UserRow>(table),
                  $$UsersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userCredentialsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userCredentialsRefs) db.userCredentials,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userCredentialsRefs)
                    await $_getPrefetchedData<
                      UserRow,
                      $UsersTable,
                      UserCredentialRow
                    >(
                      currentTable: table,
                      referencedTable: $$UsersTableReferences
                          ._userCredentialsRefsTable(db),
                      managerFromTypedResult: (p0) => $$UsersTableReferences(
                        db,
                        table,
                        p0,
                      ).userCredentialsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.userId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$FoundationDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, $$UsersTableReferences),
      UserRow,
      PrefetchHooks Function({bool userCredentialsRefs})
    >;
typedef $$UserCredentialsTableCreateCompanionBuilder =
    UserCredentialsCompanion Function({
      required String userId,
      required String passwordHash,
      required String salt,
      required String hashAlgorithm,
      required int iterations,
      required String recoveryKeyHash,
      Value<int> rowid,
    });
typedef $$UserCredentialsTableUpdateCompanionBuilder =
    UserCredentialsCompanion Function({
      Value<String> userId,
      Value<String> passwordHash,
      Value<String> salt,
      Value<String> hashAlgorithm,
      Value<int> iterations,
      Value<String> recoveryKeyHash,
      Value<int> rowid,
    });

final class $$UserCredentialsTableReferences
    extends
        BaseReferences<
          _$FoundationDatabase,
          $UserCredentialsTable,
          UserCredentialRow
        > {
  $$UserCredentialsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$FoundationDatabase db) =>
      db.users.createAlias('user_credentials__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserCredentialsTableFilterComposer
    extends Composer<_$FoundationDatabase, $UserCredentialsTable> {
  $$UserCredentialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hashAlgorithm => $composableBuilder(
    column: $table.hashAlgorithm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iterations => $composableBuilder(
    column: $table.iterations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recoveryKeyHash => $composableBuilder(
    column: $table.recoveryKeyHash,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCredentialsTableOrderingComposer
    extends Composer<_$FoundationDatabase, $UserCredentialsTable> {
  $$UserCredentialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hashAlgorithm => $composableBuilder(
    column: $table.hashAlgorithm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iterations => $composableBuilder(
    column: $table.iterations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recoveryKeyHash => $composableBuilder(
    column: $table.recoveryKeyHash,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCredentialsTableAnnotationComposer
    extends Composer<_$FoundationDatabase, $UserCredentialsTable> {
  $$UserCredentialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<String> get hashAlgorithm => $composableBuilder(
    column: $table.hashAlgorithm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get iterations => $composableBuilder(
    column: $table.iterations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recoveryKeyHash => $composableBuilder(
    column: $table.recoveryKeyHash,
    builder: (column) => column,
  );

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCredentialsTableTableManager
    extends
        RootTableManager<
          _$FoundationDatabase,
          $UserCredentialsTable,
          UserCredentialRow,
          $$UserCredentialsTableFilterComposer,
          $$UserCredentialsTableOrderingComposer,
          $$UserCredentialsTableAnnotationComposer,
          $$UserCredentialsTableCreateCompanionBuilder,
          $$UserCredentialsTableUpdateCompanionBuilder,
          (UserCredentialRow, $$UserCredentialsTableReferences),
          UserCredentialRow,
          PrefetchHooks Function({bool userId})
        > {
  $$UserCredentialsTableTableManager(
    _$FoundationDatabase db,
    $UserCredentialsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCredentialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserCredentialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserCredentialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> salt = const Value.absent(),
                Value<String> hashAlgorithm = const Value.absent(),
                Value<int> iterations = const Value.absent(),
                Value<String> recoveryKeyHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserCredentialsCompanion(
                userId: userId,
                passwordHash: passwordHash,
                salt: salt,
                hashAlgorithm: hashAlgorithm,
                iterations: iterations,
                recoveryKeyHash: recoveryKeyHash,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String passwordHash,
                required String salt,
                required String hashAlgorithm,
                required int iterations,
                required String recoveryKeyHash,
                Value<int> rowid = const Value.absent(),
              }) => UserCredentialsCompanion.insert(
                userId: userId,
                passwordHash: passwordHash,
                salt: salt,
                hashAlgorithm: hashAlgorithm,
                iterations: iterations,
                recoveryKeyHash: recoveryKeyHash,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserCredentialsTable, UserCredentialRow>(table),
                  $$UserCredentialsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
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
                    if (userId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.userId,
                        referencedTable: $$UserCredentialsTableReferences
                            ._userIdTable(db),
                        referencedColumn: $$UserCredentialsTableReferences
                            ._userIdTable(db)
                            .id,
                      ) as T;
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

typedef $$UserCredentialsTableProcessedTableManager =
    ProcessedTableManager<
      _$FoundationDatabase,
      $UserCredentialsTable,
      UserCredentialRow,
      $$UserCredentialsTableFilterComposer,
      $$UserCredentialsTableOrderingComposer,
      $$UserCredentialsTableAnnotationComposer,
      $$UserCredentialsTableCreateCompanionBuilder,
      $$UserCredentialsTableUpdateCompanionBuilder,
      (UserCredentialRow, $$UserCredentialsTableReferences),
      UserCredentialRow,
      PrefetchHooks Function({bool userId})
    >;
typedef $$RolesTableCreateCompanionBuilder = RolesCompanion Function({
  required String id,
  required String name,
  required String capabilitiesJson,
  Value<bool> isSystem,
  required int createdAtUtcMs,
  Value<int> rowid,
});
typedef $$RolesTableUpdateCompanionBuilder = RolesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> capabilitiesJson,
  Value<bool> isSystem,
  Value<int> createdAtUtcMs,
  Value<int> rowid,
});

class $$RolesTableFilterComposer
    extends Composer<_$FoundationDatabase, $RolesTable> {
  $$RolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capabilitiesJson => $composableBuilder(
    column: $table.capabilitiesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RolesTableOrderingComposer
    extends Composer<_$FoundationDatabase, $RolesTable> {
  $$RolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capabilitiesJson => $composableBuilder(
    column: $table.capabilitiesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RolesTableAnnotationComposer
    extends Composer<_$FoundationDatabase, $RolesTable> {
  $$RolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get capabilitiesJson => $composableBuilder(
    column: $table.capabilitiesJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => column,
  );
}

class $$RolesTableTableManager
    extends
        RootTableManager<
          _$FoundationDatabase,
          $RolesTable,
          RoleRow,
          $$RolesTableFilterComposer,
          $$RolesTableOrderingComposer,
          $$RolesTableAnnotationComposer,
          $$RolesTableCreateCompanionBuilder,
          $$RolesTableUpdateCompanionBuilder,
          (RoleRow, BaseReferences<_$FoundationDatabase, $RolesTable, RoleRow>),
          RoleRow,
          PrefetchHooks Function()
        > {
  $$RolesTableTableManager(_$FoundationDatabase db, $RolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> capabilitiesJson = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<int> createdAtUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RolesCompanion(
                id: id,
                name: name,
                capabilitiesJson: capabilitiesJson,
                isSystem: isSystem,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String capabilitiesJson,
                Value<bool> isSystem = const Value.absent(),
                required int createdAtUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => RolesCompanion.insert(
                id: id,
                name: name,
                capabilitiesJson: capabilitiesJson,
                isSystem: isSystem,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RolesTable, RoleRow>(table),
                  BaseReferences<_$FoundationDatabase, $RolesTable, RoleRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RolesTableProcessedTableManager =
    ProcessedTableManager<
      _$FoundationDatabase,
      $RolesTable,
      RoleRow,
      $$RolesTableFilterComposer,
      $$RolesTableOrderingComposer,
      $$RolesTableAnnotationComposer,
      $$RolesTableCreateCompanionBuilder,
      $$RolesTableUpdateCompanionBuilder,
      (RoleRow, BaseReferences<_$FoundationDatabase, $RolesTable, RoleRow>),
      RoleRow,
      PrefetchHooks Function()
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required String userId,
  required String username,
  required String roleId,
  required String branchId,
  required String token,
  required int expiresAtUtcMs,
  required int lastActivityUtcMs,
  Value<bool> isLocked,
  required int createdAtUtcMs,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> username,
  Value<String> roleId,
  Value<String> branchId,
  Value<String> token,
  Value<int> expiresAtUtcMs,
  Value<int> lastActivityUtcMs,
  Value<bool> isLocked,
  Value<int> createdAtUtcMs,
  Value<int> rowid,
});

class $$SessionsTableFilterComposer
    extends Composer<_$FoundationDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleId => $composableBuilder(
    column: $table.roleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAtUtcMs => $composableBuilder(
    column: $table.expiresAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastActivityUtcMs => $composableBuilder(
    column: $table.lastActivityUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$FoundationDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleId => $composableBuilder(
    column: $table.roleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAtUtcMs => $composableBuilder(
    column: $table.expiresAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastActivityUtcMs => $composableBuilder(
    column: $table.lastActivityUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$FoundationDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get roleId =>
      $composableBuilder(column: $table.roleId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<int> get expiresAtUtcMs => $composableBuilder(
    column: $table.expiresAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastActivityUtcMs => $composableBuilder(
    column: $table.lastActivityUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => column,
  );
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$FoundationDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (
            SessionRow,
            BaseReferences<_$FoundationDatabase, $SessionsTable, SessionRow>,
          ),
          SessionRow,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$FoundationDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> roleId = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String> token = const Value.absent(),
                Value<int> expiresAtUtcMs = const Value.absent(),
                Value<int> lastActivityUtcMs = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<int> createdAtUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                userId: userId,
                username: username,
                roleId: roleId,
                branchId: branchId,
                token: token,
                expiresAtUtcMs: expiresAtUtcMs,
                lastActivityUtcMs: lastActivityUtcMs,
                isLocked: isLocked,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String username,
                required String roleId,
                required String branchId,
                required String token,
                required int expiresAtUtcMs,
                required int lastActivityUtcMs,
                Value<bool> isLocked = const Value.absent(),
                required int createdAtUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                userId: userId,
                username: username,
                roleId: roleId,
                branchId: branchId,
                token: token,
                expiresAtUtcMs: expiresAtUtcMs,
                lastActivityUtcMs: lastActivityUtcMs,
                isLocked: isLocked,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, SessionRow>(table),
                  BaseReferences<
                    _$FoundationDatabase,
                    $SessionsTable,
                    SessionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$FoundationDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (
        SessionRow,
        BaseReferences<_$FoundationDatabase, $SessionsTable, SessionRow>,
      ),
      SessionRow,
      PrefetchHooks Function()
    >;
typedef $$AuditEventsTableCreateCompanionBuilder =
    AuditEventsCompanion Function({
      required String id,
      required String actorUserId,
      required String actorUsername,
      required String action,
      required String entityType,
      required String entityId,
      required String detailsJson,
      required int createdAtUtcMs,
      Value<int> rowid,
    });
typedef $$AuditEventsTableUpdateCompanionBuilder =
    AuditEventsCompanion Function({
      Value<String> id,
      Value<String> actorUserId,
      Value<String> actorUsername,
      Value<String> action,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> detailsJson,
      Value<int> createdAtUtcMs,
      Value<int> rowid,
    });

class $$AuditEventsTableFilterComposer
    extends Composer<_$FoundationDatabase, $AuditEventsTable> {
  $$AuditEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorUsername => $composableBuilder(
    column: $table.actorUsername,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditEventsTableOrderingComposer
    extends Composer<_$FoundationDatabase, $AuditEventsTable> {
  $$AuditEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorUsername => $composableBuilder(
    column: $table.actorUsername,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditEventsTableAnnotationComposer
    extends Composer<_$FoundationDatabase, $AuditEventsTable> {
  $$AuditEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorUsername => $composableBuilder(
    column: $table.actorUsername,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => column,
  );
}

class $$AuditEventsTableTableManager
    extends
        RootTableManager<
          _$FoundationDatabase,
          $AuditEventsTable,
          AuditEventRow,
          $$AuditEventsTableFilterComposer,
          $$AuditEventsTableOrderingComposer,
          $$AuditEventsTableAnnotationComposer,
          $$AuditEventsTableCreateCompanionBuilder,
          $$AuditEventsTableUpdateCompanionBuilder,
          (
            AuditEventRow,
            BaseReferences<
              _$FoundationDatabase,
              $AuditEventsTable,
              AuditEventRow
            >,
          ),
          AuditEventRow,
          PrefetchHooks Function()
        > {
  $$AuditEventsTableTableManager(
    _$FoundationDatabase db,
    $AuditEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> actorUserId = const Value.absent(),
                Value<String> actorUsername = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> detailsJson = const Value.absent(),
                Value<int> createdAtUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditEventsCompanion(
                id: id,
                actorUserId: actorUserId,
                actorUsername: actorUsername,
                action: action,
                entityType: entityType,
                entityId: entityId,
                detailsJson: detailsJson,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String actorUserId,
                required String actorUsername,
                required String action,
                required String entityType,
                required String entityId,
                required String detailsJson,
                required int createdAtUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => AuditEventsCompanion.insert(
                id: id,
                actorUserId: actorUserId,
                actorUsername: actorUsername,
                action: action,
                entityType: entityType,
                entityId: entityId,
                detailsJson: detailsJson,
                createdAtUtcMs: createdAtUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditEventsTable, AuditEventRow>(table),
                  BaseReferences<
                    _$FoundationDatabase,
                    $AuditEventsTable,
                    AuditEventRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$FoundationDatabase,
      $AuditEventsTable,
      AuditEventRow,
      $$AuditEventsTableFilterComposer,
      $$AuditEventsTableOrderingComposer,
      $$AuditEventsTableAnnotationComposer,
      $$AuditEventsTableCreateCompanionBuilder,
      $$AuditEventsTableUpdateCompanionBuilder,
      (
        AuditEventRow,
        BaseReferences<_$FoundationDatabase, $AuditEventsTable, AuditEventRow>,
      ),
      AuditEventRow,
      PrefetchHooks Function()
    >;
typedef $$LoginAttemptsTableCreateCompanionBuilder =
    LoginAttemptsCompanion Function({
      required String username,
      Value<int> failedAttempts,
      Value<int?> lockedUntilUtcMs,
      Value<int> rowid,
    });
typedef $$LoginAttemptsTableUpdateCompanionBuilder =
    LoginAttemptsCompanion Function({
      Value<String> username,
      Value<int> failedAttempts,
      Value<int?> lockedUntilUtcMs,
      Value<int> rowid,
    });

class $$LoginAttemptsTableFilterComposer
    extends Composer<_$FoundationDatabase, $LoginAttemptsTable> {
  $$LoginAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lockedUntilUtcMs => $composableBuilder(
    column: $table.lockedUntilUtcMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LoginAttemptsTableOrderingComposer
    extends Composer<_$FoundationDatabase, $LoginAttemptsTable> {
  $$LoginAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lockedUntilUtcMs => $composableBuilder(
    column: $table.lockedUntilUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LoginAttemptsTableAnnotationComposer
    extends Composer<_$FoundationDatabase, $LoginAttemptsTable> {
  $$LoginAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lockedUntilUtcMs => $composableBuilder(
    column: $table.lockedUntilUtcMs,
    builder: (column) => column,
  );
}

class $$LoginAttemptsTableTableManager
    extends
        RootTableManager<
          _$FoundationDatabase,
          $LoginAttemptsTable,
          LoginAttemptRow,
          $$LoginAttemptsTableFilterComposer,
          $$LoginAttemptsTableOrderingComposer,
          $$LoginAttemptsTableAnnotationComposer,
          $$LoginAttemptsTableCreateCompanionBuilder,
          $$LoginAttemptsTableUpdateCompanionBuilder,
          (
            LoginAttemptRow,
            BaseReferences<
              _$FoundationDatabase,
              $LoginAttemptsTable,
              LoginAttemptRow
            >,
          ),
          LoginAttemptRow,
          PrefetchHooks Function()
        > {
  $$LoginAttemptsTableTableManager(
    _$FoundationDatabase db,
    $LoginAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoginAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoginAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoginAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> username = const Value.absent(),
                Value<int> failedAttempts = const Value.absent(),
                Value<int?> lockedUntilUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoginAttemptsCompanion(
                username: username,
                failedAttempts: failedAttempts,
                lockedUntilUtcMs: lockedUntilUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String username,
                Value<int> failedAttempts = const Value.absent(),
                Value<int?> lockedUntilUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoginAttemptsCompanion.insert(
                username: username,
                failedAttempts: failedAttempts,
                lockedUntilUtcMs: lockedUntilUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LoginAttemptsTable, LoginAttemptRow>(table),
                  BaseReferences<
                    _$FoundationDatabase,
                    $LoginAttemptsTable,
                    LoginAttemptRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LoginAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$FoundationDatabase,
      $LoginAttemptsTable,
      LoginAttemptRow,
      $$LoginAttemptsTableFilterComposer,
      $$LoginAttemptsTableOrderingComposer,
      $$LoginAttemptsTableAnnotationComposer,
      $$LoginAttemptsTableCreateCompanionBuilder,
      $$LoginAttemptsTableUpdateCompanionBuilder,
      (
        LoginAttemptRow,
        BaseReferences<
          _$FoundationDatabase,
          $LoginAttemptsTable,
          LoginAttemptRow
        >,
      ),
      LoginAttemptRow,
      PrefetchHooks Function()
    >;

class $FoundationDatabaseManager {
  final _$FoundationDatabase _db;
  $FoundationDatabaseManager(this._db);
  $$OrganizationsTableTableManager get organizations =>
      $$OrganizationsTableTableManager(_db, _db.organizations);
  $$BranchesTableTableManager get branches =>
      $$BranchesTableTableManager(_db, _db.branches);
  $$FinancialPeriodsTableTableManager get financialPeriods =>
      $$FinancialPeriodsTableTableManager(_db, _db.financialPeriods);
  $$AppMetadataTableTableManager get appMetadata =>
      $$AppMetadataTableTableManager(_db, _db.appMetadata);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$UserCredentialsTableTableManager get userCredentials =>
      $$UserCredentialsTableTableManager(_db, _db.userCredentials);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db, _db.roles);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$AuditEventsTableTableManager get auditEvents =>
      $$AuditEventsTableTableManager(_db, _db.auditEvents);
  $$LoginAttemptsTableTableManager get loginAttempts =>
      $$LoginAttemptsTableTableManager(_db, _db.loginAttempts);
}
