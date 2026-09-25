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

abstract class _$FoundationDatabase extends GeneratedDatabase {
  _$FoundationDatabase(QueryExecutor e) : super(e);
  $FoundationDatabaseManager get managers => $FoundationDatabaseManager(this);
  late final $OrganizationsTable organizations = $OrganizationsTable(this);
  late final $BranchesTable branches = $BranchesTable(this);
  late final $FinancialPeriodsTable financialPeriods = $FinancialPeriodsTable(
    this,
  );
  late final $AppMetadataTable appMetadata = $AppMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    organizations,
    branches,
    financialPeriods,
    appMetadata,
  ];
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
}
