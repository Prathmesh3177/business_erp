import 'package:business_erp/app/locale_controller.dart';
import 'package:business_erp/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('locale controller switches English to Marathi', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: _LocaleProbe()));
    expect(find.text('Shree Krushna Sales ERP'), findsOneWidget);
    await tester.tap(find.byType(TextButton));
    await tester.pump();
    expect(find.text('श्री कृष्णा सेल्स ईआरपी'), findsOneWidget);
  });
}

final class _LocaleProbe extends ConsumerWidget {
  const _LocaleProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      locale: locale,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) => Scaffold(
          body: Column(
            children: [
              Text(AppStrings.of(context).get('appTitle')),
              TextButton(
                onPressed: () => ref.read(localeProvider.notifier).toggle(),
                child: const Text('switch'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
