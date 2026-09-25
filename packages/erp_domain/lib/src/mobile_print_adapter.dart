enum PrintTransportType {
  osSpooler,
  bluetooth,
  network,
  usbOtg,
}

final class PrintTransportCapability {
  const PrintTransportCapability({
    required this.transportType,
    required this.isSupported,
    required this.isAvailable,
    this.deviceName,
    this.deviceAddress,
    this.details = '',
  });

  final PrintTransportType transportType;
  final bool isSupported;
  final bool isAvailable;
  final String? deviceName;
  final String? deviceAddress;
  final String details;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintTransportCapability &&
          runtimeType == other.runtimeType &&
          transportType == other.transportType &&
          isSupported == other.isSupported &&
          isAvailable == other.isAvailable &&
          deviceName == other.deviceName &&
          deviceAddress == other.deviceAddress &&
          details == other.details;

  @override
  int get hashCode =>
      transportType.hashCode ^
      isSupported.hashCode ^
      isAvailable.hashCode ^
      deviceName.hashCode ^
      deviceAddress.hashCode ^
      details.hashCode;
}
