import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:erp_application/erp_application.dart';

final class PlatformPasswordHasher implements PasswordHasher {
  const PlatformPasswordHasher();

  @override
  String hashPassword({
    required String password,
    required String salt,
    int iterations = 100000,
  }) {
    final saltBytes = utf8.encode(salt);
    final passwordBytes = utf8.encode(password);

    // PBKDF2-HMAC-SHA256 implementation using standard Dart crypto package
    final hmac = Hmac(sha256, passwordBytes);
    var block = Uint8List.fromList([...saltBytes, 0, 0, 0, 1]);
    var u = hmac.convert(block).bytes;
    var result = Uint8List.fromList(u);

    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    return base64UrlEncode(result);
  }

  @override
  String hashRecoveryKey(String recoveryKey) {
    final bytes = utf8.encode(recoveryKey.trim().toUpperCase());
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  String generateSalt({int byteLength = 16}) {
    final random = Random.secure();
    final values = List<int>.generate(byteLength, (_) => random.nextInt(256));
    return base64UrlEncode(values);
  }

  @override
  String generateRecoveryKey() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No O, 0, 1, I confusion
    final random = Random.secure();
    final parts = <String>[];
    for (var i = 0; i < 4; i++) {
      final chunk = String.fromCharCodes(
        Iterable.generate(
          4,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
        ),
      );
      parts.add(chunk);
    }
    return parts.join('-');
  }
}
