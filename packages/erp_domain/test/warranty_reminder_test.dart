import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('P12 Warranty Reminder & Mobile Print Adapter Domain Tests', () {
    test('WarrantyReminderStatus.calculateStatus calculates status correctly', () {
      final now = DateTime(2026, 9, 25);

      final activeDate = DateTime(2026, 11, 25);
      expect(
        WarrantyReminder.calculateStatus(activeDate, now),
        WarrantyReminderStatus.active,
      );

      final expiringSoonDate = DateTime(2026, 10, 15);
      expect(
        WarrantyReminder.calculateStatus(expiringSoonDate, now),
        WarrantyReminderStatus.expiringSoon,
      );

      final expiredDate = DateTime(2026, 8, 1);
      expect(
        WarrantyReminder.calculateStatus(expiredDate, now),
        WarrantyReminderStatus.expired,
      );
    });

    test('WarrantyReminder deduplicationKey generates partyId_serialId string', () {
      final reminder = WarrantyReminder(
        id: 'rem-1',
        serialId: 'ser-100',
        serialNumber: 'SN-SOLAR-1001',
        productId: 'prod-5hp',
        productName: '5 HP Solar Pump',
        partyId: 'cust-50',
        customerName: 'Ramesh Patil',
        customerPhone: '9881630001',
        startDate: DateTime(2025, 9, 25),
        endDate: DateTime(2026, 9, 25),
        daysRemaining: 0,
        status: WarrantyReminderStatus.expiringSoon,
      );

      expect(reminder.deduplicationKey, equals('cust-50_ser-100'));
    });

    test('PrintTransportCapability constructs correct capability model', () {
      const cap = PrintTransportCapability(
        transportType: PrintTransportType.bluetooth,
        isSupported: true,
        isAvailable: false,
        deviceName: 'POS Thermal Printer',
        deviceAddress: '00:11:22:33:44:55',
        details: 'Bluetooth SPP profile configured',
      );

      expect(cap.transportType, equals(PrintTransportType.bluetooth));
      expect(cap.isSupported, isTrue);
      expect(cap.isAvailable, isFalse);
    });
  });
}
