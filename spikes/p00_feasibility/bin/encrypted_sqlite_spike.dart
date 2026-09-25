import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

void main() {
  final directory = Directory.systemTemp.createTempSync(
    'solar_erp_p00_sqlite_',
  );
  final path = '${directory.path}${Platform.pathSeparator}encrypted.db';
  const key = 'p00-disposable-key-not-for-production';

  try {
    final created = sqlite3.open(path);
    final cipherRows = created.select('PRAGMA cipher;');
    if (cipherRows.isEmpty) {
      throw StateError(
        'sqlite3mc is not active; PRAGMA cipher returned no rows',
      );
    }
    created.execute("PRAGMA key = '$key';");
    created.execute('PRAGMA temp_store = MEMORY;');
    created.execute('CREATE TABLE proof (value TEXT NOT NULL);');
    created.execute('INSERT INTO proof VALUES (?)', ['encrypted payload']);
    created.close();

    var unkeyedRejected = false;
    final unkeyed = sqlite3.open(path);
    try {
      unkeyed.select('SELECT value FROM proof;');
    } on SqliteException {
      unkeyedRejected = true;
    } finally {
      unkeyed.close();
    }

    var wrongKeyRejected = false;
    final wrongKey = sqlite3.open(path);
    try {
      wrongKey.execute("PRAGMA key = 'wrong-key';");
      wrongKey.select('SELECT value FROM proof;');
    } on SqliteException {
      wrongKeyRejected = true;
    } finally {
      wrongKey.close();
    }

    final reopened = sqlite3.open(path);
    reopened.execute("PRAGMA key = '$key';");
    final value = reopened.select('SELECT value FROM proof;').single['value'];
    reopened.close();

    if (!unkeyedRejected || !wrongKeyRejected || value != 'encrypted payload') {
      throw StateError('encrypted database acceptance checks failed');
    }

    stdout.writeln('PASS cipher=${cipherRows.first.values.first}');
    stdout.writeln('PASS unkeyed_read_rejected=$unkeyedRejected');
    stdout.writeln('PASS wrong_key_rejected=$wrongKeyRejected');
    stdout.writeln('PASS correct_key_round_trip=true');
  } finally {
    directory.deleteSync(recursive: true);
  }
}
