enum DocumentKind {
  saleInvoice,
  purchaseBill,
  payment,
  receipt,
  salesReturn,
  purchaseReturn,
  journal,
  openingBalance,
}

enum DocumentStatus { draft, validated, posted, cancelled }

final class DocumentHeader {
  const DocumentHeader({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.kind,
    this.status = DocumentStatus.posted,
    required this.businessDate,
    required this.documentNumber,
    required this.fiscalYear,
    required this.sourceCommandId,
    required this.createdAt,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final DocumentKind kind;
  final DocumentStatus status;
  final DateTime businessDate;
  final String documentNumber; // E.g., "A/2627/000001"
  final String fiscalYear; // E.g., "2026-2027"
  final String sourceCommandId;
  final DateTime createdAt;
}

final class DocumentSequence {
  const DocumentSequence({
    required this.id,
    required this.registrationId,
    required this.fiscalYear,
    required this.series,
    required this.nextValue,
  });

  final String id;
  final String registrationId;
  final String fiscalYear;
  final String series; // E.g., "SKS" or "A"
  final int nextValue; // E.g., 1, 2, 3...

  String formatNextNumber() {
    final parts = fiscalYear.split('-');
    final yearSuffix = parts.length == 2
        ? '${parts[0].substring(parts[0].length - 2)}${parts[1].substring(parts[1].length - 2)}'
        : '2627';
    final paddedNumber = nextValue.toString().padLeft(6, '0');
    return '$series/$yearSuffix/$paddedNumber';
  }
}

final class CommandResultRecord {
  const CommandResultRecord({
    required this.id,
    required this.commandId,
    required this.payloadHash,
    required this.resultJson,
    required this.createdAt,
  });

  final String id;
  final String commandId;
  final String payloadHash;
  final String resultJson;
  final DateTime createdAt;
}
