import 'package:erp_platform/erp_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlatformPasswordHasher', () {
    const hasher = PlatformPasswordHasher();

    test('generates random salt and hashes password deterministically', () {
      final salt = hasher.generateSalt();
      expect(salt, isNotEmpty);

      final hash1 = hasher.hashPassword(password: 'Secret123!', salt: salt);
      final hash2 = hasher.hashPassword(password: 'Secret123!', salt: salt);
      final hash3 = hasher.hashPassword(password: 'DifferentPass', salt: salt);

      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals(hash3)));
    });

    test('generates formatted recovery key and computes hash', () {
      final key = hasher.generateRecoveryKey();
      expect(
        key,
        matches(RegExp(r'^[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}$')),
      );

      final hash1 = hasher.hashRecoveryKey(key);
      final hash2 = hasher.hashRecoveryKey(
        key.toLowerCase(),
      ); // Case insensitive

      expect(hash1, equals(hash2));
    });
  });
}
