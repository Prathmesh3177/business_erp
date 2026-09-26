import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../common/erp_shell.dart';
import '../common/indian_currency_formatter.dart';

final class PartyDetailPage extends ConsumerWidget {
  const PartyDetailPage({super.key, required this.partyId});

  final String partyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<_PartyProfile>(
      future: _loadProfile(ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final profile = snapshot.data!;
        return DefaultTabController(
          length: 6,
          child: ErpFeatureScaffold(
            appBar: AppBar(
              title: Text(profile.party.name),
              bottom: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Purchase History'),
                  Tab(text: 'Quotations'),
                  Tab(text: 'Pending Orders'),
                  Tab(text: 'Projects'),
                  Tab(text: 'Ledger'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _Overview(profile: profile),
                _SalesHistory(sales: profile.sales),
                _QuotationHistory(quotations: profile.quotations),
                _OrdersHistory(orders: profile.orders),
                _ProjectsHistory(projects: profile.projects),
                _Ledger(profile: profile),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<_PartyProfile> _loadProfile(WidgetRef ref) async {
    final runtime = await ref.read(runtimeProvider.future);
    final db = runtime.database;
    final identity = runtime.identity!;
    final party = await db.getPartyById(
      identity.organization.id.value,
      partyId,
    );
    if (party == null) throw StateError('Customer not found');
    final results = await Future.wait([
      db.getPartyAddresses(partyId),
      db.getPartyContacts(partyId),
      db.listSales(
        organizationId: identity.organization.id.value,
        customerPartyId: partyId,
      ),
      db.getQuotationsByCustomer(identity.organization.id.value, partyId),
      db.getOrdersByCustomer(identity.organization.id.value, partyId),
      db.getProjectsByCustomer(identity.organization.id.value, partyId),
    ]);
    return _PartyProfile(
      party: party,
      addresses: results[0] as List<PartyAddress>,
      contacts: results[1] as List<PartyContact>,
      sales: results[2] as List<SaleHeader>,
      quotations: results[3] as List<QuotationHeader>,
      orders: results[4] as List<SaleOrder>,
      projects: results[5] as List<SolarProject>,
    );
  }
}

final class _PartyProfile {
  const _PartyProfile({
    required this.party,
    required this.addresses,
    required this.contacts,
    required this.sales,
    required this.quotations,
    required this.orders,
    required this.projects,
  });
  final Party party;
  final List<PartyAddress> addresses;
  final List<PartyContact> contacts;
  final List<SaleHeader> sales;
  final List<QuotationHeader> quotations;
  final List<SaleOrder> orders;
  final List<SolarProject> projects;
}

final class _Overview extends StatelessWidget {
  const _Overview({required this.profile});
  final _PartyProfile profile;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _section('Customer details', [
        'GSTIN: ${profile.party.gstin ?? 'Unregistered'}',
        'PAN: ${profile.party.pan ?? 'Not available'}',
        'Payment terms: ${profile.party.paymentTermsDays} days',
        'Credit limit: ${formatIndianCurrency(profile.party.creditLimitPaise / 100)}',
      ]),
      _section(
        'Address',
        profile.addresses.isEmpty
            ? ['No address recorded']
            : profile.addresses
                  .map(
                    (a) =>
                        '${a.addressLine1}, ${a.city}, ${a.state} - ${a.pincode}',
                  )
                  .toList(),
      ),
      _section(
        'Contact',
        profile.contacts.isEmpty
            ? ['No contact recorded']
            : profile.contacts
                  .map(
                    (c) =>
                        '${c.name}: ${c.phone}${c.email == null ? '' : ' · ${c.email}'}',
                  )
                  .toList(),
      ),
    ],
  );
  Widget _section(String title, List<String> values) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...values.map(Text.new),
        ],
      ),
    ),
  );
}

final class _SalesHistory extends StatelessWidget {
  const _SalesHistory({required this.sales});
  final List<SaleHeader> sales;
  @override
  Widget build(BuildContext context) => _HistoryList(
    items: sales
        .map(
          (s) => (
            'Invoice ${s.id.substring(0, 8)}',
            '${_date(s.businessDate)} · ${_paymentStatus(s)} · Paid ${formatIndianCurrency(s.amountPaidPaise.inRupees)} · Due ${formatIndianCurrency(s.balanceDuePaise.inRupees)}',
            formatIndianCurrency(s.grandTotalPaise.inRupees),
          ),
        )
        .toList(),
    empty: 'No purchases recorded.',
  );
}

final class _QuotationHistory extends StatelessWidget {
  const _QuotationHistory({required this.quotations});
  final List<QuotationHeader> quotations;
  @override
  Widget build(BuildContext context) => _HistoryList(
    items: quotations
        .map(
          (q) => (
            'Quotation ${q.quotationNumber}',
            '${q.status.name.toUpperCase()} · valid until ${_date(q.validUntil)}',
            formatIndianCurrency(q.grandTotalPaise.inRupees),
          ),
        )
        .toList(),
    empty: 'No quotations recorded.',
  );
}

final class _OrdersHistory extends StatelessWidget {
  const _OrdersHistory({required this.orders});
  final List<SaleOrder> orders;
  @override
  Widget build(BuildContext context) => _HistoryList(
    items: orders
        .map(
          (o) => (
            'Order ${o.id.substring(0, 8)}',
            '${o.status.name.toUpperCase()} · ${_date(o.orderDate)}',
            formatIndianCurrency(o.grandTotalPaise.inRupees),
          ),
        )
        .toList(),
    empty: 'No pending orders.',
  );
}

final class _ProjectsHistory extends StatelessWidget {
  const _ProjectsHistory({required this.projects});
  final List<SolarProject> projects;
  @override
  Widget build(BuildContext context) => _HistoryList(
    items: projects
        .map(
          (p) => (
            '${p.projectNumber} · ${p.name}',
            '${p.status.name.toUpperCase()} · ${p.siteAddress}',
            formatIndianCurrency(p.invoicedPaise.inRupees),
          ),
        )
        .toList(),
    empty: 'No projects recorded.',
  );
}

final class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.items, required this.empty});
  final List<(String, String, String)> items;
  final String empty;
  @override
  Widget build(BuildContext context) => items.isEmpty
      ? Center(child: Text(empty))
      : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (_, i) => ListTile(
            title: Text(items[i].$1),
            subtitle: Text(items[i].$2),
            trailing: Text(
              items[i].$3,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
}

final class _Ledger extends StatelessWidget {
  const _Ledger({required this.profile});
  final _PartyProfile profile;
  @override
  Widget build(BuildContext context) {
    final billed = profile.sales.fold<double>(
      0,
      (sum, sale) => sum + sale.grandTotalPaise.inRupees,
    );
    final paid = profile.sales.fold<double>(
      0,
      (sum, sale) => sum + sale.amountPaidPaise.inRupees,
    );
    final due = profile.sales.fold<double>(
      0,
      (sum, sale) => sum + sale.balanceDuePaise.inRupees,
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Customer Ledger',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Invoiced: ${formatIndianCurrency(billed)}'),
                Text('Received: ${formatIndianCurrency(paid)}'),
                const Divider(),
                Text(
                  'Outstanding: ${formatIndianCurrency(due)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Payment history', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        ...profile.sales.map(
          (sale) => Card(
            child: ListTile(
              leading: Icon(
                sale.balanceDuePaise.paise == 0
                    ? Icons.check_circle
                    : Icons.pending_actions,
                color: sale.balanceDuePaise.paise == 0
                    ? Colors.green
                    : Colors.orange,
              ),
              title: Text(
                'Invoice ${sale.id.substring(0, 8)} · ${_paymentStatus(sale)}',
              ),
              subtitle: Text(
                '${_date(sale.businessDate)} · Received ${formatIndianCurrency(sale.amountPaidPaise.inRupees)}',
              ),
              trailing: Text(
                'Due ${formatIndianCurrency(sale.balanceDuePaise.inRupees)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

String _paymentStatus(SaleHeader sale) => sale.balanceDuePaise.paise == 0
    ? 'PAID'
    : sale.amountPaidPaise.paise == 0
    ? 'UNPAID'
    : 'PARTIALLY PAID';
