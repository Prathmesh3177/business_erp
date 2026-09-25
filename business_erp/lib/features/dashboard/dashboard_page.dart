import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';
import '../../app/theme.dart';
import '../../l10n/strings.dart';
import '../common/erp_ui.dart';
import '../common/erp_shell.dart';
import '../reports/reports_page.dart';

final class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

final class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _loading = false;
  DashboardMetrics? _metrics;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    try {
      final store = ref.read(reportStoreProvider);
      final runtime = ref.read(runtimeProvider).value;
      final session = ref.read(authProvider);
      final orgId = runtime?.identity?.organization.id.value ?? 'org_1';

      if (session == null) {
        throw StateError(
          'A signed-in user is required to load dashboard data.',
        );
      }
      final contextUseCase = CommandContext(
        session: session,
        timestampUtc: DateTime.now().toUtc(),
      );

      final useCase = GenerateDashboardMetricsUseCase(store);
      final result = await useCase.execute(
        context: contextUseCase,
        organizationId: orgId,
      );

      if (mounted) {
        setState(() {
          _metrics = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = _metrics;
    final strings = AppStrings.of(context);

    return ErpFeatureScaffold(
      appBar: AppBar(
        title: Text(strings.get('dashboardTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
            tooltip: strings.get('refresh'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildKpiGrid(theme, metrics),
                    const SizedBox(height: 20),
                    _buildQuickActionToolbar(context),
                    const SizedBox(height: 20),
                    _buildReorderAlertsSection(theme, metrics),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKpiGrid(ThemeData theme, DashboardMetrics? metrics) {
    final strings = AppStrings.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final isCompact = constraints.maxWidth < ErpBreakpoints.compact;
        final crossAxisCount = isWide ? 4 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          // Compact cards need room for a two-line label and the monetary value.
          childAspectRatio: isCompact ? 1.3 : 2.2,
          children: [
            _KpiCard(
              title: strings.get('todaysSales'),
              value:
                  '₹${metrics?.todaySales.inRupees.toStringAsFixed(2) ?? "0.00"}',
              icon: Icons.point_of_sale,
              color: SolarColors.crimson,
            ),
            _KpiCard(
              title: strings.get('todaysCollections'),
              value:
                  '₹${metrics?.todayCollections.inRupees.toStringAsFixed(2) ?? "0.00"}',
              icon: Icons.account_balance_wallet,
              color: Colors.green,
            ),
            _KpiCard(
              title: strings.get('lowStockItems'),
              value: '${metrics?.lowStockCount ?? 0} ${strings.get('alerts')}',
              icon: Icons.warning_amber_rounded,
              color: Colors.amber.shade800,
            ),
            _KpiCard(
              title: strings.get('outstandingReceivables'),
              value:
                  '₹${metrics?.totalReceivables.inRupees.toStringAsFixed(2) ?? "0.00"}',
              icon: Icons.trending_up,
              color: Colors.blue.shade700,
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionToolbar(BuildContext context) {
    final strings = AppStrings.of(context);
    final session = ref.watch(authProvider);
    bool can(Capability capability) =>
        session == null || session.hasCapability(capability);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.get('quickAccess'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (can(Capability.salesCreate))
                  ElevatedButton.icon(
                    icon: const Icon(Icons.point_of_sale),
                    label: Text(strings.get('createInvoice')),
                    onPressed: () => context.push('/sales'),
                  ),
                if (can(Capability.salesRead))
                  ElevatedButton.icon(
                    icon: const Icon(Icons.analytics),
                    label: Text(strings.get('viewReports')),
                    onPressed: () => context.push('/reports'),
                  ),
                if (can(Capability.inventoryManage))
                  OutlinedButton.icon(
                    icon: const Icon(Icons.inventory_2),
                    label: Text(strings.get('checkStock')),
                    onPressed: () => context.push('/inventory'),
                  ),
                if (can(Capability.purchaseManage))
                  OutlinedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: Text(strings.get('addPurchase')),
                    onPressed: () => context.push('/purchases'),
                  ),
                if (can(Capability.financeManage))
                  OutlinedButton.icon(
                    icon: const Icon(Icons.account_balance),
                    label: Text(strings.get('finance')),
                    onPressed: () => context.push('/finance'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderAlertsSection(
    ThemeData theme,
    DashboardMetrics? metrics,
  ) {
    final strings = AppStrings.of(context);
    final alerts = metrics?.recentReorderAlerts ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  strings.get('reorderAlerts'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: const Text(
                    'Formula: (AvgDaily * LeadTime) + SafetyStock',
                  ),
                  backgroundColor: Colors.grey.shade200,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (alerts.isEmpty)
              ErpEmptyState(
                icon: Icons.inventory_2_outlined,
                title: strings.get('stockHealthy'),
                message: strings.get('stockHealthyMessage'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alerts.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.warning, color: Colors.white),
                    ),
                    title: Text('${alert.productName} (${alert.sku})'),
                    subtitle: Text(
                      'Current Stock: ${alert.currentStock.toStringAsFixed(1)} | '
                      'Reorder Point: ${alert.reorderPoint.toStringAsFixed(1)} | '
                      'Lead Time: ${alert.leadTimeDays}d | '
                      'Safety Stock: ${alert.safetyStock.toStringAsFixed(1)}',
                    ),
                    trailing: Text(
                      'Suggest Order: +${alert.suggestedOrderQuantity.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: SolarColors.deepRed,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
