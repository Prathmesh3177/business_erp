import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_controller.dart';
import '../../app/locale_controller.dart';
import '../../app/theme.dart';
import '../../l10n/strings.dart';
import '../settings/backup_restore_dialog.dart';
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
    // The dashboard rail needs roughly 236px. Collapse it at tablet widths so
    // feature pages keep the same stable composition without squeezing their
    // content or top bar into a different-looking desktop layout.
    final compact = MediaQuery.sizeOf(context).width < ErpBreakpoints.tablet;
    final session = ref.watch(authProvider);
    final strings = AppStrings.of(context);
    final nav = _FeatureNavigation(session: session);
    final featureAppBar = _FeatureAppBar(source: appBar, showMenu: false);
    return Scaffold(
      drawer: compact ? Drawer(child: nav) : null,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: compact
          ? _CompactQuickNavigation(session: session)
          : null,
      body: SafeArea(
        child: Column(
          children: [
            _UnifiedWorkspaceHeader(
              compact: compact,
              strings: strings,
              session: session,
              onLanguage: () => ref.read(localeProvider.notifier).toggle(),
            ),
            Expanded(
              child: Row(
                children: [
                  if (!compact) SizedBox(width: 236, child: nav),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: featureAppBar.preferredSize.height,
                          child: featureAppBar,
                        ),
                        Expanded(child: body),
                      ],
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

/// The same fixed top bar used by the executive dashboard. Keeping it in the
/// shared feature shell prevents individual workflows from drifting into their
/// own navigation and account chrome.
class _UnifiedWorkspaceHeader extends StatelessWidget {
  const _UnifiedWorkspaceHeader({
    required this.compact,
    required this.strings,
    required this.session,
    required this.onLanguage,
  });

  final bool compact;
  final AppStrings strings;
  final UserSession? session;
  final VoidCallback onLanguage;

  @override
  Widget build(BuildContext context) => Container(
    height: 68,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: const BoxDecoration(
      color: SolarColors.surface,
      border: Border(bottom: BorderSide(color: SolarColors.slate100)),
    ),
    child: Row(
      children: [
        if (compact)
          Builder(
            builder: (menuContext) => IconButton(
              onPressed: () => Scaffold.of(menuContext).openDrawer(),
              icon: const Icon(Icons.menu_rounded),
            ),
          )
        else
          const SizedBox(width: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/app_logo.png',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.solar_power_rounded,
              color: SolarColors.crimson,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (compact)
          Expanded(
            child: Text(
              strings.get('shopName'),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          )
        else
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.get('shopName'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              Text(strings.get('branch'), style: const TextStyle(color: SolarColors.slate500, fontSize: 11)),
            ],
          ),
        if (!compact) ...[
          const SizedBox(width: 24),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: SolarColors.canvas,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: SolarColors.slate100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 19, color: SolarColors.slate500),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: strings.get('searchHint'),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: SolarColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: SolarColors.slate100),
                        ),
                        child: const Text('Ctrl + K', style: TextStyle(fontSize: 11, color: SolarColors.slate500, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ] else const Spacer(),
        compact
            ? IconButton(
                onPressed: onLanguage,
                icon: const Icon(Icons.language_rounded),
                tooltip: strings.get('language'),
              )
            : InkWell(
                onTap: onLanguage,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: SolarColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SolarColors.slate100),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.language_rounded, size: 16, color: SolarColors.charcoal),
                    const SizedBox(width: 6),
                    Text(strings.get('language'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: SolarColors.slate500),
                  ]),
                ),
              ),
        const SizedBox(width: 10),
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF065F46),
          child: Text(
            session?.username.isNotEmpty == true ? session!.username[0].toUpperCase() : 'A',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(session?.username ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(
                session?.roleId == Role.adminRoleId ? strings.get('administrator') : strings.get('counterStaff'),
                style: const TextStyle(fontSize: 11, color: SolarColors.slate500),
              ),
            ],
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: SolarColors.slate500),
          const SizedBox(width: 18),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.remove, size: 16, color: SolarColors.slate500),
              SizedBox(width: 12),
              Icon(Icons.crop_square, size: 14, color: SolarColors.slate500),
              SizedBox(width: 12),
              Icon(Icons.close, size: 16, color: SolarColors.slate500),
            ],
          ),
        ],
      ],
    ),
  );
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                children: [
                  for (final entry in entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -1),
                        minLeadingWidth: 20,
                        selected: entry.matches(currentPath),
                        selectedTileColor: const Color(0xFFE8F1FF),
                        leading: Icon(
                          entry.icon,
                          size: 20,
                          color: entry.matches(currentPath)
                              ? const Color(0xFF0B57D0)
                              : const Color(0xFF475569),
                        ),
                        title: Text(
                          strings.get(entry.labelKey),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: entry.matches(currentPath)
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: entry.matches(currentPath)
                                ? const Color(0xFF0B57D0)
                                : const Color(0xFF334155),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        onTap: () {
                          if (MediaQuery.sizeOf(context).width < ErpBreakpoints.tablet) {
                            Navigator.of(context).pop();
                          }
                          if (entry == _FeatureNavEntry.backup) {
                            showDialog<void>(
                              context: context,
                              builder: (_) => const BackupRestoreDialog(),
                            );
                            return;
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
              builder: (context, ref, _) => ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -2),
                leading: const Icon(Icons.lock_outline_rounded, size: 19, color: Color(0xFF475569)),
                title: Text(strings.get('lockSession'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                onTap: () => ref.read(authProvider.notifier).lockSession(),
              ),
            ),
            Consumer(
              builder: (context, ref, _) => ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -2),
                leading: const Icon(Icons.logout_rounded, size: 19, color: SolarColors.crimson),
                title: Text(
                  strings.get('logout'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SolarColors.crimson),
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
  dashboard('/dashboard', 'dashboard', Icons.dashboard_rounded, Capability.salesRead),
  reports('/reports', 'reports', Icons.bar_chart_rounded, Capability.salesRead),
  catalog(
    '/catalog',
    'catalog',
    Icons.category_outlined,
    Capability.inventoryManage,
  ),
  inventory(
    '/inventory',
    'inventory',
    Icons.dns_outlined,
    Capability.inventoryManage,
  ),
  sales(
    '/sales',
    'sales',
    Icons.shopping_cart_outlined,
    Capability.salesCreate,
  ),
  orders(
    '/orders',
    'orders',
    Icons.pending_actions_outlined,
    Capability.salesCreate,
  ),
  finance(
    '/finance',
    'finance',
    Icons.payments_outlined,
    Capability.financeManage,
  ),
  purchases(
    '/purchases',
    'purchases',
    Icons.local_shipping_outlined,
    Capability.purchaseManage,
  ),
  accounting(
    '/accounting',
    'accounting',
    Icons.calculate_outlined,
    Capability.costDataRead,
  ),
  projects('/projects', 'projects', Icons.wb_sunny_outlined, Capability.salesCreate),
  service('/service', 'service', Icons.build_outlined, null),
  parties(
    '/parties',
    'parties',
    Icons.people_alt_outlined,
    Capability.partyManage,
  ),
  warranty(
    '/warranty',
    'warranty',
    Icons.verified_user_outlined,
    Capability.salesRead,
  ),
  backup(
    '#backup',
    'backup',
    Icons.cloud_sync_outlined,
    Capability.userManage,
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
    if (this == service) {
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
