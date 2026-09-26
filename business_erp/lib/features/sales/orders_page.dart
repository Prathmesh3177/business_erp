import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/bootstrap.dart';
import '../common/erp_shell.dart';
import '../common/indian_currency_formatter.dart';
import 'order_sale_draft.dart';

final saleOrdersProvider = FutureProvider.autoDispose<List<SaleOrder>>((
  ref,
) async {
  final runtime = await ref.watch(runtimeProvider.future);
  return runtime.database.listSaleOrders(
    organizationId: runtime.identity!.organization.id.value,
  );
});

final class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

List<OrderStatus> _allowedStatuses(OrderStatus status) {
  const transitions = {
    OrderStatus.pending: [
      OrderStatus.pending,
      OrderStatus.ordered,
      OrderStatus.cancelled,
    ],
    OrderStatus.ordered: [
      OrderStatus.ordered,
      OrderStatus.partialArrival,
      OrderStatus.arrived,
      OrderStatus.cancelled,
    ],
    OrderStatus.partialArrival: [
      OrderStatus.partialArrival,
      OrderStatus.arrived,
      OrderStatus.cancelled,
    ],
    OrderStatus.arrived: [
      OrderStatus.arrived,
      OrderStatus.readyToDeliver,
      OrderStatus.cancelled,
    ],
    OrderStatus.readyToDeliver: [
      OrderStatus.readyToDeliver,
      OrderStatus.delivered,
      OrderStatus.cancelled,
    ],
    OrderStatus.delivered: [OrderStatus.delivered],
    OrderStatus.cancelled: [OrderStatus.cancelled],
  };
  return transitions[status]!;
}

final class _OrdersPageState extends ConsumerState<OrdersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(saleOrdersProvider);
    return ErpFeatureScaffold(
      appBar: AppBar(
        title: const Text('Pending Orders'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions), text: 'Pending Orders'),
            Tab(icon: Icon(Icons.task_alt), text: 'Completed Orders'),
          ],
        ),
      ),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load orders: $error')),
        data: (items) => TabBarView(
          controller: _tabs,
          children: [
            _OrderList(
              orders: items
                  .where((order) => !_isComplete(order.status))
                  .toList(),
              onStatusChanged: _changeStatus,
            ),
            _OrderList(
              orders: items
                  .where((order) => _isComplete(order.status))
                  .toList(),
              onStatusChanged: _changeStatus,
            ),
          ],
        ),
      ),
    );
  }

  static bool _isComplete(OrderStatus status) =>
      status == OrderStatus.delivered || status == OrderStatus.cancelled;

  Future<void> _changeStatus(SaleOrder order, OrderStatus status) async {
    final runtime = await ref.read(runtimeProvider.future);
    final lines = await runtime.database.getSaleOrderLines(order.id);
    final updatedLines = lines
        .map(
          (line) => SaleOrderLine(
            id: line.id,
            orderId: line.orderId,
            productId: line.productId,
            productName: line.productName,
            quantity: line.quantity,
            unitPrice: line.unitPrice,
            taxRate: line.taxRate,
            isInStock:
                status == OrderStatus.arrived ||
                status == OrderStatus.readyToDeliver ||
                status == OrderStatus.delivered,
          ),
        )
        .toList();
    final updated = SaleOrder(
      id: order.id,
      organizationId: order.organizationId,
      branchId: order.branchId,
      customerPartyId: order.customerPartyId,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      orderDate: order.orderDate,
      status: status,
      quotationId: order.quotationId,
      saleHeaderId: order.saleHeaderId,
      grandTotalPaise: order.grandTotalPaise,
      expectedDeliveryDate: order.expectedDeliveryDate,
      notes: order.notes,
      createdAtUtc: order.createdAtUtc,
    );
    await runtime.database.saveSaleOrder(order: updated, lines: updatedLines);
    ref.invalidate(saleOrdersProvider);
  }
}

final class _OrderList extends ConsumerWidget {
  const _OrderList({required this.orders, required this.onStatusChanged});

  final List<SaleOrder> orders;
  final Future<void> Function(SaleOrder order, OrderStatus status)
  onStatusChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders in this section.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Chip(label: Text(_label(order.status))),
                  ],
                ),
                Text(
                  'Phone: ${order.customerPhone.isEmpty ? 'Not provided' : order.customerPhone}',
                ),
                Text('Order date: ${_date(order.orderDate)}'),
                Text(
                  'Total: ${formatIndianCurrency(order.grandTotalPaise.inRupees)}',
                ),
                FutureBuilder<List<SaleOrderLine>>(
                  future: ref
                      .read(runtimeProvider.future)
                      .then(
                        (runtime) =>
                            runtime.database.getSaleOrderLines(order.id),
                      ),
                  builder: (context, snapshot) => Text(
                    snapshot.hasData
                        ? 'Items: ${snapshot.data!.map((line) => '${line.productName} × ${line.quantity.inUnits}').join(', ')}'
                        : 'Items: loading…',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<OrderStatus>(
                        initialValue: order.status,
                        decoration: const InputDecoration(
                          labelText: 'Order status',
                        ),
                        items: _allowedStatuses(order.status)
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(_label(status)),
                              ),
                            )
                            .toList(),
                        onChanged: (status) {
                          if (status != null && status != order.status) {
                            onStatusChanged(order, status);
                          }
                        },
                      ),
                    ),
                    if (order.status == OrderStatus.arrived ||
                        order.status == OrderStatus.readyToDeliver) ...[
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () async {
                          final runtime = await ProviderScope.containerOf(
                            context,
                          ).read(runtimeProvider.future);
                          final lines = await runtime.database
                              .getSaleOrderLines(order.id);
                          stageOrderForSale(
                            OrderSaleDraft(
                              customerPartyId: order.customerPartyId,
                              lines: lines,
                            ),
                          );
                          if (context.mounted) context.go('/sales');
                        },
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Create Bill'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _label(OrderStatus status) => status.name
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
      .toUpperCase();
  static String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}
