import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_page.dart';
import '../features/foundation/foundation_page.dart';
import '../features/settings/user_management_page.dart';
import '../features/splash/splash_screen.dart';
import '../l10n/strings.dart';
import 'auth_controller.dart';
import 'bootstrap.dart';
import 'locale_controller.dart';
import 'theme.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const RootShell()),
    GoRoute(
      path: '/users',
      builder: (context, state) => const UserManagementPage(),
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
