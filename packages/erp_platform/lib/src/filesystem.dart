import 'dart:io';

import 'package:erp_application/erp_application.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final class AppFileLocations {
  const AppFileLocations(this.configuration);

  final AppConfiguration configuration;

  Future<File> databaseFile() async {
    final root = await getApplicationSupportDirectory();
    return File(p.join(root.path, configuration.databaseFileName));
  }

  Future<Directory> snapshotDirectory() async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory(
      p.join(root.path, configuration.snapshotDirectoryName),
    );
    await directory.create(recursive: true);
    return directory;
  }
}
