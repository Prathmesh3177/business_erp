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

/// The signed-in workspace deliberately owns navigation.  Individual feature
/// pages remain focused on their workflow, while this shell consistently shows
/// only the areas the current role is allowed to open.
final class _ReadyView extends ConsumerWidget {
  const _ReadyView({required this.runtime});

  final AppRuntime runtime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);
    final strings = AppStrings.of(context);
    final copy = _WorkspaceCopy.of(context);
    final modules = _WorkspaceModule.values
        .where((item) => item.isVisibleTo(session))
        .toList();
    final compact = ErpBreakpoints.isCompact(context);

    final workspace = _WorkspaceOverview(
      runtime: runtime,
      modules: modules,
      copy: copy,
      onOpen: (module) => context.go(module.path),
    );

    return Scaffold(
      drawer: compact
          ? Drawer(
              child: _WorkspaceNavigation(
                modules: modules,
                copy: copy,
                onOpen: (module) {
                  Navigator.of(context).pop();
                  context.go(module.path);
                },
                onLogout: () => ref.read(authProvider.notifier).logout(),
              ),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!compact)
              SizedBox(
                width: 244,
                child: _WorkspaceNavigation(
                  modules: modules,
                  copy: copy,
                  onOpen: (module) => context.go(module.path),
                  onLogout: () => ref.read(authProvider.notifier).logout(),
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  Builder(
                    builder: (scaffoldContext) => _WorkspaceTopBar(
                      compact: compact,
                      branch: runtime.identity!.branch.name,
                      username: session?.username ?? '',
                      role: session?.roleId == Role.adminRoleId
                          ? copy.administrator
                          : copy.counterStaff,
                      language: strings.get('language'),
                      onMenu: compact
                          ? () => Scaffold.of(scaffoldContext).openDrawer()
                          : null,
                      onLanguage: () =>
                          ref.read(localeProvider.notifier).toggle(),
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
    this.onMenu,
  });

  final bool compact;
  final String branch;
  final String username;
  final String role;
  final String language;
  final VoidCallback onLanguage;
  final VoidCallback onLock;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) => Container(
    height: 80,
    padding: const EdgeInsets.symmetric(horizontal: 18),
    decoration: const BoxDecoration(
      color: SolarColors.surface,
      border: Border(bottom: BorderSide(color: SolarColors.slate100)),
    ),
    child: Row(
      children: [
        if (onMenu != null)
          IconButton(onPressed: onMenu, icon: const Icon(Icons.menu)),
        if (!compact) ...[
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Search products, customers, invoices…',
                prefixIcon: Icon(Icons.search),
                suffixIcon: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Ctrl + K', style: TextStyle(fontSize: 11)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
        ] else
          const Spacer(),
        OutlinedButton.icon(
          onPressed: onLanguage,
          icon: const Icon(Icons.language, size: 18),
          label: Text(language),
        ),
        const SizedBox(width: 10),
        PopupMenuButton<String>(
          tooltip: 'Account',
          onSelected: (item) {
            if (item == 'lock') onLock();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'lock', child: Text('Lock session')),
          ],
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: SolarColors.success,
                child: Text(
                  username.isEmpty ? 'U' : username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '$role · $branch',
                      style: const TextStyle(
                        fontSize: 11,
                        color: SolarColors.slate500,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ],
          ),
        ),
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
  });
  final List<_WorkspaceModule> modules;
  final _WorkspaceCopy copy;
  final ValueChanged<_WorkspaceModule> onOpen;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => Material(
    color: SolarColors.surface,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: SolarColors.slate100)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 14, 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.solar_power,
                    color: SolarColors.crimson,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shree Krushna',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        copy.salesErp,
                        style: const TextStyle(
                          color: SolarColors.crimson,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _navTile(
                  context,
                  Icons.dashboard_outlined,
                  copy.dashboard,
                  onTap: () => onOpen(_WorkspaceModule.dashboard),
                ),
                for (final module in modules.where(
                  (item) => item != _WorkspaceModule.dashboard,
                ))
                  _navTile(
                    context,
                    module.icon,
                    copy.moduleName(module),
                    onTap: () => onOpen(module),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: SolarColors.crimson),
            title: Text(
              copy.signOut,
              style: const TextStyle(
                color: SolarColors.crimson,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: onLogout,
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );

  Widget _navTile(
    BuildContext context,
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) => ListTile(
    minLeadingWidth: 24,
    leading: Icon(icon, color: SolarColors.charcoal),
    title: Text(label),
    onTap: onTap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 22),
  );
}

final class _WorkspaceOverview extends StatelessWidget {
  const _WorkspaceOverview({
    required this.runtime,
    required this.modules,
    required this.copy,
    required this.onOpen,
  });
  final AppRuntime runtime;
  final List<_WorkspaceModule> modules;
  final _WorkspaceCopy copy;
  final ValueChanged<_WorkspaceModule> onOpen;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.all(ErpBreakpoints.isCompact(context) ? 14 : 22),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeBanner(runtime: runtime, copy: copy),
          const SizedBox(height: 16),
          Text(copy.quickAccess, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 1150
                  ? 6
                  : constraints.maxWidth >= 760
                  ? 3
                  : 2;
              final quick = modules
                  .where((item) => item != _WorkspaceModule.dashboard)
                  .take(6)
                  .toList();
              return GridView.builder(
                itemCount: quick.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: constraints.maxWidth < 600 ? 1.15 : 2.1,
                ),
                itemBuilder: (_, index) => _QuickModuleCard(
                  module: quick[index],
                  label: copy.moduleName(quick[index]),
                  onTap: () => onOpen(quick[index]),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _RoleGuidance(
            copy: copy,
            isCounter:
                modules.contains(_WorkspaceModule.sales) &&
                !modules.contains(_WorkspaceModule.purchases),
          ),
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      image: const DecorationImage(
        image: AssetImage('assets/images/solar_pump_hero.png'),
        fit: BoxFit.cover,
        alignment: Alignment.centerRight,
      ),
      border: Border.all(color: SolarColors.slate100),
    ),
    child: Wrap(
      spacing: 24,
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .88),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                copy.welcome,
                style: const TextStyle(
                  color: SolarColors.slate500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                runtime.identity!.organization.displayName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              ErpStatusBadge(
                label: runtime.identity!.branch.name,
                tone: ErpStatusTone.success,
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.solar_power, size: 46, color: SolarColors.crimson),
            const SizedBox(width: 10),
            Text(
              copy.solarPromise,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: SolarColors.charcoal,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

final class _QuickModuleCard extends StatelessWidget {
  const _QuickModuleCard({
    required this.module,
    required this.label,
    required this.onTap,
  });
  final _WorkspaceModule module;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: ErpSectionCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: module.color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(module.icon, color: module.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );
}

final class _RoleGuidance extends StatelessWidget {
  const _RoleGuidance({required this.copy, required this.isCounter});
  final _WorkspaceCopy copy;
  final bool isCounter;
  @override
  Widget build(BuildContext context) => ErpSectionCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isCounter ? Icons.point_of_sale : Icons.admin_panel_settings_outlined,
          color: SolarColors.info,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCounter ? copy.counterWorkspace : copy.adminWorkspace,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                isCounter ? copy.counterHelp : copy.adminHelp,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

enum _WorkspaceModule {
  dashboard('/', Icons.dashboard_outlined, SolarColors.info, null),
  sales(
    '/sales',
    Icons.point_of_sale_outlined,
    SolarColors.crimson,
    Capability.salesCreate,
  ),
  inventory(
    '/inventory',
    Icons.inventory_2_outlined,
    Color(0xFFB45309),
    Capability.inventoryManage,
  ),
  catalog(
    '/catalog',
    Icons.category_outlined,
    Color(0xFF2563EB),
    Capability.inventoryManage,
  ),
  parties(
    '/parties',
    Icons.people_outline,
    Color(0xFF7C3AED),
    Capability.partyManage,
  ),
  purchases(
    '/purchases',
    Icons.local_shipping_outlined,
    Color(0xFF059669),
    Capability.purchaseManage,
  ),
  finance(
    '/finance',
    Icons.account_balance_wallet_outlined,
    Color(0xFF0F766E),
    Capability.financeManage,
  ),
  accounting(
    '/accounting',
    Icons.receipt_long_outlined,
    Color(0xFF0369A1),
    Capability.costDataRead,
  ),
  reports(
    '/reports',
    Icons.bar_chart_outlined,
    SolarColors.info,
    Capability.salesRead,
  ),
  projects('/projects', Icons.wb_sunny_outlined, Color(0xFFF59E0B), null),
  service('/service', Icons.handyman_outlined, Color(0xFF0891B2), null),
  warranty(
    '/warranty',
    Icons.verified_user_outlined,
    Color(0xFF16A34A),
    Capability.salesRead,
  ),
  users(
    '/users',
    Icons.manage_accounts_outlined,
    SolarColors.crimson,
    Capability.userManage,
  );

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
  String get quickAccess => marathi ? 'जलद प्रवेश' : 'Quick access';
  String get welcome => marathi ? 'आपले स्वागत आहे' : 'Welcome to';
  String get solarPromise => marathi
      ? 'उत्तम उद्यासाठी सौर उपाय'
      : 'Solar solutions for a better tomorrow';
  String get administrator => marathi ? 'प्रशासक' : 'Administrator';
  String get counterStaff => marathi ? 'काउंटर कर्मचारी' : 'Counter staff';
  String get signOut => marathi ? 'साइन आउट' : 'Sign out';
  String get counterWorkspace =>
      marathi ? 'काउंटर कार्यक्षेत्र' : 'Counter workspace';
  String get adminWorkspace =>
      marathi ? 'प्रशासक कार्यक्षेत्र' : 'Administrator workspace';
  String get counterHelp => marathi
      ? 'इनव्हॉइस तयार करा, उत्पादनांचा साठा तपासा आणि ग्राहकांची देयके नोंदवा.'
      : 'Create invoices, check product availability, and record customer payments.';
  String get adminHelp => marathi
      ? 'साठा, खरेदी, वित्त, अहवाल आणि वापरकर्त्यांचे नियंत्रण एकाच ठिकाणी.'
      : 'Control inventory, purchases, finance, reports, and users from one place.';
  String moduleName(_WorkspaceModule module) => switch (module) {
    _WorkspaceModule.dashboard => dashboard,
    _WorkspaceModule.sales => marathi ? 'विक्री / पीओएस' : 'Sales / POS',
    _WorkspaceModule.inventory =>
      marathi ? 'साठा व सिरियल' : 'Inventory & serials',
    _WorkspaceModule.catalog => marathi ? 'उत्पादन सूची' : 'Product catalog',
    _WorkspaceModule.parties =>
      marathi ? 'ग्राहक व पुरवठादार' : 'Customers & suppliers',
    _WorkspaceModule.purchases => marathi ? 'खरेदी' : 'Purchases',
    _WorkspaceModule.finance =>
      marathi ? 'देयके व खर्च' : 'Payments & expenses',
    _WorkspaceModule.accounting =>
      marathi ? 'लेखांकन व जीएसटी' : 'Accounting & GST',
    _WorkspaceModule.reports => marathi ? 'अहवाल' : 'Reports',
    _WorkspaceModule.projects => marathi ? 'सौर प्रकल्प' : 'Solar projects',
    _WorkspaceModule.service => marathi ? 'सेवा व एएमसी' : 'Service & AMC',
    _WorkspaceModule.warranty =>
      marathi ? 'हमी व स्मरणपत्रे' : 'Warranty & reminders',
    _WorkspaceModule.users =>
      marathi ? 'वापरकर्ता व्यवस्थापन' : 'User management',
  };
}
