import 'dart:io';

void main() {
  var hasError = false;

  print('1. Checking package boundaries...');
  final domainFiles = Directory('packages/erp_domain/lib')
      .listSync(recursive: true)
      .whereType<File>();
  for (final file in domainFiles) {
    if (!file.path.endsWith('.dart')) continue;
    final content = file.readAsStringSync();
    if (RegExp(
      r'package:(flutter|drift|sqlite3|erp_application|erp_local_data|erp_platform)/',
    ).hasMatch(content)) {
      print('  ERROR: Domain boundary violation in ${file.path}');
      hasError = true;
    }
  }

  final appFiles = Directory('packages/erp_application/lib')
      .listSync(recursive: true)
      .whereType<File>();
  for (final file in appFiles) {
    if (!file.path.endsWith('.dart')) continue;
    final content = file.readAsStringSync();
    if (RegExp(r'package:(flutter|drift|sqlite3|erp_local_data|erp_platform)/')
        .hasMatch(content)) {
      print('  ERROR: Application boundary violation in ${file.path}');
      hasError = true;
    }
  }

  final presentationFiles = Directory('business_erp/lib')
      .listSync(recursive: true)
      .whereType<File>();
  for (final file in presentationFiles) {
    if (!file.path.endsWith('.dart')) continue;
    final content = file.readAsStringSync();
    if (RegExp(
      r'foundation_database\.g\.dart|OrganizationsCompanion|BranchesCompanion|FinancialPeriodsCompanion',
    ).hasMatch(content)) {
      print('  ERROR: Presentation boundary violation in ${file.path}');
      hasError = true;
    }
  }

  if (!hasError) {
    print('   Package boundary check passed.');
  }

  print('2. Checking documentation links and code fences...');
  final docFiles = Directory('docs')
      .listSync(recursive: true)
      .whereType<File>();
  for (final file in docFiles) {
    if (!file.path.endsWith('.md')) continue;
    final content = file.readAsStringSync();
    final fences = RegExp(r'^```', multiLine: true).allMatches(content).length;
    if (fences % 2 != 0) {
      print('  ERROR: Unpaired code fence in ${file.path}');
      hasError = true;
    }

    final linkRegex = RegExp(r'\[[^\]]+\]\(([^)]+)\)');
    for (final match in linkRegex.allMatches(content)) {
      final target = match.group(1)!;
      if (target.startsWith('http://') ||
          target.startsWith('https://') ||
          target.startsWith('mailto:') ||
          target.startsWith('#')) {
        continue;
      }
      final pathOnly = target.split('#').first;
      if (pathOnly.isEmpty) continue;
      final targetFile = File('${file.parent.path}/$pathOnly');
      final targetDir = Directory('${file.parent.path}/$pathOnly');
      if (!targetFile.existsSync() && !targetDir.existsSync()) {
        print('  ERROR: Broken link in ${file.path}: $target');
        hasError = true;
      }
    }
  }

  if (!hasError) {
    print('   Documentation check passed.');
  } else {
    exit(1);
  }
}
