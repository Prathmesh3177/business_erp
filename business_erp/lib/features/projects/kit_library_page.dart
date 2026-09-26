import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../common/erp_shell.dart';

final class KitLibraryPage extends ConsumerStatefulWidget {
  const KitLibraryPage({super.key});

  @override
  ConsumerState<KitLibraryPage> createState() => _KitLibraryPageState();
}

final class _KitLibraryPageState extends ConsumerState<KitLibraryPage> {
  List<Kit> _kits = const [];
  List<Product> _products = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity!.organization.id.value;
    final results = await Future.wait([
      runtime.database.listKits(orgId, includeInactive: true),
      runtime.database.searchProducts(orgId),
    ]);
    if (!mounted) return;
    setState(() {
      _kits = results[0] as List<Kit>;
      _products = results[1] as List<Product>;
      _loading = false;
    });
  }

  Future<void> _edit([Kit? existing]) async {
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity!.organization.id.value;
    final priorLines = existing == null
        ? <KitLine>[]
        : await runtime.database.getKitLines(existing.id);
    if (!mounted) return;
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _KitEditorDialog(
        kit: existing,
        lines: priorLines,
        products: _products,
        organizationId: orgId,
        onSave: (kit, lines) => runtime.database.saveKit(kit: kit, lines: lines),
      ),
    );
    if (changed == true) _load();
  }

  Future<void> _delete(Kit kit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${kit.name}?'),
        content: const Text('This removes the saved kit and its material lines. Existing quotations are unchanged.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    final runtime = await ref.read(runtimeProvider.future);
    await runtime.database.deleteKit(runtime.identity!.organization.id.value, kit.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) => ErpFeatureScaffold(
    appBar: AppBar(
      title: const Text('Kit Library'),
      actions: [IconButton(onPressed: () => _edit(), icon: const Icon(Icons.add), tooltip: 'New kit')],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _kits.isEmpty
        ? const Center(child: Text('No saved kits. Create one and select catalog products for its materials.'))
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _kits.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final kit = _kits[index];
              return ListTile(
                leading: Icon(kit.active ? Icons.inventory_2_outlined : Icons.inventory_2_outlined, color: kit.active ? null : Colors.grey),
                title: Text(kit.name),
                subtitle: Text('${kit.category} · ${kit.capacityKw} kW · Installation ₹${kit.installationChargesPaise.inRupees.toStringAsFixed(0)}${kit.active ? '' : ' · Inactive'}'),
                onTap: () => _edit(kit),
                trailing: IconButton(onPressed: () => _delete(kit), icon: const Icon(Icons.delete_outline), tooltip: 'Delete kit'),
              );
            },
          ),
  );
}

final class _DraftLine {
  _DraftLine({this.productId, this.quantity = '1'});
  String? productId;
  String quantity;
}

final class _KitEditorDialog extends StatefulWidget {
  const _KitEditorDialog({required this.kit, required this.lines, required this.products, required this.organizationId, required this.onSave});
  final Kit? kit;
  final List<KitLine> lines;
  final List<Product> products;
  final String organizationId;
  final Future<void> Function(Kit, List<KitLine>) onSave;
  @override
  State<_KitEditorDialog> createState() => _KitEditorDialogState();
}

final class _KitEditorDialogState extends State<_KitEditorDialog> {
  late final TextEditingController _name = TextEditingController(text: widget.kit?.name ?? '');
  late final TextEditingController _category = TextEditingController(text: widget.kit?.category ?? 'residential_rooftop');
  late final TextEditingController _capacity = TextEditingController(text: widget.kit?.capacityKw.toString() ?? '');
  late final TextEditingController _installation = TextEditingController(text: widget.kit?.installationChargesPaise.inRupees.toStringAsFixed(0) ?? '0');
  late bool _active = widget.kit?.active ?? true;
  late final List<_DraftLine> _lines = widget.lines.map((line) => _DraftLine(productId: line.productId, quantity: line.quantity.inUnits.toString())).toList();
  String? _error;
  bool _saving = false;

  @override
  void dispose() { _name.dispose(); _category.dispose(); _capacity.dispose(); _installation.dispose(); super.dispose(); }

  Future<void> _save() async {
    final capacity = double.tryParse(_capacity.text.trim()) ?? 0;
    final installation = double.tryParse(_installation.text.trim());
    if (_name.text.trim().isEmpty || installation == null || capacity < 0 || _lines.isEmpty || _lines.any((line) => line.productId == null || (double.tryParse(line.quantity) ?? 0) <= 0)) {
      setState(() => _error = 'Enter kit details and select a catalog product with a positive quantity for every line.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    final now = DateTime.now().toUtc();
    final id = widget.kit?.id ?? 'kit_${now.microsecondsSinceEpoch}';
    final kit = Kit(id: id, organizationId: widget.organizationId, name: _name.text.trim(), category: _category.text.trim(), capacityKw: capacity, installationChargesPaise: Money.fromRupees(installation), active: _active, createdAtUtc: widget.kit?.createdAtUtc ?? now, updatedAtUtc: now);
    final lines = [for (var i = 0; i < _lines.length; i++) KitLine(id: widget.lines.length > i ? widget.lines[i].id : '${id}_line_$i', kitId: id, productId: _lines[i].productId!, quantity: Quantity.fromUnits(double.parse(_lines[i].quantity)), sortOrder: i)];
    await widget.onSave(kit, lines);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.kit == null ? 'New kit' : 'Edit kit'),
    content: SizedBox(width: 640, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Kit name')),
      TextField(controller: _category, decoration: const InputDecoration(labelText: 'Category')),
      Row(children: [Expanded(child: TextField(controller: _capacity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity (kW)'))), const SizedBox(width: 12), Expanded(child: TextField(controller: _installation, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Installation charges (₹)')))]),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Active'), value: _active, onChanged: (value) => setState(() => _active = value)),
      const Divider(),
      ..._lines.asMap().entries.map((entry) { final index = entry.key; final line = entry.value; return Row(children: [Expanded(child: DropdownButtonFormField<String>(initialValue: line.productId, decoration: const InputDecoration(labelText: 'Catalog product'), items: widget.products.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.sku} — ${p.name}', overflow: TextOverflow.ellipsis))).toList(), onChanged: (value) => setState(() => line.productId = value))), const SizedBox(width: 12), SizedBox(width: 100, child: TextFormField(initialValue: line.quantity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Qty'), onChanged: (value) => line.quantity = value)), IconButton(onPressed: () => setState(() => _lines.removeAt(index)), icon: const Icon(Icons.remove_circle_outline))]); }),
      Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: widget.products.isEmpty ? null : () => setState(() => _lines.add(_DraftLine())), icon: const Icon(Icons.add), label: const Text('Add material line'))),
      if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
    ]))),
    actions: [TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : 'Save kit'))],
  );
}
