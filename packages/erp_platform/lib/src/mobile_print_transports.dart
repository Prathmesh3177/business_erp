import 'package:erp_domain/erp_domain.dart';

final class MobilePrintTransportManager {
  const MobilePrintTransportManager();

  List<PrintTransportCapability> detectCapabilities({
    bool isAndroidHost = false,
    bool isBluetoothAvailable = false,
    bool isNetworkAvailable = false,
    bool isUsbOtgConnected = false,
  }) {
    return [
      PrintTransportCapability(
        transportType: PrintTransportType.osSpooler,
        isSupported: true,
        isAvailable: true,
        deviceName: 'OS System Print Spooler',
        details: 'Standard desktop & mobile PDF print service',
      ),
      PrintTransportCapability(
        transportType: PrintTransportType.bluetooth,
        isSupported: isAndroidHost,
        isAvailable: isAndroidHost && isBluetoothAvailable,
        deviceName: isBluetoothAvailable ? 'BT-Thermal-80mm' : null,
        deviceAddress: isBluetoothAvailable ? '00:11:22:33:44:55' : null,
        details: isAndroidHost
            ? (isBluetoothAvailable
                ? 'Bluetooth SPP / LE connected'
                : 'Bluetooth adapter ready, no device paired')
            : 'Bluetooth thermal printing is disabled on desktop host',
      ),
      PrintTransportCapability(
        transportType: PrintTransportType.network,
        isSupported: true,
        isAvailable: isNetworkAvailable,
        deviceName: isNetworkAvailable ? 'Net-Thermal-Printer' : null,
        deviceAddress: isNetworkAvailable ? '192.168.1.200:9100' : null,
        details: isNetworkAvailable
            ? 'Wi-Fi / LAN Direct TCP RAW port 9100 connected'
            : 'No network thermal printer configured',
      ),
      PrintTransportCapability(
        transportType: PrintTransportType.usbOtg,
        isSupported: isAndroidHost,
        isAvailable: isAndroidHost && isUsbOtgConnected,
        deviceName: isUsbOtgConnected ? 'USB-POS-Printer' : null,
        details: isAndroidHost
            ? (isUsbOtgConnected ? 'USB OTG POS Printer connected' : 'USB OTG supported, no device connected')
            : 'USB OTG disabled on desktop host',
      ),
    ];
  }
}
