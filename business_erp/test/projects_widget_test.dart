import 'package:business_erp/features/projects/projects_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('P15 Solar Projects & Quotations Widget Tests', () {
    testWidgets('ProjectsPage renders tabs and switches views', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProjectsPage(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Solar Projects & Quotations'), findsOneWidget);
      expect(find.text('Quotations'), findsOneWidget);
      expect(find.text('Solar Projects'), findsOneWidget);
      expect(find.text('Budget & Costing BI'), findsOneWidget);

      // Tap Solar Projects tab
      await tester.tap(find.text('Solar Projects'));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Budget & Costing BI tab
      await tester.tap(find.text('Budget & Costing BI'));
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
