import 'package:flutter/material.dart';

final class AttachmentManagerWidget extends StatefulWidget {
  const AttachmentManagerWidget({
    super.key,
    required this.entityType,
    required this.entityId,
  });

  final String entityType;
  final String entityId;

  @override
  State<AttachmentManagerWidget> createState() => _AttachmentManagerWidgetState();
}

final class _AttachmentManagerWidgetState extends State<AttachmentManagerWidget> {
  final List<Map<String, String>> _attachments = [
    {
      'fileName': 'solar_panel_datasheet.pdf',
      'mimeType': 'application/pdf',
      'size': '240 KB',
      'hash': 'a1b2c3d4e5f67890',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Managed Attachments (Max 10MB)', style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Upload File'),
              onPressed: _mockUpload,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_attachments.isEmpty)
          const Text('No attachments uploaded yet.', style: TextStyle(color: Colors.grey, fontSize: 12))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attachments.length,
            itemBuilder: (context, index) {
              final att = _attachments[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Color(0xFF990000)),
                  title: Text(att['fileName'] ?? ''),
                  subtitle: Text('${att['size']} | SHA256: ${att['hash']?.substring(0, 8)}...'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () => setState(() => _attachments.removeAt(index)),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _mockUpload() {
    setState(() {
      _attachments.add({
        'fileName': 'gst_certificate_${DateTime.now().millisecondsSinceEpoch}.pdf',
        'mimeType': 'application/pdf',
        'size': '1.2 MB',
        'hash': '${DateTime.now().microsecondsSinceEpoch}hash',
      });
    });
  }
}
