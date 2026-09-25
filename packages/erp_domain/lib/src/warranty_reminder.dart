enum WarrantyReminderStatus {
  active,
  expiringSoon,
  expired,
}

final class WarrantyReminder {
  const WarrantyReminder({
    required this.id,
    required this.serialId,
    required this.serialNumber,
    required this.productId,
    required this.productName,
    required this.partyId,
    required this.customerName,
    required this.customerPhone,
    required this.startDate,
    required this.endDate,
    required this.daysRemaining,
    required this.status,
  });

  final String id;
  final String serialId;
  final String serialNumber;
  final String productId;
  final String productName;
  final String partyId;
  final String customerName;
  final String customerPhone;
  final DateTime startDate;
  final DateTime endDate;
  final int daysRemaining;
  final WarrantyReminderStatus status;

  /// Primary deduplication key to suppress repeated reminders for the same serial and party
  String get deduplicationKey => '${partyId}_$serialId';

  static WarrantyReminderStatus calculateStatus(DateTime endDate, DateTime referenceDate) {
    final days = endDate.difference(referenceDate).inDays;
    if (days < 0) {
      return WarrantyReminderStatus.expired;
    } else if (days <= 30) {
      return WarrantyReminderStatus.expiringSoon;
    } else {
      return WarrantyReminderStatus.active;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WarrantyReminder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serialId == other.serialId &&
          serialNumber == other.serialNumber &&
          productId == other.productId &&
          productName == other.productName &&
          partyId == other.partyId &&
          customerName == other.customerName &&
          customerPhone == other.customerPhone &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          daysRemaining == other.daysRemaining &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      serialId.hashCode ^
      serialNumber.hashCode ^
      productId.hashCode ^
      productName.hashCode ^
      partyId.hashCode ^
      customerName.hashCode ^
      customerPhone.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      daysRemaining.hashCode ^
      status.hashCode;
}
