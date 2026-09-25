import 'dart:convert';
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

@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text().unique()();
  TextColumn get fullName => text()();
  TextColumn get roleId => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('UserCredentialRow')
class UserCredentials extends Table {
  TextColumn get userId =>
      text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get passwordHash => text()();
  TextColumn get salt => text()();
  TextColumn get hashAlgorithm => text()();
  IntColumn get iterations => integer()();
  TextColumn get recoveryKeyHash => text()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

@DataClassName('RoleRow')
class Roles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get capabilitiesJson => text()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get username => text()();
  TextColumn get roleId => text()();
  TextColumn get branchId => text()();
  TextColumn get token => text()();
  IntColumn get expiresAtUtcMs => integer()();
  IntColumn get lastActivityUtcMs => integer()();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AuditEventRow')
class AuditEvents extends Table {
  TextColumn get id => text()();
  TextColumn get actorUserId => text()();
  TextColumn get actorUsername => text()();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get detailsJson => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LoginAttemptRow')
class LoginAttempts extends Table {
  TextColumn get username => text()();
  IntColumn get failedAttempts => integer().withDefault(const Constant(0))();
  IntColumn get lockedUntilUtcMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {username};
}

@DriftDatabase(
  tables: [
    Organizations,
    Branches,
    FinancialPeriods,
    AppMetadata,
    Users,
    UserCredentials,
    Roles,
    Sessions,
    AuditEvents,
    LoginAttempts,
  ],
)
final class FoundationDatabase extends _$FoundationDatabase
    implements FoundationStore, IdentityStore, AuditStore {
  FoundationDatabase._(super.executor, this._file, this._key);

  final File _file;
  final List<int> _key;

  static FoundationDatabase open({
    required File file,
    List<int> key = const [],
  }) {
    if (key.isNotEmpty && key.length != 32) {
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _seedDefaultRoles();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 1) {
        await migrator.createAll();
      }
      if (from < 2) {
        await migrator.createTable(users);
        await migrator.createTable(userCredentials);
        await migrator.createTable(roles);
        await migrator.createTable(sessions);
        await migrator.createTable(auditEvents);
        await migrator.createTable(loginAttempts);
        await _seedDefaultRoles();
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

  Future<void> _seedDefaultRoles() async {
    for (final role in Role.defaultRoles) {
      await into(roles).insertOnConflictUpdate(
        RolesCompanion.insert(
          id: role.id,
          name: role.name,
          capabilitiesJson: jsonEncode(
            role.capabilities.map((c) => c.identifier).toList(),
          ),
          isSystem: Value(role.isSystem),
          createdAtUtcMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

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

  // --- IdentityStore implementation ---

  @override
  Future<User?> getUserByUsername(String username) async {
    final row =
        await (select(users)
              ..where((u) => u.username.equals(username.toLowerCase())))
            .getSingleOrNull();
    if (row == null) return null;
    return User(
      id: UserId(row.id),
      username: row.username,
      fullName: row.fullName,
      roleId: row.roleId,
      isActive: row.isActive,
      createdAtUtc: _fromEpoch(row.createdAtUtcMs),
    );
  }

  @override
  Future<User?> getUserById(UserId id) async {
    final row = await (select(
      users,
    )..where((u) => u.id.equals(id.value))).getSingleOrNull();
    if (row == null) return null;
    return User(
      id: UserId(row.id),
      username: row.username,
      fullName: row.fullName,
      roleId: row.roleId,
      isActive: row.isActive,
      createdAtUtc: _fromEpoch(row.createdAtUtcMs),
    );
  }

  @override
  Future<UserCredential?> getUserCredential(UserId id) async {
    final row = await (select(
      userCredentials,
    )..where((c) => c.userId.equals(id.value))).getSingleOrNull();
    if (row == null) return null;
    return UserCredential(
      userId: UserId(row.userId),
      passwordHash: row.passwordHash,
      salt: row.salt,
      hashAlgorithm: row.hashAlgorithm,
      iterations: row.iterations,
      recoveryKeyHash: row.recoveryKeyHash,
    );
  }

  @override
  Future<List<User>> getAllUsers() async {
    final rows = await select(users).get();
    return rows
        .map(
          (r) => User(
            id: UserId(r.id),
            username: r.username,
            fullName: r.fullName,
            roleId: r.roleId,
            isActive: r.isActive,
            createdAtUtc: _fromEpoch(r.createdAtUtcMs),
          ),
        )
        .toList();
  }

  @override
  Future<void> createUser(User user, UserCredential credential) async {
    await transaction(() async {
      await into(users).insert(
        UsersCompanion.insert(
          id: user.id.value,
          username: user.username,
          fullName: user.fullName,
          roleId: user.roleId,
          isActive: Value(user.isActive),
          createdAtUtcMs: user.createdAtUtc.millisecondsSinceEpoch,
        ),
      );
      await into(userCredentials).insert(
        UserCredentialsCompanion.insert(
          userId: credential.userId.value,
          passwordHash: credential.passwordHash,
          salt: credential.salt,
          hashAlgorithm: credential.hashAlgorithm,
          iterations: credential.iterations,
          recoveryKeyHash: credential.recoveryKeyHash,
        ),
      );
    });
  }

  @override
  Future<void> updateUserStatus(UserId id, bool isActive) async {
    await (update(users)..where((u) => u.id.equals(id.value))).write(
      UsersCompanion(isActive: Value(isActive)),
    );
  }

  @override
  Future<void> updateUserRole(UserId id, String roleId) async {
    await (update(users)..where((u) => u.id.equals(id.value))).write(
      UsersCompanion(roleId: Value(roleId)),
    );
  }

  @override
  Future<void> updateUserCredential(
    UserId id,
    UserCredential credential,
  ) async {
    await (update(
      userCredentials,
    )..where((c) => c.userId.equals(id.value))).write(
      UserCredentialsCompanion(
        passwordHash: Value(credential.passwordHash),
        salt: Value(credential.salt),
        hashAlgorithm: Value(credential.hashAlgorithm),
        iterations: Value(credential.iterations),
        recoveryKeyHash: Value(credential.recoveryKeyHash),
      ),
    );
  }

  @override
  Future<Role?> getRoleById(String roleId) async {
    final row = await (select(
      roles,
    )..where((r) => r.id.equals(roleId))).getSingleOrNull();
    if (row == null) return null;
    final capList = (jsonDecode(row.capabilitiesJson) as List)
        .map((e) => Capability.fromIdentifier(e as String))
        .whereType<Capability>()
        .toSet();
    return Role(
      id: row.id,
      name: row.name,
      capabilities: capList,
      isSystem: row.isSystem,
    );
  }

  @override
  Future<List<Role>> getAllRoles() async {
    final rows = await select(roles).get();
    return rows.map((row) {
      final capList = (jsonDecode(row.capabilitiesJson) as List)
          .map((e) => Capability.fromIdentifier(e as String))
          .whereType<Capability>()
          .toSet();
      return Role(
        id: row.id,
        name: row.name,
        capabilities: capList,
        isSystem: row.isSystem,
      );
    }).toList();
  }

  @override
  Future<void> createRole(Role role) async {
    await into(roles).insert(
      RolesCompanion.insert(
        id: role.id,
        name: role.name,
        capabilitiesJson: jsonEncode(
          role.capabilities.map((c) => c.identifier).toList(),
        ),
        isSystem: Value(role.isSystem),
        createdAtUtcMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<void> saveSession(UserSession session) async {
    await into(sessions).insertOnConflictUpdate(
      SessionsCompanion.insert(
        id: session.id.value,
        userId: session.userId.value,
        username: session.username,
        roleId: session.roleId,
        branchId: session.branchId.value,
        token: session.token,
        expiresAtUtcMs: session.expiresAtUtc.millisecondsSinceEpoch,
        lastActivityUtcMs: session.lastActivityAtUtc.millisecondsSinceEpoch,
        isLocked: Value(session.isLocked),
        createdAtUtcMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<UserSession?> getSessionById(SessionId id) async {
    final row = await (select(
      sessions,
    )..where((s) => s.id.equals(id.value))).getSingleOrNull();
    if (row == null) return null;
    final role = await getRoleById(row.roleId) ?? Role.admin;
    return UserSession(
      id: SessionId(row.id),
      userId: UserId(row.userId),
      username: row.username,
      roleId: row.roleId,
      branchId: BranchId(row.branchId),
      capabilities: role.capabilities,
      token: row.token,
      expiresAtUtc: _fromEpoch(row.expiresAtUtcMs),
      lastActivityAtUtc: _fromEpoch(row.lastActivityUtcMs),
      isLocked: row.isLocked,
    );
  }

  @override
  Future<void> deleteSession(SessionId id) async {
    await (delete(sessions)..where((s) => s.id.equals(id.value))).go();
  }

  @override
  Future<LoginThrottleStatus> getThrottleStatus(
    String username,
    DateTime nowUtc,
  ) async {
    final row =
        await (select(loginAttempts)
              ..where((a) => a.username.equals(username.toLowerCase())))
            .getSingleOrNull();
    if (row == null) {
      return const LoginThrottleStatus(failedAttempts: 0, isLockedOut: false);
    }
    final lockedUntil = row.lockedUntilUtcMs != null
        ? _fromEpoch(row.lockedUntilUtcMs!)
        : null;
    final isLockedOut = lockedUntil != null && nowUtc.isBefore(lockedUntil);
    return LoginThrottleStatus(
      failedAttempts: row.failedAttempts,
      isLockedOut: isLockedOut,
      lockedUntilUtc: lockedUntil,
    );
  }

  @override
  Future<void> recordLoginAttempt(
    String username,
    bool success,
    DateTime nowUtc,
  ) async {
    final lowerUsername = username.toLowerCase();
    if (success) {
      await (delete(
        loginAttempts,
      )..where((a) => a.username.equals(lowerUsername))).go();
      return;
    }

    final current = await (select(
      loginAttempts,
    )..where((a) => a.username.equals(lowerUsername))).getSingleOrNull();
    final newCount = (current?.failedAttempts ?? 0) + 1;

    DateTime? lockedUntil;
    if (newCount >= 5) {
      // 15-minute lockout after 5 consecutive failures
      lockedUntil = nowUtc.add(const Duration(minutes: 15));
    }

    await into(loginAttempts).insertOnConflictUpdate(
      LoginAttemptsCompanion.insert(
        username: lowerUsername,
        failedAttempts: Value(newCount),
        lockedUntilUtcMs: Value(lockedUntil?.millisecondsSinceEpoch),
      ),
    );
  }

  // --- AuditStore implementation ---

  @override
  Future<void> appendAuditEvent(AuditEvent event) async {
    await into(auditEvents).insert(
      AuditEventsCompanion.insert(
        id: event.id.value,
        actorUserId: event.actorUserId.value,
        actorUsername: event.actorUsername,
        action: event.action,
        entityType: event.entityType,
        entityId: event.entityId,
        detailsJson: event.detailsJson,
        createdAtUtcMs: event.createdAtUtc.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<List<AuditEvent>> getAuditEvents({
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(auditEvents)
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.createdAtUtcMs, mode: OrderingMode.desc),
      ])
      ..limit(limit, offset: offset);
    final rows = await query.get();
    return rows
        .map(
          (r) => AuditEvent(
            id: AuditEventId(r.id),
            actorUserId: UserId(r.actorUserId),
            actorUsername: r.actorUsername,
            action: r.action,
            entityType: r.entityType,
            entityId: r.entityId,
            detailsJson: r.detailsJson,
            createdAtUtc: _fromEpoch(r.createdAtUtcMs),
          ),
        )
        .toList();
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
  if (key.isNotEmpty) {
    try {
      final cipher = database.select('PRAGMA cipher;');
      if (cipher.isNotEmpty && cipher.first.values.firstOrNull != null) {
        final keyHex = key
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join();
        database.execute('PRAGMA key = "x\'$keyHex\'";');
      }
    } catch (_) {
      // PRAGMA cipher not present (standard normal SQLite)
    }
  }
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
    if (version < 1) {
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
