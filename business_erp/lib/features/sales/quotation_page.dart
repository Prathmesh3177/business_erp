import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';
import '../common/indian_currency_formatter.dart';
import 'quotation_sale_draft.dart';

final quotationListProvider = FutureProvider.autoDispose<List<QuotationHeader>>(
  (ref) async {
    final runtime = await ref.watch(runtimeProvider.future);
    return runtime.database.listQuotations(
      runtime.identity!.organization.id.value,
    );
  },
);

final class QuotationPage extends ConsumerStatefulWidget {
  const QuotationPage({super.key});

  @override
  ConsumerState<QuotationPage> createState() => _QuotationPageState();
}

final class _QuotationPageState extends ConsumerState<QuotationPage> {
  final _searchController = TextEditingController();
  final List<_QuotationDraftLine> _lines = [];
  List<Product> _products = [];
  List<Party> _customers = [];
  Party? _customer;
  QuotationStatus? _statusFilter;
  int _validityDays = 15;
  bool _loadingMasters = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadMasters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMasters() async {
    try {
      final runtime = await ref.read(runtimeProvider.future);
      final orgId = runtime.identity!.organization.id.value;
      final products = await runtime.database.searchProducts(orgId);
      final customers = await runtime.database.searchParties(
        orgId,
        isCustomer: true,
      );
      if (!mounted) return;
      setState(() {
        _products = products;
        _customers = customers;
        _loadingMasters = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMasters = false);
    }
  }

  double get _subtotal => _lines.fold(0, (sum, line) => sum + line.taxable);
  double get _tax => _lines.fold(0, (sum, line) => sum + line.tax);
  double get _total => _subtotal + _tax;

  @override
  Widget build(BuildContext context) {
    final quotations = ref.watch(quotationListProvider);
    final query = _searchController.text.trim().toLowerCase();
    final filteredProducts = _products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query) ||
              product.sku.toLowerCase().contains(query),
        )
        .toList();

    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Party>(
                        initialValue: _customer,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Customer *',
                          border: OutlineInputBorder(),
                        ),
                        items: _customers
                            .map(
                              (party) => DropdownMenuItem(
                                value: party,
                                child: Text(party.name),
                              ),
                            )
                            .toList(),
                        onChanged: (party) => setState(() => _customer = party),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: _validityDays,
                      items: const [7, 15, 30, 45, 60]
                          .map(
                            (days) => DropdownMenuItem(
                              value: days,
                              child: Text('$days days validity'),
                            ),
                          )
                          .toList(),
                      onChanged: (days) =>
                          setState(() => _validityDays = days ?? 15),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search products to add',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (query.isNotEmpty)
                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return ListTile(
                          dense: true,
                          title: Text(product.name),
                          subtitle: Text(
                            '${product.sku} · ${formatIndianCurrency(product.sellingPricePaise / 100)}',
                          ),
                          trailing: product.isMadeToOrder
                              ? const Chip(label: Text('Made to Order'))
                              : null,
                          onTap: () {
                            setState(() {
                              final existing = _lines
                                  .where(
                                    (line) => line.product.id == product.id,
                                  )
                                  .firstOrNull;
                              if (existing == null) {
                                _lines.add(_QuotationDraftLine(product));
                              } else {
                                existing.quantity += 1;
                              }
                              _searchController.clear();
                            });
                          },
                        );
                      },
                    ),
                  ),
                if (_loadingMasters)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _lines.isEmpty
              ? const Center(
                  child: Text('Add products to build this quotation.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _lines.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) =>
                      _buildLine(context, _lines[index]),
                ),
        ),
        _buildTotals(context),
        const Divider(height: 1),
        Expanded(
          flex: 2,
          child: quotations.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('Could not load quotations: $error')),
            data: (items) => _buildQuotationList(context, items),
          ),
        ),
      ],
    );
  }

  Widget _buildLine(BuildContext context, _QuotationDraftLine line) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.product.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${line.product.sku} · GST ${(line.product.defaultTaxRateBps / 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (line.product.isMadeToOrder)
                const Text(
                  'Made to Order',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        _numberInput(
          'Qty',
          line.quantity,
          (value) => setState(() => line.quantity = value),
          width: 72,
        ),
        const SizedBox(width: 8),
        _numberInput(
          'Price',
          line.unitPrice,
          (value) => setState(() => line.unitPrice = value),
          width: 94,
        ),
        const SizedBox(width: 8),
        Text(
          formatIndianCurrency(line.total),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => setState(() => _lines.remove(line)),
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Remove line',
        ),
      ],
    );
  }

  Widget _numberInput(
    String label,
    double value,
    ValueChanged<double> onChanged, {
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        key: ValueKey('$label-${value.toStringAsFixed(2)}'),
        initialValue: value % 1 == 0
            ? value.toInt().toString()
            : value.toStringAsFixed(2),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, isDense: true),
        onChanged: (text) => onChanged(double.tryParse(text) ?? 0),
      ),
    );
  }

  Widget _buildTotals(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Subtotal ${formatIndianCurrency(_subtotal)}   GST ${formatIndianCurrency(_tax)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            'Total ${formatIndianCurrency(_total)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _saving ? null : _saveQuotation,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Quotation'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationList(
    BuildContext context,
    List<QuotationHeader> quotations,
  ) {
    final filtered =
        quotations
            .where(
              (quote) => _statusFilter == null || quote.status == _statusFilter,
            )
            .toList()
          ..sort((a, b) => b.createdAtUtc.compareTo(a.createdAtUtc));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Text(
                'Saved quotations',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              DropdownButton<QuotationStatus?>(
                value: _statusFilter,
                hint: const Text('All statuses'),
                items: [
                  const DropdownMenuItem<QuotationStatus?>(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  ...QuotationStatus.values.map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.name.toUpperCase()),
                    ),
                  ),
                ],
                onChanged: (status) => setState(() => _statusFilter = status),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No quotations match this filter.'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final quote = filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(_statusIcon(quote.status)),
                      ),
                      title: Text(
                        '${quote.quotationNumber} · ${quote.customerName}',
                      ),
                      subtitle: Text(
                        '${quote.status.name.toUpperCase()} · valid until ${_date(quote.validUntil)}',
                      ),
                      trailing: Text(
                        formatIndianCurrency(quote.grandTotalPaise.inRupees),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () => _showQuotationDetails(quote),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _saveQuotation() async {
    if (_customer == null || _lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a customer and add at least one product.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final runtime = await ref.read(runtimeProvider.future);
      final identity = runtime.identity!;
      await CreateQuotationUseCase(
        projectStore: runtime.database,
        accountingStore: runtime.database,
      ).execute(
        CommandContext(
          session: _effectiveSession(),
          timestampUtc: DateTime.now(),
        ),
        organizationId: identity.organization.id.value,
        branchId: identity.branch.id.value,
        customerPartyId: _customer!.id,
        customerName: _customer!.name,
        validUntil: DateTime.now().add(Duration(days: _validityDays)),
        lineInputs: _lines
            .map(
              (line) => QuotationLineInput(
                productId: line.product.id,
                productName: line.product.name,
                sku: line.product.sku,
                hsnCode: line.product.hsnCode,
                quantity: Quantity.fromUnits(line.quantity),
                unitPrice: UnitPrice.fromRupees(line.unitPrice),
                taxRate: TaxRate.fromBps(line.product.defaultTaxRateBps),
              ),
            )
            .toList(),
      );
      if (!mounted) return;
      setState(() {
        _lines.clear();
        _customer = null;
      });
      ref.invalidate(quotationListProvider);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Quotation saved.')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save quotation: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showQuotationDetails(QuotationHeader quote) async {
    final runtime = await ref.read(runtimeProvider.future);
    final lines = await runtime.database.getQuotationLines(quote.id);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Quotation ${quote.quotationNumber}'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote.customerName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Valid until ${_date(quote.validUntil)} · ${quote.status.name.toUpperCase()}',
                ),
                const Divider(),
                ...lines.map(
                  (line) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(line.productName),
                    subtitle: Text(
                      '${line.quantity.inUnits} × ${formatIndianCurrency(line.unitPrice.inRupees)}',
                    ),
                    trailing: Text(
                      formatIndianCurrency(line.netTotalPaise.inRupees),
                    ),
                  ),
                ),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total ${formatIndianCurrency(quote.grandTotalPaise.inRupees)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _setStatus(quote, QuotationStatus.sent),
            child: const Text('Mark Sent'),
          ),
          TextButton(
            onPressed: () => _setStatus(quote, QuotationStatus.rejected),
            child: const Text('Reject'),
          ),
          TextButton(
            onPressed: () => _previewQuotation(quote, lines),
            child: const Text('Preview / Print'),
          ),
          TextButton(
            onPressed: () => _editQuotation(quote, lines),
            child: const Text('Edit'),
          ),
          if (quote.status != QuotationStatus.approved)
            TextButton(
              onPressed: () => _convertToProject(quote),
              child: const Text('Convert to Project'),
            ),
          FilledButton(
            onPressed: () {
              stageQuotationForSale(
                QuotationSaleDraft(
                  customerPartyId: quote.customerPartyId,
                  lines: lines,
                ),
              );
              Navigator.pop(dialogContext);
              context.go('/sales');
            },
            child: const Text('Convert to Sale'),
          ),
        ],
      ),
    );
  }

  Future<void> _editQuotation(
    QuotationHeader quote,
    List<QuotationLine> lines,
  ) async {
    final quantities = lines
        .map(
          (line) =>
              TextEditingController(text: line.quantity.inUnits.toString()),
        )
        .toList();
    final prices = lines
        .map(
          (line) => TextEditingController(
            text: line.unitPrice.inRupees.toStringAsFixed(2),
          ),
        )
        .toList();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit ${quote.quotationNumber}'),
        content: SizedBox(
          width: 560,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: lines.length,
            itemBuilder: (_, index) => Row(
              children: [
                Expanded(child: Text(lines[index].productName)),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: quantities[index],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Qty'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: prices[index],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Price ₹'),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    final requests = <TaxLineRequest>[];
    for (var index = 0; index < lines.length; index++) {
      requests.add(
        TaxLineRequest(
          lineId: lines[index].id,
          quantity: Quantity.fromUnits(
            double.tryParse(quantities[index].text) ?? 0,
          ),
          unitPrice: UnitPrice.fromRupees(
            double.tryParse(prices[index].text) ?? 0,
          ),
          taxRate: TaxRate.fromBps(
            lines[index].taxSnapshot.taxableAmount.paise == 0
                ? 0
                : ((lines[index].taxSnapshot.totalTax.paise /
                              lines[index].taxSnapshot.taxableAmount.paise) *
                          10000)
                      .round(),
          ),
        ),
      );
    }
    final invoice = const TaxEngine().calculateInvoiceTax(
      lines: requests,
      supplyType: TaxSupplyType.intraState,
    );
    final updated = <QuotationLine>[];
    for (var index = 0; index < lines.length; index++) {
      final old = lines[index];
      final request = requests[index];
      final tax = invoice.lineResults[index];
      updated.add(
        QuotationLine(
          id: old.id,
          quotationId: old.quotationId,
          productId: old.productId,
          productName: old.productName,
          sku: old.sku,
          hsnCode: old.hsnCode,
          quantity: request.quantity,
          unitPrice: request.unitPrice,
          lineDiscountPaise: old.lineDiscountPaise,
          taxSnapshot: tax,
          netTotalPaise: tax.totalAmount,
          isServiceLine: old.isServiceLine,
          bomSnapshotJson: old.bomSnapshotJson,
        ),
      );
    }
    final subtotal = invoice.subtotal;
    final header = QuotationHeader(
      id: quote.id,
      organizationId: quote.organizationId,
      branchId: quote.branchId,
      quotationNumber: quote.quotationNumber,
      revisionNumber: quote.revisionNumber + 1,
      customerPartyId: quote.customerPartyId,
      customerName: quote.customerName,
      validUntil: quote.validUntil,
      status: quote.status,
      subtotalPaise: subtotal,
      allocatedDiscountPaise: quote.allocatedDiscountPaise,
      totalTaxPaise: invoice.totalTax,
      grandTotalPaise: invoice.grandTotal + quote.installationChargesPaise,
      installationChargesPaise: quote.installationChargesPaise,
      termsSnapshot: quote.termsSnapshot,
      createdAtUtc: quote.createdAtUtc,
    );
    final runtime = await ref.read(runtimeProvider.future);
    await runtime.database.saveQuotation(header: header, lines: updated);
    ref.invalidate(quotationListProvider);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _setStatus(QuotationHeader quote, QuotationStatus status) async {
    final runtime = await ref.read(runtimeProvider.future);
    final lines = await runtime.database.getQuotationLines(quote.id);
    final changed = QuotationHeader(
      id: quote.id,
      organizationId: quote.organizationId,
      branchId: quote.branchId,
      quotationNumber: quote.quotationNumber,
      revisionNumber: quote.revisionNumber,
      customerPartyId: quote.customerPartyId,
      customerName: quote.customerName,
      validUntil: quote.validUntil,
      status: status,
      subtotalPaise: quote.subtotalPaise,
      allocatedDiscountPaise: quote.allocatedDiscountPaise,
      totalTaxPaise: quote.totalTaxPaise,
      grandTotalPaise: quote.grandTotalPaise,
      installationChargesPaise: quote.installationChargesPaise,
      termsSnapshot: quote.termsSnapshot,
      createdAtUtc: quote.createdAtUtc,
    );
    await runtime.database.saveQuotation(header: changed, lines: lines);
    ref.invalidate(quotationListProvider);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _previewQuotation(
    QuotationHeader quote,
    List<QuotationLine> lines,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quotation Preview'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SHREE KRUSHNA SALES',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('Quotation ${quote.quotationNumber}'),
              const Divider(),
              Text('Customer: ${quote.customerName}'),
              ...lines.map(
                (line) => Text(
                  '${line.productName}  ×${line.quantity.inUnits}  ${formatIndianCurrency(line.netTotalPaise.inRupees)}',
                ),
              ),
              const Divider(),
              Text(
                'Grand Total: ${formatIndianCurrency(quote.grandTotalPaise.inRupees)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Valid until: ${_date(quote.validUntil)}'),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _convertToProject(QuotationHeader quote) async {
    final name = TextEditingController(
      text: 'Solar installation - ${quote.customerName}',
    );
    final address = TextEditingController();
    final values = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Project name'),
            ),
            TextField(
              controller: address,
              decoration: const InputDecoration(labelText: 'Site address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, (name.text, address.text)),
            child: const Text('Create Project'),
          ),
        ],
      ),
    );
    if (values == null) return;
    try {
      final runtime = await ref.read(runtimeProvider.future);
      await ApproveQuotationUseCase(
        projectStore: runtime.database,
        accountingStore: runtime.database,
      ).execute(
        CommandContext(
          session: _effectiveSession(),
          timestampUtc: DateTime.now(),
        ),
        quotationId: quote.id,
        projectName: values.$1,
        siteAddress: values.$2,
      );
      ref.invalidate(quotationListProvider);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create project: $error')),
        );
      }
    }
  }

  UserSession _effectiveSession() =>
      ref.read(authProvider) ??
      UserSession(
        id: const SessionId('quotation_session'),
        userId: const UserId('admin'),
        username: 'admin',
        roleId: Role.adminRoleId,
        branchId: const BranchId('br_1'),
        capabilities: Capability.values.toSet(),
        token: 'local',
        expiresAtUtc: DateTime.now().add(const Duration(hours: 1)),
        lastActivityAtUtc: DateTime.now(),
      );
  IconData _statusIcon(QuotationStatus status) =>
      status == QuotationStatus.approved
      ? Icons.check_circle
      : status == QuotationStatus.rejected
      ? Icons.cancel
      : Icons.description_outlined;
  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

final class _QuotationDraftLine {
  _QuotationDraftLine(this.product)
    : quantity = 1,
      unitPrice = product.sellingPricePaise / 100;
  final Product product;
  double quantity;
  double unitPrice;
  double get taxable => quantity * unitPrice;
  double get tax => taxable * product.defaultTaxRateBps / 10000;
  double get total => taxable + tax;
}

extension on Iterable<_QuotationDraftLine> {
  _QuotationDraftLine? get firstOrNull => isEmpty ? null : first;
}
