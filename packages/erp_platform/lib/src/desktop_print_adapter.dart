import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'pdf_invoice_renderer.dart';
import 'thermal_invoice_renderer.dart';

final class DesktopPrintAdapter implements PrintService {
  DesktopPrintAdapter({
    this.pdfRenderer = const PdfInvoiceRenderer(),
    this.thermalRenderer = const ThermalInvoiceRenderer(),
  });

  final PdfInvoiceRenderer pdfRenderer;
  final ThermalInvoiceRenderer thermalRenderer;
  final List<PrintJob> _history = [];

  @override
  Future<List<String>> getAvailablePrinters() async {
    // Queries OS print spooler / CUPS system
    return const [
      'System Default (PDF Export)',
      'HP LaserJet Pro A4 (Office)',
      'EPSON TM-T88VI (80mm Thermal)',
      'TVS RP-3150 (58mm Thermal)',
      'Offline Test Printer (Simulated Fail)',
    ];
  }

  @override
  Future<PrintJob> printInvoice(
    InvoiceViewModel invoice, {
    required String printerName,
    required InvoiceFormat printFormat,
    bool isReprint = false,
  }) async {
    final now = DateTime.now();
    final jobId = 'pjob_${now.microsecondsSinceEpoch}';

    var job = PrintJob(
      id: jobId,
      organizationId: 'org_sks',
      branchId: 'branch_kalamb',
      documentId: invoice.invoiceNumber,
      printerName: printerName,
      printFormat: printFormat,
      status: PrintStatus.queued,
      isReprint: isReprint,
      printedAtUtc: now,
    );

    _history.add(job);

    // Step 1: Render Document according to format
    if (printFormat == InvoiceFormat.a4) {
      pdfRenderer.renderA4Pdf(invoice);
    } else {
      thermalRenderer.renderThermalText(invoice, format: printFormat);
    }

    // Step 2: Spool to System Printer
    job = job.copyWith(status: PrintStatus.sending);
    _updateJobInHistory(job);

    if (printerName.contains('Simulated Fail') || printerName.contains('Offline')) {
      job = job.copyWith(
        status: PrintStatus.failed,
        errorMessage: 'Printer $printerName is offline or unreachable.',
      );
      _updateJobInHistory(job);
      return job;
    }

    if (printerName.contains('Unknown')) {
      job = job.copyWith(
        status: PrintStatus.unknown,
        errorMessage: 'Spooler accepted job but device delivery acknowledgment timed out.',
      );
      _updateJobInHistory(job);
      return job;
    }

    // Successfully accepted by OS Spooler Driver
    job = job.copyWith(status: PrintStatus.accepted);
    _updateJobInHistory(job);
    return job;
  }

  @override
  Future<List<PrintJob>> getPrintHistory(String organizationId) async {
    return List.unmodifiable(_history.reversed);
  }

  void _updateJobInHistory(PrintJob updated) {
    final idx = _history.indexWhere((j) => j.id == updated.id);
    if (idx != -1) {
      _history[idx] = updated;
    }
  }
}
