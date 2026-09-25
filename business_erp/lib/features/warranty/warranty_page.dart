import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';

import '../common/erp_shell.dart';

class WarrantyPage extends StatefulWidget {
  const WarrantyPage({
    super.key,
    required this.salesStore,
  });

  final SalesStore salesStore;

  @override
  State<WarrantyPage> createState() => _WarrantyPageState();
}

class _WarrantyPageState extends State<WarrantyPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<WarrantyReminder> _allReminders = [];
  bool _isLoading = true;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWarranties();
  }

  Future<void> _loadWarranties() async {
    setState(() {
      _isLoading = true;
    });

    final generateUseCase =
        GenerateWarrantyRemindersUseCase(salesStore: widget.salesStore);

    // Dummy context for view
    final session = UserSession(
      id: const SessionId('sess_view'),
      userId: const UserId('usr_view'),
      username: 'admin',
      roleId: Role.adminRoleId,
      branchId: const BranchId('branch_1'),
      capabilities: Role.admin.capabilities,
      token: 'tok_view',
      expiresAtUtc: DateTime.now().add(const Duration(hours: 1)),
      lastActivityAtUtc: DateTime.now(),
    );

    final context = CommandContext(
      session: session,
      timestampUtc: DateTime.now(),
    );

    try {
      final reminders = await generateUseCase.execute(
        context: context,
        organizationId: 'default_org',
        referenceDate: DateTime.now(),
      );
      setState(() {
        _allReminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error loading warranties: $e';
      });
    }
  }

  void _exportCsv() {
    const exportUseCase = ExportWarrantyRemindersUseCase();
    final csv = exportUseCase.executeCsv(_allReminders);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exported Warranty Reminder Queue (CSV)'),
        content: SingleChildScrollView(
          child: SelectableText(csv),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = _allReminders
        .where((r) => r.status == WarrantyReminderStatus.active)
        .toList();
    final expiringSoon = _allReminders
        .where((r) => r.status == WarrantyReminderStatus.expiringSoon)
        .toList();
    final expired = _allReminders
        .where((r) => r.status == WarrantyReminderStatus.expired)
        .toList();

    return ErpFeatureScaffold(
      appBar: AppBar(
        title: const Text('Warranty Management & Reminders'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Reminder Queue (CSV)',
            onPressed: _exportCsv,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWarranties,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: [
            Tab(text: 'Expiring Soon (${expiringSoon.length})'),
            Tab(text: 'Active (${active.length})'),
            Tab(text: 'Expired (${expired.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_statusMessage != null)
                  Container(
                    width: double.infinity,
                    color: Colors.amber.shade100,
                    padding: const EdgeInsets.all(8),
                    child: Text(_statusMessage!,
                        style: const TextStyle(color: Colors.black87)),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildReminderList(expiringSoon, isExpiring: true),
                      _buildReminderList(active),
                      _buildReminderList(expired, isExpired: true),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildReminderList(List<WarrantyReminder> list,
      {bool isExpiring = false, bool isExpired = false}) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'No warranty records found in this category.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        Color cardColor = Colors.white;
        if (isExpiring) cardColor = Colors.amber.shade50;
        if (isExpired) cardColor = Colors.red.shade50;

        return Card(
          color: cardColor,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isExpiring
                  ? Colors.amber
                  : (isExpired ? Colors.red : Colors.green),
              child: Icon(
                isExpiring
                    ? Icons.warning_amber
                    : (isExpired ? Icons.error : Icons.verified),
                color: Colors.white,
              ),
            ),
            title: Text(
              '${item.serialNumber} (${item.productName})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Customer: ${item.customerName} • End Date: ${item.endDate.toIso8601String().split('T').first}',
            ),
            trailing: Chip(
              label: Text(
                isExpired
                    ? 'Expired (${item.daysRemaining.abs()}d ago)'
                    : '${item.daysRemaining} days remaining',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}
