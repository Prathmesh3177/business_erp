import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';
import '../../app/locale_controller.dart';
import '../../l10n/strings.dart';
import '../settings/backup_restore_dialog.dart';

final class FoundationPage extends ConsumerWidget {
  const FoundationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final runtime = ref.watch(runtimeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.get('appTitle')),
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(localeProvider.notifier).toggle(),
            icon: const Icon(Icons.language),
            label: Text(strings.get('language')),
          ),
        ],
      ),
      body: runtime.when(
        loading: () => Center(child: Text(strings.get('loading'))),
        error: (error, stackTrace) =>
            _StartupFailure(onRetry: () => ref.invalidate(runtimeProvider)),
        data: (value) => value.identity == null
            ? _SetupForm(runtime: value)
            : _ReadyView(runtime: value),
      ),
    );
  }
}

final class _StartupFailure extends StatelessWidget {
  const _StartupFailure({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 16),
                Text(strings.get('startupFailed'), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onRetry,
                  child: Text(strings.get('retry')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _SetupForm extends ConsumerStatefulWidget {
  const _SetupForm({required this.runtime});
  final AppRuntime runtime;

  @override
  ConsumerState<_SetupForm> createState() => _SetupFormState();
}

final class _SetupFormState extends ConsumerState<_SetupForm> {
  final _formKey = GlobalKey<FormState>();
  final _legalName = TextEditingController(text: 'Shree Krushna Sales');
  final _displayName = TextEditingController(text: 'Shree Krushna Sales');
  final _branchName = TextEditingController(text: 'Kalamb Main Branch');
  final _adminUsername = TextEditingController(text: 'admin');
  final _adminFullName = TextEditingController(text: 'Shree Krushna Admin');
  final _adminPassword = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _legalName.dispose();
    _displayName.dispose();
    _branchName.dispose();
    _adminUsername.dispose();
    _adminFullName.dispose();
    _adminPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final now = DateTime.now();
    final year = now.month >= 4 ? now.year : now.year - 1;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      strings.get('setupTitle'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    _field(_legalName, strings.get('organizationLegalName')),
                    const SizedBox(height: 16),
                    _field(
                      _displayName,
                      strings.get('organizationDisplayName'),
                    ),
                    const SizedBox(height: 16),
                    _field(_branchName, strings.get('branchName')),
                    const SizedBox(height: 24),
                    Text(
                      strings.get('adminAccount'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _field(_adminUsername, strings.get('adminUsername')),
                    const SizedBox(height: 16),
                    _field(_adminFullName, strings.get('adminFullName')),
                    const SizedBox(height: 16),
                    _field(
                      _adminPassword,
                      strings.get('adminPassword'),
                      isObscure: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${strings.get('financialYear')}: '
                      '01-04-$year — 31-03-${year + 1}',
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : () => _submit(year),
                      child: Text(strings.get('saveSetup')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool isObscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          value == null || value.trim().isEmpty ? label : null,
    );
  }

  Future<void> _submit(int year) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final setup = FirstRunSetup.validate(
        legalName: _legalName.text,
        displayName: _displayName.text,
        branchName: _branchName.text,
        timeZone: 'Asia/Kolkata',
        locale: ref.read(localeProvider).languageCode,
        financialYearStartsOn: DateTime.utc(year, 4),
        financialYearEndsOn: DateTime.utc(year + 1, 3, 31),
      );

      await widget.runtime.initialize.call(setup);

      final recoveryKey = await widget.runtime.createFirstAdmin.call(
        username: _adminUsername.text,
        fullName: _adminFullName.text,
        password: _adminPassword.text,
      );

      if (mounted) {
        await _showRecoveryKeyDialog(context, recoveryKey);
      }

      ref.invalidate(runtimeProvider);
    } on ErpFailure catch (failure) {
      setState(() => _error = failure.safeMessage);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showRecoveryKeyDialog(
    BuildContext context,
    String recoveryKey,
  ) async {
    final strings = AppStrings.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(strings.get('recoveryKeyTitle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.get('recoveryKeyNotice')),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                recoveryKey,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(letterSpacing: 2, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('I Have Saved This Key'),
          ),
        ],
      ),
    );
  }
}

final class _ReadyView extends ConsumerWidget {
  const _ReadyView({required this.runtime});
  final AppRuntime runtime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final identity = runtime.identity!;
    final session = ref.watch(authProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.solar_power, size: 64, color: Color(0xFF990000)),
            const SizedBox(height: 8),
            Text(
              identity.organization.displayName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF990000),
              ),
            ),
            Text(
              identity.branch.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF004D40),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2D3748)),
              ),
              child: Column(
                children: [
                  Text(
                    strings.get('shopAddress'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.get('shopPhone'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004D40),
                    ),
                  ),
                ],
              ),
            ),
            if (session != null) ...[
              const SizedBox(height: 12),
              Chip(
                avatar: const Icon(Icons.person, size: 16, color: Colors.white),
                backgroundColor: const Color(0xFF004D40),
                labelStyle: const TextStyle(color: Colors.white),
                label: Text('${session.username} (${session.roleId})'),
              ),
            ],
            const SizedBox(height: 12),
            Text(strings.get('singleAuthority'), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF990000), foregroundColor: Colors.white),
                  onPressed: () => context.push('/dashboard'),
                  icon: const Icon(Icons.dashboard),
                  label: const Text('Executive Dashboard'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40), foregroundColor: Colors.white),
                  onPressed: () => context.push('/reports'),
                  icon: const Icon(Icons.analytics),
                  label: const Text('Reports & BI'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF990000), foregroundColor: Colors.white),
                  onPressed: () => context.push('/catalog'),
                  icon: const Icon(Icons.inventory),
                  label: const Text('Product Catalog'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40), foregroundColor: Colors.white),
                  onPressed: () => context.push('/parties'),
                  icon: const Icon(Icons.people),
                  label: const Text('Party Masters'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF990000), foregroundColor: Colors.white),
                  onPressed: () => context.push('/accounting'),
                  icon: const Icon(Icons.account_balance),
                  label: const Text('Accounting & GST'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40), foregroundColor: Colors.white),
                  onPressed: () => context.push('/inventory'),
                  icon: const Icon(Icons.inventory_2),
                  label: const Text('Inventory & Serials'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000), foregroundColor: Colors.white),
                  onPressed: () => context.push('/sales'),
                  icon: const Icon(Icons.point_of_sale),
                  label: const Text('Counter POS & Sales'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF990000), foregroundColor: Colors.white),
                  onPressed: () => context.push('/purchases'),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Purchases & Receipts'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40), foregroundColor: Colors.white),
                  onPressed: () => context.push('/finance'),
                  icon: const Icon(Icons.payments),
                  label: const Text('Finance, Returns & Expenses'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE65100), foregroundColor: Colors.white),
                  onPressed: () => context.push('/projects'),
                  icon: const Icon(Icons.wb_sunny),
                  label: const Text('Solar Projects & Quotations'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0288D1), foregroundColor: Colors.white),
                  onPressed: () => context.push('/service'),
                  icon: const Icon(Icons.build),
                  label: const Text('Service & AMC Workflows'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _snapshot(context),
                  icon: const Icon(Icons.backup_outlined),
                  label: Text(strings.get('snapshot')),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40), foregroundColor: Colors.white),
                  onPressed: () => context.push('/warranty'),
                  icon: const Icon(Icons.verified_user),
                  label: const Text('Warranty & Reminders'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF990000), foregroundColor: Colors.white),
                  onPressed: () => context.push('/mobile'),
                  icon: const Icon(Icons.phone_android),
                  label: const Text('Mobile Draft Workflows'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40), foregroundColor: Colors.white),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const BackupRestoreDialog(),
                  ),
                  icon: const Icon(Icons.security),
                  label: const Text('Backup & Recovery (ADR-013)'),
                ),

                if (session?.hasCapability(Capability.userManage) ?? false)
                  ElevatedButton.icon(
                    onPressed: () => context.push('/users'),
                    icon: const Icon(Icons.manage_accounts),
                    label: Text(strings.get('userManagement')),
                  ),
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(authProvider.notifier).lockSession(),
                  icon: const Icon(Icons.lock_outline),
                  label: Text(strings.get('lockSession')),
                ),
                TextButton.icon(
                  onPressed: () => ref.read(authProvider.notifier).logout(),
                  icon: const Icon(Icons.logout),
                  label: Text(strings.get('logout')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _snapshot(BuildContext context) async {
    final directory = await runtime.locations.snapshotDirectory();
    final target =
        '${directory.path}/manual-'
        '${DateTime.now().toUtc().millisecondsSinceEpoch}.erpdb';
    await runtime.database.createVerifiedSnapshot(target);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).get('snapshotCreated'))),
      );
    }
  }
}
