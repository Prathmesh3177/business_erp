import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';

final class AccountingPage extends ConsumerStatefulWidget {
  const AccountingPage({super.key});

  @override
  ConsumerState<AccountingPage> createState() => _AccountingPageState();
}

final class _AccountingPageState extends ConsumerState<AccountingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounting & GST Engine'),
        backgroundColor: const Color(0xFF990000),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.account_tree), text: 'Chart of Accounts'),
            Tab(icon: Icon(Icons.menu_book), text: 'Party Ledgers'),
            Tab(icon: Icon(Icons.calculate), text: 'GST Simulator'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ChartOfAccountsTab(),
          _PartyLedgersTab(),
          _GstSimulatorTab(),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. Chart of Accounts Tab
// -----------------------------------------------------------------------------
final class _ChartOfAccountsTab extends ConsumerStatefulWidget {
  const _ChartOfAccountsTab();

  @override
  ConsumerState<_ChartOfAccountsTab> createState() => _ChartOfAccountsTabState();
}

final class _ChartOfAccountsTabState extends ConsumerState<_ChartOfAccountsTab> {
  List<Account> _accounts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity?.organization.id.value ?? 'default_org';
    final list = await runtime.database.getAccounts(orgId);
    if (mounted) {
      setState(() {
        _accounts = list;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'General Ledger Accounts (${_accounts.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF004D40),
                    ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF990000),
                  foregroundColor: Colors.white,
                ),
                onPressed: _showAddAccountDialog,
                icon: const Icon(Icons.add),
                label: const Text('New Account'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              elevation: 2,
              child: ListView.separated(
                itemCount: _accounts.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final acc = _accounts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getAccountTypeColor(acc.type).withAlpha(40),
                      foregroundColor: _getAccountTypeColor(acc.type),
                      child: Text(
                        acc.code,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      acc.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Type: ${acc.type.name.toUpperCase()} | Role: ${acc.controlRole.name}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Chip(
                      label: Text(
                        acc.type.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: _getAccountTypeColor(acc.type),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccountTypeColor(AccountType type) {
    switch (type) {
      case AccountType.asset:
        return const Color(0xFF004D40); // Pine Green
      case AccountType.liability:
        return const Color(0xFF990000); // Crimson
      case AccountType.equity:
        return Colors.indigo;
      case AccountType.revenue:
        return Colors.teal;
      case AccountType.expense:
        return Colors.deepOrange;
    }
  }

  Future<void> _showAddAccountDialog() async {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    AccountType selectedType = AccountType.asset;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add General Ledger Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Account Code (e.g. 1400)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AccountType>(
                initialValue: selectedType,
                decoration: const InputDecoration(labelText: 'Account Type'),
                items: AccountType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedType = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF990000)),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result == true && codeController.text.isNotEmpty && nameController.text.isNotEmpty) {
      final runtime = await ref.read(runtimeProvider.future);
      final orgId = runtime.identity?.organization.id.value ?? 'default_org';
      final newAcc = Account(
        id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
        organizationId: orgId,
        code: codeController.text.trim(),
        name: nameController.text.trim(),
        type: selectedType,
      );
      await runtime.database.saveAccount(newAcc);
      _loadAccounts();
    }
  }
}

// -----------------------------------------------------------------------------
// 2. Party Ledgers Tab
// -----------------------------------------------------------------------------
final class _PartyLedgersTab extends ConsumerStatefulWidget {
  const _PartyLedgersTab();

  @override
  ConsumerState<_PartyLedgersTab> createState() => _PartyLedgersTabState();
}

final class _PartyLedgersTabState extends ConsumerState<_PartyLedgersTab> {
  List<Party> _parties = [];
  Party? _selectedParty;
  int _balancePaise = 0;
  List<JournalEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  Future<void> _loadParties() async {
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity?.organization.id.value ?? 'default_org';
    final list = await runtime.database.searchParties(orgId);
    if (mounted) {
      setState(() {
        _parties = list;
        _loading = false;
        if (list.isNotEmpty) {
          _selectedParty = list.first;
          _selectParty(list.first);
        }
      });
    }
  }

  Future<void> _selectParty(Party party) async {
    setState(() {
      _selectedParty = party;
      _loading = true;
    });

    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity?.organization.id.value ?? 'default_org';
    final balance = await runtime.database.getPartyBalancePaise(orgId, party.id);
    final entries = await runtime.database.getJournalEntries(orgId, partyId: party.id);

    if (mounted) {
      setState(() {
        _balancePaise = balance;
        _entries = entries;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _parties.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Party>(
                  initialValue: _selectedParty,
                  decoration: const InputDecoration(
                    labelText: 'Select Customer / Supplier Party',
                    border: OutlineInputBorder(),
                  ),
                  items: _parties
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text('${p.name} ${p.gstin != null ? "(${p.gstin})" : ""}'),
                          ))
                      .toList(),
                  onChanged: (p) {
                    if (p != null) _selectParty(p);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedParty != null) ...[
            Card(
              color: _balancePaise >= 0 ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedParty!.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'GSTIN: ${_selectedParty!.gstin ?? "N/A"} | Terms: ${_selectedParty!.paymentTermsDays} Days',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Net Balance',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          '₹${(_balancePaise.abs() / 100).toStringAsFixed(2)} '
                          '${_balancePaise >= 0 ? "Dr (Receivable)" : "Cr (Payable)"}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _balancePaise >= 0 ? const Color(0xFF004D40) : const Color(0xFF990000),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ledger Journal Transactions (${_entries.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _entries.isEmpty
                  ? const Center(child: Text('No journal transactions recorded for this party.'))
                  : ListView.builder(
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            title: Text(
                              'Document ID: ${entry.documentId}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${entry.memo} • ${entry.postingDate.toLocal().toString().split(" ")[0]}'),
                            children: entry.lines.map((l) {
                              return ListTile(
                                dense: true,
                                title: Text('Account ID: ${l.accountId}'),
                                trailing: Text(
                                  l.debitPaise > 0
                                      ? 'Dr: ₹${(l.debitPaise / 100).toStringAsFixed(2)}'
                                      : 'Cr: ₹${(l.creditPaise / 100).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: l.debitPaise > 0 ? const Color(0xFF004D40) : const Color(0xFF990000),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. GST Tax Simulator Tab
// -----------------------------------------------------------------------------
final class _GstSimulatorTab extends StatefulWidget {
  const _GstSimulatorTab();

  @override
  State<_GstSimulatorTab> createState() => _GstSimulatorTabState();
}

final class _GstSimulatorTabState extends State<_GstSimulatorTab> {
  TaxSupplyType _supplyType = TaxSupplyType.intraState;
  bool _pricesIncludeTax = false;
  final _unitPriceController = TextEditingController(text: '1000.00');
  final _qtyController = TextEditingController(text: '10');
  final _discountPctController = TextEditingController(text: '5');
  int _selectedTaxBps = 1800; // 18% GST

  TaxInvoiceResult? _result;

  @override
  void initState() {
    super.initState();
    _calculateTax();
  }

  void _calculateTax() {
    try {
      final unitPriceVal = double.tryParse(_unitPriceController.text) ?? 0;
      final qtyVal = double.tryParse(_qtyController.text) ?? 0;
      final discountPctVal = double.tryParse(_discountPctController.text) ?? 0;

      final unitPrice = UnitPrice.fromRupees(unitPriceVal);
      final qty = Quantity.fromUnits(qtyVal > 0 ? qtyVal : 1.0);

      final lineReq = TaxLineRequest(
        lineId: 'line_1',
        unitPrice: unitPrice,
        quantity: qty,
        taxRate: TaxRate.fromBps(_selectedTaxBps),
        isTaxInclusive: _pricesIncludeTax,
      );

      final grossTotalRupees = unitPriceVal * qtyVal;
      final invoiceDiscRupees = grossTotalRupees * (discountPctVal / 100.0);

      final invoiceRes = const TaxEngine().calculateInvoiceTax(
        lines: [lineReq],
        supplyType: _supplyType,
        invoiceDiscount: Money.fromRupees(invoiceDiscRupees),
      );

      setState(() {
        _result = invoiceRes;
      });
    } catch (_) {
      // Ignore parsing failures during input typing
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Indian GST Tax Engine Simulator',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF990000),
                        ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<TaxSupplyType>(
                    segments: const [
                      ButtonSegment(
                        value: TaxSupplyType.intraState,
                        label: Text('Intra-State (CGST + SGST)'),
                        icon: Icon(Icons.home_work),
                      ),
                      ButtonSegment(
                        value: TaxSupplyType.interState,
                        label: Text('Inter-State (IGST)'),
                        icon: Icon(Icons.local_shipping),
                      ),
                    ],
                    selected: {_supplyType},
                    onSelectionChanged: (newSelection) {
                      setState(() => _supplyType = newSelection.first);
                      _calculateTax();
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Prices Include Tax (Tax Inclusive)'),
                    subtitle: const Text('Extract taxable amount backward from gross price'),
                    value: _pricesIncludeTax,
                    onChanged: (val) {
                      setState(() => _pricesIncludeTax = val);
                      _calculateTax();
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _unitPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Unit Price (₹)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateTax(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _qtyController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateTax(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _discountPctController,
                          decoration: const InputDecoration(
                            labelText: 'Invoice Discount %',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateTax(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedTaxBps,
                          decoration: const InputDecoration(
                            labelText: 'GST Rate',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('0% Exempt')),
                            DropdownMenuItem(value: 500, child: Text('5% GST')),
                            DropdownMenuItem(value: 1200, child: Text('12% GST')),
                            DropdownMenuItem(value: 1800, child: Text('18% GST')),
                            DropdownMenuItem(value: 2800, child: Text('28% GST')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedTaxBps = val);
                              _calculateTax();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_result != null) ...[
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFF004D40), width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GST Calculation Breakdown (Fixed-Point Engine)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF004D40),
                          ),
                    ),
                    const Divider(height: 24),
                    _summaryRow('Total Taxable Value', '₹${_result!.subtotal.inRupees.toStringAsFixed(2)}'),
                    _summaryRow('CGST Amount', '₹${_result!.totalCgst.inRupees.toStringAsFixed(2)}'),
                    _summaryRow('SGST Amount', '₹${_result!.totalSgst.inRupees.toStringAsFixed(2)}'),
                    _summaryRow('IGST Amount', '₹${_result!.totalIgst.inRupees.toStringAsFixed(2)}'),
                    _summaryRow('Total Tax Amount', '₹${_result!.totalTax.inRupees.toStringAsFixed(2)}'),
                    _summaryRow('Invoice Discount Allocated', '₹${_result!.allocatedDiscount.inRupees.toStringAsFixed(2)}'),
                    _summaryRow('Round-off Adjustment', '₹${_result!.roundOff.inRupees.toStringAsFixed(2)}'),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Final Payable Invoice Total',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${_result!.grandTotal.inRupees.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF990000),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
