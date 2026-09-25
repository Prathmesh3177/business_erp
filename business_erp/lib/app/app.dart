import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/foundation/foundation_page.dart';
import '../l10n/strings.dart';
import 'locale_controller.dart';
import 'theme.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const FoundationPage()),
  ],
);

final class SolarErpApp extends ConsumerWidget {
  const SolarErpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'Solar Shop ERP',
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
