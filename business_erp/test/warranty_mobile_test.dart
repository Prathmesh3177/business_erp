import 'package:business_erp/features/mobile/mobile_navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('P12 Mobile Shell & Warranty Widget Tests', () {
    testWidgets('MobileNavigationShell renders persistent isolated data banner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MobileNavigationShell(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Isolated Mobile Data Mode — Local Offline Drafts'), findsOneWidget);
      expect(find.text('Shree Krushna Sales — Mobile Drafts'), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    });

    testWidgets('MobileNavigationShell switches tabs on bottom bar tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MobileNavigationShell(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Scan tab
      await tester.tap(find.byIcon(Icons.qr_code_scanner));
      await tester.pumpAndSettle();

      expect(find.text('Camera Barcode & Serial Scanner'), findsOneWidget);

      // Tap Stock tab
      await tester.tap(find.byIcon(Icons.inventory_2));
      await tester.pumpAndSettle();

      expect(find.text('Mobile Stock Inspection'), findsOneWidget);
    });
  });
}
