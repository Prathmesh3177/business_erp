import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/accounting/accounting_page.dart';
import '../features/auth/login_page.dart';
import '../features/catalog/catalog_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/finance/finance_page.dart';
import '../features/foundation/foundation_page.dart';
import '../features/inventory/inventory_page.dart';
import '../features/parties/parties_page.dart';
import '../features/purchases/purchases_page.dart';
import '../features/projects/projects_page.dart';
import '../features/reports/reports_page.dart';
import '../features/sales/pos_page.dart';
import '../features/mobile/mobile_navigation_shell.dart';
import '../features/splash/splash_screen.dart';
import '../features/warranty/warranty_page.dart';
import '../features/service/service_amc_page.dart';
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
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsPage(),
    ),
    GoRoute(
      path: '/users',
      builder: (context, state) => const UserManagementPage(),
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) => const CatalogPage(),
    ),
    GoRoute(
      path: '/parties',
      builder: (context, state) => const PartiesPage(),
    ),
    GoRoute(
      path: '/accounting',
      builder: (context, state) => const AccountingPage(),
    ),
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const InventoryPage(),
    ),
    GoRoute(
      path: '/purchases',
      builder: (context, state) => const PurchasesPage(),
    ),
    GoRoute(
      path: '/sales',
      builder: (context, state) => const PosPage(),
    ),
    GoRoute(
      path: '/finance',
      builder: (context, state) => const FinancePage(),
    ),
    GoRoute(
      path: '/projects',
      builder: (context, state) => const ProjectsPage(),
    ),
    GoRoute(
      path: '/mobile',
      builder: (context, state) => const MobileNavigationShell(),
    ),
    GoRoute(
      path: '/warranty',
      builder: (context, state) => Consumer(
        builder: (context, ref, child) {
          final runtime = ref.watch(runtimeProvider).asData?.value;
          return WarrantyPage(salesStore: runtime!.database);
        },
      ),
    ),
    GoRoute(
      path: '/service',
      builder: (context, state) => const ServiceAmcPage(),
    ),
  ],
);


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
