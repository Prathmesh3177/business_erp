import 'package:business_erp/features/service/service_amc_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('P16 Service & AMC Workflows Widget Tests', () {
    testWidgets('ServiceAmcPage renders tabs and switches views', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ServiceAmcPage(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Service & AMC Workflows'), findsOneWidget);
      expect(find.text('Service Tickets'), findsOneWidget);
      expect(find.text('AMC Contracts'), findsOneWidget);
      expect(find.text('Reminders & My Jobs'), findsOneWidget);

      // Tap AMC Contracts tab
      await tester.tap(find.text('AMC Contracts'));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Reminders & My Jobs tab
      await tester.tap(find.text('Reminders & My Jobs'));
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
