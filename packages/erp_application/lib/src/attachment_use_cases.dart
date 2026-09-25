import 'package:erp_domain/erp_domain.dart';

import 'attachment_store.dart';
import 'command_context.dart';

final class UploadAttachmentUseCase {
  const UploadAttachmentUseCase(this._attachmentStore);

  final AttachmentStore _attachmentStore;

  Future<Attachment> execute(
    CommandContext context, {
    required String organizationId,
    required String fileName,
    required String mimeType,
    required int fileSizeBytes,
    required String sha256Hash,
    required String storagePath,
    required String entityType,
    required String entityId,
  }) async {
    context.requireCapability(Capability.inventoryManage);

    final existing = await _attachmentStore.getAttachmentByHash(organizationId, sha256Hash);
    if (existing != null) {
      final link = AttachmentLink(
        id: 'link_${DateTime.now().microsecondsSinceEpoch}',
        attachmentId: existing.id,
        entityType: entityType,
        entityId: entityId,
        createdAt: DateTime.now(),
      );
      await _attachmentStore.linkAttachment(link);
      return existing;
    }

    final attachment = Attachment(
      id: 'att_${DateTime.now().microsecondsSinceEpoch}',
      organizationId: organizationId,
      fileName: fileName,
      mimeType: mimeType,
      fileSizeBytes: fileSizeBytes,
      sha256Hash: sha256Hash,
      storagePath: storagePath,
      createdAt: DateTime.now(),
    );

    await _attachmentStore.saveAttachment(attachment);

    final link = AttachmentLink(
      id: 'link_${DateTime.now().microsecondsSinceEpoch}',
      attachmentId: attachment.id,
      entityType: entityType,
      entityId: entityId,
      createdAt: DateTime.now(),
    );
    await _attachmentStore.linkAttachment(link);

    return attachment;
  }
}
