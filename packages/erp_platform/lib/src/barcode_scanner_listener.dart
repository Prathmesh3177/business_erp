import 'dart:async';

final class BarcodeScanResult {
  const BarcodeScanResult({
    required this.barcode,
    required this.scannedAtUtc,
    required this.isHardwareScanner,
  });

  final String barcode;
  final DateTime scannedAtUtc;
  final bool isHardwareScanner;
}

final class BarcodeScannerBuffer {
  BarcodeScannerBuffer({
    this.maxInterKeystrokeMs = 50,
    this.debounceWindowMs = 500,
  });

  final int maxInterKeystrokeMs;
  final int debounceWindowMs;

  final StringBuffer _buffer = StringBuffer();
  DateTime? _lastCharTime;
  String? _lastScannedBarcode;
  DateTime? _lastScannedTime;

  bool _isFastPulse = true;

  /// Process an incoming key character and optional termination signal (e.g. Enter).
  /// Returns [BarcodeScanResult] if a complete barcode is recognized, or `null`.
  BarcodeScanResult? processKeyInput(String char, {bool isEnterKey = false}) {
    final now = DateTime.now();

    if (_lastCharTime != null) {
      final diffMs = now.difference(_lastCharTime!).inMilliseconds;
      if (diffMs > maxInterKeystrokeMs) {
        _isFastPulse = false;
      }
    } else {
      _isFastPulse = true;
    }

    _lastCharTime = now;

    if (isEnterKey) {
      final rawStr = _buffer.toString().trim().toUpperCase();
      _buffer.clear();
      _lastCharTime = null;

      if (rawStr.isEmpty) return null;

      // Debounce duplicate scans
      if (_lastScannedBarcode == rawStr && _lastScannedTime != null) {
        final elapsedMs = now.difference(_lastScannedTime!).inMilliseconds;
        if (elapsedMs < debounceWindowMs) {
          return null; // Duplicate scan ignored
        }
      }

      _lastScannedBarcode = rawStr;
      _lastScannedTime = now;

      final result = BarcodeScanResult(
        barcode: rawStr,
        scannedAtUtc: now,
        isHardwareScanner: _isFastPulse,
      );

      _isFastPulse = true;
      return result;
    }

    _buffer.write(char);
    return null;
  }

  void reset() {
    _buffer.clear();
    _lastCharTime = null;
    _isFastPulse = true;
  }
}
