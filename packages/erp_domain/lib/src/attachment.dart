import 'errors.dart';

enum AttachmentStatus { active, orphaned }

final class Attachment {
  Attachment({
    required this.id,
    required this.organizationId,
    required this.fileName,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.sha256Hash,
    required this.storagePath,
    this.status = AttachmentStatus.active,
    required this.createdAt,
  }) {
    if (fileSizeBytes <= 0) {
      throw const ValidationFailure('invalid_size', 'Attachment file size must be greater than 0');
    }
    if (fileSizeBytes > maxSizeBytes) {
      throw const ValidationFailure('size_limit_exceeded', 'Attachment size exceeds 10MB limit');
    }
    if (!allowedMimeTypes.contains(mimeType.toLowerCase())) {
      throw ValidationFailure('unsupported_type', 'Unsupported attachment file type: $mimeType. Allowed: JPEG, PNG, WEBP, PDF.');
    }
  }

  final String id;
  final String organizationId;
  final String fileName;
  final String mimeType;
  final int fileSizeBytes;
  final String sha256Hash;
  final String storagePath;
  final AttachmentStatus status;
  final DateTime createdAt;

  static const int maxSizeBytes = 10 * 1024 * 1024; // 10 MB
  static const Set<String> allowedMimeTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
    'application/pdf',
  };
}

final class AttachmentLink {
  const AttachmentLink({
    required this.id,
    required this.attachmentId,
    required this.entityType, // "product", "party"
    required this.entityId,
    this.linkType = 'document',
    required this.createdAt,
  });

  final String id;
  final String attachmentId;
  final String entityType;
  final String entityId;
  final String linkType;
  final DateTime createdAt;
}
