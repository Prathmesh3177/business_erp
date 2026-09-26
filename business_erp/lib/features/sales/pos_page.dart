import 'dart:convert';

import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';
import '../common/erp_shell.dart';
import '../common/indian_currency_formatter.dart';
import '../printing/invoice_preview_dialog.dart';
import '../printing/tax_invoice_widget.dart';

final class PosPage extends ConsumerStatefulWidget {
  const PosPage({super.key});

  @override
  ConsumerState<PosPage> createState() => _PosPageState();
}

final class _PosPageState extends ConsumerState<PosPage>
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
    return ErpFeatureScaffold(
      appBar: AppBar(
        title: const Text('Counter POS & Sales Billing'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.point_of_sale), text: 'Counter POS'),
            Tab(icon: Icon(Icons.pause_circle_outline), text: 'Held Drafts'),
            Tab(icon: Icon(Icons.history), text: 'Sales History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CounterPosTab(
            onHoldSuccess: () => _tabController.animateTo(1),
            onViewDrafts: () => _tabController.animateTo(1),
          ),
          _HeldDraftsTab(onResumeDraft: () => _tabController.animateTo(0)),
          const _SalesHistoryTab(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Tab 1: Counter POS Interface & Real-time Live Bill Preview
// ---------------------------------------------------------------------

class _CounterPosTab extends ConsumerStatefulWidget {
  const _CounterPosTab({
    required this.onHoldSuccess,
    required this.onViewDrafts,
  });

  final VoidCallback onHoldSuccess;
  final VoidCallback onViewDrafts;

  @override
  ConsumerState<_CounterPosTab> createState() => _CounterPosTabState();
}

class _PosCartItem {
  _PosCartItem({
    required this.product,
    double qty = 1.0,
    double unitPriceRupees = 0.0,
    this.gstRate = 12.0,
    this.unit = 'unit_pcs',
    String hsnCode = '85414011',
  })  : qtyController = TextEditingController(
          text: qty % 1 == 0 ? qty.toInt().toString() : qty.toString(),
        ),
        priceController = TextEditingController(
          text: unitPriceRupees.toStringAsFixed(2),
        ),
        discountController = TextEditingController(text: '0.00'),
        serialsController = TextEditingController(),
        hsnController = TextEditingController(text: hsnCode.isEmpty ? '85414011' : hsnCode);

  Product product;
  final TextEditingController qtyController;
  final TextEditingController priceController;
  final TextEditingController discountController;
  final TextEditingController serialsController;
  final TextEditingController hsnController;
  double gstRate;
  String unit;

  double get qty => double.tryParse(qtyController.text) ?? 1.0;
  double get unitPrice => double.tryParse(priceController.text) ?? 0.0;
  double get discountRupees => double.tryParse(discountController.text) ?? 0.0;

  double get taxableSubtotal => (qty * unitPrice) - discountRupees;
  double get taxAmount => taxableSubtotal * (gstRate / 100.0);
  double get totalWithTax => taxableSubtotal + taxAmount;
}

class _CounterPosTabState extends ConsumerState<_CounterPosTab> {
  final _searchController = TextEditingController();
  final _remarksController = TextEditingController();

  List<Product> _allProducts = [];
  List<Party> _customers = [];
  Party? _selectedCustomer;
  String _customerAddress = 'Buria Road, Jagadhri-135003, Distt. Yamuna Nagar, Haryana';
  String _customerPhone = '9881630001';
  String _customerGstin = '';

  // Invoice Meta
  DateTime _invoiceDate = DateTime.now();
  String _invoiceNo = '20';
  String _gstType = 'registered'; // 'registered', 'without_gst', 'consumer', 'interstate'
  String _priceList = 'Default Price';
  String _selectedLocationId = 'loc_default_sellable';
  String? _ewayBillNo;
  String? _vehicleNo;
  String? _deliveryNote;

  // Additional Charges & Discounts
  double _overallDiscountPercent = 0.0;
  double _overallDiscountAmount = 0.0;
  double _additionalCharges = 0.0;

  // Right pane tab: 0 = Bill Preview, 1 = Settings
  int _rightPaneTab = 0;

  bool _loadingMasters = true;
  bool _submitting = false;

  final List<_PosCartItem> _cart = [];

  bool get _isWithGst => _gstType != 'without_gst';

  @override
  void initState() {
    super.initState();
    _loadMasters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _remarksController.dispose();
    for (final item in _cart) {
      item.qtyController.dispose();
      item.priceController.dispose();
      item.discountController.dispose();
      item.serialsController.dispose();
      item.hsnController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMasters() async {
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity?.organization.id.value ?? 'default_org';

    final prods = await runtime.database.searchProducts(orgId);
    final custs = await runtime.database.searchParties(orgId, isCustomer: true);
    final sales = await runtime.database.listSales(organizationId: orgId);

    if (mounted) {
      setState(() {
        _allProducts = prods;
        _customers = custs;
        _invoiceNo = '${sales.length + 20}';
        _loadingMasters = false;

        // Auto-select or initialize sample customer if available
        if (_selectedCustomer == null && custs.isNotEmpty) {
          _onCustomerSelected(custs.first);
        } else if (_selectedCustomer == null) {
          _selectedCustomer = null;
          _customerAddress = 'Shop No. 3 Village & Post Office Damupura, Tehsil Jagadhri-135001, Distt. Yamuna Nagar';
          _customerPhone = '9881630001';
          _customerGstin = '06ALFPC3114K1ZJ';
        }
      });
    }
  }

  Future<void> _onCustomerSelected(Party? cust) async {
    setState(() => _selectedCustomer = cust);
    if (cust == null) {
      setState(() {
        _customerAddress = 'Counter Cash Customer (Guest)';
        _customerPhone = '';
        _customerGstin = '';
      });
      return;
    }

    try {
      final runtime = await ref.read(runtimeProvider.future);
      final addrs = await runtime.database.getPartyAddresses(cust.id);
      final contacts = await runtime.database.getPartyContacts(cust.id);

      if (mounted) {
        setState(() {
          if (addrs.isNotEmpty) {
            final a = addrs.first;
            _customerAddress = '${a.addressLine1}, ${a.city}-${a.pincode}, ${a.state}';
          } else {
            _customerAddress = 'Kalamb, Maharashtra - 413507';
          }
          if (contacts.isNotEmpty) {
            _customerPhone = contacts.first.phone;
          } else {
            _customerPhone = '';
          }
          _customerGstin = cust.gstin ?? '';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _customerAddress = 'Kalamb, Maharashtra';
          _customerPhone = '';
          _customerGstin = cust.gstin ?? '';
        });
      }
    }
  }

  void _addToCart(Product product) {
    setState(() {
      final existingIndex = _cart.indexWhere((c) => c.product.id == product.id);
      if (existingIndex >= 0) {
        final item = _cart[existingIndex];
        final currentQty = double.tryParse(item.qtyController.text) ?? 1.0;
        item.qtyController.text = (currentQty + 1.0).toString();
      } else {
        _cart.add(
          _PosCartItem(
            product: product,
            qty: 1.0,
            unitPriceRupees: product.sellingPricePaise / 100.0,
            gstRate: _isWithGst ? (product.defaultTaxRateBps / 100.0) : 0.0,
            unit: product.baseUnitId.isNotEmpty ? product.baseUnitId : 'unit_pcs',
            hsnCode: product.hsnCode.isNotEmpty ? product.hsnCode : '85414011',
          ),
        );
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
      _overallDiscountAmount = 0.0;
      _overallDiscountPercent = 0.0;
      _additionalCharges = 0.0;
      _remarksController.clear();
    });
  }

  // Totals Calculations
  double get _itemsSubtotalRupees =>
      _cart.fold(0.0, (sum, item) => sum + (item.qty * item.unitPrice));

  double get _itemsLineDiscountRupees =>
      _cart.fold(0.0, (sum, item) => sum + item.discountRupees);

  double get _totalDiscountRupees {
    final pctDiscount = (_itemsSubtotalRupees * _overallDiscountPercent) / 100.0;
    return _itemsLineDiscountRupees + _overallDiscountAmount + pctDiscount;
  }

  double get _taxableSubtotalRupees => _itemsSubtotalRupees - _totalDiscountRupees;

  double get _taxTotalRupees {
    if (!_isWithGst) return 0.0;
    return _cart.fold(0.0, (sum, item) {
      final lineTaxable = (item.qty * item.unitPrice) - item.discountRupees;
      return sum + (lineTaxable * (item.gstRate / 100.0));
    });
  }

  double get _cgstRupees => _gstType == 'interstate' ? 0.0 : (_taxTotalRupees / 2.0);
  double get _sgstRupees => _gstType == 'interstate' ? 0.0 : (_taxTotalRupees / 2.0);
  double get _igstRupees => _gstType == 'interstate' ? _taxTotalRupees : 0.0;

  double get _grandTotalRupees =>
      _itemsSubtotalRupees - _totalDiscountRupees + _additionalCharges + _taxTotalRupees;

  // Convert cart to TaxInvoiceItemData for the Live Bill Preview
  List<TaxInvoiceItemData> get _previewItems {
    return _cart.map((c) {
      return TaxInvoiceItemData(
        productName: c.product.name,
        sku: c.product.sku,
        hsnCode: c.hsnController.text,
        quantity: c.qty,
        rate: c.unitPrice,
        unit: c.unit,
        gstRate: _isWithGst ? c.gstRate : 0.0,
        discount: c.discountRupees,
        serials: c.serialsController.text.trim().isEmpty
            ? []
            : c.serialsController.text.split(',').map((s) => s.trim()).toList(),
      );
    }).toList();
  }

  // Dialog: Add New Customer & Save to Database
  void _showAddCustomerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final streetCtrl = TextEditingController();
    final cityCtrl = TextEditingController(text: 'Kalamb');
    final pincodeCtrl = TextEditingController(text: '413507');
    final stateCtrl = TextEditingController(text: 'Maharashtra');
    final gstinCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.person_add, color: Color(0xFFD32F2F)),
              const SizedBox(width: 8),
              const Text('Add New Customer (Save Record)'),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Customer / Business Name *',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact / Phone Number *',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Contact number is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: streetCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Street Address / Area',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: cityCtrl,
                            decoration: const InputDecoration(
                              labelText: 'City / Town',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: pincodeCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Pincode',
                              border: OutlineInputBorder(),
                              isDense: true,
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
                            controller: stateCtrl,
                            decoration: const InputDecoration(
                              labelText: 'State',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: gstinCtrl,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'GSTIN (Optional)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
              ),
              icon: const Icon(Icons.check),
              label: const Text('Save Customer'),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                try {
                  final runtime = await ref.read(runtimeProvider.future);
                  final orgId = runtime.identity?.organization.id.value ?? 'default_org';

                  final partyId = 'cust_${DateTime.now().millisecondsSinceEpoch}';
                  final cleanGstin = gstinCtrl.text.trim().toUpperCase();

                  final newParty = Party(
                    id: partyId,
                    organizationId: orgId,
                    name: nameCtrl.text.trim(),
                    isCustomer: true,
                    isSupplier: false,
                    gstin: cleanGstin.isEmpty ? null : cleanGstin,
                    creditLimitPaise: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  final newAddr = PartyAddress(
                    id: 'addr_$partyId',
                    partyId: partyId,
                    addressLine1: streetCtrl.text.trim().isEmpty ? 'Main Market' : streetCtrl.text.trim(),
                    city: cityCtrl.text.trim().isEmpty ? 'Kalamb' : cityCtrl.text.trim(),
                    state: stateCtrl.text.trim().isEmpty ? 'Maharashtra' : stateCtrl.text.trim(),
                    pincode: pincodeCtrl.text.trim().isEmpty ? '413507' : pincodeCtrl.text.trim(),
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

                  // Refresh customer list & select this customer
                  final custs = await runtime.database.searchParties(orgId, isCustomer: true);
                  if (mounted) {
                    setState(() {
                      _customers = custs;
                      _selectedCustomer = newParty;
                      _customerAddress = '${newAddr.addressLine1}, ${newAddr.city}-${newAddr.pincode}, ${newAddr.state}';
                      _customerPhone = newContact.phone;
                      _customerGstin = newParty.gstin ?? '';
                    });
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Customer "${newParty.name}" saved successfully!'),
                        backgroundColor: Colors.green[800],
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error saving customer: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog: Add Products Catalog Selector Modal
  void _showAddProductsDialog() {
    final searchCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final query = searchCtrl.text.toLowerCase();
            final filtered = _allProducts.where((p) {
              return p.name.toLowerCase().contains(query) ||
                  p.sku.toLowerCase().contains(query) ||
                  p.hsnCode.toLowerCase().contains(query);
            }).toList();

            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.add_shopping_cart, color: Color(0xFFD32F2F)),
                  const SizedBox(width: 8),
                  const Text('Select Products to Add'),
                ],
              ),
              content: SizedBox(
                width: 600,
                height: 450,
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Filter by name, SKU or HSN...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No matching products found.'))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (c, i) {
                                final prod = filtered[i];
                                final price = prod.sellingPricePaise / 100.0;
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFFD32F2F).withValues(alpha: 0.1),
                                      child: const Icon(Icons.solar_power, color: Color(0xFFD32F2F)),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            prod.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        if (prod.isMadeToOrder) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F5E9),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: const Color(0xFF2E7D32)),
                                            ),
                                            child: const Text(
                                              'Made to Order',
                                              style: TextStyle(
                                                color: Color(0xFF2E7D32),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    subtitle: Text(
                                      'SKU: ${prod.sku} | HSN: ${prod.hsnCode} | GST: ${(prod.defaultTaxRateBps / 100).toStringAsFixed(0)}%',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '₹${price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF8B0000),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: const Color(0xFFD32F2F),
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                          ),
                                          onPressed: () {
                                            _addToCart(prod);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Added "${prod.name}" to bill'),
                                                duration: const Duration(milliseconds: 700),
                                              ),
                                            );
                                          },
                                          child: const Text('Add'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog: Add Discount
  void _showAddDiscountDialog() {
    final pctCtrl = TextEditingController(text: _overallDiscountPercent.toString());
    final amtCtrl = TextEditingController(text: _overallDiscountAmount.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Bill Discount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pctCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Discount Percentage (%)',
                  suffixText: '%',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Discount Fixed Amount (₹)',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _overallDiscountPercent = double.tryParse(pctCtrl.text) ?? 0.0;
                  _overallDiscountAmount = double.tryParse(amtCtrl.text) ?? 0.0;
                });
                Navigator.pop(ctx);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  // Dialog: Add Additional Charges
  void _showAddChargesDialog() {
    final chargesCtrl = TextEditingController(text: _additionalCharges.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Additional Charges (Freight / Delivery)'),
          content: TextField(
            controller: chargesCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Charges Amount (₹)',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _additionalCharges = double.tryParse(chargesCtrl.text) ?? 0.0;
                });
                Navigator.pop(ctx);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  // Dialog: Full Page Invoice View Modal
  void _showFullPageInvoiceModal() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFFF2F4F7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Full Page Invoice Preview (A4 Standard Print)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
                          icon: const Icon(Icons.print),
                          label: const Text('Print Now'),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _openPrintPreviewDialog();
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: SizedBox(
                      width: 800,
                      child: _buildTaxInvoiceWidget(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Construct TaxInvoiceWidget with current state
  Widget _buildTaxInvoiceWidget() {
    final customerName = _selectedCustomer?.name ?? 'Counter Cash Customer (Guest)';

    return TaxInvoiceWidget(
      sellerName: 'Shree Krushna Sales (2024-25)',
      sellerAddress: 'Rajmata Jijau Chowk, Jantre Plaza, Dhoki Road, Kalamb - 413507',
      sellerPhone: '7020422291 / 9881630001',
      sellerGstin: _isWithGst ? '27AAAAA0000A1Z5' : null,
      sellerState: 'Maharashtra',
      sellerStateCode: '27',
      invoiceNo: _invoiceNo,
      invoiceDate: '${_invoiceDate.day}-${_getMonthName(_invoiceDate.month)}-${_invoiceDate.year}',
      ewayBillNo: _ewayBillNo,
      deliveryNote: _deliveryNote,
      paymentMode: 'Cash / UPI / Bank',
      vehicleNo: _vehicleNo,
      destination: 'Kalamb Local',
      customerName: customerName,
      customerAddress: _customerAddress,
      customerPhone: _customerPhone,
      customerGstin: _customerGstin,
      customerState: 'Maharashtra',
      customerStateCode: '27',
      placeOfSupply: 'Maharashtra',
      items: _previewItems,
      discountAmount: _totalDiscountRupees,
      additionalCharges: _additionalCharges,
      isWithGst: _isWithGst,
      remarks: _remarksController.text,
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
  }

  // Open the Invoice Print & Spool Dialog
  void _openPrintPreviewDialog() {
    final vm = InvoiceViewModel(
      invoiceNumber: 'INV-$_invoiceNo',
      businessDate: _invoiceDate,
      originalSaleId: 'sale_${DateTime.now().millisecondsSinceEpoch}',
      sellerLegalName: 'Shree Krushna Sales',
      sellerDisplayName: 'Shree Krushna Sales (2024-25)',
      sellerAddress: 'Rajmata Jijau Chowk, Jantre Plaza, Dhoki Road, Kalamb - 413507',
      sellerPhone: '7020422291 / 9881630001',
      sellerGstin: _isWithGst ? '27AAAAA0000A1Z5' : null,
      sellerStateCode: '27-Maharashtra',
      customerPartyId: _selectedCustomer?.id ?? 'guest_customer',
      customerName: _selectedCustomer?.name ?? 'Counter Cash Customer',
      customerAddress: _customerAddress,
      customerPhone: _customerPhone,
      customerGstin: _customerGstin.isNotEmpty ? _customerGstin : null,
      lineItems: _cart.asMap().entries.map((entry) {
        final i = entry.value;
        final taxAmt = _isWithGst ? i.taxAmount : 0.0;
        return InvoiceLineViewModel(
          lineId: 'line_${entry.key}',
          productName: i.product.name,
          sku: i.product.sku,
          hsnCode: i.hsnController.text,
          quantityUnits: i.qty,
          unitPriceRupees: i.unitPrice,
          discountPaise: Money.fromRupees(i.discountRupees),
          taxableAmountPaise: Money.fromRupees(i.taxableSubtotal),
          taxRatePercentage: _isWithGst ? i.gstRate : 0.0,
          cgstPaise: Money.fromRupees(_isWithGst ? (taxAmt / 2) : 0),
          sgstPaise: Money.fromRupees(_isWithGst ? (taxAmt / 2) : 0),
          igstPaise: Money.zero,
          totalTaxPaise: Money.fromRupees(taxAmt),
          lineTotalPaise: Money.fromRupees(i.taxableSubtotal + taxAmt),
          serials: i.serialsController.text.trim().isEmpty
              ? []
              : i.serialsController.text.split(',').map((s) => s.trim()).toList(),
        );
      }).toList(),
      subtotalPaise: Money.fromRupees(_itemsSubtotalRupees),
      totalDiscountPaise: Money.fromRupees(_totalDiscountRupees),
      taxableAmountPaise: Money.fromRupees(_taxableSubtotalRupees),
      cgstPaise: Money.fromRupees(_cgstRupees),
      sgstPaise: Money.fromRupees(_sgstRupees),
      igstPaise: Money.fromRupees(_igstRupees),
      totalTaxPaise: Money.fromRupees(_taxTotalRupees),
      roundOffPaise: Money.zero,
      grandTotalPaise: Money.fromRupees(_grandTotalRupees),
      amountPaidPaise: Money.fromRupees(_grandTotalRupees),
      balanceDuePaise: Money.zero,
      paymentStatus: 'PAID',
    );

    InvoicePreviewDialog.show(context, invoice: vm);
  }

  // Hold Draft Action
  Future<void> _holdDraft() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty. Cannot hold empty draft.')),
      );
      return;
    }

    try {
      final runtime = await ref.read(runtimeProvider.future);
      final orgId = runtime.identity?.organization.id.value ?? 'default_org';
      final branchId = runtime.identity?.branch.id.value ?? 'branch_1';

      final draftLinesJson = jsonEncode(
        _cart
            .map(
              (c) => {
                'productId': c.product.id,
                'productName': c.product.name,
                'qty': c.qty,
                'unitPrice': c.unitPrice,
                'discount': c.discountRupees,
                'gstRate': c.gstRate,
                'hsn': c.hsnController.text,
                'unit': c.unit,
                'serials': c.serialsController.text,
              },
            )
            .toList(),
      );

      final draft = SaleDraft(
        id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
        organizationId: orgId,
        branchId: branchId,
        customerPartyId: _selectedCustomer?.id,
        customerName: _selectedCustomer?.name ?? 'Counter Cash Customer',
        linesJson: draftLinesJson,
        updatedAtUtc: DateTime.now(),
        notes: _remarksController.text,
      );

      await runtime.database.saveSaleDraft(draft);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('POS Draft saved successfully!')),
        );
        _clearCart();
        widget.onHoldSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error holding draft: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Tender & Checkout Modal (Generate & Print Bill)
  void _showTenderModal() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add items to cart before proceeding.')),
      );
      return;
    }

    final cashController = TextEditingController(
      text: _grandTotalRupees.toStringAsFixed(2),
    );
    final upiController = TextEditingController(text: '0.00');
    final cardController = TextEditingController(text: '0.00');
    final bankController = TextEditingController(text: '0.00');
    final creditController = TextEditingController(text: '0.00');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cashAmt = double.tryParse(cashController.text) ?? 0.0;
            final upiAmt = double.tryParse(upiController.text) ?? 0.0;
            final cardAmt = double.tryParse(cardController.text) ?? 0.0;
            final bankAmt = double.tryParse(bankController.text) ?? 0.0;
            final creditAmt = double.tryParse(creditController.text) ?? 0.0;

            final totalPaid = cashAmt + upiAmt + cardAmt + bankAmt + creditAmt;
            final balanceDue = _grandTotalRupees - totalPaid;

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payment Allocation & Complete Bill',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Grand Total Payable:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatIndianCurrency(_grandTotalRupees),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B0000),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: cashController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cash Amount (₹)',
                        prefixIcon: Icon(Icons.money),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: upiController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'UPI / QR Payment (₹)',
                        prefixIcon: Icon(Icons.qr_code),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cardController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Card Payment (₹)',
                        prefixIcon: Icon(Icons.credit_card),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: bankController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Bank Transfer / RTGS (₹)',
                        prefixIcon: Icon(Icons.account_balance),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: creditController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Customer Credit / Ledger (₹)',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: balanceDue <= 0 ? Colors.green[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: balanceDue <= 0 ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            balanceDue <= 0 ? 'Fully Paid / Change:' : 'Remaining Balance Due:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatIndianCurrency(balanceDue.abs()),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: balanceDue <= 0 ? Colors.green[900] : Colors.orange[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _submitting
                            ? null
                            : () async {
                                Navigator.pop(modalCtx);
                                await _completeCheckout(
                                  cashPaise: (cashAmt * 100).round(),
                                  upiPaise: (upiAmt * 100).round(),
                                  cardPaise: (cardAmt * 100).round(),
                                  bankPaise: (bankAmt * 100).round(),
                                  creditPaise: (creditAmt * 100).round(),
                                );
                              },
                        icon: const Icon(Icons.print),
                        label: Text(
                          _submitting ? 'Generating Invoice...' : 'Generate & Print Bill',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _completeCheckout({
    required int cashPaise,
    required int upiPaise,
    required int cardPaise,
    required int bankPaise,
    required int creditPaise,
  }) async {
    setState(() => _submitting = true);

    try {
      final runtime = await ref.read(runtimeProvider.future);
      final orgId = runtime.identity?.organization.id.value ?? 'default_org';
      final branchId = runtime.identity?.branch.id.value ?? 'branch_1';
      final session = ref.read(authProvider);

      if (session == null) {
        throw const AuthenticationFailure('unauthenticated', 'Not logged in');
      }

      final commandContext = CommandContext(
        session: session,
        timestampUtc: DateTime.now(),
      );

      final lineInputs = _cart.map((c) {
        final serialsList = c.serialsController.text.trim().isEmpty
            ? <String>[]
            : c.serialsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

        return SaleLineInput(
          productId: c.product.id,
          productName: c.product.name,
          sku: c.product.sku,
          hsnCode: c.hsnController.text.isNotEmpty ? c.hsnController.text : c.product.hsnCode,
          baseUnit: c.unit,
          quantity: Quantity.fromUnits(c.qty),
          unitPrice: UnitPrice.fromRupees(c.unitPrice),
          lineDiscount: Money.fromRupees(c.discountRupees),
          taxRate: _isWithGst ? TaxRate.fromPercentage(c.gstRate) : TaxRate.zero,
          serials: serialsList,
          isMadeToOrder: c.product.isMadeToOrder,
        );
      }).toList();

      final tenderLines = <TenderLine>[];
      if (cashPaise > 0) {
        tenderLines.add(TenderLine(method: TenderMethod.cash, amountPaise: Money.fromPaise(cashPaise)));
      }
      if (upiPaise > 0) {
        tenderLines.add(TenderLine(method: TenderMethod.upi, amountPaise: Money.fromPaise(upiPaise)));
      }
      if (cardPaise > 0) {
        tenderLines.add(TenderLine(method: TenderMethod.card, amountPaise: Money.fromPaise(cardPaise)));
      }
      if (bankPaise > 0) {
        tenderLines.add(TenderLine(method: TenderMethod.bankTransfer, amountPaise: Money.fromPaise(bankPaise)));
      }
      if (creditPaise > 0) {
        tenderLines.add(TenderLine(method: TenderMethod.customerCredit, amountPaise: Money.fromPaise(creditPaise)));
      }

      if (tenderLines.isEmpty) {
        tenderLines.add(TenderLine(method: TenderMethod.cash, amountPaise: Money.fromRupees(_grandTotalRupees)));
      }

      final supplyType = _gstType == 'interstate' ? TaxSupplyType.interState : TaxSupplyType.intraState;

      final useCase = PostSaleUseCase(
        salesStore: runtime.database,
        inventoryStore: runtime.database,
        accountingStore: runtime.database,
        partyStore: runtime.database,
      );

      final saleHeader = await useCase.execute(
        commandContext,
        organizationId: orgId,
        branchId: branchId,
        customerPartyId: _selectedCustomer?.id ?? 'guest_customer',
        customerName: _selectedCustomer?.name ?? 'Counter Cash Customer',
        businessDate: _invoiceDate,
        locationId: _selectedLocationId,
        supplyType: supplyType,
        lineInputs: lineInputs,
        tenderLines: tenderLines,
        commandId: 'cmd_pos_${DateTime.now().millisecondsSinceEpoch}',
        invoiceDiscount: Money.fromRupees(_totalDiscountRupees),
        notes: _remarksController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sale Posted Successfully! Invoice #${saleHeader.id.substring(0, 8)}'),
            backgroundColor: Colors.green[800],
          ),
        );

        // Open print preview immediately
        _openPrintPreviewDialog();
        _clearCart();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing sale: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingMasters) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1050;

        if (!isDesktop) {
          // Compact / Tablet mode with View Switcher
          return _buildCompactLayout(context);
        }

        // Full Desktop Split Layout matching Reference Image 1
        return SizedBox.expand(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Invoice Form & Items Table (~58%)
              Expanded(
                flex: 58,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopMetadataRow(context),
                      const SizedBox(height: 10),
                      _buildSecondOptionsRow(),
                      const SizedBox(height: 12),
                      _buildProductSearchBar(),
                      const SizedBox(height: 12),
                      _buildLineItemsTable(),
                      const SizedBox(height: 10),
                      _buildChargesAndRemarksRow(),
                      const SizedBox(height: 12),
                      _buildTotalsAndGrandTotalCard(),
                      const SizedBox(height: 14),
                      _buildBottomActionButtons(),
                    ],
                  ),
                ),
              ),

              const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE0E0E0)),

              // Right Column: Live Bill Preview & Settings Tab (~42%)
              Expanded(
                flex: 42,
                child: Container(
                  color: const Color(0xFFF7F9FA),
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      _buildRightPaneHeader(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _rightPaneTab == 0
                            ? SingleChildScrollView(
                                child: _buildTaxInvoiceWidget(),
                              )
                            : _buildSettingsTab(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 1. Top Row: Customer Selector, Date, Invoice No
  Widget _buildTopMetadataRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Customer Avatar Box
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.person, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 8),

          // Customer Selector Dropdown with subtitle address
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<Party?>(
                    isExpanded: true,
                    value: _selectedCustomer,
                    hint: const Text(
                      'Select Customer *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    items: [
                      const DropdownMenuItem<Party?>(
                        value: null,
                        child: Text(
                          'Counter Cash Customer (Guest)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      ..._customers.map(
                        (c) => DropdownMenuItem<Party?>(
                          value: c,
                          child: Text(
                            c.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) => _onCustomerSelected(val),
                  ),
                ),
                Text(
                  _customerAddress,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Add Customer Red "+" Button
          IconButton(
            onPressed: () => _showAddCustomerDialog(context),
            icon: const Icon(Icons.add, color: Color(0xFFD32F2F)),
            tooltip: 'Add New Customer',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFFF0F0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: Color(0xFFFFCDD2)),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Search Customer Icon
          IconButton(
            onPressed: () => _showCustomerSearchDialog(context),
            icon: const Icon(Icons.search, size: 20),
            tooltip: 'Search Customer',
          ),
          const SizedBox(width: 8),

          // Invoice Date Field
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _invoiceDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  setState(() => _invoiceDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Invoice Date', style: TextStyle(fontSize: 9, color: Colors.grey)),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          '${_invoiceDate.day}-${_getMonthName(_invoiceDate.month)}-${_invoiceDate.year}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Invoice No Field
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Invoice No.', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  Text(
                    _invoiceNo,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Second Row: GST Type, Price List, Location
  Widget _buildSecondOptionsRow() {
    return Row(
      children: [
        // GST Type Selector (With GST or Without GST)
        Expanded(
          flex: 4,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _gstType,
            decoration: const InputDecoration(
              labelText: 'GST Type',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(
                value: 'registered',
                child: Text('With GST (Tax Invoice)', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
              ),
              DropdownMenuItem(
                value: 'without_gst',
                child: Text('Without GST (Cash Bill)', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
              ),
              DropdownMenuItem(
                value: 'consumer',
                child: Text('Consumer / Unreg', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
              ),
              DropdownMenuItem(
                value: 'interstate',
                child: Text('Inter-State (IGST)', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
              ),
            ],
            onChanged: (val) {
              setState(() {
                _gstType = val!;
                // Update item rates
                for (final item in _cart) {
                  item.gstRate = _isWithGst ? (item.product.defaultTaxRateBps / 100.0) : 0.0;
                }
              });
            },
          ),
        ),
        const SizedBox(width: 8),

        // Price List
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _priceList,
            decoration: const InputDecoration(
              labelText: 'Price List',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'Default Price', child: Text('Default Price', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
              DropdownMenuItem(value: 'Wholesale', child: Text('Wholesale', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
              DropdownMenuItem(value: 'Dealer', child: Text('Dealer', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (val) => setState(() => _priceList = val!),
          ),
        ),
        const SizedBox(width: 8),

        // Location
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _selectedLocationId,
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'loc_default_sellable', child: Text('Main Warehouse', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
              DropdownMenuItem(value: 'loc_default_quarantine', child: Text('Quarantine Store', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (val) => setState(() => _selectedLocationId = val!),
          ),
        ),
      ],
    );
  }

  // 3. Product Action Bar & Search
  Widget _buildProductSearchBar() {
    return Row(
      children: [
        // Red "Add Products" Button
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: _showAddProductsDialog,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Products', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),

        // Search by Barcode Button
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: () => _searchController.clear(),
          child: const Text('Search by Barcode (F2)', style: TextStyle(fontSize: 11)),
        ),
        const SizedBox(width: 8),

        // Search input
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search product by name, SKU, or barcode...',
              hintStyle: const TextStyle(fontSize: 12),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: Color(0xFFD32F2F), size: 20),
                onPressed: () {},
              ),
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            onChanged: (val) => setState(() {}),
          ),
        ),
      ],
    );
  }

  // 4. Line Items Table matching Image 1
  Widget _buildLineItemsTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              width: constraints.maxWidth < 620 ? 620 : constraints.maxWidth,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 24, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                Expanded(flex: 4, child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                Expanded(flex: 2, child: Text('HSN/SAC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                SizedBox(width: 70, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                SizedBox(width: 80, child: Text('Rate (₹)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                SizedBox(width: 48, child: Text('Per', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                SizedBox(width: 58, child: Text('GST %', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                SizedBox(width: 85, child: Text('Amount (₹)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.right)),
                SizedBox(width: 55, child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
              ],
            ),
          ),

          // Items List
          if (_cart.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    const Text('No items in bill. Search product or tap "+ Add Products".', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cart.length,
              separatorBuilder: (c, i) => Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, idx) {
                final item = _cart[idx];
                final lineAmount = item.qty * item.unitPrice;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      // #
                      SizedBox(
                        width: 24,
                        child: Text('${idx + 1}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ),

                      // Product Name & SKU
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.solar_power, size: 18, color: Colors.blueGrey),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        'SKU: ${item.product.sku}',
                                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                                      ),
                                      if (item.product.isMadeToOrder)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F5E9),
                                            borderRadius: BorderRadius.circular(3),
                                            border: Border.all(color: const Color(0xFF2E7D32), width: 0.5),
                                          ),
                                          child: const Text(
                                            'Made to Order',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E7D32),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // HSN/SAC
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 28,
                          child: TextFormField(
                            controller: item.hsnController,
                            style: const TextStyle(fontSize: 11),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Qty input with stepper
                      SizedBox(
                        width: 70,
                        height: 28,
                        child: TextFormField(
                          controller: item.qtyController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Rate (₹)
                      SizedBox(
                        width: 80,
                        height: 28,
                        child: TextFormField(
                          controller: item.priceController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 11),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Per (unit)
                      SizedBox(
                        width: 48,
                        height: 28,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: item.unit,
                            isDense: true,
                            style: const TextStyle(fontSize: 11, color: Colors.black87),
                            items: const [
                              DropdownMenuItem(value: 'unit_pcs', child: Text('pcs')),
                              DropdownMenuItem(value: 'unit_nos', child: Text('nos')),
                              DropdownMenuItem(value: 'unit_set', child: Text('set')),
                              DropdownMenuItem(value: 'unit_kg', child: Text('kg')),
                              DropdownMenuItem(value: 'unit_meter', child: Text('mtr')),
                              DropdownMenuItem(value: 'unit_box', child: Text('box')),
                            ],
                            onChanged: (val) => setState(() => item.unit = val!),
                          ),
                        ),
                      ),

                      // GST %
                      SizedBox(
                        width: 58,
                        height: 28,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<double>(
                            value: _isWithGst ? item.gstRate : 0.0,
                            isDense: true,
                            style: const TextStyle(fontSize: 11, color: Colors.black87),
                            items: [
                              const DropdownMenuItem(value: 0.0, child: Text('0%')),
                              if (_isWithGst) ...const [
                                DropdownMenuItem(value: 5.0, child: Text('5%')),
                                DropdownMenuItem(value: 12.0, child: Text('12%')),
                                DropdownMenuItem(value: 18.0, child: Text('18%')),
                                DropdownMenuItem(value: 28.0, child: Text('28%')),
                              ],
                            ],
                            onChanged: _isWithGst
                                ? (val) => setState(() => item.gstRate = val!)
                                : null,
                          ),
                        ),
                      ),

                      // Amount (₹)
                      SizedBox(
                        width: 85,
                        child: Text(
                          formatIndianCurrency(lineAmount, showSymbol: false),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                      ),

                      // Actions (Edit serials, Delete)
                      SizedBox(
                        width: 55,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => _showEditItemDialog(item),
                              child: const Icon(Icons.edit, size: 16, color: Colors.orange),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => _removeFromCart(idx),
                              child: const Icon(Icons.delete, size: 16, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
},
);
}

  void _showEditItemDialog(_PosCartItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit: ${item.product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: item.discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Item Discount (₹)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: item.serialsController,
                decoration: const InputDecoration(
                  labelText: 'Serial Numbers (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // 5. Additional Charges, Discounts & Remarks
  Widget _buildChargesAndRemarksRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            const Text(
              'Additional Charges / Discounts',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            TextButton.icon(
              onPressed: _showAddDiscountDialog,
              icon: const Icon(Icons.add, size: 14, color: Color(0xFFD32F2F)),
              label: const Text('+ Add Discount', style: TextStyle(color: Color(0xFFD32F2F), fontSize: 11)),
            ),
            TextButton.icon(
              onPressed: _showAddChargesDialog,
              icon: const Icon(Icons.add, size: 14, color: Color(0xFFD32F2F)),
              label: const Text('+ Add Charges', style: TextStyle(color: Color(0xFFD32F2F), fontSize: 11)),
            ),
            TextButton.icon(
              onPressed: () => _remarksController.text = 'Delivery within 2 days. Kalamb main store warranty.',
              icon: const Icon(Icons.note_add, size: 14),
              label: const Text('+ Add Note', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _remarksController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Add delivery note, terms, or other remarks here...',
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.all(8),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  // 6. Totals & Grand Total Box
  Widget _buildTotalsAndGrandTotalCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Subtotal Breakdown
          Expanded(
            flex: 5,
            child: Column(
              children: [
                _buildTotalRow('Items Total (${_cart.length})', formatIndianCurrency(_itemsSubtotalRupees)),
                if (_totalDiscountRupees > 0)
                  _buildTotalRow('Discount', '- ${formatIndianCurrency(_totalDiscountRupees)}', isDiscount: true),
                if (_additionalCharges > 0)
                  _buildTotalRow('Additional Charges', '+ ${formatIndianCurrency(_additionalCharges)}'),
                _buildTotalRow('Subtotal', formatIndianCurrency(_taxableSubtotalRupees), isBold: true),
                if (_isWithGst) ...[
                  _buildTotalRow('CGST (6% / 9%)', formatIndianCurrency(_cgstRupees)),
                  _buildTotalRow('SGST (6% / 9%)', formatIndianCurrency(_sgstRupees)),
                ],
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Right Highlight Grand Total Box (pinkish red card)
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grand Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B0000),
                        ),
                      ),
                      Text(
                        formatIndianCurrency(_grandTotalRupees),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF8B0000),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Amount in Words',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Text(
                    numberToIndianWords(_grandTotalRupees),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red.shade900 : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red.shade900 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 7. Sticky Bottom Action Buttons
  Widget _buildBottomActionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            OutlinedButton.icon(
              onPressed: _cart.isEmpty ? null : _clearCart,
              icon: const Icon(Icons.delete_outline, size: 15, color: Colors.red),
              label: const Text('Clear All', style: TextStyle(color: Colors.red, fontSize: 11)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _cart.isEmpty ? null : _holdDraft,
              icon: const Icon(Icons.pause, size: 15),
              label: const Text('Hold Draft', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
            OutlinedButton.icon(
              onPressed: widget.onViewDrafts,
              icon: const Icon(Icons.folder_open, size: 15),
              label: const Text('Load Draft', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            OutlinedButton.icon(
              onPressed: _cart.isEmpty ? null : _openPrintPreviewDialog,
              icon: const Icon(Icons.print, size: 15),
              label: const Text('Print (F9)', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: _cart.isEmpty ? null : _showTenderModal,
              icon: const Icon(Icons.receipt_long, size: 16),
              label: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Generate & Print Bill (F5)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 8. Right Pane Header (Tabs: Bill Preview | Settings)
  Widget _buildRightPaneHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => setState(() => _rightPaneTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _rightPaneTab == 0 ? const Color(0xFFD32F2F) : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  'Bill Preview',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _rightPaneTab == 0 ? const Color(0xFFD32F2F) : Colors.black54,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => setState(() => _rightPaneTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _rightPaneTab == 1 ? const Color(0xFFD32F2F) : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.settings, size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _rightPaneTab == 1 ? const Color(0xFFD32F2F) : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Full Page View Button
        OutlinedButton.icon(
          onPressed: _showFullPageInvoiceModal,
          icon: const Icon(Icons.fullscreen, size: 16),
          label: const Text('Full Page View', style: TextStyle(fontSize: 11)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  // Right Pane Settings Tab
  Widget _buildSettingsTab() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListView(
        children: [
          const Text('Invoice Customization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _ewayBillNo,
            decoration: const InputDecoration(labelText: 'e-Way Bill No.', border: OutlineInputBorder(), isDense: true),
            onChanged: (val) => setState(() => _ewayBillNo = val),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _vehicleNo,
            decoration: const InputDecoration(labelText: 'Motor Vehicle No.', border: OutlineInputBorder(), isDense: true),
            onChanged: (val) => setState(() => _vehicleNo = val),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _deliveryNote,
            decoration: const InputDecoration(labelText: 'Delivery Note / Challan No.', border: OutlineInputBorder(), isDense: true),
            onChanged: (val) => setState(() => _deliveryNote = val),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const Text('Printer Spool Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: 'A4 Standard Invoice',
            decoration: const InputDecoration(labelText: 'Default Format', border: OutlineInputBorder(), isDense: true),
            items: const [
              DropdownMenuItem(value: 'A4 Standard Invoice', child: Text('A4 Standard Laser/Inkjet')),
              DropdownMenuItem(value: '80mm Thermal', child: Text('80mm POS Thermal Receipt')),
              DropdownMenuItem(value: '58mm Thermal', child: Text('58mm Small Thermal Receipt')),
            ],
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }

  // Customer search dialog modal
  void _showCustomerSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        String filter = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _customers.where((c) {
              return c.name.toLowerCase().contains(filter.toLowerCase()) ||
                  (c.gstin?.toLowerCase().contains(filter.toLowerCase()) ?? false);
            }).toList();

            return AlertDialog(
              title: const Text('Search Customer Directory'),
              content: SizedBox(
                width: 400,
                height: 350,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by customer name or GSTIN...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (val) => setModalState(() => filter = val),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (c, i) {
                          final party = filtered[i];
                          return ListTile(
                            title: Text(party.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('GSTIN: ${party.gstin ?? "Unregistered"}'),
                            onTap: () {
                              Navigator.pop(ctx);
                              _onCustomerSelected(party);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
              ],
            );
          },
        );
      },
    );
  }

  // Compact layout for smaller screens
  Widget _buildCompactLayout(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Color(0xFFD32F2F),
              tabs: [
                Tab(icon: Icon(Icons.edit_document), text: 'Billing Form'),
                Tab(icon: Icon(Icons.visibility), text: 'Live Bill Preview'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildTopMetadataRow(context),
                      const SizedBox(height: 10),
                      _buildSecondOptionsRow(),
                      const SizedBox(height: 12),
                      _buildProductSearchBar(),
                      const SizedBox(height: 12),
                      _buildLineItemsTable(),
                      const SizedBox(height: 10),
                      _buildChargesAndRemarksRow(),
                      const SizedBox(height: 12),
                      _buildTotalsAndGrandTotalCard(),
                      const SizedBox(height: 14),
                      _buildBottomActionButtons(),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: _buildTaxInvoiceWidget(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Tab 2: Held Drafts Management Tab
// ---------------------------------------------------------------------

class _HeldDraftsTab extends ConsumerStatefulWidget {
  const _HeldDraftsTab({required this.onResumeDraft});

  final VoidCallback onResumeDraft;

  @override
  ConsumerState<_HeldDraftsTab> createState() => _HeldDraftsTabState();
}

class _HeldDraftsTabState extends ConsumerState<_HeldDraftsTab> {
  List<SaleDraft> _drafts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    setState(() => _loading = true);
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity?.organization.id.value ?? 'default_org';

    final items = await runtime.database.listSaleDrafts(orgId);

    if (mounted) {
      setState(() {
        _drafts = items;
        _loading = false;
      });
    }
  }

  Future<void> _deleteDraft(String id) async {
    final runtime = await ref.read(runtimeProvider.future);
    await runtime.database.deleteSaleDraft(id);
    _loadDrafts();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Held POS Draft Sales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _loadDrafts,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Drafts'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _drafts.isEmpty
                ? const Center(child: Text('No held sales drafts found.'))
                : ListView.builder(
                    itemCount: _drafts.length,
                    itemBuilder: (context, idx) {
                      final item = _drafts[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.pause, color: Colors.white),
                          ),
                          title: Text(
                            'Customer: ${item.customerName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Last Updated: ${item.updatedAtUtc.toLocal().toString().split('.')[0]}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                onPressed: widget.onResumeDraft,
                                icon: const Icon(Icons.play_arrow, size: 16),
                                label: const Text('Resume'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF005F56),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteDraft(item.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Tab 3: Sales Invoices History Tab
// ---------------------------------------------------------------------

class _SalesHistoryTab extends ConsumerStatefulWidget {
  const _SalesHistoryTab();

  @override
  ConsumerState<_SalesHistoryTab> createState() => _SalesHistoryTabState();
}

class _SalesHistoryTabState extends ConsumerState<_SalesHistoryTab> {
  List<SaleHeader> _sales = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => _loading = true);
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity?.organization.id.value ?? 'default_org';

    final items = await runtime.database.listSales(organizationId: orgId);

    if (mounted) {
      setState(() {
        _sales = items;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _sales.where((s) {
      final query = _searchQuery.toLowerCase();
      return s.customerName.toLowerCase().contains(query) ||
          s.id.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Sales by Customer Name or Invoice ID...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _loadSales,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No posted sales recorded yet.'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final item = filtered[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF8B0000),
                            child: Icon(
                              Icons.point_of_sale,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            '${item.customerName} — Invoice #${item.id.substring(0, 8)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Date: ${item.businessDate.toLocal().toString().split(' ')[0]} | Grand Total: ₹${item.grandTotalPaise.inRupees.toStringAsFixed(2)} | Paid: ₹${item.amountPaidPaise.inRupees.toStringAsFixed(2)}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Chip(
                                label: Text(
                                  item.status.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                                backgroundColor:
                                    item.status == SaleStatus.posted
                                        ? Colors.green[700]
                                        : Colors.grey,
                                visualDensity: VisualDensity.compact,
                              ),
                              Text(
                                'Due: ₹${item.balanceDuePaise.inRupees.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: item.balanceDuePaise.paise > 0
                                      ? Colors.red
                                      : Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showSaleDetails(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSaleDetails(SaleHeader header) async {
    final runtime = await ref.read(runtimeProvider.future);
    final lines = await runtime.database.getSaleLines(header.id);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'POS Sale Invoice Details — #${header.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Customer: ${header.customerName}'),
              Text(
                'Business Date: ${header.businessDate.toLocal().toString().split(' ')[0]}',
              ),
              Text(
                'Subtotal: ₹${header.subtotalPaise.inRupees.toStringAsFixed(2)}',
              ),
              Text(
                'GST Tax: ₹${header.totalTaxPaise.inRupees.toStringAsFixed(2)}',
              ),
              const Divider(height: 24),
              const Text(
                'Sold Items & Serials:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: lines.length,
                  itemBuilder: (c, i) {
                    final l = lines[i];
                    return ListTile(
                      dense: true,
                      title: Text('${l.productName} (${l.sku})'),
                      subtitle: Text(
                        'Qty: ${l.quantity.inUnits} ${l.baseUnit} | Price: ₹${l.unitPrice.inRupees.toStringAsFixed(2)} | Tax: ₹${l.taxSnapshot.totalTax.inRupees.toStringAsFixed(2)}\nSerials: ${l.serials.isEmpty ? "None" : l.serials.join(", ")}',
                      ),
                      trailing: Text(
                        '₹${l.netTotalPaise.inRupees.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Grand Total: ₹${header.grandTotalPaise.inRupees.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF990000),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.print),
                        label: const Text('Print / Preview Invoice'),
                        onPressed: () {
                          final identity = runtime.identity!;
                          final vm = InvoiceViewModel.fromSale(
                            sale: header,
                            lines: lines,
                            org: identity.organization,
                            branch: identity.branch,
                            isReprint: true,
                          );
                          InvoicePreviewDialog.show(ctx, invoice: vm);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
