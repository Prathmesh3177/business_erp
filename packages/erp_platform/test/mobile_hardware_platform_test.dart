import 'dart:convert';
import 'package:erp_domain/erp_domain.dart';
import 'package:erp_platform/erp_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('P12 Mobile Hardware & Camera Platform Tests', () {
    test('MobileCameraAdapter compresses raw image bytes and computes SHA-256 hash', () {
      const adapter = MobileCameraAdapter();
      final rawBytes = utf8.encode('SIMULATED_SOLAR_PUMP_NAMEPLATE_PHOTO_DATA');

      final result = adapter.compressAndResize(
        rawBytes: rawBytes,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      expect(result.mimeType, equals('image/jpeg'));
      expect(result.width, equals(1920));
      expect(result.height, equals(1080));
      expect(result.sha256Hash, isNotEmpty);
      expect(result.thumbnailBytes.length, greaterThan(0));
    });

    test('MobilePrintTransportManager detects transport capability on Android host', () {
      const manager = MobilePrintTransportManager();

      final capabilities = manager.detectCapabilities(
        isAndroidHost: true,
        isBluetoothAvailable: true,
        isNetworkAvailable: true,
        isUsbOtgConnected: false,
      );

      expect(capabilities.length, equals(4));

      final btCap = capabilities.firstWhere(
        (c) => c.transportType == PrintTransportType.bluetooth,
      );
      expect(btCap.isSupported, isTrue);
      expect(btCap.isAvailable, isTrue);
      expect(btCap.deviceName, equals('BT-Thermal-80mm'));

      final usbCap = capabilities.firstWhere(
        (c) => c.transportType == PrintTransportType.usbOtg,
      );
      expect(usbCap.isSupported, isTrue);
      expect(usbCap.isAvailable, isFalse);
    });

    test('MobilePrintTransportManager disables Bluetooth & USB OTG on Desktop host', () {
      const manager = MobilePrintTransportManager();

      final capabilities = manager.detectCapabilities(
        isAndroidHost: false,
        isBluetoothAvailable: false,
        isNetworkAvailable: false,
        isUsbOtgConnected: false,
      );

      final btCap = capabilities.firstWhere(
        (c) => c.transportType == PrintTransportType.bluetooth,
      );
      expect(btCap.isSupported, isFalse);

      final netCap = capabilities.firstWhere(
        (c) => c.transportType == PrintTransportType.network,
      );
      expect(netCap.isSupported, isTrue);
      expect(netCap.isAvailable, isFalse);
    });
  });
}
