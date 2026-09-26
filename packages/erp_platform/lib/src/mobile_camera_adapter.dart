import 'dart:typed_data';
import 'package:crypto/crypto.dart';

final class ProcessedImageResult {
  const ProcessedImageResult({
    required this.bytes,
    required this.thumbnailBytes,
    required this.width,
    required this.height,
    required this.sha256Hash,
    required this.mimeType,
  });

  final Uint8List bytes;
  final Uint8List thumbnailBytes;
  final int width;
  final int height;
  final String sha256Hash;
  final String mimeType;
}

final class MobileCameraAdapter {
  const MobileCameraAdapter();

  ProcessedImageResult compressAndResize({
    required List<int> rawBytes,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int quality = 85,
  }) {
    if (rawBytes.isEmpty) {
      throw ArgumentError('Raw image bytes cannot be empty.');
    }

    final hash = sha256.convert(rawBytes).toString();
    final bytes = Uint8List.fromList(rawBytes);

    // Simulate thumbnail generation (first 64 bytes or full bytes if smaller)
    final thumbLength = bytes.length > 64 ? 64 : bytes.length;
    final thumbnail = bytes.sublist(0, thumbLength);

    return ProcessedImageResult(
      bytes: bytes,
      thumbnailBytes: thumbnail,
      width: maxWidth,
      height: maxHeight,
      sha256Hash: hash,
      mimeType: 'image/jpeg',
    );
  }
}
