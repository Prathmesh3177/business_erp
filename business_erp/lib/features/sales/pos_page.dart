import 'dart:convert';

import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';
import '../../app/theme.dart';
import '../common/erp_ui.dart';
import '../common/erp_shell.dart';
import '../printing/invoice_preview_dialog.dart';

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
          _CounterPosTab(onHoldSuccess: () => _tabController.animateTo(1)),
          _HeldDraftsTab(onResumeDraft: () => _tabController.animateTo(0)),
          const _SalesHistoryTab(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Tab 1: Counter POS Interface
// ---------------------------------------------------------------------

class _CounterPosTab extends ConsumerStatefulWidget {
  const _CounterPosTab({required this.onHoldSuccess});

  final VoidCallback onHoldSuccess;

  @override
  ConsumerState<_CounterPosTab> createState() => _CounterPosTabState();
}

class _PosCartItem {
  _PosCartItem({
    required this.product,
    double qty = 1.0,
    double unitPriceRupees = 0.0,
    this.gstRate = 18.0,
  }) : qtyController = TextEditingController(text: qty.toString()),
       priceController = TextEditingController(
         text: unitPriceRupees.toString(),
       ),
       discountController = TextEditingController(text: '0.0'),
       serialsController = TextEditingController();

  Product product;
  final TextEditingController qtyController;
  final TextEditingController priceController;
  final TextEditingController discountController;
  final TextEditingController serialsController;
  double gstRate;

  double get qty => double.tryParse(qtyController.text) ?? 1.0;
  double get unitPrice => double.tryParse(priceController.text) ?? 0.0;
  double get discountRupees => double.tryParse(discountController.text) ?? 0.0;

  double get taxableSubtotal => (qty * unitPrice) - discountRupees;
  double get taxAmount => taxableSubtotal * (gstRate / 100.0);
  double get totalWithTax => taxableSubtotal + taxAmount;
}

class _CounterPosTabState extends ConsumerState<_CounterPosTab> {
  final _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Party> _customers = [];
  Party? _selectedCustomer;
  final TaxSupplyType _supplyType = TaxSupplyType.intraState;
  String _selectedLocationId = 'MAIN_WH';
  bool _loadingMasters = true;
  bool _submitting = false;

  final List<_PosCartItem> _cart = [];

  @override
  void initState() {
    super.initState();
    _loadMasters();
  }

  Future<void> _loadMasters() async {
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity?.organization.id.value ?? 'default_org';

    final prods = await runtime.database.searchProducts(orgId);
    final custs = await runtime.database.searchParties(orgId, isCustomer: true);

    if (mounted) {
      setState(() {
        _allProducts = prods;
        _customers = custs;
        _loadingMasters = false;
      });
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
            gstRate: product.defaultTaxRateBps / 100.0,
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
      _selectedCustomer = null;
    });
  }

  double get _subtotalRupees =>
      _cart.fold(0.0, (sum, item) => sum + (item.qty * item.unitPrice));

  double get _discountTotalRupees =>
      _cart.fold(0.0, (sum, item) => sum + item.discountRupees);

  double get _taxTotalRupees =>
      _cart.fold(0.0, (sum, item) => sum + item.taxAmount);

  double get _grandTotalRupees =>
      _subtotalRupees - _discountTotalRupees + _taxTotalRupees;

  Future<void> _holdDraft() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty. Cannot hold empty draft.'),
        ),
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
          SnackBar(
            content: Text('Error holding draft: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showTenderModal() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add items to cart before proceeding to checkout.',
          ),
        ),
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
                          'Payment Allocation & Checkout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${_grandTotalRupees.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: bankController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Bank Transfer (₹)',
                        prefixIcon: Icon(Icons.account_balance),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 12),
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
                        color: balanceDue <= 0
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: balanceDue <= 0 ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            balanceDue <= 0
                                ? 'Fully Paid / Change:'
                                : 'Remaining Balance Due:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${balanceDue.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: balanceDue <= 0
                                  ? Colors.green[900]
                                  : Colors.orange[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
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
                          _submitting
                              ? 'Processing Invoice...'
                              : 'Post Sale & Complete Invoice',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005F56), // Dark Teal
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
            : c.serialsController.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();

        return SaleLineInput(
          productId: c.product.id,
          productName: c.product.name,
          sku: c.product.sku,
          hsnCode: c.product.hsnCode,
          baseUnit: c.product.baseUnitId,
          quantity: Quantity.fromUnits(c.qty),
          unitPrice: UnitPrice.fromRupees(c.unitPrice),
          lineDiscount: Money.fromRupees(c.discountRupees),
          taxRate: TaxRate.fromPercentage(c.gstRate),
          serials: serialsList,
        );
      }).toList();

      final tenderLines = <TenderLine>[];
      if (cashPaise > 0) {
        tenderLines.add(
          TenderLine(
            method: TenderMethod.cash,
            amountPaise: Money.fromPaise(cashPaise),
          ),
        );
      }
      if (upiPaise > 0) {
        tenderLines.add(
          TenderLine(
            method: TenderMethod.upi,
            amountPaise: Money.fromPaise(upiPaise),
          ),
        );
      }
      if (cardPaise > 0) {
        tenderLines.add(
          TenderLine(
            method: TenderMethod.card,
            amountPaise: Money.fromPaise(cardPaise),
          ),
        );
      }
      if (bankPaise > 0) {
        tenderLines.add(
          TenderLine(
            method: TenderMethod.bankTransfer,
            amountPaise: Money.fromPaise(bankPaise),
          ),
        );
      }
      if (creditPaise > 0) {
        tenderLines.add(
          TenderLine(
            method: TenderMethod.customerCredit,
            amountPaise: Money.fromPaise(creditPaise),
          ),
        );
      }

      if (tenderLines.isEmpty) {
        tenderLines.add(
          TenderLine(
            method: TenderMethod.cash,
            amountPaise: Money.fromRupees(_grandTotalRupees),
          ),
        );
      }

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
        businessDate: DateTime.now(),
        locationId: _selectedLocationId,
        supplyType: _supplyType,
        lineInputs: lineInputs,
        tenderLines: tenderLines,
        commandId: 'cmd_pos_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sale Posted Successfully! Invoice #${saleHeader.id.substring(0, 8)}',
            ),
            backgroundColor: Colors.green[800],
          ),
        );
        _clearCart();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing sale: $e'),
            backgroundColor: Colors.red,
          ),
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

    final query = _searchController.text.toLowerCase();
    final filteredProducts = _allProducts.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query) ||
          p.hsnCode.toLowerCase().contains(query);
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < ErpBreakpoints.tablet) {
          return _buildCompactCounter(context, filteredProducts);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Catalog Search & Item Selector
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Product Name, SKU, or Barcode...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, idx) {
                          final prod = filteredProducts[idx];
                          final priceRupees = prod.sellingPricePaise / 100.0;
                          return Card(
                            elevation: 2,
                            child: InkWell(
                              onTap: () => _addToCart(prod),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      prod.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'SKU: ${prod.sku}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '₹${priceRupees.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: SolarColors.deepRed,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const VerticalDivider(width: 1),

            // Right Column: Cart, Customer & Checkout
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer & Warehouse Selector Header
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<Party?>(
                            initialValue: _selectedCustomer,
                            decoration: const InputDecoration(
                              labelText: 'Customer',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: [
                              const DropdownMenuItem<Party?>(
                                value: null,
                                child: Text('Counter Cash Customer (Guest)'),
                              ),
                              ..._customers.map(
                                (c) => DropdownMenuItem<Party?>(
                                  value: c,
                                  child: Text(
                                    '${c.name} (Credit: ₹${c.creditLimitPaise / 100})',
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (val) =>
                                setState(() => _selectedCustomer = val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedLocationId,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'MAIN_WH',
                                child: Text('Main WH'),
                              ),
                              DropdownMenuItem(
                                value: 'SHOWROOM',
                                child: Text('Showroom'),
                              ),
                            ],
                            onChanged: (val) =>
                                setState(() => _selectedLocationId = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Cart Table
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _cart.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Cart is empty. Tap products to add.',
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _cart.length,
                                  itemBuilder: (context, idx) {
                                    final item = _cart[idx];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    item.product.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 60,
                                                  child: TextFormField(
                                                    controller:
                                                        item.qtyController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText: 'Qty',
                                                          isDense: true,
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                    onChanged: (_) =>
                                                        setState(() {}),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                SizedBox(
                                                  width: 80,
                                                  child: TextFormField(
                                                    controller:
                                                        item.priceController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText: 'Price ₹',
                                                          isDense: true,
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                    onChanged: (_) =>
                                                        setState(() {}),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                SizedBox(
                                                  width: 70,
                                                  child: TextFormField(
                                                    controller:
                                                        item.discountController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText: 'Disc ₹',
                                                          isDense: true,
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                    onChanged: (_) =>
                                                        setState(() {}),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () =>
                                                      _removeFromCart(idx),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            TextFormField(
                                              controller:
                                                  item.serialsController,
                                              decoration: const InputDecoration(
                                                labelText: 'Serial No. (comma-separated)',
                                                isDense: true,
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Order Totals Summary Card
                    Card(
                      color: Colors.grey.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal:'),
                                Text('₹${_subtotalRupees.toStringAsFixed(2)}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Discount:'),
                                Text(
                                  '- ₹${_discountTotalRupees.toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('GST Tax:'),
                                Text(
                                  '+ ₹${_taxTotalRupees.toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                            const Divider(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Grand Total:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${_grandTotalRupees.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: SolarColors.deepRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Action Buttons Row
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: _clearCart,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade800,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('Clear'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _holdDraft,
                            icon: const Icon(Icons.pause),
                            label: const Text('Hold Draft'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _showTenderModal,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Pay & Print'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B0000),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompactCounter(BuildContext context, List<Product> products) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search product, SKU, or barcode',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<Party?>(
          initialValue: _selectedCustomer,
          decoration: const InputDecoration(labelText: 'Customer'),
          items: [
            const DropdownMenuItem<Party?>(
              value: null,
              child: Text('Counter cash customer'),
            ),
            ..._customers.map(
              (customer) =>
                  DropdownMenuItem(value: customer, child: Text(customer.name)),
            ),
          ],
          onChanged: (value) => setState(() => _selectedCustomer = value),
        ),
        const SizedBox(height: 16),
        Text('Products', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (products.isEmpty)
          const ErpEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No matching products',
            message: 'Try a product name, SKU, or scanner input.',
          )
        else
          ...products
              .take(12)
              .map(
                (product) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    minVerticalPadding: 10,
                    leading: const CircleAvatar(child: Icon(Icons.solar_power)),
                    title: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${product.sku} · ₹${(product.sellingPricePaise / 100).toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Add ${product.name}',
                      onPressed: () => _addToCart(product),
                      icon: const Icon(
                        Icons.add_circle,
                        color: SolarColors.crimson,
                      ),
                    ),
                    onTap: () => _addToCart(product),
                  ),
                ),
              ),
        const SizedBox(height: 12),
        ErpSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cart (${_cart.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '₹${_grandTotalRupees.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: SolarColors.deepRed,
                    ),
                  ),
                ],
              ),
              const Divider(),
              if (_cart.isEmpty)
                const Text('Your cart is empty. Add an item to start billing.')
              else
                ..._cart.asMap().entries.map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      entry.value.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${entry.value.qty} × ₹${entry.value.unitPrice.toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Remove item',
                      onPressed: () => _removeFromCart(entry.key),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _cart.isEmpty ? null : _clearCart,
                    child: const Text('Clear'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _cart.isEmpty ? null : _holdDraft,
                    icon: const Icon(Icons.pause),
                    label: const Text('Hold'),
                  ),
                  FilledButton.icon(
                    onPressed: _cart.isEmpty ? null : _showTenderModal,
                    icon: const Icon(Icons.payment),
                    label: const Text('Pay & Print'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
                                onPressed: () {
                                  widget.onResumeDraft();
                                },
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
