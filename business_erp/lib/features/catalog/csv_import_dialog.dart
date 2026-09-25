import 'package:flutter/material.dart';

final class CsvImportWizardDialog extends StatefulWidget {
  const CsvImportWizardDialog({super.key, required this.onImportCompleted});

  final void Function(int importedCount) onImportCompleted;

  @override
  State<CsvImportWizardDialog> createState() => _CsvImportWizardDialogState();
}

final class _CsvImportWizardDialogState extends State<CsvImportWizardDialog> {
  final TextEditingController _csvController = TextEditingController(
    text: '''sku,name,category_id,selling_price,cost_price,hsn
SKS-P330,330W Poly Panel,solarPanel,9500,8100,85414011
SKS-P450,450W Mono Panel,solarPanel,12500,10400,85414011
SKS-INV3K,3kW Solar Inverter,solarInverter,28000,24000,85044090''',
  );

  int _step = 1;
  int _validRows = 0;
  int _errorRows = 0;
  List<String> _previewLines = [];

  void _analyzeCsv() {
    final lines = _csvController.text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.length <= 1) {
      setState(() {
        _validRows = 0;
        _errorRows = 1;
        _previewLines = ['Error: Missing header or empty content'];
      });
      return;
    }

    int valid = 0;
    int error = 0;
    for (int i = 1; i < lines.length; i++) {
      final cols = lines[i].split(',');
      if (cols.length >= 2 && cols[0].isNotEmpty && cols[1].isNotEmpty) {
        valid++;
      } else {
        error++;
      }
    }

    setState(() {
      _step = 2;
      _validRows = valid;
      _errorRows = error;
      _previewLines = lines.take(4).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('CSV Master Import Wizard'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_step == 1) ...[
                const Text('Paste or edit CSV product master content:'),
                const SizedBox(height: 8),
                TextField(
                  controller: _csvController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'sku,name,category_id,selling_price,cost_price,hsn...',
                  ),
                ),
              ] else ...[
                const Text('Validation Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      avatar: const Icon(Icons.check_circle, color: Colors.green),
                      label: Text('$_validRows Valid Rows'),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      avatar: const Icon(Icons.warning, color: Colors.amber),
                      label: Text('$_errorRows Errors/Skipped'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Preview (First 3 Rows):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _previewLines.map((l) => Text(l, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (_step == 2)
          TextButton(onPressed: () => setState(() => _step = 1), child: const Text('Back')),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF990000)),
          onPressed: () {
            if (_step == 1) {
              _analyzeCsv();
            } else {
              widget.onImportCompleted(_validRows);
              Navigator.pop(context);
            }
          },
          child: Text(_step == 1 ? 'Analyze & Preview' : 'Import Masters'),
        ),
      ],
    );
  }
}
