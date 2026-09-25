import 'user.dart';

final class AuditEventId {
  const AuditEventId(this.value);
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditEventId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

final class AuditEvent {
  const AuditEvent({
    required this.id,
    required this.actorUserId,
    required this.actorUsername,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.detailsJson,
    required this.createdAtUtc,
  });

  final AuditEventId id;
  final UserId actorUserId;
  final String actorUsername;
  final String action;
  final String entityType;
  final String entityId;
  final String detailsJson;
  final DateTime createdAtUtc;
}
