import 'package:erp_domain/erp_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap.dart';

final authProvider = NotifierProvider<AuthController, UserSession?>(
  AuthController.new,
);

final class AuthController extends Notifier<UserSession?> {
  @override
  UserSession? build() => null;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final runtime = ref.read(runtimeProvider).value;
    if (runtime == null || runtime.identity == null) {
      throw StateError('System runtime or branch identity not initialized.');
    }

    final session = await runtime.authenticateUser.call(
      username: username,
      password: password,
      branchId: runtime.identity!.branch.id,
    );

    state = session;
  }

  void lockSession() {
    if (state != null) {
      state = state!.copyWith(isLocked: true);
    }
  }

  Future<void> unlockSession(String password) async {
    if (state == null) return;
    final runtime = ref.read(runtimeProvider).value;
    if (runtime == null) return;

    // Verify password for current user
    final cred = await runtime.database.getUserCredential(state!.userId);
    if (cred == null) {
      throw const AuthenticationFailure(
        'auth.invalid_user',
        'User credential missing.',
      );
    }

    final computedHash = runtime.passwordHasher.hashPassword(
      password: password,
      salt: cred.salt,
      iterations: cred.iterations,
    );

    if (computedHash != cred.passwordHash) {
      throw const AuthenticationFailure(
        'auth.invalid_password',
        'Incorrect unlock password.',
      );
    }

    state = state!.copyWith(isLocked: false);
  }

  Future<void> logout() async {
    if (state != null) {
      final runtime = ref.read(runtimeProvider).value;
      if (runtime != null) {
        await runtime.database.deleteSession(state!.id);
      }
    }
    state = null;
  }
}
