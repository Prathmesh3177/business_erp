import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';
import '../common/erp_shell.dart';
import '../inventory/add_product_dialog.dart';

final class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

final class _CatalogPageState extends ConsumerState<CatalogPage> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final runtime = await ref.read(runtimeProvider.future);
      final orgId = runtime.identity?.organization.id.value ?? 'default_org';
      final prods = await runtime.database.searchProducts(orgId, includeInactive: true);
      if (mounted) {
        setState(() {
          _products = prods;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _products = const [];
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authProvider);
    final hasCostAccess =
        session?.hasCapability(Capability.costDataRead) ?? false;
    final isAdministrator = session?.roleId == Role.adminRoleId;

    final filteredProducts = _products.where((p) {
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
              onPressed: () async {
                final added = await AddProductDialog.show(context);
                if (added == true) {
                  _loadProducts();
                }
              },
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
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: Card(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          _products.isEmpty
                              ? 'No products in catalog yet. Click Add Product to create one.'
                              : 'No products match this search.',
                        ),
                      )
                    : ListView.separated(
                  itemCount: filteredProducts.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ListTile(
                      leading: _buildProductThumbnail(product),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (product.isMadeToOrder)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF2E7D32)),
                              ),
                              child: const Text(
                                'Made to Order',
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
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
                            runSpacing: 4,
                            children: [
                              if (product.isMadeToOrder)
                                Chip(
                                  avatar: const Icon(Icons.build_circle_outlined, size: 14, color: Color(0xFF2E7D32)),
                                  label: const Text(
                                    'Made to Order',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  backgroundColor: const Color(0xFFE8F5E9),
                                  side: const BorderSide(color: Color(0xFF2E7D32), width: 0.5),
                                ),
                              if (product.attributes['supplierName'] != null)
                                Chip(
                                  avatar: const Icon(Icons.business_outlined, size: 14, color: Color(0xFF004D40)),
                                  label: Text(
                                    'Supplier: ${product.attributes['supplierName']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF004D40),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  backgroundColor: const Color(0xFFE0F2F1),
                                  side: const BorderSide(color: Color(0xFF004D40), width: 0.5),
                                ),
                              ...product.attributes.entries
                                  .where((e) => !['imageUrl', 'image', 'supplierId', 'supplierName'].contains(e.key))
                                  .map((e) {
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
                              }),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
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
                          if (isAdministrator) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              tooltip: 'Edit Product',
                              onPressed: () async {
                                final updated = await AddProductDialog.show(
                                  context,
                                  existingProduct: product,
                                );
                                if (updated == true) {
                                  _loadProducts();
                                }
                              },
                            ),
                          ],
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

  Widget _buildProductThumbnail(Product product) {
    final img = product.imageUrl;
    if (img != null && img.trim().isNotEmpty) {
      if (img.startsWith('http://') || img.startsWith('https://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            img,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildCategoryAvatar(product.categoryId),
          ),
        );
      } else if (img.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            img,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildCategoryAvatar(product.categoryId),
          ),
        );
      }
    }
    return _buildCategoryAvatar(product.categoryId);
  }

  Widget _buildCategoryAvatar(String categoryId) {
    return CircleAvatar(
      backgroundColor: const Color(0xFF990000).withValues(alpha: 0.1),
      child: Icon(
        _getCategoryIcon(categoryId),
        color: const Color(0xFF990000),
      ),
    );
  }
}
