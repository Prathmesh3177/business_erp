import 'invoice_view_model.dart';

enum PrintStatus { queued, sending, accepted, failed, unknown }

final class PrintJob {
  const PrintJob({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.documentId,
    required this.printerName,
    required this.printFormat,
    required this.status,
    required this.isReprint,
    required this.printedAtUtc,
    this.errorMessage,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String documentId;
  final String printerName;
  final InvoiceFormat printFormat;
  final PrintStatus status;
  final bool isReprint;
  final DateTime printedAtUtc;
  final String? errorMessage;

  PrintJob copyWith({
    PrintStatus? status,
    String? errorMessage,
  }) {
    return PrintJob(
      id: id,
      organizationId: organizationId,
      branchId: branchId,
      documentId: documentId,
      printerName: printerName,
      printFormat: printFormat,
      status: status ?? this.status,
      isReprint: isReprint,
      printedAtUtc: printedAtUtc,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
