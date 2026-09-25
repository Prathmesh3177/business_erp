sealed class ErpFailure implements Exception {
  const ErpFailure(this.code, this.safeMessage, {this.retryable = false});

  final String code;
  final String safeMessage;
  final bool retryable;

  @override
  String toString() => '$runtimeType($code)';
}

final class ValidationFailure extends ErpFailure {
  const ValidationFailure(super.code, super.safeMessage);
}

final class ConflictFailure extends ErpFailure {
  const ConflictFailure(super.code, super.safeMessage);
}

final class StorageFailure extends ErpFailure {
  const StorageFailure(super.code, super.safeMessage, {super.retryable});
}

final class SecurityFailure extends ErpFailure {
  const SecurityFailure(super.code, super.safeMessage);
}

final class AuthenticationFailure extends ErpFailure {
  const AuthenticationFailure(super.code, super.safeMessage);
}

final class AuthorizationFailure extends ErpFailure {
  const AuthorizationFailure(super.code, super.safeMessage);
}

final class LockedFailure extends ErpFailure {
  const LockedFailure(super.code, super.safeMessage, {super.retryable});
}
