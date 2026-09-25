import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class PartiesPage extends ConsumerStatefulWidget {
  const PartiesPage({super.key});

  @override
  ConsumerState<PartiesPage> createState() => _PartiesPageState();
}

final class _PartiesPageState extends ConsumerState<PartiesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  final List<Party> _mockParties = [
    Party(
      id: 'party_1',
      organizationId: 'org1',
      name: 'M/S Rahul Solar Installation',
      isCustomer: true,
      isSupplier: false,
      gstin: '27AAAAA0000A1Z5',
      pan: 'AAAAA0000A',
      creditLimitPaise: 50000000, // ₹5,00,000
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Party(
      id: 'party_2',
      organizationId: 'org1',
      name: 'Waaree Energies Ltd',
      isCustomer: false,
      isSupplier: true,
      gstin: '27WAARE1234A1Z1',
      pan: 'WAARE1234A',
      paymentTermsDays: 45,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: const Icon(Icons.group_add),
            tooltip: 'Add Party',
            onPressed: () => _showAddPartyDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Party by Name, GSTIN...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    final filtered = _mockParties.where((p) {
      final matchesRole = isCustomer ? p.isCustomer : p.isSupplier;
      final matchesQuery = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.gstin?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
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

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final party = filtered[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF004D40).withValues(alpha: 0.1),
              child: Icon(isCustomer ? Icons.person : Icons.business, color: const Color(0xFF004D40)),
            ),
            title: Text(party.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('GSTIN: ${party.gstin ?? 'Unregistered'} | Terms: ${party.paymentTermsDays} Days'),
            trailing: isCustomer
                ? Text(
                    'Limit: ₹${(party.creditLimitPaise / 100).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF990000)),
                  )
                : const Chip(label: Text('Supplier'), backgroundColor: Colors.amber),
          ),
        );
      },
    );
  }

  void _showAddPartyDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final gstinCtrl = TextEditingController();
    final creditCtrl = TextEditingController(text: '100000');
    bool isCustomer = true;
    bool isSupplier = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Party Master'),
        content: StatefulBuilder(
          builder: (context, setDlgState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Party Legal Name')),
              TextField(controller: gstinCtrl, decoration: const InputDecoration(labelText: 'GSTIN (15 Alphanumeric)')),
              TextField(controller: creditCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Credit Limit (₹)')),
              Row(
                children: [
                  Checkbox(
                    value: isCustomer,
                    onChanged: (val) => setDlgState(() => isCustomer = val ?? true),
                  ),
                  const Text('Customer'),
                  const SizedBox(width: 16),
                  Checkbox(
                    value: isSupplier,
                    onChanged: (val) => setDlgState(() => isSupplier = val ?? false),
                  ),
                  const Text('Supplier'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF990000)),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && (isCustomer || isSupplier)) {
                try {
                  final newParty = Party(
                    id: 'party_${DateTime.now().millisecondsSinceEpoch}',
                    organizationId: 'org1',
                    name: nameCtrl.text,
                    isCustomer: isCustomer,
                    isSupplier: isSupplier,
                    gstin: gstinCtrl.text.isEmpty ? null : gstinCtrl.text,
                    creditLimitPaise: ((double.tryParse(creditCtrl.text) ?? 0) * 100).round(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  setState(() => _mockParties.add(newParty));
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Save Party'),
          ),
        ],
      ),
    );
  }
}
