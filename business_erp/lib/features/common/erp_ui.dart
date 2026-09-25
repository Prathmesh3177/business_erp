import 'package:flutter/material.dart';

import '../../app/theme.dart';

abstract final class ErpBreakpoints {
  static const compact = 600.0;
  static const tablet = 840.0;
  static const desktop = 1200.0;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;
}

class ErpSectionCard extends StatelessWidget {
  const ErpSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}

class ErpStatusBadge extends StatelessWidget {
  const ErpStatusBadge({
    super.key,
    required this.label,
    this.tone = ErpStatusTone.neutral,
  });
  final String label;
  final ErpStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      ErpStatusTone.success => (const Color(0xFFDCFCE7), SolarColors.success),
      ErpStatusTone.warning => (const Color(0xFFFEF3C7), SolarColors.warning),
      ErpStatusTone.danger => (const Color(0xFFFEE2E2), SolarColors.deepRed),
      ErpStatusTone.info => (const Color(0xFFE0F2FE), SolarColors.info),
      ErpStatusTone.neutral => (SolarColors.slate100, SolarColors.slate500),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.$2,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

enum ErpStatusTone { success, warning, danger, info, neutral }

class ErpEmptyState extends StatelessWidget {
  const ErpEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: SolarColors.slate500),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    ),
  );
}

class ErpResponsiveTable extends StatelessWidget {
  const ErpResponsiveTable({
    super.key,
    required this.columns,
    required this.rows,
  });
  final List<DataColumn> columns;
  final List<DataRow> rows;

  @override
  Widget build(BuildContext context) => ErpSectionCard(
    padding: EdgeInsets.zero,
    child: Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(columns: columns, rows: rows),
      ),
    ),
  );
}
