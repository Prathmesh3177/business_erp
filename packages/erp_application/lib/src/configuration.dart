final class AppConfiguration {
  const AppConfiguration({
    required this.databaseFileName,
    required this.snapshotDirectoryName,
  });

  final String databaseFileName;
  final String snapshotDirectoryName;

  static const production = AppConfiguration(
    databaseFileName: 'solar-shop.erpdb',
    snapshotDirectoryName: 'recovery',
  );
}
