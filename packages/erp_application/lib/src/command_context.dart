import 'package:erp_domain/erp_domain.dart';

final class CommandContext {
  const CommandContext({required this.session, required this.timestampUtc});

  final UserSession session;
  final DateTime timestampUtc;

  bool hasCapability(Capability capability) {
    if (session.isLocked || session.isExpired(timestampUtc)) {
      return false;
    }
    return session.hasCapability(capability);
  }

  void requireCapability(Capability capability) {
    if (session.isLocked) {
      throw const LockedFailure(
        'session.locked',
        'Session is locked. Unlock required.',
      );
    }
    if (session.isExpired(timestampUtc)) {
      throw const AuthenticationFailure(
        'session.expired',
        'Session has expired. Login required.',
      );
    }
    if (!session.hasCapability(capability)) {
      throw AuthorizationFailure(
        'authorization.denied',
        'Permission denied. Missing capability: ${capability.identifier}',
      );
    }
  }

  void requireAnyCapability(Set<Capability> capabilities) {
    if (session.isLocked) {
      throw const LockedFailure(
        'session.locked',
        'Session is locked. Unlock required.',
      );
    }
    if (session.isExpired(timestampUtc)) {
      throw const AuthenticationFailure(
        'session.expired',
        'Session has expired. Login required.',
      );
    }
    final hasAny = capabilities.any((c) => session.hasCapability(c));
    if (!hasAny) {
      throw AuthorizationFailure(
        'authorization.denied',
        'Permission denied. Required capabilities missing.',
      );
    }
  }
}
