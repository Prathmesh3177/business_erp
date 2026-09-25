import 'capabilities.dart';
import 'errors.dart';
import 'ids.dart';

final class UserId {
  const UserId(this.value);
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

final class SessionId {
  const SessionId(this.value);
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

final class User {
  const User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.roleId,
    required this.isActive,
    required this.createdAtUtc,
  });

  final UserId id;
  final String username;
  final String fullName;
  final String roleId;
  final bool isActive;
  final DateTime createdAtUtc;

  User copyWith({String? fullName, String? roleId, bool? isActive}) {
    return User(
      id: id,
      username: username,
      fullName: fullName ?? this.fullName,
      roleId: roleId ?? this.roleId,
      isActive: isActive ?? this.isActive,
      createdAtUtc: createdAtUtc,
    );
  }

  static String normalizeUsername(String raw) {
    final trimmed = raw.trim().toLowerCase();
    if (trimmed.length < 3 || !RegExp(r'^[a-z0-9_]+$').hasMatch(trimmed)) {
      throw const ValidationFailure(
        'user.invalid_username',
        'Username must be at least 3 characters and contain only lowercase letters, numbers, and underscores.',
      );
    }
    return trimmed;
  }

  static void validatePassword(String password) {
    if (password.length < 8) {
      throw const ValidationFailure(
        'user.password_too_short',
        'Password must be at least 8 characters long.',
      );
    }
  }

  static void validateLastAdminSafeguard({
    required UserId targetUserId,
    required List<User> allUsers,
    required bool newIsActiveStatus,
    required String newRoleId,
  }) {
    final targetUser = allUsers.firstWhere(
      (u) => u.id == targetUserId,
      orElse: () =>
          throw const ValidationFailure('user.not_found', 'User not found.'),
    );

    // If target was admin and is being deactivated or role changed away from admin:
    if (targetUser.roleId == Role.adminRoleId) {
      final activeAdminCount = allUsers
          .where((u) => u.isActive && u.roleId == Role.adminRoleId)
          .length;

      final isDisabling = !newIsActiveStatus;
      final isChangingRole = newRoleId != Role.adminRoleId;

      if ((isDisabling || isChangingRole) && activeAdminCount <= 1) {
        throw const ConflictFailure(
          'user.last_admin_protected',
          'Cannot deactivate or remove admin rights from the last active Administrator.',
        );
      }
    }
  }
}

final class UserCredential {
  const UserCredential({
    required this.userId,
    required this.passwordHash,
    required this.salt,
    required this.hashAlgorithm,
    required this.iterations,
    required this.recoveryKeyHash,
  });

  final UserId userId;
  final String passwordHash;
  final String salt;
  final String hashAlgorithm;
  final int iterations;
  final String recoveryKeyHash;
}

final class UserSession {
  const UserSession({
    required this.id,
    required this.userId,
    required this.username,
    required this.roleId,
    required this.branchId,
    required this.capabilities,
    required this.token,
    required this.expiresAtUtc,
    required this.lastActivityAtUtc,
    this.isLocked = false,
  });

  final SessionId id;
  final UserId userId;
  final String username;
  final String roleId;
  final BranchId branchId;
  final Set<Capability> capabilities;
  final String token;
  final DateTime expiresAtUtc;
  final DateTime lastActivityAtUtc;
  final bool isLocked;

  bool hasCapability(Capability capability) =>
      capabilities.contains(capability);

  bool isExpired(DateTime nowUtc) => nowUtc.isAfter(expiresAtUtc);

  UserSession copyWith({
    DateTime? expiresAtUtc,
    DateTime? lastActivityAtUtc,
    bool? isLocked,
  }) {
    return UserSession(
      id: id,
      userId: userId,
      username: username,
      roleId: roleId,
      branchId: branchId,
      capabilities: capabilities,
      token: token,
      expiresAtUtc: expiresAtUtc ?? this.expiresAtUtc,
      lastActivityAtUtc: lastActivityAtUtc ?? this.lastActivityAtUtc,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
