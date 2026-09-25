import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';
import '../../app/theme.dart';
import '../common/erp_ui.dart';
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

      final contextUseCase = CommandContext(
        session:
            session ??
            UserSession(
              id: const SessionId('sess_guest'),
              userId: const UserId('user_guest'),
              username: 'guest',
              roleId: 'admin',
              branchId: const BranchId('branch_1'),
              capabilities: {
                Capability.salesCreate,
                Capability.inventoryManage,
                Capability.costDataRead,
              },
              token: 'tok_guest',
              expiresAtUtc: DateTime.now().add(const Duration(hours: 1)),
              lastActivityAtUtc: DateTime.now(),
            ),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Executive Dashboard & BI Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
            tooltip: 'Refresh Dashboard',
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
              title: "Today's Sales",
              value:
                  '₹${metrics?.todaySales.inRupees.toStringAsFixed(2) ?? "0.00"}',
              icon: Icons.point_of_sale,
              color: SolarColors.crimson,
            ),
            _KpiCard(
              title: "Today's Collections",
              value:
                  '₹${metrics?.todayCollections.inRupees.toStringAsFixed(2) ?? "0.00"}',
              icon: Icons.account_balance_wallet,
              color: Colors.green,
            ),
            _KpiCard(
              title: 'Low Stock Items',
              value: '${metrics?.lowStockCount ?? 0} Alert(s)',
              icon: Icons.warning_amber_rounded,
              color: Colors.amber.shade800,
            ),
            _KpiCard(
              title: 'Outstanding Receivables',
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Access Navigation',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.point_of_sale),
                  label: const Text('POS Checkout'),
                  onPressed: () => context.push('/sales'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.analytics),
                  label: const Text('All Reports'),
                  onPressed: () => context.push('/reports'),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.inventory_2),
                  label: const Text('Inventory'),
                  onPressed: () => context.push('/inventory'),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Purchases'),
                  onPressed: () => context.push('/purchases'),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.account_balance),
                  label: const Text('Finance & Cash'),
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
                const Text(
                  'Deterministic Reorder Alerts & Suggestions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              const ErpEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Stock levels are healthy',
                message: 'No reorder alerts need attention.',
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
