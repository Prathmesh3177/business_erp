import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_domain/erp_domain.dart';

import '../features/accounting/accounting_page.dart';
import '../features/auth/login_page.dart';
import '../features/catalog/catalog_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/finance/finance_page.dart';
import '../features/foundation/foundation_page.dart';
import '../features/inventory/inventory_page.dart';
import '../features/parties/parties_page.dart';
import '../features/parties/party_detail_page.dart';
import '../features/purchases/purchases_page.dart';
import '../features/projects/projects_page.dart';
import '../features/reports/reports_page.dart';
import '../features/sales/pos_page.dart';
import '../features/sales/orders_page.dart';
import '../features/mobile/mobile_navigation_shell.dart';
import '../features/splash/splash_screen.dart';
import '../features/warranty/warranty_page.dart';
import '../features/service/service_amc_page.dart';
import '../features/settings/user_management_page.dart';
import '../l10n/strings.dart';
import 'auth_controller.dart';
import 'bootstrap.dart';
import 'locale_controller.dart';
import 'theme.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const RootShell()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const _RoleGuard(
        capability: Capability.salesRead,
        child: DashboardPage(),
      ),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const _RoleGuard(
        capability: Capability.salesRead,
        child: ReportsPage(),
      ),
    ),
    GoRoute(
      path: '/users',
      builder: (context, state) => const _RoleGuard(
        capability: Capability.userManage,
        child: UserManagementPage(),
      ),
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) => const _RoleGuard(
        capability: Capability.inventoryManage,
        child: CatalogPage(),
      ),
    ),
    GoRoute(
      path: '/parties',
      builder: (context, state) => const _RoleGuard(
        capability: Capability.partyManage,
        child: PartiesPage(),
      ),
    ),
    GoRoute(
      path: '/parties/:partyId',
      builder: (context, state) => _RoleGuard(
        capability: Capability.partyManage,
        child: PartyDetailPage(partyId: state.pathParameters['partyId']!),
      ),
    ),
    GoRoute(
      path: '/accounting',
      builder: (context, state) => const _RoleGuard(
        capability: Capability.costDataRead,
        child: AccountingPage(),
      ),
    ),
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const _RoleGuard(
        capability: Capability.inventoryManage,
        child: InventoryPage(),
      ),
    ),
    GoRoute(
      path: '/purchases',
      builder: (context, state) => const _RoleGuard(
        capability: Capability.purchaseManage,
        child: PurchasesPage(),
      ),
    ),
    GoRoute(
      path: '/sales',
      builder: (context, state) => const _RoleGuard(
        capability: Capability.salesCreate,
        child: PosPage(),
      ),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const _RoleGuard(
        capability: Capability.salesCreate,
        child: OrdersPage(),
      ),
    ),
    GoRoute(
      path: '/finance',
      builder: (context, state) => const _RoleGuard(
        capability: Capability.financeManage,
        child: FinancePage(),
      ),
    ),
    GoRoute(
      path: '/projects',
      builder: (context, state) => const _AdminRoleGuard(child: ProjectsPage()),
    ),
    GoRoute(
      path: '/mobile',
      builder: (context, state) => const _RoleGuard(
        capability: Capability.salesCreate,
        child: MobileNavigationShell(),
      ),
    ),
    GoRoute(
      path: '/warranty',
      builder: (context, state) => Consumer(
        builder: (context, ref, child) {
          final runtime = ref.watch(runtimeProvider).asData?.value;
          if (runtime == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return _RoleGuard(
            capability: Capability.salesRead,
            child: WarrantyPage(salesStore: runtime.database),
          );
        },
      ),
    ),
    GoRoute(
      path: '/service',
      builder: (context, state) =>
          const _AdminRoleGuard(child: ServiceAmcPage()),
    ),
  ],
);

final class _RoleGuard extends ConsumerWidget {
  const _RoleGuard({required this.capability, required this.child});

  final Capability capability;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);
    if (session != null && session.hasCapability(capability)) return child;
    return const _AccessDeniedPage();
  }
}

final class _AdminRoleGuard extends ConsumerWidget {
  const _AdminRoleGuard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);
    if (session?.roleId == Role.adminRoleId) return child;
    return const _AccessDeniedPage();
  }
}

final class _AccessDeniedPage extends StatelessWidget {
  const _AccessDeniedPage();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.get('accessRestricted'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                size: 56,
                color: SolarColors.crimson,
              ),
              const SizedBox(height: 16),
              Text(
                strings.get('accessRestrictedMessage'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(strings.get('accessRestrictedHelp')),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_outlined),
                label: Text(strings.get('backToWorkspace')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class SolarErpApp extends ConsumerWidget {
  const SolarErpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'Shree Krushna Sales ERP',
      debugShowCheckedModeBanner: false,
      theme: buildSolarTheme(),
      locale: locale,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}

final class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

final class _RootShellState extends ConsumerState<RootShell> {
  bool _splashCompleted = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashCompleted) {
      return SplashScreen(
        onFinished: () {
          if (mounted) {
            setState(() => _splashCompleted = true);
          }
        },
      );
    }

    final runtime = ref.watch(runtimeProvider);
    final session = ref.watch(authProvider);

    return runtime.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => const FoundationPage(),
      data: (value) {
        if (value.identity == null) {
          return const FoundationPage();
        }
        if (session == null) {
          return const LoginPage();
        }
        if (session.isLocked) {
          return const LockScreenModal();
        }
        return const FoundationPage();
      },
    );
  }
}
