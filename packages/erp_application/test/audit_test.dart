import 'package:erp_application/erp_application.dart';
import 'package:test/test.dart';

void main() {
  group('AuditRedactor', () {
    test('redacts sensitive keys in map and nested objects', () {
      final input = {
        'username': 'admin',
        'password': 'secret_password_123',
        'recoveryKey': 'ABCD-EFGH-JKLM-NPQR',
        'nested': {
          'token': 'bearer-12345',
          'publicField': 'visible',
          'bank_account': '1234567890',
        },
      };

      final redacted = AuditRedactor.redactMap(input);

      expect(redacted['username'], equals('admin'));
      expect(redacted['password'], equals('[REDACTED]'));
      expect(redacted['recoveryKey'], equals('[REDACTED]'));
      expect((redacted['nested'] as Map)['token'], equals('[REDACTED]'));
      expect((redacted['nested'] as Map)['bank_account'], equals('[REDACTED]'));
      expect((redacted['nested'] as Map)['publicField'], equals('visible'));
    });
  });
}
