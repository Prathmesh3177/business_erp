import 'dart:convert';

import 'package:erp_domain/erp_domain.dart';

abstract interface class AuditStore {
  Future<void> appendAuditEvent(AuditEvent event);
  Future<List<AuditEvent>> getAuditEvents({int limit = 100, int offset = 0});
}

final class AuditRedactor {
  static const _sensitiveKeys = {
    'password',
    'password_hash',
    'passwordhash',
    'recovery_key',
    'recoverykey',
    'recoverykeyhash',
    'token',
    'secret',
    'pan',
    'bank_account',
    'account_number',
    'cvv',
  };

  static Map<String, dynamic> redactMap(Map<String, dynamic> input) {
    final result = <String, dynamic>{};
    for (final entry in input.entries) {
      final keyLower = entry.key.toLowerCase();
      if (_sensitiveKeys.contains(keyLower)) {
        result[entry.key] = '[REDACTED]';
      } else if (entry.value is Map<String, dynamic>) {
        result[entry.key] = redactMap(entry.value as Map<String, dynamic>);
      } else if (entry.value is List) {
        result[entry.key] = (entry.value as List).map((item) {
          if (item is Map<String, dynamic>) {
            return redactMap(item);
          }
          return item;
        }).toList();
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  static String redactJsonString(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) {
        return jsonEncode(redactMap(decoded));
      }
      return rawJson;
    } catch (_) {
      return '[INVALID_JSON]';
    }
  }
}
