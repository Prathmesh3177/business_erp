import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth_controller.dart';
import '../common/erp_shell.dart';

final class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

final class _CatalogPageState extends ConsumerState<CatalogPage> {
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<Product> _mockProducts = [
    Product(
      id: 'p1',
      organizationId: 'org1',
      sku: 'SKS-PANEL-540W',
      name: 'Shree Krushna 540W Mono PERC Panel',
      categoryId: 'solarPanel',
      baseUnitId: 'Pcs',
      hsnCode: '85414011',
      costPricePaise: 1350000,
      sellingPricePaise: 1650000,
      attributes: {
        'wattage': '540W',
        'cell_type': 'Mono PERC',
        'efficiency': '21.3%',
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: 'p2',
      organizationId: 'org1',
      sku: 'SKS-INV-5KW',
      name: '5kW Hybrid Solar Inverter (3-Phase)',
      categoryId: 'solarInverter',
      baseUnitId: 'Pcs',
      hsnCode: '85044090',
      costPricePaise: 4200000,
      sellingPricePaise: 4950000,
      attributes: {
        'capacity': '5kW',
        'phase': 'Three Phase',
        'waveform': 'Pure Sine',
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: 'p3',
      organizationId: 'org1',
      sku: 'SKS-BAT-150AH',
      name: '150Ah Solar Tall Tubular Battery',
      categoryId: 'solarBattery',
      baseUnitId: 'Pcs',
      hsnCode: '85072000',
      costPricePaise: 1100000,
      sellingPricePaise: 1380000,
      attributes: {
        'capacity': '150Ah',
        'voltage': '12V',
        'type': 'C10 Lead Acid',
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authProvider);
    final hasCostAccess =
        session?.hasCapability(Capability.costDataRead) ?? false;
    final isAdministrator = session?.roleId == Role.adminRoleId;

    final filteredProducts = _mockProducts.where((p) {
      final matchesCategory =
          _selectedCategory == 'all' || p.categoryId == _selectedCategory;
      final matchesQuery =
          _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.hsnCode.contains(_searchQuery);
      return matchesCategory && matchesQuery;
    }).toList();

    return ErpFeatureScaffold(
      appBar: AppBar(
        title: const Text('Product Catalog & Solar Attributes'),
        actions: [
          if (isAdministrator)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Product',
              onPressed: () => _showAddProductDialog(context),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by SKU, Name, HSN...',
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
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All Products', 'all'),
                  _buildFilterChip('Solar Panels', 'solarPanel'),
                  _buildFilterChip('Inverters', 'solarInverter'),
                  _buildFilterChip('Batteries', 'solarBattery'),
                  _buildFilterChip('Cables', 'solarCable'),
                  _buildFilterChip('Pumps', 'solarPump'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: ListView.separated(
                  itemCount: filteredProducts.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF990000)
                            .withValues(alpha: 0.1),
                        child: Icon(
                          _getCategoryIcon(product.categoryId),
                          color: const Color(0xFF990000),
                        ),
                      ),
                      title: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SKU: ${product.sku} | HSN: ${product.hsnCode} | Unit: ${product.baseUnitId}',
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            children: product.attributes.entries.map((e) {
                              return Chip(
                                label: Text(
                                  '${e.key}: ${e.value}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                backgroundColor: const Color(0xFF004D40)
                                    .withValues(alpha: 0.1),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${(product.sellingPricePaise / 100).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF990000),
                            ),
                          ),
                          Text(
                            hasCostAccess
                                ? 'Cost: ₹${(product.costPricePaise / 100).toStringAsFixed(2)}'
                                : 'Cost: [REDACTED]',
                            style: TextStyle(
                              fontSize: 12,
                              color: hasCostAccess
                                  ? Colors.grey[700]
                                  : Colors.amber[900],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String categoryId) {
    final isSelected = _selectedCategory == categoryId;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF990000).withValues(alpha: 0.2),
        checkmarkColor: const Color(0xFF990000),
        onSelected: (_) => setState(() => _selectedCategory = categoryId),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'solarPanel':
        return Icons.solar_power;
      case 'solarInverter':
        return Icons.electric_bolt;
      case 'solarBattery':
        return Icons.battery_charging_full;
      case 'solarCable':
        return Icons.cable;
      case 'solarPump':
        return Icons.water_drop;
      default:
        return Icons.inventory_2;
    }
  }

  void _showAddProductDialog(BuildContext context) {
    final skuCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final hsnCtrl = TextEditingController(text: '85414011');
    final priceCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    String category = 'solarPanel';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Solar Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: skuCtrl,
                decoration: const InputDecoration(
                  labelText: 'SKU (e.g. SKS-PANEL-400)',
                ),
              ),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              DropdownButtonFormField<String>(
                initialValue: category,
                items: const [
                  DropdownMenuItem(
                    value: 'solarPanel',
                    child: Text('Solar Panel'),
                  ),
                  DropdownMenuItem(
                    value: 'solarInverter',
                    child: Text('Inverter'),
                  ),
                  DropdownMenuItem(
                    value: 'solarBattery',
                    child: Text('Battery'),
                  ),
                  DropdownMenuItem(value: 'solarCable', child: Text('Cable')),
                  DropdownMenuItem(value: 'solarPump', child: Text('Pump')),
                ],
                onChanged: (val) => category = val!,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: hsnCtrl,
                decoration: const InputDecoration(labelText: 'HSN Code'),
              ),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Selling Price (₹)',
                ),
              ),
              TextField(
                controller: costCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Purchase Cost (₹)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF990000),
            ),
            onPressed: () {
              if (skuCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                setState(() {
                  _mockProducts.add(
                    Product(
                      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                      organizationId: 'org1',
                      sku: skuCtrl.text,
                      name: nameCtrl.text,
                      categoryId: category,
                      baseUnitId: 'Pcs',
                      hsnCode: hsnCtrl.text,
                      costPricePaise:
                          ((double.tryParse(costCtrl.text) ?? 0) * 100).round(),
                      sellingPricePaise:
                          ((double.tryParse(priceCtrl.text) ?? 0) * 100)
                              .round(),
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save Product'),
          ),
        ],
      ),
    );
  }
}
