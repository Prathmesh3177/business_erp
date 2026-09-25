import 'package:erp_domain/erp_domain.dart';

final class LoginThrottleStatus {
  const LoginThrottleStatus({
    required this.failedAttempts,
    required this.isLockedOut,
    this.lockedUntilUtc,
  });

  final int failedAttempts;
  final bool isLockedOut;
  final DateTime? lockedUntilUtc;
}

abstract interface class IdentityStore {
  Future<User?> getUserByUsername(String username);
  Future<User?> getUserById(UserId id);
  Future<UserCredential?> getUserCredential(UserId id);
  Future<List<User>> getAllUsers();

  Future<void> createUser(User user, UserCredential credential);
  Future<void> updateUserStatus(UserId id, bool isActive);
  Future<void> updateUserRole(UserId id, String roleId);
  Future<void> updateUserCredential(UserId id, UserCredential credential);

  Future<Role?> getRoleById(String roleId);
  Future<List<Role>> getAllRoles();
  Future<void> createRole(Role role);

  Future<void> saveSession(UserSession session);
  Future<UserSession?> getSessionById(SessionId id);
  Future<void> deleteSession(SessionId id);

  Future<LoginThrottleStatus> getThrottleStatus(
    String username,
    DateTime nowUtc,
  );
  Future<void> recordLoginAttempt(
    String username,
    bool success,
    DateTime nowUtc,
  );
}
