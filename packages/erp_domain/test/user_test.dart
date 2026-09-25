import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('User & Security Invariants', () {
    test('normalizes username and rejects invalid characters', () {
      expect(User.normalizeUsername('  Admin_01 '), equals('admin_01'));
      expect(
        () => User.normalizeUsername('ab'),
        throwsA(isA<ValidationFailure>()),
      );
      expect(
        () => User.normalizeUsername('user@domain'),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('validates password length', () {
      expect(
        () => User.validatePassword('short'),
        throwsA(isA<ValidationFailure>()),
      );
      expect(() => User.validatePassword('valid_pass_123'), returnsNormally);
    });

    test('last administrator safeguard blocks deactivating last admin', () {
      final admin1 = User(
        id: const UserId('user-1'),
        username: 'admin1',
        fullName: 'Admin One',
        roleId: Role.adminRoleId,
        isActive: true,
        createdAtUtc: DateTime.now(),
      );

      final users = [admin1];

      // Deactivating last admin must throw ConflictFailure
      expect(
        () => User.validateLastAdminSafeguard(
          targetUserId: admin1.id,
          allUsers: users,
          newIsActiveStatus: false,
          newRoleId: Role.adminRoleId,
        ),
        throwsA(isA<ConflictFailure>()),
      );

      // Changing role of last admin must throw ConflictFailure
      expect(
        () => User.validateLastAdminSafeguard(
          targetUserId: admin1.id,
          allUsers: users,
          newIsActiveStatus: true,
          newRoleId: Role.counterRoleId,
        ),
        throwsA(isA<ConflictFailure>()),
      );
    });

    test('capabilities check works correctly', () {
      expect(Role.admin.hasCapability(Capability.userManage), isTrue);
      expect(Role.admin.hasCapability(Capability.costDataRead), isTrue);

      expect(Role.counter.hasCapability(Capability.salesCreate), isTrue);
      expect(Role.counter.hasCapability(Capability.costDataRead), isFalse);
    });
  });
}
