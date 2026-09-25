abstract interface class PasswordHasher {
  String hashPassword({
    required String password,
    required String salt,
    int iterations = 100000,
  });

  String hashRecoveryKey(String recoveryKey);

  String generateSalt({int byteLength = 16});

  String generateRecoveryKey();
}
