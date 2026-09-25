import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';
import '../../l10n/strings.dart';
import '../common/erp_shell.dart';

final class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

final class _UserManagementPageState extends ConsumerState<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return ErpFeatureScaffold(
      appBar: AppBar(
        title: Text(strings.get('userManagement')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.people),
              text: strings.get('userManagement'),
            ),
            Tab(
              icon: const Icon(Icons.receipt_long),
              text: strings.get('auditLog'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_UserListView(), _AuditLogView()],
      ),
    );
  }
}

final class _UserListView extends ConsumerWidget {
  const _UserListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final runtime = ref.watch(runtimeProvider).value;
    if (runtime == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<User>>(
      future: runtime.database.getAllUsers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data!;

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddUserDialog(context, ref, runtime),
            icon: const Icon(Icons.person_add),
            label: Text(strings.get('addUser')),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final u = users[index];
              return ListTile(
                leading: CircleAvatar(child: Text(u.username[0].toUpperCase())),
                title: Text('${u.fullName} (@${u.username})'),
                subtitle: Text('Role: ${u.roleId}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(
                        u.isActive
                            ? strings.get('active')
                            : strings.get('disabled'),
                      ),
                      backgroundColor: u.isActive
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                    ),
                    IconButton(
                      icon: Icon(
                        u.isActive ? Icons.block : Icons.check_circle_outline,
                      ),
                      onPressed: () => _toggleStatus(context, ref, runtime, u),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _toggleStatus(
    BuildContext context,
    WidgetRef ref,
    AppRuntime runtime,
    User user,
  ) async {
    final session = ref.read(authProvider);
    if (session == null) return;

    try {
      final cmdCtx = CommandContext(
        session: session,
        timestampUtc: DateTime.now(),
      );
      await runtime.toggleUserStatus.call(
        context: cmdCtx,
        targetUserId: user.id,
        newIsActiveStatus: !user.isActive,
      );
      ref.invalidate(runtimeProvider);
    } on ErpFailure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.safeMessage)));
      }
    }
  }

  void _showAddUserDialog(
    BuildContext context,
    WidgetRef ref,
    AppRuntime runtime,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => _AddUserDialog(runtime: runtime),
    );
  }
}

final class _AddUserDialog extends ConsumerStatefulWidget {
  const _AddUserDialog({required this.runtime});
  final AppRuntime runtime;

  @override
  ConsumerState<_AddUserDialog> createState() => _AddUserDialogState();
}

final class _AddUserDialogState extends ConsumerState<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _fullName = TextEditingController();
  final _password = TextEditingController();
  String _selectedRoleId = Role.counterRoleId;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _fullName.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return AlertDialog(
      title: Text(strings.get('addUser')),
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
                controller: _fullName,
                decoration: InputDecoration(
                  labelText: strings.get('adminFullName'),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? strings.get('adminFullName')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(labelText: strings.get('password')),
                validator: (v) => v == null || v.trim().isEmpty
                    ? strings.get('password')
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedRoleId,
                decoration: InputDecoration(labelText: strings.get('role')),
                items: [
                  DropdownMenuItem(
                    value: Role.adminRoleId,
                    child: Text(Role.admin.name),
                  ),
                  DropdownMenuItem(
                    value: Role.counterRoleId,
                    child: Text(Role.counter.name),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRoleId = val);
                },
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
          child: Text(strings.get('addUser')),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final session = ref.read(authProvider);
    if (session == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final cmdCtx = CommandContext(
        session: session,
        timestampUtc: DateTime.now(),
      );
      await widget.runtime.createUser.call(
        context: cmdCtx,
        username: _username.text,
        fullName: _fullName.text,
        password: _password.text,
        roleId: _selectedRoleId,
      );

      ref.invalidate(runtimeProvider);
      if (mounted) Navigator.of(context).pop();
    } on ErpFailure catch (failure) {
      setState(() => _error = failure.safeMessage);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

final class _AuditLogView extends ConsumerWidget {
  const _AuditLogView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(runtimeProvider).value;
    if (runtime == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<AuditEvent>>(
      future: runtime.database.getAuditEvents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final events = snapshot.data!;

        if (events.isEmpty) {
          return const Center(child: Text('No audit events logged.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, index) {
            final ev = events[index];
            return ListTile(
              leading: const Icon(Icons.security),
              title: Text('${ev.action} by @${ev.actorUsername}'),
              subtitle: Text(
                'Entity: ${ev.entityType} (${ev.entityId})\nDetails: ${ev.detailsJson}',
              ),
              trailing: Text(
                '${ev.createdAtUtc.hour}:${ev.createdAtUtc.minute.toString().padLeft(2, '0')}',
              ),
            );
          },
        );
      },
    );
  }
}
