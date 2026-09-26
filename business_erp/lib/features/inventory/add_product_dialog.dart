import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';
import '../../app/theme.dart';

/// Modal dialog allowing administrators to create a new product in the catalog
/// and optionally seed initial inventory stock in one cohesive step.
final class AddProductDialog extends ConsumerStatefulWidget {
  const AddProductDialog({super.key, this.existingProduct});

  final Product? existingProduct;

  static Future<bool?> show(BuildContext context, {Product? existingProduct}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddProductDialog(existingProduct: existingProduct),
    );
  }

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

final class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();

  // Required Field
  late final TextEditingController _nameController;

  // Optional Fields
  late final TextEditingController _skuController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _initialStockController;
  late final TextEditingController _hsnController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _minStockController;

  String _selectedCategory = 'solarPanel';
  String _selectedUnit = 'unit_pcs';
  int _selectedTaxRateBps = 1800; // 18% GST default
  bool _addInitialStock = true;
  bool _isMadeToOrder = false;
  bool _showAdvanced = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Party> _suppliers = [];
  String? _selectedSupplierId;

  static const Map<String, ({String label, String defaultHsn, IconData icon})> _categories = {
    'solarPanel': (
      label: 'Solar Panel',
      defaultHsn: '85414011',
      icon: Icons.solar_power,
    ),
    'solarInverter': (
      label: 'Solar Inverter',
      defaultHsn: '85044090',
      icon: Icons.electric_bolt,
    ),
    'solarBattery': (
      label: 'Solar Battery',
      defaultHsn: '85072000',
      icon: Icons.battery_charging_full,
    ),
    'solarCable': (
      label: 'Solar Cable',
      defaultHsn: '85444990',
      icon: Icons.cable,
    ),
    'solarPump': (
      label: 'Solar Water Pump',
      defaultHsn: '84137090',
      icon: Icons.water_drop,
    ),
    'mountingStructure': (
      label: 'Mounting Structure',
      defaultHsn: '73089000',
      icon: Icons.grid_view,
    ),
    'accessories': (
      label: 'Electrical Accessories',
      defaultHsn: '85369090',
      icon: Icons.settings_input_component,
    ),
    'other': (
      label: 'Other Hardware',
      defaultHsn: '85414011',
      icon: Icons.category,
    ),
  };

  static const List<({String id, String label})> _units = [
    (id: 'unit_pcs', label: 'Pieces (Pcs)'),
    (id: 'unit_set', label: 'Sets (Set)'),
    (id: 'unit_meter', label: 'Meters (M)'),
    (id: 'unit_nos', label: 'Numbers (Nos)'),
    (id: 'unit_kg', label: 'Kilograms (Kg)'),
    (id: 'unit_box', label: 'Boxes (Box)'),
  ];

  static const List<({int bps, String label})> _gstRates = [
    (bps: 0, label: '0% (Exempt)'),
    (bps: 500, label: '5% GST'),
    (bps: 1200, label: '12% GST'),
    (bps: 1800, label: '18% GST (Standard)'),
    (bps: 2800, label: '28% GST'),
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    if (p != null) {
      _nameController = TextEditingController(text: p.name);
      _skuController = TextEditingController(text: p.sku);
      _imageUrlController = TextEditingController(
        text: p.attributes['imageUrl'] ?? p.attributes['image'] ?? '',
      );
      _purchasePriceController = TextEditingController(
        text: p.costPricePaise > 0 ? (p.costPricePaise / 100).toStringAsFixed(2) : '',
      );
      _sellingPriceController = TextEditingController(
        text: p.sellingPricePaise > 0 ? (p.sellingPricePaise / 100).toStringAsFixed(2) : '',
      );
      _initialStockController = TextEditingController(text: '0');
      _hsnController = TextEditingController(text: p.hsnCode);
      _brandController = TextEditingController(text: p.brandId ?? '');
      _modelController = TextEditingController(text: p.model ?? '');
      _minStockController = TextEditingController(text: p.minStock.toString());
      _selectedCategory = _categories.containsKey(p.categoryId) ? p.categoryId : 'solarPanel';
      _selectedUnit = p.baseUnitId.isNotEmpty ? p.baseUnitId : 'unit_pcs';
      _selectedTaxRateBps = p.defaultTaxRateBps;
      _isMadeToOrder = p.isMadeToOrder;
      _addInitialStock = false;
      _selectedSupplierId = p.attributes['supplierId'];
    } else {
      _nameController = TextEditingController();
      _skuController = TextEditingController();
      _imageUrlController = TextEditingController();
      _purchasePriceController = TextEditingController();
      _sellingPriceController = TextEditingController();
      _initialStockController = TextEditingController(text: '10');
      _hsnController = TextEditingController(text: _categories[_selectedCategory]!.defaultHsn);
      _brandController = TextEditingController();
      _modelController = TextEditingController();
      _minStockController = TextEditingController(text: '0');
    }

    _imageUrlController.addListener(() {
      if (mounted) setState(() {});
    });

    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    try {
      final runtime = await ref.read(runtimeProvider.future);
      final orgId = runtime.identity?.organization.id.value ?? 'default_org';
      final suppliers = await runtime.database.searchParties(orgId, isSupplier: true);

      String? matchedSupplierId = _selectedSupplierId;
      if (matchedSupplierId == null && widget.existingProduct != null) {
        final links = await runtime.database.getProductSupplierLinks(widget.existingProduct!.id);
        if (links.isNotEmpty) {
          matchedSupplierId = links.first.partyId;
        }
      }

      if (mounted) {
        setState(() {
          _suppliers = suppliers;
          _selectedSupplierId = matchedSupplierId;
        });
      }
    } catch (_) {}
  }

  Future<void> _showQuickAddSupplierDialog() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final gstinCtrl = TextEditingController();

    final created = await showDialog<Party>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Add New Supplier'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Supplier Legal Name *',
                  hintText: 'e.g. Tata Power Solar',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g. 9876543210',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gstinCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'GSTIN (Optional)',
                  hintText: '27AAAAA0000A1Z5',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              try {
                final runtime = await ref.read(runtimeProvider.future);
                final orgId = runtime.identity?.organization.id.value ?? 'default_org';
                final partyId = 'supp_${DateTime.now().millisecondsSinceEpoch}';
                final cleanGstin = gstinCtrl.text.trim().toUpperCase();

                final newParty = Party(
                  id: partyId,
                  organizationId: orgId,
                  name: name,
                  isCustomer: false,
                  isSupplier: true,
                  gstin: cleanGstin.isEmpty ? null : cleanGstin,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                final newAddr = PartyAddress(
                  id: 'addr_$partyId',
                  partyId: partyId,
                  addressLine1: 'Main Market',
                  city: 'Kalamb',
                  state: 'Maharashtra',
                  pincode: '413507',
                  stateCode: '27',
                );

                final newContact = PartyContact(
                  id: 'cont_$partyId',
                  partyId: partyId,
                  name: name,
                  phone: phoneCtrl.text.trim(),
                );

                await runtime.database.saveParty(
                  newParty,
                  addresses: [newAddr],
                  contacts: [newContact],
                );

                if (dialogCtx.mounted) {
                  Navigator.pop(dialogCtx, newParty);
                }
              } catch (e) {
                if (dialogCtx.mounted) {
                  ScaffoldMessenger.of(dialogCtx).showSnackBar(
                    SnackBar(content: Text('Error adding supplier: $e')),
                  );
                }
              }
            },
            child: const Text('Save Supplier'),
          ),
        ],
      ),
    );

    if (created != null && mounted) {
      await _loadSuppliers();
      setState(() {
        _selectedSupplierId = created.id;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Supplier "${created.name}" added and selected!'),
            backgroundColor: const Color(0xFF004D40),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _imageUrlController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _initialStockController.dispose();
    _hsnController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? newCat) {
    if (newCat == null || newCat == _selectedCategory) return;
    final oldCatDefaultHsn = _categories[_selectedCategory]?.defaultHsn;
    final newCatDefaultHsn = _categories[newCat]?.defaultHsn ?? '85414011';

    setState(() {
      _selectedCategory = newCat;
      // Auto-update HSN if empty or was set to previous default
      if (_hsnController.text.trim().isEmpty || _hsnController.text.trim() == oldCatDefaultHsn) {
        _hsnController.text = newCatDefaultHsn;
      }
    });
  }

  String _autoGenerateSku(String name, String category) {
    final prefix = switch (category) {
      'solarPanel' => 'PNL',
      'solarInverter' => 'INV',
      'solarBattery' => 'BAT',
      'solarCable' => 'CBL',
      'solarPump' => 'PMP',
      'mountingStructure' => 'STR',
      'accessories' => 'ACC',
      _ => 'PRD',
    };
    final cleanName = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    final slug = cleanName.length > 5 ? cleanName.substring(0, 5) : cleanName;
    final suffix = (DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    return '$prefix-$slug-$suffix';
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final session = ref.read(authProvider);
    if (session == null || session.roleId != Role.adminRoleId) {
      setState(() {
        _errorMessage = 'Permission denied. Only administrators can add or edit products.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final runtime = await ref.read(runtimeProvider.future);
      final orgId = runtime.identity?.organization.id.value ?? 'default_org';
      final branchId = runtime.identity?.branch.id.value ?? 'main_branch';
      final commandContext = CommandContext(
        session: session,
        timestampUtc: DateTime.now(),
      );

      final name = _nameController.text.trim();
      final sku = _skuController.text.trim().isNotEmpty
          ? _skuController.text.trim().toUpperCase()
          : _autoGenerateSku(name, _selectedCategory);

      final purchasePriceRupees = double.tryParse(_purchasePriceController.text.trim()) ?? 0.0;
      final sellingPriceRupees = double.tryParse(_sellingPriceController.text.trim()) ?? 0.0;
      final costPricePaise = (purchasePriceRupees * 100).round();
      final sellingPricePaise = (sellingPriceRupees * 100).round();

      final now = DateTime.now();

      // Edit existing product flow
      if (widget.existingProduct != null) {
        final existing = widget.existingProduct!;
        final updatedAttributes = Map<String, String>.from(existing.attributes);
        final imageUrl = _imageUrlController.text.trim();
        if (imageUrl.isNotEmpty) {
          updatedAttributes['imageUrl'] = imageUrl;
        } else {
          updatedAttributes.remove('imageUrl');
        }
        if (_selectedSupplierId != null) {
          updatedAttributes['supplierId'] = _selectedSupplierId!;
          final sup = _suppliers.where((s) => s.id == _selectedSupplierId).firstOrNull;
          if (sup != null) {
            updatedAttributes['supplierName'] = sup.name;
          }
        } else {
          updatedAttributes.remove('supplierId');
          updatedAttributes.remove('supplierName');
        }

        final updatedProduct = existing.copyWith(
          name: name,
          sku: sku,
          categoryId: _selectedCategory,
          brandId: _brandController.text.trim().isNotEmpty ? _brandController.text.trim() : null,
          model: _modelController.text.trim().isNotEmpty ? _modelController.text.trim() : null,
          baseUnitId: _selectedUnit,
          minStock: double.tryParse(_minStockController.text.trim()) ?? 0.0,
          hsnCode: _hsnController.text.trim().isNotEmpty
              ? _hsnController.text.trim()
              : (_categories[_selectedCategory]?.defaultHsn ?? '85414011'),
          defaultTaxRateBps: _selectedTaxRateBps,
          costPricePaise: costPricePaise,
          sellingPricePaise: sellingPricePaise,
          isMadeToOrder: _isMadeToOrder,
          attributes: updatedAttributes,
          updatedAt: now,
        );

        await runtime.database.saveProduct(updatedProduct);

        if (_selectedSupplierId != null) {
          await runtime.database.saveProductSupplierLink(
            ProductSupplierLink(
              id: 'psl_${existing.id}_$_selectedSupplierId',
              productId: existing.id,
              partyId: _selectedSupplierId!,
              supplierProductCode: sku,
              isPrimary: true,
            ),
          );
        }

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF004D40),
              content: Text('Product "$name" updated successfully!'),
            ),
          );
        }
        return;
      }

      // Add new product flow
      final attributes = <String, String>{};
      final imageUrl = _imageUrlController.text.trim();
      if (imageUrl.isNotEmpty) {
        attributes['imageUrl'] = imageUrl;
      }
      if (_selectedSupplierId != null) {
        attributes['supplierId'] = _selectedSupplierId!;
        final sup = _suppliers.where((s) => s.id == _selectedSupplierId).firstOrNull;
        if (sup != null) {
          attributes['supplierName'] = sup.name;
        }
      }

      final productId = 'prod_${now.millisecondsSinceEpoch}';

      final product = Product(
        id: productId,
        organizationId: orgId,
        sku: sku,
        name: name,
        categoryId: _selectedCategory,
        brandId: _brandController.text.trim().isNotEmpty ? _brandController.text.trim() : null,
        model: _modelController.text.trim().isNotEmpty ? _modelController.text.trim() : null,
        baseUnitId: _selectedUnit,
        minStock: double.tryParse(_minStockController.text.trim()) ?? 0.0,
        hsnCode: _hsnController.text.trim().isNotEmpty
            ? _hsnController.text.trim()
            : (_categories[_selectedCategory]?.defaultHsn ?? '85414011'),
        defaultTaxRateBps: _selectedTaxRateBps,
        costPricePaise: costPricePaise,
        sellingPricePaise: sellingPricePaise,
        active: true,
        isMadeToOrder: _isMadeToOrder,
        attributes: attributes,
        createdAt: now,
        updatedAt: now,
      );

      // Save product to database
      await runtime.database.saveProduct(product);

      if (_selectedSupplierId != null) {
        await runtime.database.saveProductSupplierLink(
          ProductSupplierLink(
            id: 'psl_${product.id}_$_selectedSupplierId',
            productId: product.id,
            partyId: _selectedSupplierId!,
            supplierProductCode: sku,
            isPrimary: true,
          ),
        );
      }

      // Add to initial stock if requested
      final initialStockUnits = (!_isMadeToOrder && _addInitialStock)
          ? (double.tryParse(_initialStockController.text.trim()) ?? 0.0)
          : 0.0;

      if (initialStockUnits > 0) {
        final totalValuation = purchasePriceRupees > 0
            ? (initialStockUnits * purchasePriceRupees)
            : 0.0;

        await PostOpeningStockUseCase(
          inventoryStore: runtime.database,
          accountingStore: runtime.database,
        ).execute(
          commandContext,
          organizationId: orgId,
          branchId: branchId,
          productId: product.id,
          locationId: 'loc_default_sellable',
          quantity: Quantity.fromUnits(initialStockUnits),
          totalValue: Money.fromRupees(totalValuation),
          commandId: 'cmd_op_${now.millisecondsSinceEpoch}',
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF004D40),
            content: Text(
              initialStockUnits > 0
                  ? 'Product "$name" added with $initialStockUnits ${_selectedUnit.replaceFirst('unit_', '')} in stock!'
                  : 'Product "$name" added to catalog successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Widget _buildImagePreview() {
    final img = _imageUrlController.text.trim();
    final catInfo = _categories[_selectedCategory] ?? _categories['solarPanel']!;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: SolarColors.slate50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SolarColors.slate300),
      ),
      clipBehavior: Clip.antiAlias,
      child: img.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(catInfo.icon, size: 36, color: SolarColors.slate500),
                const SizedBox(height: 2),
                const Text(
                  'No Image',
                  style: TextStyle(fontSize: 10, color: SolarColors.slate500),
                ),
              ],
            )
          : (img.startsWith('http://') || img.startsWith('https://'))
              ? Image.network(
                  img,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.broken_image, size: 28, color: SolarColors.deepRed),
                      Text('Failed', style: TextStyle(fontSize: 9, color: SolarColors.deepRed)),
                    ],
                  ),
                )
              : (img.startsWith('assets/'))
                  ? Image.asset(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.broken_image, size: 28, color: SolarColors.deepRed),
                          Text('Failed', style: TextStyle(fontSize: 9, color: SolarColors.deepRed)),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.image, size: 28, color: SolarColors.info),
                        Text('Local', style: TextStyle(fontSize: 9, color: SolarColors.info)),
                      ],
                    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF990000).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add_box,
                        color: Color(0xFF990000),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.existingProduct != null
                                ? 'Edit Product'
                                : 'Add Product to Inventory',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: SolarColors.charcoal,
                            ),
                          ),
                          Text(
                            widget.existingProduct != null
                                ? 'Admin Portal • Update product catalog specifications'
                                : 'Admin Portal • Enter details & initial opening stock',
                            style: const TextStyle(
                              fontSize: 12,
                              color: SolarColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Error alert if any
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SolarColors.deepRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SolarColors.deepRed.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: SolarColors.deepRed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: SolarColors.deepRed,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Scrollable Form Body
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SECTION 1: Essential Details
                        const Text(
                          '1. Essential Product Info',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF004D40),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Product Name (REQUIRED)
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Product Name *',
                            hintText: 'e.g. 540W Mono PERC Solar Panel',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                            helperText: 'Required: Full name or model description',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Product name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Category & Unit of Measure
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  prefixIcon: Icon(Icons.category_outlined),
                                ),
                                items: _categories.entries.map((entry) {
                                  return DropdownMenuItem(
                                    value: entry.key,
                                    child: Row(
                                      children: [
                                        Icon(entry.value.icon, size: 18, color: const Color(0xFF004D40)),
                                        const SizedBox(width: 8),
                                        Text(entry.value.label),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: _onCategoryChanged,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedUnit,
                                decoration: const InputDecoration(
                                  labelText: 'Base Unit',
                                  prefixIcon: Icon(Icons.straighten_outlined),
                                ),
                                items: _units.map((u) {
                                  return DropdownMenuItem(
                                    value: u.id,
                                    child: Text(u.label),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedUnit = val);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // SECTION 2: Pricing & Stock (Optional)
                        const Text(
                          '2. Pricing & Stock Control (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF004D40),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _purchasePriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Purchase / Cost Price (₹)',
                                  hintText: '0.00',
                                  prefixIcon: Icon(Icons.currency_rupee),
                                  helperText: 'Optional: Unit cost to purchase',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _sellingPriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Selling Price (₹)',
                                  hintText: '0.00',
                                  prefixIcon: Icon(Icons.sell_outlined),
                                  helperText: 'Optional: Standard sales price',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Preferred Supplier (Optional)
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                key: ValueKey(_selectedSupplierId),
                                initialValue: _selectedSupplierId,
                                decoration: const InputDecoration(
                                  labelText: 'Preferred Supplier (Optional)',
                                  prefixIcon: Icon(Icons.business_outlined),
                                  helperText: 'Supplier providing this product',
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('None / Direct Purchase'),
                                  ),
                                  ..._suppliers.map((s) => DropdownMenuItem<String?>(
                                    value: s.id,
                                    child: Text(s.name),
                                  )),
                                ],
                                onChanged: (val) {
                                  setState(() => _selectedSupplierId = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: IconButton.outlined(
                                tooltip: 'Add New Supplier',
                                icon: const Icon(Icons.person_add_alt_1, color: Color(0xFF990000)),
                                onPressed: _showQuickAddSupplierDialog,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Made to Order / Order on Demand Switch
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Made to Order / Order on Demand',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: SolarColors.charcoal,
                              ),
                            ),
                            subtitle: const Text(
                              'Item is procured/fabricated on demand. Bypasses stock check at POS.',
                              style: TextStyle(
                                fontSize: 12,
                                color: SolarColors.slate500,
                              ),
                            ),
                            value: _isMadeToOrder,
                            activeThumbColor: const Color(0xFF004D40),
                            onChanged: (val) {
                              setState(() {
                                _isMadeToOrder = val;
                                if (_isMadeToOrder) {
                                  _addInitialStock = false;
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Initial Stock Card (Only for new products)
                        if (widget.existingProduct == null) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _isMadeToOrder
                                  ? Colors.grey.shade100
                                  : const Color(0xFF004D40).withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isMadeToOrder
                                    ? Colors.grey.shade300
                                    : const Color(0xFF004D40).withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: !_isMadeToOrder && _addInitialStock,
                                      activeColor: const Color(0xFF004D40),
                                      onChanged: _isMadeToOrder
                                          ? null
                                          : (val) {
                                              setState(() => _addInitialStock = val ?? false);
                                            },
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Add to initial inventory stock immediately',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: _isMadeToOrder
                                              ? Colors.grey.shade500
                                              : SolarColors.charcoal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_isMadeToOrder)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 36, top: 4),
                                    child: Text(
                                      'Initial stock disabled for Made-to-Order items.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                if (!_isMadeToOrder && _addInitialStock) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _initialStockController,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: InputDecoration(
                                            labelText: 'Initial Quantity (${_selectedUnit.replaceFirst('unit_', '')})',
                                            hintText: 'e.g. 10',
                                            prefixIcon: const Icon(Icons.all_inbox_outlined),
                                            helperText: 'Posted to Main Warehouse (Sellable)',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        // SECTION 3: Image (Optional)
                        const Text(
                          '3. Product Image (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF004D40),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImagePreview(),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _imageUrlController,
                                    decoration: const InputDecoration(
                                      labelText: 'Image URL or Asset Path (Optional)',
                                      hintText: 'https://... or assets/images/...',
                                      prefixIcon: Icon(Icons.image_outlined),
                                      helperText: 'Web image URL or local asset image',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      ActionChip(
                                        label: const Text('Solar Pump Hero Asset', style: TextStyle(fontSize: 11)),
                                        avatar: const Icon(Icons.photo, size: 14),
                                        onPressed: () {
                                          _imageUrlController.text = 'assets/images/solar_pump_hero.png';
                                        },
                                      ),
                                      ActionChip(
                                        label: const Text('Solar Panel URL', style: TextStyle(fontSize: 11)),
                                        avatar: const Icon(Icons.link, size: 14),
                                        onPressed: () {
                                          _imageUrlController.text =
                                              'https://images.unsplash.com/photo-1509391365360-2e959784a276?w=400';
                                        },
                                      ),
                                      if (_imageUrlController.text.isNotEmpty)
                                        ActionChip(
                                          label: const Text('Clear', style: TextStyle(fontSize: 11)),
                                          avatar: const Icon(Icons.clear, size: 14),
                                          onPressed: () {
                                            _imageUrlController.clear();
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // SECTION 4: Advanced Optional Fields (Toggleable)
                        InkWell(
                          onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  _showAdvanced ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: SolarColors.slate500,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _showAdvanced ? 'Hide Advanced Settings' : 'Show More Optional Fields (SKU, HSN, GST, Brand)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: SolarColors.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_showAdvanced) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _skuController,
                                  decoration: const InputDecoration(
                                    labelText: 'SKU / Barcode (Optional)',
                                    hintText: 'Auto-generated if blank',
                                    prefixIcon: Icon(Icons.qr_code),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _hsnController,
                                  decoration: const InputDecoration(
                                    labelText: 'HSN Code',
                                    prefixIcon: Icon(Icons.tag),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  initialValue: _selectedTaxRateBps,
                                  decoration: const InputDecoration(
                                    labelText: 'GST Tax Rate',
                                    prefixIcon: Icon(Icons.percent),
                                  ),
                                  items: _gstRates.map((g) {
                                    return DropdownMenuItem(
                                      value: g.bps,
                                      child: Text(g.label),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedTaxRateBps = val);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _minStockController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Min Stock Alert',
                                    hintText: '0',
                                    prefixIcon: Icon(Icons.notification_important_outlined),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _brandController,
                                  decoration: const InputDecoration(
                                    labelText: 'Brand / Make (Optional)',
                                    hintText: 'e.g. Waaree, Luminous',
                                    prefixIcon: Icon(Icons.branding_watermark_outlined),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _modelController,
                                  decoration: const InputDecoration(
                                    labelText: 'Model Number (Optional)',
                                    prefixIcon: Icon(Icons.build_circle_outlined),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Dialog Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF990000),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      onPressed: _isSaving ? null : _handleSave,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        _isSaving
                            ? 'Saving...'
                            : (widget.existingProduct != null
                                ? 'Update Product'
                                : 'Save & Add to Inventory'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
