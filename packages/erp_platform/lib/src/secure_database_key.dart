import 'dart:convert';
import 'dart:math';

import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class PlatformDatabaseKeyVault implements DatabaseKeyVault {
  const PlatformDatabaseKeyVault({this.storage = const FlutterSecureStorage()});

  static const _entry = 'solar_shop_erp_database_key_v1';
  final FlutterSecureStorage storage;

  @override
  Future<List<int>?> readDatabaseKey() async {
    try {
      final encoded = await storage.read(key: _entry);
      if (encoded == null) return null;
      final key = base64Url.decode(encoded);
      if (key.length != 32) {
        throw const SecurityFailure(
          'vault.invalid_database_key',
          'The protected database key is invalid.',
        );
      }
      return key;
    } catch (error) {
      if (error is ErpFailure) rethrow;
      throw const SecurityFailure(
        'vault.read_failed',
        'The protected database key could not be read.',
      );
    }
  }

  @override
  Future<void> writeDatabaseKey(List<int> key) async {
    if (key.length != 32) {
      throw const SecurityFailure(
        'vault.invalid_database_key',
        'The protected database key is invalid.',
      );
    }
    try {
      await storage.write(key: _entry, value: base64UrlEncode(key));
    } catch (_) {
      throw const SecurityFailure(
        'vault.write_failed',
        'The database key could not be protected by this device.',
      );
    }
  }
}

final class PlatformSecureRandom implements SecureRandomBytes {
  PlatformSecureRandom() : _random = Random.secure();

  final Random _random;

  @override
  List<int> nextBytes(int length) =>
      List<int>.generate(length, (_) => _random.nextInt(256));
}

final class DatabaseKeyProvisioner {
  const DatabaseKeyProvisioner({required this.vault, required this.random});

  final DatabaseKeyVault vault;
  final SecureRandomBytes random;

  Future<List<int>> loadOrCreate({required bool databaseExists}) async {
    final existing = await vault.readDatabaseKey();
    if (existing != null) return existing;
    if (databaseExists) {
      throw const SecurityFailure(
        'vault.database_key_missing',
        'The existing database key is unavailable. Use a verified recovery copy.',
      );
    }
    final key = random.nextBytes(32);
    await vault.writeDatabaseKey(key);
    final verified = await vault.readDatabaseKey();
    if (verified == null || !_constantTimeEquals(key, verified)) {
      throw const SecurityFailure(
        'vault.verification_failed',
        'The database key could not be verified after secure storage.',
      );
    }
    return verified;
  }
}

bool _constantTimeEquals(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  var difference = 0;
  for (var index = 0; index < left.length; index++) {
    difference |= left[index] ^ right[index];
  }
  return difference == 0;
}
