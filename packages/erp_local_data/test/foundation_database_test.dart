import 'dart:io';

import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:erp_local_data/erp_local_data.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  final key = List<int>.generate(32, (index) => index + 1);

  test('encrypted identity persists across a real database restart', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-db-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}foundation.db',
    );
    var database = FoundationDatabase.open(file: file, key: key);
    final expected = await _initialize(database);
    await database.close();

    database = FoundationDatabase.open(file: file, key: key);
    final actual = await database.loadIdentity();
    expect(actual?.organization.id.value, expected.organization.id.value);
    expect(actual?.branch.name, 'Main Branch');
    await database.close();

    final bytes = file.readAsBytesSync();
    expect(String.fromCharCodes(bytes), isNot(contains('Solar Shop Private')));
  });

  test('wrong database key fails closed', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-key-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}foundation.db',
    );
    final database = FoundationDatabase.open(file: file, key: key);
    await _initialize(database);
    await database.close();

    final wrong = FoundationDatabase.open(
      file: file,
      key: List<int>.filled(32, 99),
    );
    await expectLater(wrong.loadIdentity(), throwsA(anything));
    await wrong.close();
  });

  test('unit of work rolls all setup rows back on failure', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-uow-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final database = FoundationDatabase.open(
      file: File('${directory.path}${Platform.pathSeparator}foundation.db'),
      key: key,
    );
    final identity = _identity();
    await expectLater(
      database.inTransaction<void>((transaction) async {
        await transaction.insertIdentity(identity);
        throw StateError('deliberate failure');
      }),
      throwsStateError,
    );
    expect(await database.loadIdentity(), isNull);
    await database.close();
  });

  test('schema v0 upgrades to v1 and creates constrained tables', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-migrate-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}foundation.db',
    );
    final raw = sqlite3.open(file.path);
    _keyRaw(raw, key);
    raw.execute('CREATE TABLE legacy_marker(value TEXT NOT NULL);');
    raw.userVersion = 0;
    raw.close();

    final database = FoundationDatabase.open(file: file, key: key);
    expect(await database.loadIdentity(), isNull);
    await _initialize(database);
    expect(
      (await database.loadIdentity())?.branch.organizationId.value,
      'id-1',
    );
    await database.close();
  });

  test('consistent snapshot is encrypted and can be reopened', () async {
    final directory = Directory.systemTemp.createTempSync(
      'solar-erp-snapshot-',
    );
    addTearDown(() => directory.deleteSync(recursive: true));
    final database = FoundationDatabase.open(
      file: File('${directory.path}${Platform.pathSeparator}foundation.db'),
      key: key,
    );
    await _initialize(database);
    final snapshot = File(
      '${directory.path}${Platform.pathSeparator}snapshot.db',
    );
    await database.createVerifiedSnapshot(snapshot.path);
    await database.close();

    final restored = FoundationDatabase.open(file: snapshot, key: key);
    expect(
      (await restored.loadIdentity())?.organization.legalName,
      'Solar Shop Private',
    );
    await restored.close();
  });

  test('IdentityStore and AuditStore persist users, sessions, throttling and audit events', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-id-test-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}foundation.db',
    );
    final db = FoundationDatabase.open(file: file, key: key);

    // 1. Verify default roles seeded
    final roles = await db.getAllRoles();
    expect(roles.length, greaterThanOrEqualTo(2));
    expect(roles.any((r) => r.id == Role.adminRoleId), isTrue);
    expect(roles.any((r) => r.id == Role.counterRoleId), isTrue);

    // 2. Create user and credential
    final user = User(
      id: const UserId('u-101'),
      username: 'salesrep',
      fullName: 'Sales Person',
      roleId: Role.counterRoleId,
      isActive: true,
      createdAtUtc: DateTime.utc(2026, 9, 25),
    );
    final cred = const UserCredential(
      userId: UserId('u-101'),
      passwordHash: 'hash123',
      salt: 'salt123',
      hashAlgorithm: 'pbkdf2_sha256',
      iterations: 100000,
      recoveryKeyHash: 'rec123',
    );

    await db.createUser(user, cred);

    final fetched = await db.getUserByUsername('salesrep');
    expect(fetched?.fullName, equals('Sales Person'));
    expect(fetched?.roleId, equals(Role.counterRoleId));

    final fetchedCred = await db.getUserCredential(user.id);
    expect(fetchedCred?.passwordHash, equals('hash123'));

    // 3. Throttle recording
    final now = DateTime.utc(2026, 9, 25, 12);
    for (var i = 0; i < 5; i++) {
      await db.recordLoginAttempt('salesrep', false, now);
    }
    final status = await db.getThrottleStatus('salesrep', now);
    expect(status.isLockedOut, isTrue);

    await db.recordLoginAttempt('salesrep', true, now);
    final statusAfterSuccess = await db.getThrottleStatus('salesrep', now);
    expect(statusAfterSuccess.isLockedOut, isFalse);

    // 4. Audit Event logging
    final auditEvent = AuditEvent(
      id: const AuditEventId('aud-1'),
      actorUserId: user.id,
      actorUsername: user.username,
      action: 'user.created',
      entityType: 'User',
      entityId: user.id.value,
      detailsJson: '{"key":"value"}',
      createdAtUtc: now,
    );

    await db.appendAuditEvent(auditEvent);
    final auditLogs = await db.getAuditEvents();
    expect(auditLogs.length, equals(1));
    expect(auditLogs.first.action, equals('user.created'));

    await db.close();
  });
}

Future<FoundationIdentity> _initialize(FoundationStore store) {
  return InitializeFoundation(
    store: store,
    clock: _FixedClock(),
    ids: _SequenceIds(),
  ).call(
    FirstRunSetup.validate(
      legalName: 'Solar Shop Private',
      displayName: 'Solar Shop',
      branchName: 'Main Branch',
      timeZone: 'Asia/Kolkata',
      locale: 'en',
      financialYearStartsOn: DateTime.utc(2026, 4),
      financialYearEndsOn: DateTime.utc(2027, 3, 31),
    ),
  );
}

FoundationIdentity _identity() => FoundationIdentity(
  organization: Organization(
    id: const OrganizationId('rollback-org'),
    legalName: 'Rollback',
    displayName: 'Rollback',
    createdAtUtc: DateTime.utc(2026),
  ),
  branch: Branch(
    id: const BranchId('rollback-branch'),
    organizationId: const OrganizationId('rollback-org'),
    name: 'Rollback',
    timeZone: 'Asia/Kolkata',
    locale: 'en',
    createdAtUtc: DateTime.utc(2026),
  ),
  financialPeriod: FinancialPeriod(
    id: const FinancialPeriodId('rollback-period'),
    organizationId: const OrganizationId('rollback-org'),
    branchId: const BranchId('rollback-branch'),
    startsOn: DateTime.utc(2026, 4),
    endsOn: DateTime.utc(2027, 3, 31),
    createdAtUtc: DateTime.utc(2026),
  ),
);

void _keyRaw(Database database, List<int> key) {
  final hex = key.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  database.execute('PRAGMA key = "x\'$hex\'";');
}

final class _FixedClock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 9, 25, 12);
}

final class _SequenceIds implements IdGenerator {
  var _next = 0;

  @override
  String next() => 'id-${++_next}';
}
