import 'dart:math' as math;
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';
import '../../app/locale_controller.dart';
import '../../app/theme.dart';
import '../../l10n/strings.dart';
import '../common/erp_ui.dart';
import '../settings/backup_restore_dialog.dart';

final class FoundationPage extends ConsumerWidget {
  const FoundationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final runtime = ref.watch(runtimeProvider);
    return runtime.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(strings.get('appTitle'))),
        body: Center(child: Text(strings.get('loading'))),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(strings.get('appTitle'))),
        body: _StartupFailure(onRetry: () => ref.invalidate(runtimeProvider)),
      ),
      data: (value) => value.identity == null
          ? Scaffold(
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
              body: _SetupForm(runtime: value),
            )
          : _ReadyView(runtime: value),
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

// Kept temporarily as a migration reference while the responsive workspace
// below replaces the original button wall.
// ignore: unused_element
final class _LegacyReadyView extends ConsumerWidget {
  const _LegacyReadyView({required this.runtime});
  final AppRuntime runtime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final identity = runtime.identity!;
    final session = ref.watch(authProvider);

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.solar_power,
                  size: 64,
                  color: Color(0xFF990000),
                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
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
                    avatar: const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.white,
                    ),
                    backgroundColor: const Color(0xFF004D40),
                    labelStyle: const TextStyle(color: Colors.white),
                    label: Text('${session.username} (${session.roleId})'),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  strings.get('singleAuthority'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF990000),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push('/dashboard'),
                      icon: const Icon(Icons.dashboard),
                      label: const Text('Executive Dashboard'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push('/reports'),
                      icon: const Icon(Icons.analytics),
                      label: const Text('Reports & BI'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF990000),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push('/catalog'),
                      icon: const Icon(Icons.inventory),
                      label: const Text('Product Catalog'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push('/parties'),
                      icon: const Icon(Icons.people),
                      label: const Text('Party Masters'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF990000),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push('/accounting'),
                      icon: const Icon(Icons.account_balance),
                      label: const Text('Accounting & GST'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push('/inventory'),
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('Inventory & Serials'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push('/sales'),
                      icon: const Icon(Icons.point_of_sale),
                      label: const Text('Counter POS & Sales'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF990000),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push('/purchases'),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Purchases & Receipts'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push('/finance'),
                      icon: const Icon(Icons.payments),
                      label: const Text('Finance, Returns & Expenses'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push('/projects'),
                      icon: const Icon(Icons.wb_sunny),
                      label: const Text('Solar Projects & Quotations'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0288D1),
                        foregroundColor: Colors.white,
                      ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push('/warranty'),
                      icon: const Icon(Icons.verified_user),
                      label: const Text('Warranty & Reminders'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF990000),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push('/mobile'),
                      icon: const Icon(Icons.phone_android),
                      label: const Text('Mobile Draft Workflows'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                        foregroundColor: Colors.white,
                      ),
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

/// The signed-in workspace deliberately owns navigation. Individual feature
/// pages remain focused on their workflow, while this shell consistently shows
/// only the areas the current role is allowed to open.
final class _ReadyView extends ConsumerStatefulWidget {
  const _ReadyView({required this.runtime});

  final AppRuntime runtime;

  @override
  ConsumerState<_ReadyView> createState() => _ReadyViewState();
}

final class _ReadyViewState extends ConsumerState<_ReadyView> {
  bool _quickAccessExpanded = true;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authProvider);
    final strings = AppStrings.of(context);
    final copy = _WorkspaceCopy.of(context);
    final modules = _WorkspaceModule.values
        .where((item) => item.isVisibleTo(session))
        .toList();
    final compact = ErpBreakpoints.isCompact(context);

    final workspace = _WorkspaceOverview(
      runtime: widget.runtime,
      modules: modules,
      copy: copy,
      quickAccessExpanded: _quickAccessExpanded,
      onToggleQuickAccess: () =>
          setState(() => _quickAccessExpanded = !_quickAccessExpanded),
      onOpen: (module) {
        if (module == _WorkspaceModule.backup) {
          showDialog<void>(
            context: context,
            builder: (_) => const BackupRestoreDialog(),
          );
        } else {
          context.go(module.path);
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: compact
          ? Drawer(
              child: _WorkspaceNavigation(
                modules: modules,
                copy: copy,
                onOpen: (module) {
                  Navigator.of(context).pop();
                  if (module == _WorkspaceModule.backup) {
                    showDialog<void>(
                      context: context,
                      builder: (_) => const BackupRestoreDialog(),
                    );
                  } else {
                    context.go(module.path);
                  }
                },
                onLogout: () => ref.read(authProvider.notifier).logout(),
                onLock: () => ref.read(authProvider.notifier).lockSession(),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Builder(
              builder: (scaffoldContext) => _WorkspaceTopBar(
                compact: compact,
                branch: widget.runtime.identity!.branch.name,
                username: session?.username ?? 'Admin',
                role: session?.roleId == Role.adminRoleId
                    ? copy.administrator
                    : copy.counterStaff,
                language: strings.get('language'),
                onMenu: compact
                    ? () => Scaffold.of(scaffoldContext).openDrawer()
                    : null,
                onLanguage: () => ref.read(localeProvider.notifier).toggle(),
                onLock: () => ref.read(authProvider.notifier).lockSession(),
                onLogout: () => ref.read(authProvider.notifier).logout(),
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!compact)
                    SizedBox(
                      width: 236,
                      child: _WorkspaceNavigation(
                        modules: modules,
                        copy: copy,
                        onOpen: (module) {
                          if (module == _WorkspaceModule.backup) {
                            showDialog<void>(
                              context: context,
                              builder: (_) => const BackupRestoreDialog(),
                            );
                          } else {
                            context.go(module.path);
                          }
                        },
                        onLogout: () =>
                            ref.read(authProvider.notifier).logout(),
                        onLock: () =>
                            ref.read(authProvider.notifier).lockSession(),
                      ),
                    ),
                  Expanded(child: workspace),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _WorkspaceTopBar extends StatelessWidget {
  const _WorkspaceTopBar({
    required this.compact,
    required this.branch,
    required this.username,
    required this.role,
    required this.language,
    required this.onLanguage,
    required this.onLock,
    required this.onLogout,
    this.onMenu,
  });

  final bool compact;
  final String branch;
  final String username;
  final String role;
  final String language;
  final VoidCallback onLanguage;
  final VoidCallback onLock;
  final VoidCallback onLogout;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) => Container(
    height: 68,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
    ),
    child: Row(
      children: [
        if (onMenu != null)
          IconButton(
            onPressed: onMenu,
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF334155)),
            tooltip: 'Menu',
          )
        else
          const SizedBox(width: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/app_logo.png',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.solar_power_rounded,
                color: Color(0xFFDC2626),
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Shree Krushna Sales ERP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            Text(
              branch,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        if (!compact)
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        size: 19,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Search products, customers, invoices, ...',
                            hintStyle: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          'Ctrl + K',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          const Spacer(),
        InkWell(
          onTap: onLanguage,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.language_rounded,
                  size: 16,
                  color: Color(0xFF334155),
                ),
                const SizedBox(width: 6),
                Text(
                  language,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        PopupMenuButton<String>(
          tooltip: 'Account',
          onSelected: (item) {
            if (item == 'lock') onLock();
            if (item == 'logout') onLogout();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'lock', child: Text('Lock session')),
            PopupMenuItem(value: 'logout', child: Text('Sign out')),
          ],
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFF065F46),
                child: Text(
                  username.isEmpty ? 'A' : username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      role,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
              ],
            ],
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 18),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.remove, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 12),
              Icon(Icons.crop_square, size: 14, color: Color(0xFF64748B)),
              SizedBox(width: 12),
              Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
            ],
          ),
        ],
      ],
    ),
  );
}

final class _WorkspaceNavigation extends StatelessWidget {
  const _WorkspaceNavigation({
    required this.modules,
    required this.copy,
    required this.onOpen,
    required this.onLogout,
    required this.onLock,
  });

  final List<_WorkspaceModule> modules;
  final _WorkspaceCopy copy;
  final ValueChanged<_WorkspaceModule> onOpen;
  final VoidCallback onLogout;
  final VoidCallback onLock;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              children: [
                _navTile(
                  context: context,
                  icon: Icons.dashboard_rounded,
                  label: copy.dashboard,
                  isActive: true,
                  onTap: () => onOpen(_WorkspaceModule.dashboard),
                ),
                for (final module in modules.where(
                  (item) => item != _WorkspaceModule.dashboard,
                ))
                  _navTile(
                    context: context,
                    icon: module.icon,
                    label: copy.moduleName(module),
                    isActive: false,
                    onTap: () => onOpen(module),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              children: [
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  leading: const Icon(
                    Icons.lock_outline_rounded,
                    size: 19,
                    color: Color(0xFF475569),
                  ),
                  title: Text(
                    copy.lockSession,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  onTap: onLock,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  leading: const Icon(
                    Icons.logout_rounded,
                    size: 19,
                    color: Color(0xFFDC2626),
                  ),
                  title: Text(
                    copy.signOut,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  onTap: onLogout,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _navTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      minLeadingWidth: 20,
      selected: isActive,
      selectedTileColor: const Color(0xFFE8F1FF),
      leading: Icon(
        icon,
        size: 20,
        color: isActive ? const Color(0xFF0B57D0) : const Color(0xFF475569),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? const Color(0xFF0B57D0) : const Color(0xFF334155),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      onTap: onTap,
    ),
  );
}

final class _WorkspaceOverview extends StatelessWidget {
  const _WorkspaceOverview({
    required this.runtime,
    required this.modules,
    required this.copy,
    required this.quickAccessExpanded,
    required this.onToggleQuickAccess,
    required this.onOpen,
  });

  final AppRuntime runtime;
  final List<_WorkspaceModule> modules;
  final _WorkspaceCopy copy;
  final bool quickAccessExpanded;
  final VoidCallback onToggleQuickAccess;
  final ValueChanged<_WorkspaceModule> onOpen;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.all(ErpBreakpoints.isCompact(context) ? 14 : 20),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WelcomeBanner(runtime: runtime, copy: copy),
          const SizedBox(height: 18),
          _QuickAccessSection(
            copy: copy,
            expanded: quickAccessExpanded,
            onToggle: onToggleQuickAccess,
            onOpen: onOpen,
          ),
          const SizedBox(height: 18),
          _DashboardMiddleRow(copy: copy, onOpen: onOpen),
          const SizedBox(height: 18),
          _DashboardBottomRow(copy: copy, onOpen: onOpen),
        ],
      ),
    ),
  );
}

final class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.runtime, required this.copy});

  final AppRuntime runtime;
  final _WorkspaceCopy copy;

  @override
  Widget build(BuildContext context) {
    final isCompact = ErpBreakpoints.isCompact(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        image: const DecorationImage(
          image: AssetImage('assets/images/solar_pump_hero.png'),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white.withValues(alpha: 0.96),
              Colors.white.withValues(alpha: 0.88),
              Colors.white.withValues(alpha: 0.35),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 0.72, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 24,
              runSpacing: 8,
              children: [
                const Text(
                  'Shree Krushna Sales ERP',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E3A8A),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Solar Solutions for a Better Tomorrow',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    fontSize: isCompact ? 14 : 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: Color(0xFF059669),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    runtime.identity?.branch.name ?? 'Kalamb Main Branch',
                    style: const TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoItem(
                          icon: Icons.storefront_outlined,
                          iconBg: const Color(0xFFFFE4E6),
                          iconColor: const Color(0xFFE11D48),
                          title: 'Address',
                          subtitle:
                              'Rajmata Jijau Chowk, Jantre Plaza, Dhoki Road, Kalamb - 413507',
                        ),
                        const Divider(height: 16),
                        _infoItem(
                          icon: Icons.phone_outlined,
                          iconBg: const Color(0xFFDCFCE7),
                          iconColor: const Color(0xFF059669),
                          title: 'Contact',
                          subtitle: '7020422291 / 9881630001',
                        ),
                        const Divider(height: 16),
                        _infoItem(
                          icon: Icons.access_time_rounded,
                          iconBg: const Color(0xFFFFEDD5),
                          iconColor: const Color(0xFFEA580C),
                          title: 'Working Hours',
                          subtitle: 'Mon - Sat : 9:00 AM - 8:00 PM',
                        ),
                      ],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _infoItem(
                            icon: Icons.storefront_outlined,
                            iconBg: const Color(0xFFFFE4E6),
                            iconColor: const Color(0xFFE11D48),
                            title: 'Address',
                            subtitle:
                                'Rajmata Jijau Chowk, Jantre Plaza,\nDhoki Road, Kalamb - 413507',
                          ),
                          const VerticalDivider(
                            width: 32,
                            thickness: 1,
                            color: Color(0xFFE2E8F0),
                          ),
                          _infoItem(
                            icon: Icons.phone_outlined,
                            iconBg: const Color(0xFFDCFCE7),
                            iconColor: const Color(0xFF059669),
                            title: 'Contact',
                            subtitle: '7020422291\n9881630001',
                          ),
                          const VerticalDivider(
                            width: 32,
                            thickness: 1,
                            color: Color(0xFFE2E8F0),
                          ),
                          _infoItem(
                            icon: Icons.access_time_rounded,
                            iconBg: const Color(0xFFFFEDD5),
                            iconColor: const Color(0xFFEA580C),
                            title: 'Working Hours',
                            subtitle: 'Mon - Sat\n9:00 AM - 8:00 PM',
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(icon, size: 17, color: iconColor),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              height: 1.25,
            ),
          ),
        ],
      ),
    ],
  );
}

final class _QuickAccessSection extends StatelessWidget {
  const _QuickAccessSection({
    required this.copy,
    required this.expanded,
    required this.onToggle,
    required this.onOpen,
  });

  final _WorkspaceCopy copy;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<_WorkspaceModule> onOpen;

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickItem(
        icon: Icons.shopping_cart_rounded,
        iconBg: const Color(0xFFEF4444),
        title: 'Sales / POS',
        subtitle: 'Create Invoice',
        module: _WorkspaceModule.sales,
      ),
      _QuickItem(
        icon: Icons.local_shipping_rounded,
        iconBg: const Color(0xFF10B981),
        title: 'Purchase',
        subtitle: 'Add Purchase',
        module: _WorkspaceModule.purchases,
      ),
      _QuickItem(
        icon: Icons.inventory_2_rounded,
        iconBg: const Color(0xFF3B82F6),
        title: 'Products',
        subtitle: 'Product Catalog',
        module: _WorkspaceModule.catalog,
      ),
      _QuickItem(
        icon: Icons.dns_rounded,
        iconBg: const Color(0xFFF59E0B),
        title: 'Inventory',
        subtitle: 'Stock & Serials',
        module: _WorkspaceModule.inventory,
      ),
      _QuickItem(
        icon: Icons.group_rounded,
        iconBg: const Color(0xFF8B5CF6),
        title: 'Parties',
        subtitle: 'Customers & Suppliers',
        module: _WorkspaceModule.parties,
      ),
      _QuickItem(
        icon: Icons.bar_chart_rounded,
        iconBg: const Color(0xFFF43F5E),
        title: 'Reports',
        subtitle: 'View Reports',
        module: _WorkspaceModule.reports,
      ),
      _QuickItem(
        icon: Icons.build_rounded,
        iconBg: const Color(0xFF06B6D4),
        title: 'Service & AMC',
        subtitle: 'Service Requests',
        module: _WorkspaceModule.service,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              copy.quickAccess,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
        if (expanded) ...[
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 1200
                  ? 7
                  : constraints.maxWidth >= 850
                  ? 4
                  : constraints.maxWidth >= 500
                  ? 3
                  : 2;

              return GridView.builder(
                itemCount: items.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: constraints.maxWidth < 600 ? 1.6 : 2.1,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return InkWell(
                    onTap: () => onOpen(item.module),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: item.iconBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ],
    );
  }
}

final class _QuickItem {
  const _QuickItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.module,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final _WorkspaceModule module;
}

final class _DashboardMiddleRow extends StatelessWidget {
  const _DashboardMiddleRow({required this.copy, required this.onOpen});

  final _WorkspaceCopy copy;
  final ValueChanged<_WorkspaceModule> onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildTodaysSummaryCard()),
              const SizedBox(width: 14),
              Expanded(flex: 8, child: _buildSalesOverviewCard()),
              const SizedBox(width: 14),
              Expanded(
                flex: 7,
                child: _buildStockStatusCard(
                  onTap: () => onOpen(_WorkspaceModule.inventory),
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildTodaysSummaryCard(),
              const SizedBox(height: 14),
              _buildSalesOverviewCard(),
              const SizedBox(height: 14),
              _buildStockStatusCard(
                onTap: () => onOpen(_WorkspaceModule.inventory),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildTodaysSummaryCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Summary",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: const [
                  Text(
                    '17 Sep 2026',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 11,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _summaryBox(
                icon: const Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                  ),
                ),
                iconBg: const Color(0xFFDCFCE7),
                title: 'Sales Today',
                value: '₹ 1,24,500',
                trend: '+12%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryBox(
                icon: const Icon(
                  Icons.shopping_cart_rounded,
                  size: 18,
                  color: Color(0xFF3B82F6),
                ),
                iconBg: const Color(0xFFDBEAFE),
                title: 'Purchase Today',
                value: '₹ 48,300',
                trend: '+8%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _summaryBox(
                icon: const Icon(
                  Icons.inventory_2_rounded,
                  size: 18,
                  color: Color(0xFFF59E0B),
                ),
                iconBg: const Color(0xFFFEF3C7),
                title: 'Items Sold',
                value: '42',
                trend: '+5%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryBox(
                icon: const Icon(
                  Icons.group_rounded,
                  size: 18,
                  color: Color(0xFF8B5CF6),
                ),
                iconBg: const Color(0xFFEDE9FE),
                title: 'New Customers',
                value: '6',
                trend: '+50%',
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _summaryBox({
    required Widget icon,
    required Color iconBg,
    required String title,
    required String value,
    required String trend,
  }) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFF1F5F9)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: icon,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.arrow_upward_rounded,
              size: 12,
              color: Color(0xFF10B981),
            ),
            const SizedBox(width: 2),
            Text(
              trend,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildSalesOverviewCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sales Overview',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: const [
                  Text(
                    'This Week',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: CustomPaint(
            size: const Size(double.infinity, 140),
            painter: _SalesOverviewChartPainter(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(const Color(0xFF2563EB), 'Sales'),
            const SizedBox(width: 18),
            _legendDot(const Color(0xFF93C5FD), 'Purchase'),
          ],
        ),
      ],
    ),
  );

  Widget _legendDot(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
      ),
    ],
  );

  Widget _buildStockStatusCard({required VoidCallback onTap}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Stock Status',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: _StockDonutPainter(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '1,248',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Total Items',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _stockStatusRow(const Color(0xFF10B981), 'In Stock', '842'),
                  const SizedBox(height: 8),
                  _stockStatusRow(const Color(0xFFF59E0B), 'Low Stock', '156'),
                  const SizedBox(height: 8),
                  _stockStatusRow(const Color(0xFFEF4444), 'Out of Stock', '98'),
                  const SizedBox(height: 8),
                  _stockStatusRow(const Color(0xFF8B5CF6), 'Expired', '12'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
      ],
    ),
  );

  Widget _stockStatusRow(Color color, String label, String count) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
      ),
      const Spacer(),
      Text(
        count,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
    ],
  );
}

final class _DashboardBottomRow extends StatelessWidget {
  const _DashboardBottomRow({required this.copy, required this.onOpen});

  final _WorkspaceCopy copy;
  final ValueChanged<_WorkspaceModule> onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildRecentInvoices(context)),
              const SizedBox(width: 14),
              Expanded(flex: 7, child: _buildLowStockItems(context)),
              const SizedBox(width: 14),
              Expanded(flex: 7, child: _buildUpcomingReminders(context)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildRecentInvoices(context),
              const SizedBox(height: 14),
              _buildLowStockItems(context),
              const SizedBox(height: 14),
              _buildUpcomingReminders(context),
            ],
          );
        }
      },
    );
  }

  Widget _buildRecentInvoices(BuildContext context) {
    final rows = [
      ('INV-1024', '17 Sep 2026', 'Patil Solar Systems', '₹ 24,500', 'Paid'),
      ('INV-1023', '17 Sep 2026', 'Shinde Enterprises', '₹ 18,900', 'Pending'),
      ('INV-1022', '16 Sep 2026', 'Deshmukh Irrigation', '₹ 45,000', 'Paid'),
      ('INV-1021', '16 Sep 2026', 'Jadhav Electricals', '₹ 12,300', 'Paid'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Invoices',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: () => onOpen(_WorkspaceModule.sales),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.6),
              1: FlexColumnWidth(1.8),
              2: FlexColumnWidth(2.6),
              3: FlexColumnWidth(1.8),
              4: FlexColumnWidth(1.5),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF1F5F9)),
                  ),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      '#',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Customer',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              for (final row in rows)
                TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF8FAFC)),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        row.$1,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        row.$2,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        row.$3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        row.$4,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: row.$5 == 'Paid'
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            row.$5,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: row.$5 == 'Paid'
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockItems(BuildContext context) {
    final items = [
      (
        Icons.solar_power_rounded,
        const Color(0xFF2563EB),
        const Color(0xFFDBEAFE),
        'Solar Panel 550W',
        3,
        10,
      ),
      (
        Icons.water_drop_rounded,
        const Color(0xFF0284C7),
        const Color(0xFFE0F2FE),
        'Submersible Pump 2HP',
        2,
        5,
      ),
      (
        Icons.electrical_services_rounded,
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
        'MC4 Connector',
        25,
        50,
      ),
      (
        Icons.cable_rounded,
        const Color(0xFF475569),
        const Color(0xFFF1F5F9),
        'Solar Cable 4 sqmm',
        40,
        100,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Low Stock Items',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: () => onOpen(_WorkspaceModule.inventory),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(4.5),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF1F5F9)),
                  ),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Product',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Current',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Min. Level',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              for (final item in items)
                TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF8FAFC)),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: item.$3,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(item.$1, size: 14, color: item.$2),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.$4,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(
                        '${item.$5}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: item.$5 <= item.$6 / 2
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(
                        '${item.$6}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingReminders(BuildContext context) {
    final reminders = [
      (
        Icons.calendar_today_rounded,
        '18 Sep 2026',
        'AMC',
        const Color(0xFFDBEAFE),
        const Color(0xFF1D4ED8),
        'Site Visit - Patil Farm',
      ),
      (
        Icons.access_time_rounded,
        '20 Sep 2026',
        'Warranty',
        const Color(0xFFFEE2E2),
        const Color(0xFFB91C1C),
        'Panel Warranty Expiry',
      ),
      (
        Icons.build_rounded,
        '22 Sep 2026',
        'Service',
        const Color(0xFFDCFCE7),
        const Color(0xFF15803D),
        'Pump Service - Shinde',
      ),
      (
        Icons.phone_outlined,
        '25 Sep 2026',
        'Follow Up',
        const Color(0xFFFEF3C7),
        const Color(0xFFB45309),
        'Quotation Follow Up',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Reminders',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: () => onOpen(_WorkspaceModule.warranty),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2.6),
              1: FlexColumnWidth(2.0),
              2: FlexColumnWidth(3.4),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF1F5F9)),
                  ),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              for (final rem in reminders)
                TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF8FAFC)),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(rem.$1, size: 12, color: const Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            rem.$2,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: rem.$4,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            rem.$3,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: rem.$5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        rem.$6,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _SalesOverviewChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;

    final salesPaint = Paint()..color = const Color(0xFF2563EB);
    final purchasePaint = Paint()..color = const Color(0xFF93C5FD);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const yLabels = ['2L', '1.5L', '1L', '50K', '0'];
    final yStep = (size.height - 20) / (yLabels.length - 1);

    for (int i = 0; i < yLabels.length; i++) {
      final y = i * yStep;
      canvas.drawLine(Offset(32, y), Offset(size.width, y), gridPaint);

      textPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(4, y - 5));
    }

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final salesRatios = [0.45, 0.70, 0.65, 0.85, 0.75, 0.68, 0.80];
    final purchaseRatios = [0.25, 0.38, 0.40, 0.50, 0.42, 0.35, 0.48];

    final chartWidth = size.width - 40;
    final groupWidth = chartWidth / days.length;
    const barWidth = 8.0;

    final baseY = size.height - 20;

    for (int i = 0; i < days.length; i++) {
      final groupX = 36 + i * groupWidth + (groupWidth - barWidth * 2 - 4) / 2;

      final sHeight = salesRatios[i] * baseY;
      final pHeight = purchaseRatios[i] * baseY;

      // Sales Bar
      final salesRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(groupX, baseY - sHeight, barWidth, sHeight),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(salesRect, salesPaint);

      // Purchase Bar
      final purchaseRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(groupX + barWidth + 3, baseY - pHeight, barWidth, pHeight),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(purchaseRect, purchasePaint);

      // Day label
      textPainter.text = TextSpan(
        text: days[i],
        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(groupX - 2, baseY + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

final class _StockDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    const total = 1248.0;
    final segments = [
      (842.0, const Color(0xFF10B981)), // In Stock
      (156.0, const Color(0xFFF59E0B)), // Low Stock
      (98.0, const Color(0xFFEF4444)),  // Out of Stock
      (12.0, const Color(0xFF8B5CF6)),  // Expired
      (140.0, const Color(0xFFE2E8F0)), // Balance / Normal
    ];

    double startAngle = -math.pi / 2;
    for (final seg in segments) {
      final sweepAngle = (seg.$1 / total) * 2 * math.pi;
      strokePaint.color = seg.$2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.04,
        false,
        strokePaint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _WorkspaceModule {
  dashboard('/', Icons.dashboard_rounded, Color(0xFF2563EB), null),
  reports('/reports', Icons.bar_chart_rounded, Color(0xFFF43F5E), Capability.salesRead),
  catalog('/catalog', Icons.category_outlined, Color(0xFF2563EB), Capability.inventoryManage),
  inventory('/inventory', Icons.dns_outlined, Color(0xFFF59E0B), Capability.inventoryManage),
  sales('/sales', Icons.shopping_cart_outlined, SolarColors.crimson, Capability.salesCreate),
  purchases('/purchases', Icons.local_shipping_outlined, Color(0xFF10B981), Capability.purchaseManage),
  accounting('/accounting', Icons.calculate_outlined, Color(0xFF0369A1), Capability.costDataRead),
  projects('/projects', Icons.wb_sunny_outlined, Color(0xFFF59E0B), null),
  service('/service', Icons.build_outlined, Color(0xFF06B6D4), null),
  parties('/parties', Icons.people_alt_outlined, Color(0xFF8B5CF6), Capability.partyManage),
  warranty('/warranty', Icons.verified_user_outlined, Color(0xFF16A34A), Capability.salesRead),
  mobile('/mobile', Icons.phone_android_outlined, Color(0xFF475569), Capability.salesCreate),
  backup('backup', Icons.cloud_sync_outlined, Color(0xFF0F766E), Capability.userManage),
  users('/users', Icons.manage_accounts_outlined, SolarColors.crimson, Capability.userManage);

  const _WorkspaceModule(this.path, this.icon, this.color, this.capability);

  final String path;
  final IconData icon;
  final Color color;
  final Capability? capability;

  bool isVisibleTo(UserSession? session) {
    if (session == null) return false;
    if (this == _WorkspaceModule.projects || this == _WorkspaceModule.service) {
      return session.roleId == Role.adminRoleId;
    }
    return capability == null || session.hasCapability(capability!);
  }
}

final class _WorkspaceCopy {
  const _WorkspaceCopy(this.marathi);

  final bool marathi;

  static _WorkspaceCopy of(BuildContext context) =>
      _WorkspaceCopy(Localizations.localeOf(context).languageCode == 'mr');

  String get salesErp => marathi ? 'सेल्स ईआरपी' : 'Sales ERP';
  String get dashboard => marathi ? 'डॅशबोर्ड' : 'Dashboard';
  String get quickAccess => marathi ? 'जलद प्रवेश' : 'Quick Access';
  String get welcome => marathi ? 'आपले स्वागत आहे' : 'Welcome to';
  String get solarPromise => marathi
      ? 'उत्तम उद्यासाठी सौर उपाय'
      : 'Solar solutions for a better tomorrow';
  String get administrator => marathi ? 'प्रशासक' : 'Administrator';
  String get counterStaff => marathi ? 'काउंटर कर्मचारी' : 'Counter Staff';
  String get signOut => marathi ? 'साइन आउट' : 'Sign Out';
  String get lockSession => marathi ? 'सत्र लॉक करा' : 'Lock Session';

  String moduleName(_WorkspaceModule module) => switch (module) {
    _WorkspaceModule.dashboard => dashboard,
    _WorkspaceModule.reports => marathi ? 'अहवाल व विश्लेषण' : 'Reports & BI',
    _WorkspaceModule.catalog => marathi ? 'उत्पादन सूची' : 'Product Catalog',
    _WorkspaceModule.inventory =>
      marathi ? 'साठा व सिरियल' : 'Inventory & Serials',
    _WorkspaceModule.sales => marathi ? 'विक्री / पीओएस' : 'Sales / POS',
    _WorkspaceModule.purchases =>
      marathi ? 'खरेदी व माल प्राप्ती' : 'Purchases & Receipts',
    _WorkspaceModule.accounting =>
      marathi ? 'लेखांकन व जीएसटी' : 'Accounting & GST',
    _WorkspaceModule.projects => marathi ? 'सौर प्रकल्प' : 'Solar Projects',
    _WorkspaceModule.service => marathi ? 'सेवा व एएमसी' : 'Service & AMC',
    _WorkspaceModule.parties =>
      marathi ? 'पार्टी मास्टर्स' : 'Party Masters',
    _WorkspaceModule.warranty =>
      marathi ? 'हमी व स्मरणपत्रे' : 'Warranty & Reminders',
    _WorkspaceModule.mobile =>
      marathi ? 'मोबाईल वर्कफ्लो' : 'Mobile Workflows',
    _WorkspaceModule.backup =>
      marathi ? 'बॅकअप व पुनर्प्राप्ती' : 'Backup & Recovery',
    _WorkspaceModule.users =>
      marathi ? 'वापरकर्ता व्यवस्थापन' : 'User Management',
  };
}
