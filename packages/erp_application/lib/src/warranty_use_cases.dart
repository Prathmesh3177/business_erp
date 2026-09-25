import 'package:erp_domain/erp_domain.dart';

import 'command_context.dart';
import 'report_use_cases.dart';
import 'sales_store.dart';

final class GenerateWarrantyRemindersUseCase {
  const GenerateWarrantyRemindersUseCase({
    required this.salesStore,
  });

  final SalesStore salesStore;

  Future<List<WarrantyReminder>> execute({
    required CommandContext context,
    required String organizationId,
    required DateTime referenceDate,
    String? partyId,
  }) async {
    context.requireCapability(Capability.salesRead);


    List<WarrantyEntitlement> rawEntitlements;
    if (partyId != null && partyId.isNotEmpty) {
      rawEntitlements = await salesStore.getWarrantyEntitlementsForCustomer(
        organizationId: organizationId,
        partyId: partyId,
      );
    } else {
      rawEntitlements = await salesStore.getAllWarrantyEntitlements(
        organizationId: organizationId,
      );
    }

    // Deduplicate by partyId_serialId to suppress repeated reminders
    final Map<String, WarrantyReminder> uniqueReminders = {};

    for (final entitlement in rawEntitlements) {
      final status = WarrantyReminder.calculateStatus(entitlement.endDate, referenceDate);
      final daysRemaining = entitlement.endDate.difference(referenceDate).inDays;

      final reminder = WarrantyReminder(
        id: entitlement.id,
        serialId: entitlement.serialId,
        serialNumber: entitlement.serialNumber,
        productId: entitlement.productId,
        productName: entitlement.productId, // Product name or ID
        partyId: entitlement.partyId,
        customerName: entitlement.partyId, // Customer name or ID
        customerPhone: '',
        startDate: entitlement.startDate,
        endDate: entitlement.endDate,
        daysRemaining: daysRemaining,
        status: status,
      );

      // Keep most urgent status if duplicate exists
      if (!uniqueReminders.containsKey(reminder.deduplicationKey)) {
        uniqueReminders[reminder.deduplicationKey] = reminder;
      }
    }

    final reminders = uniqueReminders.values.toList();
    reminders.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return reminders;
  }
}

final class ExportWarrantyRemindersUseCase {
  const ExportWarrantyRemindersUseCase();

  String _sanitize(String input) {
    if (input.isEmpty) return input;
    final first = input[0];
    if (first == '=' || first == '+' || first == '-' || first == '@' || first == '\t' || first == '\r') {
      return "'$input";
    }
    return input;
  }

  String executeCsv(List<WarrantyReminder> reminders) {
    final buffer = StringBuffer();
    buffer.writeln('Serial Number,Product,Customer,End Date,Days Remaining,Status');

    for (final rem in reminders) {
      final serial = _sanitize(rem.serialNumber);
      final product = _sanitize(rem.productName);
      final customer = _sanitize(rem.customerName);
      final endDateStr = rem.endDate.toIso8601String().split('T').first;
      final statusStr = rem.status.name;

      buffer.writeln('"$serial","$product","$customer","$endDateStr",${rem.daysRemaining},"$statusStr"');
    }

    return buffer.toString();
  }
}
