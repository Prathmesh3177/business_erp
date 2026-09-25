import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../app/locale_controller.dart';
import '../../l10n/strings.dart';

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
  final _legalName = TextEditingController();
  final _displayName = TextEditingController();
  final _branchName = TextEditingController(text: 'Main Branch');
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _legalName.dispose();
    _displayName.dispose();
    _branchName.dispose();
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

  Widget _field(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
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
      await widget.runtime.initialize.call(
        FirstRunSetup.validate(
          legalName: _legalName.text,
          displayName: _displayName.text,
          branchName: _branchName.text,
          timeZone: 'Asia/Kolkata',
          locale: ref.read(localeProvider).languageCode,
          financialYearStartsOn: DateTime.utc(year, 4),
          financialYearEndsOn: DateTime.utc(year + 1, 3, 31),
        ),
      );
      ref.invalidate(runtimeProvider);
    } on ErpFailure catch (failure) {
      setState(() => _error = failure.safeMessage);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

final class _ReadyView extends StatelessWidget {
  const _ReadyView({required this.runtime});
  final AppRuntime runtime;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final identity = runtime.identity!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.solar_power, size: 64),
            Text(
              identity.organization.displayName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(identity.branch.name),
            const SizedBox(height: 16),
            Text(strings.get('singleAuthority'), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () => _snapshot(context),
              icon: const Icon(Icons.backup_outlined),
              label: Text(strings.get('snapshot')),
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
