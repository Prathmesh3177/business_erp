import 'package:erp_domain/erp_domain.dart';

abstract interface class AttachmentStore {
  Future<void> saveAttachment(Attachment attachment);
  Future<Attachment?> getAttachmentByHash(String organizationId, String hash);
  Future<Attachment?> getAttachmentById(String id);
  Future<void> linkAttachment(AttachmentLink link);
  Future<List<Attachment>> getAttachmentsForEntity(String entityType, String entityId);
  Future<List<Attachment>> getOrphanedAttachments();
  Future<void> deleteAttachment(String id);
}
