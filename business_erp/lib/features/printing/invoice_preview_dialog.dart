import 'package:erp_domain/erp_domain.dart';
import 'package:erp_platform/erp_platform.dart';
import 'package:flutter/material.dart';

final class InvoicePreviewDialog extends StatefulWidget {
  const InvoicePreviewDialog({
    super.key,
    required this.invoice,
    this.printAdapter,
  });

  final InvoiceViewModel invoice;
  final DesktopPrintAdapter? printAdapter;

  static Future<void> show(
    BuildContext context, {
    required InvoiceViewModel invoice,
    DesktopPrintAdapter? printAdapter,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => InvoicePreviewDialog(
        invoice: invoice,
        printAdapter: printAdapter,
      ),
    );
  }

  @override
  State<InvoicePreviewDialog> createState() => _InvoicePreviewDialogState();
}

final class _InvoicePreviewDialogState extends State<InvoicePreviewDialog> {
  late DesktopPrintAdapter _adapter;
  late InvoiceLanguage _selectedLang;
  InvoiceFormat _selectedFormat = InvoiceFormat.a4;
  String _selectedPrinter = 'System Default (PDF Export)';
  bool _isReprint = false;
  List<String> _printers = [];
  bool _printing = false;

  @override
  void initState() {
    super.initState();
    _adapter = widget.printAdapter ?? DesktopPrintAdapter();
    _selectedLang = widget.invoice.language;
    _isReprint = widget.invoice.isReprint;
    _loadPrinters();
  }

  Future<void> _loadPrinters() async {
    final list = await _adapter.getAvailablePrinters();
    if (mounted) {
      setState(() {
        _printers = list;
        if (list.isNotEmpty) {
          _selectedPrinter = list.first;
        }
      });
    }
  }

  InvoiceViewModel get _activeViewModel {
    return InvoiceViewModel(
      invoiceNumber: widget.invoice.invoiceNumber,
      businessDate: widget.invoice.businessDate,
      originalSaleId: widget.invoice.originalSaleId,
      sellerLegalName: widget.invoice.sellerLegalName,
      sellerDisplayName: widget.invoice.sellerDisplayName,
      sellerAddress: widget.invoice.sellerAddress,
      sellerPhone: widget.invoice.sellerPhone,
      sellerGstin: widget.invoice.sellerGstin,
      sellerStateCode: widget.invoice.sellerStateCode,
      customerPartyId: widget.invoice.customerPartyId,
      customerName: widget.invoice.customerName,
      customerAddress: widget.invoice.customerAddress,
      customerGstin: widget.invoice.customerGstin,
      customerStateCode: widget.invoice.customerStateCode,
      customerPhone: widget.invoice.customerPhone,
      lineItems: widget.invoice.lineItems,
      subtotalPaise: widget.invoice.subtotalPaise,
      totalDiscountPaise: widget.invoice.totalDiscountPaise,
      taxableAmountPaise: widget.invoice.taxableAmountPaise,
      cgstPaise: widget.invoice.cgstPaise,
      sgstPaise: widget.invoice.sgstPaise,
      igstPaise: widget.invoice.igstPaise,
      totalTaxPaise: widget.invoice.totalTaxPaise,
      roundOffPaise: widget.invoice.roundOffPaise,
      grandTotalPaise: widget.invoice.grandTotalPaise,
      amountPaidPaise: widget.invoice.amountPaidPaise,
      balanceDuePaise: widget.invoice.balanceDuePaise,
      paymentStatus: widget.invoice.paymentStatus,
      serialsAppendix: widget.invoice.serialsAppendix,
      termsAndConditions: widget.invoice.termsAndConditions,
      templateVersion: widget.invoice.templateVersion,
      language: _selectedLang,
      isReprint: _isReprint,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = _activeViewModel;
    final thermalText = const ThermalInvoiceRenderer().renderThermalText(vm, format: _selectedFormat);

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.print, color: Color(0xFF990000)),
              const SizedBox(width: 8),
              Text('Invoice Print & Preview: ${vm.invoiceNumber}'),
            ],
          ),
          if (_isReprint)
            Chip(
              label: const Text('DUPLICATE REPRINT'),
              backgroundColor: Colors.amber.shade200,
            ),
        ],
      ),
      content: SizedBox(
        width: 750,
        height: 520,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Controls Panel
            SizedBox(
              width: 260,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Print Format', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<InvoiceFormat>(
                      initialValue: _selectedFormat,
                      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: InvoiceFormat.a4, child: Text('A4 Standard Invoice')),
                        DropdownMenuItem(value: InvoiceFormat.thermal80, child: Text('80 mm Thermal POS')),
                        DropdownMenuItem(value: InvoiceFormat.thermal58, child: Text('58 mm Thermal POS')),
                      ],
                      onChanged: (val) => setState(() => _selectedFormat = val!),
                    ),
                    const SizedBox(height: 16),
                    const Text('Language & Script', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<InvoiceLanguage>(
                      initialValue: _selectedLang,
                      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: InvoiceLanguage.english, child: Text('English')),
                        DropdownMenuItem(value: InvoiceLanguage.marathi, child: Text('मराठी (Marathi)')),
                        DropdownMenuItem(value: InvoiceLanguage.bilingual, child: Text('Bilingual (द्विभाषिक)')),
                      ],
                      onChanged: (val) => setState(() => _selectedLang = val!),
                    ),
                    const SizedBox(height: 16),
                    const Text('Target Printer Device', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPrinter,
                      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                      items: _printers.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedPrinter = val!),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Reprint Copy'),
                      subtitle: const Text('Marks watermark on invoice'),
                      value: _isReprint,
                      onChanged: (val) => setState(() => _isReprint = val),
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 24),
            // Right Live Text / Layout Preview Panel
            Expanded(
              child: Card(
                color: const Color(0xFFF7FAFC),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedFormat == InvoiceFormat.a4 ? 'A4 Document Preview' : 'Thermal Receipt Render (${_selectedFormat == InvoiceFormat.thermal58 ? "58mm" : "80mm"})',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
                          ),
                          Text('Template: ${vm.templateVersion}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _selectedFormat == InvoiceFormat.a4
                                ? String.fromCharCodes(const PdfInvoiceRenderer().renderA4Pdf(vm).bytes)
                                : thermalText,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => _exportPdf(vm),
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Export PDF'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF990000)),
          onPressed: _printing ? null : () => _doPrint(vm),
          icon: const Icon(Icons.print),
          label: Text(_printing ? 'Printing...' : 'Spool to Printer'),
        ),
      ],
    );
  }

  Future<void> _doPrint(InvoiceViewModel vm) async {
    setState(() => _printing = true);
    try {
      final job = await _adapter.printInvoice(
        vm,
        printerName: _selectedPrinter,
        printFormat: _selectedFormat,
        isReprint: _isReprint,
      );

      if (mounted) {
        setState(() => _printing = false);
        if (job.status == PrintStatus.accepted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Print job ${job.id} sent to ${job.printerName} successfully.')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Print job failed/unknown: ${job.errorMessage ?? "Printer offline"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _printing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Printing error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _exportPdf(InvoiceViewModel vm) {
    final pdfResult = const PdfInvoiceRenderer().renderA4Pdf(vm);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF Exported. SHA-256 Checksum: ${pdfResult.sha256Checksum.substring(0, 16)}...'),
      ),
    );
  }
}
