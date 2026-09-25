import 'dart:convert';

import 'package:erp_domain/erp_domain.dart';

import 'audit_logger.dart';
import 'command_context.dart';
import 'identity_store.dart';
import 'password_hasher.dart';

final class AuthenticateUser {
  const AuthenticateUser({
    required this.identityStore,
    required this.passwordHasher,
    required this.auditStore,
    required this.clock,
    required this.idGenerator,
  });

  final IdentityStore identityStore;
  final PasswordHasher passwordHasher;
  final AuditStore auditStore;
  final Clock clock;
  final IdGenerator idGenerator;

  Future<UserSession> call({
    required String username,
    required String password,
    required BranchId branchId,
  }) async {
    final now = clock.nowUtc();
    final normalizedUsername = User.normalizeUsername(username);

    // 1. Throttling check
    final throttle = await identityStore.getThrottleStatus(
      normalizedUsername,
      now,
    );
    if (throttle.isLockedOut) {
      throw LockedFailure(
        'auth.too_many_attempts',
        'Account is temporarily locked due to multiple failed login attempts. Try again later.',
      );
    }

    // 2. Fetch user
    final user = await identityStore.getUserByUsername(normalizedUsername);
    if (user == null || !user.isActive) {
      await identityStore.recordLoginAttempt(normalizedUsername, false, now);
      throw const AuthenticationFailure(
        'auth.invalid_credentials',
        'Invalid username or password.',
      );
    }

    // 3. Fetch credential & verify password
    final credential = await identityStore.getUserCredential(user.id);
    if (credential == null) {
      await identityStore.recordLoginAttempt(normalizedUsername, false, now);
      throw const AuthenticationFailure(
        'auth.invalid_credentials',
        'Invalid username or password.',
      );
    }

    final computedHash = passwordHasher.hashPassword(
      password: password,
      salt: credential.salt,
      iterations: credential.iterations,
    );

    if (computedHash != credential.passwordHash) {
      await identityStore.recordLoginAttempt(normalizedUsername, false, now);
      throw const AuthenticationFailure(
        'auth.invalid_credentials',
        'Invalid username or password.',
      );
    }

    // 4. Success -> Clear throttle, get role capabilities, build session
    await identityStore.recordLoginAttempt(normalizedUsername, true, now);
    final role = await identityStore.getRoleById(user.roleId) ?? Role.admin;

    final session = UserSession(
      id: SessionId(idGenerator.next()),
      userId: user.id,
      username: user.username,
      roleId: user.roleId,
      branchId: branchId,
      capabilities: role.capabilities,
      token: idGenerator.next(),
      expiresAtUtc: now.add(const Duration(hours: 12)),
      lastActivityAtUtc: now,
      isLocked: false,
    );

    await identityStore.saveSession(session);

    // 5. Append audit event
    await auditStore.appendAuditEvent(
      AuditEvent(
        id: AuditEventId(idGenerator.next()),
        actorUserId: user.id,
        actorUsername: user.username,
        action: 'user.login',
        entityType: 'UserSession',
        entityId: session.id.value,
        detailsJson: jsonEncode(
          AuditRedactor.redactMap({
            'username': user.username,
            'branchId': branchId.value,
          }),
        ),
        createdAtUtc: now,
      ),
    );

    return session;
  }
}

final class CreateFirstAdmin {
  const CreateFirstAdmin({
    required this.identityStore,
    required this.passwordHasher,
    required this.auditStore,
    required this.clock,
    required this.idGenerator,
  });

  final IdentityStore identityStore;
  final PasswordHasher passwordHasher;
  final AuditStore auditStore;
  final Clock clock;
  final IdGenerator idGenerator;

  Future<String> call({
    required String username,
    required String fullName,
    required String password,
  }) async {
    final now = clock.nowUtc();
    final normalizedUsername = User.normalizeUsername(username);
    User.validatePassword(password);

    final existing = await identityStore.getUserByUsername(normalizedUsername);
    if (existing != null) {
      throw const ConflictFailure(
        'user.username_exists',
        'Username already exists.',
      );
    }

    final userId = UserId(idGenerator.next());
    final salt = passwordHasher.generateSalt();
    final recoveryKey = passwordHasher.generateRecoveryKey();
    final passwordHash = passwordHasher.hashPassword(
      password: password,
      salt: salt,
    );
    final recoveryKeyHash = passwordHasher.hashRecoveryKey(recoveryKey);

    final adminUser = User(
      id: userId,
      username: normalizedUsername,
      fullName: fullName.trim(),
      roleId: Role.adminRoleId,
      isActive: true,
      createdAtUtc: now,
    );

    final credential = UserCredential(
      userId: userId,
      passwordHash: passwordHash,
      salt: salt,
      hashAlgorithm: 'pbkdf2_sha256',
      iterations: 100000,
      recoveryKeyHash: recoveryKeyHash,
    );

    await identityStore.createUser(adminUser, credential);

    await auditStore.appendAuditEvent(
      AuditEvent(
        id: AuditEventId(idGenerator.next()),
        actorUserId: userId,
        actorUsername: normalizedUsername,
        action: 'user.first_admin_created',
        entityType: 'User',
        entityId: userId.value,
        detailsJson: jsonEncode(
          AuditRedactor.redactMap({
            'username': normalizedUsername,
            'fullName': fullName,
            'roleId': Role.adminRoleId,
          }),
        ),
        createdAtUtc: now,
      ),
    );

    return recoveryKey;
  }
}

final class CreateUserUseCase {
  const CreateUserUseCase({
    required this.identityStore,
    required this.passwordHasher,
    required this.auditStore,
    required this.clock,
    required this.idGenerator,
  });

  final IdentityStore identityStore;
  final PasswordHasher passwordHasher;
  final AuditStore auditStore;
  final Clock clock;
  final IdGenerator idGenerator;

  Future<User> call({
    required CommandContext context,
    required String username,
    required String fullName,
    required String password,
    required String roleId,
  }) async {
    context.requireCapability(Capability.userManage);
    final now = clock.nowUtc();
    final normalizedUsername = User.normalizeUsername(username);
    User.validatePassword(password);

    final existing = await identityStore.getUserByUsername(normalizedUsername);
    if (existing != null) {
      throw const ConflictFailure(
        'user.username_exists',
        'Username already exists.',
      );
    }

    final role = await identityStore.getRoleById(roleId);
    if (role == null) {
      throw const ValidationFailure(
        'user.invalid_role',
        'Selected role does not exist.',
      );
    }

    final userId = UserId(idGenerator.next());
    final salt = passwordHasher.generateSalt();
    final recoveryKey = passwordHasher.generateRecoveryKey();
    final passwordHash = passwordHasher.hashPassword(
      password: password,
      salt: salt,
    );
    final recoveryKeyHash = passwordHasher.hashRecoveryKey(recoveryKey);

    final newUser = User(
      id: userId,
      username: normalizedUsername,
      fullName: fullName.trim(),
      roleId: roleId,
      isActive: true,
      createdAtUtc: now,
    );

    final credential = UserCredential(
      userId: userId,
      passwordHash: passwordHash,
      salt: salt,
      hashAlgorithm: 'pbkdf2_sha256',
      iterations: 100000,
      recoveryKeyHash: recoveryKeyHash,
    );

    await identityStore.createUser(newUser, credential);

    await auditStore.appendAuditEvent(
      AuditEvent(
        id: AuditEventId(idGenerator.next()),
        actorUserId: context.session.userId,
        actorUsername: context.session.username,
        action: 'user.created',
        entityType: 'User',
        entityId: userId.value,
        detailsJson: jsonEncode(
          AuditRedactor.redactMap({
            'username': normalizedUsername,
            'fullName': fullName,
            'roleId': roleId,
          }),
        ),
        createdAtUtc: now,
      ),
    );

    return newUser;
  }
}

final class ToggleUserStatusUseCase {
  const ToggleUserStatusUseCase({
    required this.identityStore,
    required this.auditStore,
    required this.clock,
    required this.idGenerator,
  });

  final IdentityStore identityStore;
  final AuditStore auditStore;
  final Clock clock;
  final IdGenerator idGenerator;

  Future<void> call({
    required CommandContext context,
    required UserId targetUserId,
    required bool newIsActiveStatus,
  }) async {
    context.requireCapability(Capability.userManage);
    final now = clock.nowUtc();

    final allUsers = await identityStore.getAllUsers();
    final targetUser = allUsers.firstWhere(
      (u) => u.id == targetUserId,
      orElse: () => throw const ValidationFailure(
        'user.not_found',
        'Target user not found.',
      ),
    );

    User.validateLastAdminSafeguard(
      targetUserId: targetUserId,
      allUsers: allUsers,
      newIsActiveStatus: newIsActiveStatus,
      newRoleId: targetUser.roleId,
    );

    await identityStore.updateUserStatus(targetUserId, newIsActiveStatus);

    await auditStore.appendAuditEvent(
      AuditEvent(
        id: AuditEventId(idGenerator.next()),
        actorUserId: context.session.userId,
        actorUsername: context.session.username,
        action: 'user.status_toggled',
        entityType: 'User',
        entityId: targetUserId.value,
        detailsJson: jsonEncode(
          AuditRedactor.redactMap({
            'targetUsername': targetUser.username,
            'isActive': newIsActiveStatus,
          }),
        ),
        createdAtUtc: now,
      ),
    );
  }
}

final class ResetAdminPasswordWithRecoveryKey {
  const ResetAdminPasswordWithRecoveryKey({
    required this.identityStore,
    required this.passwordHasher,
    required this.auditStore,
    required this.clock,
    required this.idGenerator,
  });

  final IdentityStore identityStore;
  final PasswordHasher passwordHasher;
  final AuditStore auditStore;
  final Clock clock;
  final IdGenerator idGenerator;

  Future<void> call({
    required String username,
    required String recoveryKey,
    required String newPassword,
  }) async {
    final now = clock.nowUtc();
    final normalizedUsername = User.normalizeUsername(username);
    User.validatePassword(newPassword);

    final user = await identityStore.getUserByUsername(normalizedUsername);
    if (user == null) {
      throw const ValidationFailure(
        'recovery.user_not_found',
        'User not found.',
      );
    }

    final credential = await identityStore.getUserCredential(user.id);
    if (credential == null) {
      throw const ValidationFailure(
        'recovery.invalid_key',
        'Invalid recovery key.',
      );
    }

    final computedKeyHash = passwordHasher.hashRecoveryKey(recoveryKey.trim());
    if (computedKeyHash != credential.recoveryKeyHash) {
      throw const ValidationFailure(
        'recovery.invalid_key',
        'Invalid recovery key.',
      );
    }

    final newSalt = passwordHasher.generateSalt();
    final newPasswordHash = passwordHasher.hashPassword(
      password: newPassword,
      salt: newSalt,
    );

    final updatedCredential = UserCredential(
      userId: user.id,
      passwordHash: newPasswordHash,
      salt: newSalt,
      hashAlgorithm: 'pbkdf2_sha256',
      iterations: 100000,
      recoveryKeyHash: credential.recoveryKeyHash,
    );

    await identityStore.updateUserCredential(user.id, updatedCredential);

    await auditStore.appendAuditEvent(
      AuditEvent(
        id: AuditEventId(idGenerator.next()),
        actorUserId: user.id,
        actorUsername: user.username,
        action: 'user.password_reset_recovery_key',
        entityType: 'User',
        entityId: user.id.value,
        detailsJson: jsonEncode(
          AuditRedactor.redactMap({'username': user.username}),
        ),
        createdAtUtc: now,
      ),
    );
  }
}
