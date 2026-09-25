import 'package:erp_application/erp_application.dart';
import 'package:test/test.dart';

void main() {
  test('structured logger redacts sensitive fields', () {
    final lines = <String>[];
    JsonLineLogger(lines.add).event(
      LogLevel.error,
      'startup.failed',
      context: {'databaseKey': 'never-log', 'attempt': 1},
    );
    expect(lines.single, contains('[REDACTED]'));
    expect(lines.single, isNot(contains('never-log')));
    expect(lines.single, contains('attempt'));
  });
}
