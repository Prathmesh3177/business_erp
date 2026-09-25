import 'dart:convert';

enum LogLevel { info, warning, error }

abstract interface class StructuredLogger {
  void event(
    LogLevel level,
    String code, {
    Map<String, Object?> context = const {},
  });
}

final class JsonLineLogger implements StructuredLogger {
  JsonLineLogger(this.sink);

  final void Function(String line) sink;

  static const _sensitiveKeys = {
    'password',
    'token',
    'key',
    'secret',
    'gstin',
    'phone',
    'email',
  };

  @override
  void event(
    LogLevel level,
    String code, {
    Map<String, Object?> context = const {},
  }) {
    final redacted = <String, Object?>{};
    for (final entry in context.entries) {
      final key = entry.key.toLowerCase();
      redacted[entry.key] = _sensitiveKeys.any(key.contains)
          ? '[REDACTED]'
          : entry.value;
    }
    sink(jsonEncode({'level': level.name, 'code': code, 'context': redacted}));
  }
}
