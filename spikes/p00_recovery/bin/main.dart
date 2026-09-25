import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

Future<void> main() async {
  const passphrase = 'correct horse battery staple';
  final random = Random.secure();
  final salt = List<int>.generate(16, (_) => random.nextInt(256));
  final databaseKey = List<int>.generate(32, (_) => random.nextInt(256));
  final kdf = Argon2id(
    parallelism: 1,
    memory: 19456,
    iterations: 2,
    hashLength: 32,
  );
  final cipher = AesGcm.with256bits();
  final wrappingKey = await kdf.deriveKeyFromPassword(
    password: passphrase,
    nonce: salt,
  );
  final wrapped = await cipher.encrypt(databaseKey, secretKey: wrappingKey);
  final archive = jsonEncode({
    'format': 1,
    'kdf': 'argon2id',
    'memoryKiB': 19456,
    'iterations': 2,
    'parallelism': 1,
    'salt': base64Encode(salt),
    'cipher': 'aes-256-gcm',
    'wrappedKey': base64Encode(wrapped.concatenation()),
  });
  final decoded = jsonDecode(archive) as Map<String, dynamic>;
  final recoverySalt = base64Decode(decoded['salt'] as String);
  final recoveryBox = SecretBox.fromConcatenation(
    base64Decode(decoded['wrappedKey'] as String),
    nonceLength: cipher.nonceLength,
    macLength: cipher.macAlgorithm.macLength,
  );
  final recovered = await cipher.decrypt(
    recoveryBox,
    secretKey: await kdf.deriveKeyFromPassword(
      password: passphrase,
      nonce: recoverySalt,
    ),
  );
  var wrongPassphraseRejected = false;
  try {
    await cipher.decrypt(
      recoveryBox,
      secretKey: await kdf.deriveKeyFromPassword(
        password: 'incorrect passphrase',
        nonce: recoverySalt,
      ),
    );
  } on SecretBoxAuthenticationError {
    wrongPassphraseRejected = true;
  }
  if (!_equalBytes(databaseKey, recovered) || !wrongPassphraseRejected) {
    throw StateError('portable recovery acceptance checks failed');
  }
  print('PASS portable_archive_round_trip=true');
  print('PASS wrong_passphrase_rejected=$wrongPassphraseRejected');
  print(
    'PASS archive_contains_plaintext_database_key='
    '${archive.contains(base64Encode(databaseKey))}',
  );
}

bool _equalBytes(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var difference = 0;
  for (var i = 0; i < a.length; i++) {
    difference |= a[i] ^ b[i];
  }
  return difference == 0;
}
