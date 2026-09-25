import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';
import '../../app/locale_controller.dart';
import '../../app/theme.dart';
import '../../l10n/strings.dart';

final class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

final class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController();
  bool _submitting = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/solar_pump_hero.png'),
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFF9FCFF),
                          Color(0xE6F9FCFF),
                          Color(0x22FFFFFF),
                        ],
                        stops: [0, .48, 1],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (wide)
                      Expanded(
                        flex: 5,
                        child: _LoginBrandPanel(strings: strings),
                      ),
                    Expanded(
                      flex: wide ? 6 : 1,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const CircleAvatar(
                                        radius: 38,
                                        backgroundColor: Color(0xFFFEE2E2),
                                        child: Icon(
                                          Icons.solar_power,
                                          size: 42,
                                          color: SolarColors.crimson,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      Text(
                                        strings.get('appTitle'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        strings.get('branch'),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: SolarColors.success,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      TextFormField(
                                        controller: _usernameController,
                                        decoration: InputDecoration(
                                          labelText: strings.get('username'),
                                          prefixIcon: const Icon(
                                            Icons.person_outline,
                                          ),
                                        ),
                                        validator: (v) =>
                                            v == null || v.trim().isEmpty
                                            ? strings.get('username')
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          labelText: strings.get('password'),
                                          prefixIcon: const Icon(
                                            Icons.lock_outline,
                                          ),
                                          suffixIcon: IconButton(
                                            tooltip: _obscurePassword
                                                ? 'Show password'
                                                : 'Hide password',
                                            onPressed: () => setState(
                                              () => _obscurePassword =
                                                  !_obscurePassword,
                                            ),
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                            ),
                                          ),
                                        ),
                                        validator: (v) =>
                                            v == null || v.trim().isEmpty
                                            ? strings.get('password')
                                            : null,
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _rememberMe,
                                            onChanged: (value) => setState(
                                              () =>
                                                  _rememberMe = value ?? false,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              strings.get('rememberMe'),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: _showResetDialog,
                                            child: Text(
                                              strings.get('forgotPassword'),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_errorMessage != null) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                      const SizedBox(height: 22),
                                      FilledButton.icon(
                                        onPressed: _submitting ? null : _submit,
                                        icon: const Icon(Icons.login),
                                        label: Text(strings.get('login')),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .login(
            username: _usernameController.text,
            password: _passwordController.text,
          );
    } on ErpFailure catch (failure) {
      setState(() => _errorMessage = failure.safeMessage);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showResetDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => const ResetPasswordDialog(),
    );
  }
}

class _LoginBrandPanel extends StatelessWidget {
  const _LoginBrandPanel({required this.strings});
  final AppStrings strings;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(56),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.solar_power, size: 72, color: SolarColors.crimson),
        const SizedBox(height: 18),
        Text(
          strings.get('appTitle'),
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          strings.get('completeBusinessSolution'),
          style: const TextStyle(fontSize: 18, color: SolarColors.slate500),
        ),
        const SizedBox(height: 34),
        _LoginBenefit(
          icon: Icons.inventory_2_outlined,
          title: strings.get('inventory'),
          detail: strings.get('inventoryBenefit'),
        ),
        _LoginBenefit(
          icon: Icons.point_of_sale_outlined,
          title: strings.get('sales'),
          detail: strings.get('billingBenefit'),
        ),
        _LoginBenefit(
          icon: Icons.people_outline,
          title: strings.get('parties'),
          detail: strings.get('customerBenefit'),
        ),
        _LoginBenefit(
          icon: Icons.bar_chart_outlined,
          title: strings.get('reports'),
          detail: strings.get('reportsBenefit'),
        ),
      ],
    ),
  );
}

class _LoginBenefit extends StatelessWidget {
  const _LoginBenefit({
    required this.icon,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String title;
  final String detail;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: SolarColors.info),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(detail, style: const TextStyle(color: SolarColors.slate500)),
          ],
        ),
      ],
    ),
  );
}

final class LockScreenModal extends ConsumerStatefulWidget {
  const LockScreenModal({super.key});

  @override
  ConsumerState<LockScreenModal> createState() => _LockScreenModalState();
}

final class _LockScreenModalState extends ConsumerState<LockScreenModal> {
  final _passwordController = TextEditingController();
  bool _unlocking = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final session = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface
          .withValues(alpha: 0.95),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    strings.get('unlockTitle'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('User: ${session?.username ?? ''}'),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: strings.get('password'),
                      prefixIcon: const Icon(Icons.key),
                    ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () =>
                            ref.read(authProvider.notifier).logout(),
                        child: Text(strings.get('logout')),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _unlocking ? null : _unlock,
                        child: Text(strings.get('unlock')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _unlock() async {
    setState(() {
      _unlocking = true;
      _error = null;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .unlockSession(_passwordController.text);
    } on ErpFailure catch (failure) {
      setState(() => _error = failure.safeMessage);
    } finally {
      if (mounted) setState(() => _unlocking = false);
    }
  }
}

final class ResetPasswordDialog extends ConsumerStatefulWidget {
  const ResetPasswordDialog({super.key});

  @override
  ConsumerState<ResetPasswordDialog> createState() =>
      _ResetPasswordDialogState();
}

final class _ResetPasswordDialogState
    extends ConsumerState<ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _recoveryKey = TextEditingController();
  final _newPassword = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _recoveryKey.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return AlertDialog(
      title: Text(strings.get('resetPasswordTitle')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _username,
                decoration: InputDecoration(labelText: strings.get('username')),
                validator: (v) => v == null || v.trim().isEmpty
                    ? strings.get('username')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _recoveryKey,
                decoration: InputDecoration(
                  labelText: strings.get('recoveryKeyLabel'),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? strings.get('recoveryKeyLabel')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newPassword,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: strings.get('newPassword'),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? strings.get('newPassword')
                    : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(strings.get('resetPassword')),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final runtime = ref.read(runtimeProvider).value;
      if (runtime == null) return;

      await runtime.resetAdminPassword.call(
        username: _username.text,
        recoveryKey: _recoveryKey.text,
        newPassword: _newPassword.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully. Please sign in.'),
          ),
        );
      }
    } on ErpFailure catch (failure) {
      setState(() => _error = failure.safeMessage);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
