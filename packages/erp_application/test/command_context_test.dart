import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('CommandContext Authorization', () {
    final now = DateTime.now();
    final counterSession = UserSession(
      id: const SessionId('sess-1'),
      userId: const UserId('user-counter'),
      username: 'cashier',
      roleId: Role.counterRoleId,
      branchId: const BranchId('branch-1'),
      capabilities: Role.counter.capabilities,
      token: 'tok-1',
      expiresAtUtc: now.add(const Duration(hours: 1)),
      lastActivityAtUtc: now,
    );

    test('permits allowed capabilities for counter session', () {
      final context = CommandContext(
        session: counterSession,
        timestampUtc: now,
      );
      expect(
        () => context.requireCapability(Capability.salesCreate),
        returnsNormally,
      );
    });

    test('T08: denies unauthorized direct command capability access', () {
      final context = CommandContext(
        session: counterSession,
        timestampUtc: now,
      );
      expect(
        () => context.requireCapability(Capability.costDataRead),
        throwsA(isA<AuthorizationFailure>()),
      );
      expect(
        () => context.requireCapability(Capability.userManage),
        throwsA(isA<AuthorizationFailure>()),
      );
    });

    test('denies execution when session is locked', () {
      final lockedSession = counterSession.copyWith(isLocked: true);
      final context = CommandContext(session: lockedSession, timestampUtc: now);
      expect(
        () => context.requireCapability(Capability.salesCreate),
        throwsA(isA<LockedFailure>()),
      );
    });

    test('denies execution when session is expired', () {
      final expiredContext = CommandContext(
        session: counterSession,
        timestampUtc: now.add(const Duration(hours: 2)),
      );
      expect(
        () => expiredContext.requireCapability(Capability.salesCreate),
        throwsA(isA<AuthenticationFailure>()),
      );
    });
  });
}
