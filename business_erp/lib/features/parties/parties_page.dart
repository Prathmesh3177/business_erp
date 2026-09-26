import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../common/erp_shell.dart';
import 'party_detail_page.dart';

final class PartiesPage extends ConsumerStatefulWidget {
  const PartiesPage({super.key});

  @override
  ConsumerState<PartiesPage> createState() => _PartiesPageState();
}

final class _PartiesPageState extends ConsumerState<PartiesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  List<Party> _parties = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _loadParties();
  }

  Future<void> _loadParties() async {
    try {
      final runtime = await ref.read(runtimeProvider.future);
      final orgId = runtime.identity?.organization.id.value ?? 'default_org';
      final all = await runtime.database.searchParties(orgId);
      if (mounted) {
        setState(() {
          _parties = all;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading parties: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErpFeatureScaffold(
      appBar: AppBar(
        title: const Text('Party Masters (Customers & Suppliers)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Customers'),
            Tab(icon: Icon(Icons.local_shipping), text: 'Suppliers'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() => _loading = true);
              _loadParties();
            },
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: 'Add Party',
            onPressed: _showAddPartyDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Party by Name, GSTIN...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPartyList(isCustomer: true),
                      _buildPartyList(isCustomer: false),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPartyList({required bool isCustomer}) {
    final filtered = _parties.where((p) {
      final matchesRole = isCustomer ? p.isCustomer : p.isSupplier;
      final matchesQuery =
          _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.gstin?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
      return matchesRole && matchesQuery;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          isCustomer ? 'No customers found.' : 'No suppliers found.',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadParties,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: filtered.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final party = filtered[index];
          return Card(
            child: ListTile(
              onTap: isCustomer
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PartyDetailPage(partyId: party.id),
                      ),
                    )
                  : null,
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF004D40).withValues(alpha: 0.1),
                child: Icon(
                  isCustomer ? Icons.person : Icons.business,
                  color: const Color(0xFF004D40),
                ),
              ),
              title: Text(
                party.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'GSTIN: ${party.gstin ?? 'Unregistered'} | Terms: ${party.paymentTermsDays} Days',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCustomer)
                    Text(
                      'Limit: ₹${(party.creditLimitPaise / 100).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF990000),
                      ),
                    )
                  else
                    const Chip(
                      label: Text('Supplier'),
                      backgroundColor: Colors.amber,
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit Party',
                    onPressed: () => _showEditPartyDialog(party),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddPartyDialog() {
    final nameCtrl = TextEditingController();
    final gstinCtrl = TextEditingController();
    final creditCtrl = TextEditingController(text: '100000');
    final phoneCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    bool isCustomer = _tabController.index == 0;
    bool isSupplier = _tabController.index == 1;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Party Master'),
        content: StatefulBuilder(
          builder: (context, setDlgState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Party Legal Name *',
                  ),
                ),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                TextField(
                  controller: cityCtrl,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                TextField(
                  controller: gstinCtrl,
                  decoration: const InputDecoration(
                    labelText: 'GSTIN (15 Alphanumeric)',
                  ),
                ),
                TextField(
                  controller: creditCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Credit Limit (₹)',
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Customer'),
                        selected: isCustomer,
                        onSelected: (_) => setDlgState(() {
                          isCustomer = true;
                          isSupplier = false;
                        }),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Supplier'),
                        selected: isSupplier,
                        onSelected: (_) => setDlgState(() {
                          isCustomer = false;
                          isSupplier = true;
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF990000),
            ),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Name is required.',
                    ),
                  ),
                );
                return;
              }
              try {
                final runtime = await ref.read(runtimeProvider.future);
                final orgId =
                    runtime.identity?.organization.id.value ?? 'default_org';
                final partyId =
                    'party_${DateTime.now().millisecondsSinceEpoch}';
                final cleanGstin = gstinCtrl.text.trim().toUpperCase();

                final newParty = Party(
                  id: partyId,
                  organizationId: orgId,
                  name: nameCtrl.text.trim(),
                  isCustomer: isCustomer,
                  isSupplier: isSupplier,
                  gstin: cleanGstin.isEmpty ? null : cleanGstin,
                  creditLimitPaise:
                      ((double.tryParse(creditCtrl.text) ?? 0) * 100).round(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                final newAddr = PartyAddress(
                  id: 'addr_$partyId',
                  partyId: partyId,
                  addressLine1: 'Main Market',
                  city: cityCtrl.text.trim().isEmpty
                      ? 'Kalamb'
                      : cityCtrl.text.trim(),
                  state: 'Maharashtra',
                  pincode: '413507',
                  stateCode: '27',
                );

                final newContact = PartyContact(
                  id: 'cont_$partyId',
                  partyId: partyId,
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                );

                await runtime.database.saveParty(
                  newParty,
                  addresses: [newAddr],
                  contacts: [newContact],
                );

                if (!mounted || !dialogContext.mounted) return;

                Navigator.pop(dialogContext);
                _loadParties(); // Refresh from database
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Party "${newParty.name}" saved successfully!',
                    ),
                    backgroundColor: Colors.green[800],
                  ),
                );
              } catch (e) {
                if (!mounted || !dialogContext.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save Party'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPartyDialog(Party party) async {
    final nameCtrl = TextEditingController(text: party.name);
    final gstinCtrl = TextEditingController(text: party.gstin ?? '');
    final creditCtrl = TextEditingController(
      text: (party.creditLimitPaise / 100).toStringAsFixed(0),
    );
    var isCustomer = party.isCustomer;
    var isSupplier = party.isSupplier;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Party'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Party legal name')),
                  const SizedBox(height: 12),
                  TextField(controller: gstinCtrl, decoration: const InputDecoration(labelText: 'GSTIN')),
                  const SizedBox(height: 12),
                  TextField(controller: creditCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Credit limit (₹)')),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: ChoiceChip(label: const Text('Customer'), selected: isCustomer, onSelected: (_) => setDialogState(() { isCustomer = true; isSupplier = false; }))),
                    const SizedBox(width: 12),
                    Expanded(child: ChoiceChip(label: const Text('Supplier'), selected: isSupplier, onSelected: (_) => setDialogState(() { isCustomer = false; isSupplier = true; }))),
                  ]),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final runtime = await ref.read(runtimeProvider.future);
                final updated = Party(
                  id: party.id,
                  organizationId: party.organizationId,
                  name: nameCtrl.text.trim(),
                  isCustomer: isCustomer,
                  isSupplier: isSupplier,
                  gstin: gstinCtrl.text.trim().isEmpty ? null : gstinCtrl.text.trim().toUpperCase(),
                  pan: party.pan,
                  paymentTermsDays: party.paymentTermsDays,
                  creditLimitPaise: ((double.tryParse(creditCtrl.text) ?? 0) * 100).round(),
                  active: party.active,
                  createdAt: party.createdAt,
                  updatedAt: DateTime.now(),
                );
                await runtime.database.saveParty(updated);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                _loadParties();
              },
              child: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
    gstinCtrl.dispose();
    creditCtrl.dispose();
  }
}
