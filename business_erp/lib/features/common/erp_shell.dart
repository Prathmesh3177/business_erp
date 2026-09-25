import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_controller.dart';
import '../../app/locale_controller.dart';
import '../../app/theme.dart';
import '../../l10n/strings.dart';
import 'erp_ui.dart';

/// Shared authenticated application chrome. Feature pages provide only their
/// workflow content and actions; this shell keeps navigation, responsive
/// behavior and role visibility consistent everywhere.
class ErpFeatureScaffold extends ConsumerWidget {
  const ErpFeatureScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.floatingActionButton,
  });

  final PreferredSizeWidget appBar;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact = ErpBreakpoints.isCompact(context);
    final session = ref.watch(authProvider);
    final nav = _FeatureNavigation(session: session);
    return Scaffold(
      drawer: compact ? Drawer(child: nav) : null,
      appBar: _FeatureAppBar(source: appBar, showMenu: compact),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: compact
          ? _CompactQuickNavigation(session: session)
          : null,
      body: Row(
        children: [
          if (!compact) SizedBox(width: 244, child: nav),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _FeatureAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _FeatureAppBar({required this.source, required this.showMenu});
  final PreferredSizeWidget source;
  final bool showMenu;

  @override
  Size get preferredSize => Size.fromHeight(
    source.preferredSize.height > 72 ? source.preferredSize.height : 72,
  );

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: SolarColors.surface,
      border: Border(bottom: BorderSide(color: SolarColors.slate100)),
    ),
    child: Row(
      children: [
        if (showMenu)
          Builder(
            builder: (scaffoldContext) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
            ),
          ),
        Expanded(child: source),
      ],
    ),
  );
}

class _FeatureNavigation extends StatelessWidget {
  const _FeatureNavigation({required this.session});
  final UserSession? session;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final currentPath = _activePath(context);
    final entries = _FeatureNavEntry.values
        .where((entry) => entry.isVisibleTo(session))
        .toList();
    return Material(
      color: SolarColors.surface,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: SolarColors.slate100)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 12, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.solar_power,
                      color: SolarColors.crimson,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shree Krushna Sales',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          strings.get('branch'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: SolarColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  for (final entry in entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      child: ListTile(
                        minLeadingWidth: 24,
                        selected: entry.matches(currentPath),
                        selectedColor: const Color(0xFF0B57D0),
                        selectedTileColor: const Color(0xFFE8F1FF),
                        leading: Icon(entry.icon),
                        title: Text(strings.get(entry.labelKey)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        onTap: () {
                          if (ErpBreakpoints.isCompact(context)) {
                            Navigator.of(context).pop();
                          }
                          context.go(entry.path);
                        },
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Consumer(
              builder: (context, ref, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                  onPressed: () => ref.read(localeProvider.notifier).toggle(),
                  icon: const Icon(Icons.language, size: 18),
                  label: Text(strings.get('language')),
                ),
              ),
            ),
            Consumer(
              builder: (context, ref, _) => ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(strings.get('lockSession')),
                onTap: () => ref.read(authProvider.notifier).lockSession(),
              ),
            ),
            Consumer(
              builder: (context, ref, _) => ListTile(
                leading: const Icon(Icons.logout, color: SolarColors.crimson),
                title: Text(
                  strings.get('logout'),
                  style: const TextStyle(color: SolarColors.crimson),
                ),
                onTap: () => ref.read(authProvider.notifier).logout(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

enum _FeatureNavEntry {
  dashboard('/', 'dashboard', Icons.dashboard_outlined, Capability.salesRead),
  sales(
    '/sales',
    'sales',
    Icons.point_of_sale_outlined,
    Capability.salesCreate,
  ),
  inventory(
    '/inventory',
    'inventory',
    Icons.inventory_2_outlined,
    Capability.inventoryManage,
  ),
  catalog(
    '/catalog',
    'catalog',
    Icons.category_outlined,
    Capability.inventoryManage,
  ),
  parties('/parties', 'parties', Icons.people_outline, Capability.partyManage),
  purchases(
    '/purchases',
    'purchases',
    Icons.local_shipping_outlined,
    Capability.purchaseManage,
  ),
  finance(
    '/finance',
    'finance',
    Icons.account_balance_wallet_outlined,
    Capability.financeManage,
  ),
  accounting(
    '/accounting',
    'accounting',
    Icons.receipt_long_outlined,
    Capability.costDataRead,
  ),
  reports(
    '/reports',
    'reports',
    Icons.bar_chart_outlined,
    Capability.salesRead,
  ),
  projects('/projects', 'projects', Icons.wb_sunny_outlined, null),
  service('/service', 'service', Icons.handyman_outlined, null),
  warranty(
    '/warranty',
    'warranty',
    Icons.verified_user_outlined,
    Capability.salesRead,
  ),
  users(
    '/users',
    'users',
    Icons.manage_accounts_outlined,
    Capability.userManage,
  );

  const _FeatureNavEntry(this.path, this.labelKey, this.icon, this.capability);
  final String path;
  final String labelKey;
  final IconData icon;
  final Capability? capability;

  bool isVisibleTo(UserSession? activeSession) {
    if (activeSession == null) return false;
    if (this == projects || this == service) {
      return activeSession.roleId == Role.adminRoleId;
    }
    return activeSession.hasCapability(capability!);
  }

  bool matches(String path) => this == dashboard
      ? path == '/' || path == '/dashboard'
      : path == this.path;
}

class _CompactQuickNavigation extends StatelessWidget {
  const _CompactQuickNavigation({required this.session});

  final UserSession? session;

  @override
  Widget build(BuildContext context) {
    final currentPath = _activePath(context);
    final preferred = [
      _FeatureNavEntry.dashboard,
      _FeatureNavEntry.sales,
      _FeatureNavEntry.inventory,
      _FeatureNavEntry.parties,
    ].where((entry) => entry.isVisibleTo(session)).toList();
    if (preferred.isEmpty) return const SizedBox.shrink();
    final selected = preferred.indexWhere(
      (entry) => entry.matches(currentPath),
    );
    final strings = AppStrings.of(context);
    return NavigationBar(
      height: 68,
      selectedIndex: selected < 0 ? 0 : selected,
      onDestinationSelected: (index) => context.go(preferred[index].path),
      destinations: [
        for (final entry in preferred)
          NavigationDestination(
            icon: Icon(entry.icon),
            selectedIcon: Icon(entry.icon, color: const Color(0xFF0B57D0)),
            label: strings.get(entry.labelKey),
          ),
      ],
    );
  }
}

String _activePath(BuildContext context) =>
    GoRouter.maybeOf(context)?.routerDelegate.currentConfiguration.uri.path ??
    '';
