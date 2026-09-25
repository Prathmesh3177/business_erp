import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

part 'foundation_database.g.dart';

@DataClassName('OrganizationRow')
class Organizations extends Table {
  TextColumn get id => text()();
  TextColumn get legalName => text()();
  TextColumn get displayName => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('BranchRow')
class Branches extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #id, onDelete: KeyAction.restrict)();
  TextColumn get name => text()();
  TextColumn get timeZone => text()();
  TextColumn get locale => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {id, organizationId},
  ];
}

@DataClassName('FinancialPeriodRow')
class FinancialPeriods extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #id, onDelete: KeyAction.restrict)();
  TextColumn get branchId => text()();
  TextColumn get startsOn => text()();
  TextColumn get endsOn => text()();
  BoolColumn get locked => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (branch_id, organization_id) '
        'REFERENCES branches(id, organization_id) ON DELETE RESTRICT',
    'CHECK (ends_on > starts_on)',
  ];
}

@DataClassName('AppMetadataRow')
class AppMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [Organizations, Branches, FinancialPeriods, AppMetadata])
final class FoundationDatabase extends _$FoundationDatabase
    implements FoundationStore {
  FoundationDatabase._(super.executor, this._file, this._key);

  final File _file;
  final List<int> _key;

  static FoundationDatabase open({required File file, required List<int> key}) {
    if (key.length != 32) {
      throw const SecurityFailure(
        'database.invalid_key_length',
        'The protected database key is invalid.',
      );
    }
    file.parent.createSync(recursive: true);
    final immutableKey = List<int>.unmodifiable(key);
    final executor = NativeDatabase.createInBackground(
      file,
      setup: (database) =>
          _configureEncryptedConnection(database, immutableKey),
    );
    return FoundationDatabase._(executor, file, immutableKey);
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 1) {
        await migrator.createAll();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      final violations = await customSelect('PRAGMA foreign_key_check').get();
      if (violations.isNotEmpty) {
        throw const StorageFailure(
          'database.foreign_key_violation',
          'Stored data failed an integrity check.',
        );
      }
    },
  );

  @override
  Future<FoundationIdentity?> loadIdentity() async {
    final rows = await customSelect('''
      SELECT
        o.id AS organization_id,
        o.legal_name,
        o.display_name,
        o.created_at_utc_ms AS organization_created_at,
        b.id AS branch_id,
        b.name AS branch_name,
        b.time_zone,
        b.locale,
        b.created_at_utc_ms AS branch_created_at,
        f.id AS period_id,
        f.starts_on,
        f.ends_on,
        f.created_at_utc_ms AS period_created_at
      FROM organizations o
      JOIN branches b ON b.organization_id = o.id
      JOIN financial_periods f
        ON f.organization_id = o.id AND f.branch_id = b.id
      ORDER BY o.created_at_utc_ms, b.created_at_utc_ms, f.starts_on
      LIMIT 1
    ''').getSingleOrNull();
    if (rows == null) return null;
    final data = rows.data;
    final organizationId = OrganizationId(data['organization_id']! as String);
    final branchId = BranchId(data['branch_id']! as String);
    return FoundationIdentity(
      organization: Organization(
        id: organizationId,
        legalName: data['legal_name']! as String,
        displayName: data['display_name']! as String,
        createdAtUtc: _fromEpoch(data['organization_created_at']! as int),
      ),
      branch: Branch(
        id: branchId,
        organizationId: organizationId,
        name: data['branch_name']! as String,
        timeZone: data['time_zone']! as String,
        locale: data['locale']! as String,
        createdAtUtc: _fromEpoch(data['branch_created_at']! as int),
      ),
      financialPeriod: FinancialPeriod(
        id: FinancialPeriodId(data['period_id']! as String),
        organizationId: organizationId,
        branchId: branchId,
        startsOn: DateTime.parse(data['starts_on']! as String),
        endsOn: DateTime.parse(data['ends_on']! as String),
        createdAtUtc: _fromEpoch(data['period_created_at']! as int),
      ),
    );
  }

  @override
  Future<T> inTransaction<T>(
    Future<T> Function(FoundationTransaction transaction) action,
  ) {
    return transaction(() => action(_FoundationDriftTransaction(this)));
  }

  @override
  Future<void> createVerifiedSnapshot(String targetPath) async {
    final target = File(targetPath).absolute;
    if (target.path == _file.absolute.path) {
      throw const StorageFailure(
        'snapshot.invalid_target',
        'Choose a different recovery snapshot location.',
      );
    }
    target.parent.createSync(recursive: true);
    final staging = File('${target.path}.staging');
    if (staging.existsSync()) staging.deleteSync();
    if (target.existsSync()) {
      throw const StorageFailure(
        'snapshot.target_exists',
        'A recovery snapshot already exists at that location.',
      );
    }
    try {
      await customStatement('PRAGMA wal_checkpoint(FULL)');
      await customStatement('VACUUM INTO ?', [staging.path]);
      _verifyEncryptedFile(staging, _key);
      staging.renameSync(target.path);
    } catch (_) {
      if (staging.existsSync()) staging.deleteSync();
      rethrow;
    }
  }
}

final class _FoundationDriftTransaction implements FoundationTransaction {
  const _FoundationDriftTransaction(this.database);

  final FoundationDatabase database;

  @override
  Future<void> insertIdentity(FoundationIdentity identity) async {
    final organization = identity.organization;
    final branch = identity.branch;
    final period = identity.financialPeriod;
    await database
        .into(database.organizations)
        .insert(
          OrganizationsCompanion.insert(
            id: organization.id.value,
            legalName: organization.legalName,
            displayName: organization.displayName,
            createdAtUtcMs: organization.createdAtUtc.millisecondsSinceEpoch,
          ),
        );
    await database
        .into(database.branches)
        .insert(
          BranchesCompanion.insert(
            id: branch.id.value,
            organizationId: branch.organizationId.value,
            name: branch.name,
            timeZone: branch.timeZone,
            locale: branch.locale,
            createdAtUtcMs: branch.createdAtUtc.millisecondsSinceEpoch,
          ),
        );
    await database
        .into(database.financialPeriods)
        .insert(
          FinancialPeriodsCompanion.insert(
            id: period.id.value,
            organizationId: period.organizationId.value,
            branchId: period.branchId.value,
            startsOn: _date(period.startsOn),
            endsOn: _date(period.endsOn),
            createdAtUtcMs: period.createdAtUtc.millisecondsSinceEpoch,
          ),
        );
    await database
        .into(database.appMetadata)
        .insert(
          AppMetadataCompanion.insert(
            key: 'authority_mode',
            value: 'single_branch',
          ),
        );
  }
}

void _configureEncryptedConnection(sqlite.Database database, List<int> key) {
  final cipher = database.select('PRAGMA cipher;');
  if (cipher.isEmpty || cipher.first.values.firstOrNull == null) {
    throw StateError('SQLite encryption support is unavailable.');
  }
  final keyHex = key
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  database.execute('PRAGMA key = "x\'$keyHex\'";');
  database.execute('PRAGMA temp_store = MEMORY;');
  database.execute('PRAGMA foreign_keys = ON;');
  database.select('SELECT count(*) FROM sqlite_master;');
}

void _verifyEncryptedFile(File file, List<int> key) {
  final database = sqlite.sqlite3.open(file.path);
  try {
    _configureEncryptedConnection(database, key);
    final integrity = database.select('PRAGMA integrity_check;');
    if (integrity.single.values.single != 'ok') {
      throw const StorageFailure(
        'snapshot.integrity_failed',
        'The recovery snapshot failed verification.',
      );
    }
    final version = database.userVersion;
    if (version != 1) {
      throw const StorageFailure(
        'snapshot.schema_mismatch',
        'The recovery snapshot schema is unsupported.',
      );
    }
  } finally {
    database.close();
  }
}

DateTime _fromEpoch(int value) =>
    DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
