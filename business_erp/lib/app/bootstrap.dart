import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:erp_local_data/erp_local_data.dart';
import 'package:erp_platform/erp_platform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final runtimeProvider = FutureProvider<AppRuntime>((ref) async {
  const configuration = AppConfiguration.production;
  final locations = AppFileLocations(configuration);
  final databaseFile = await locations.databaseFile();
  final key = await DatabaseKeyProvisioner(
    vault: const PlatformDatabaseKeyVault(),
    random: PlatformSecureRandom(),
  ).loadOrCreate(databaseExists: databaseFile.existsSync());
  final database = FoundationDatabase.open(file: databaseFile, key: key);
  ref.onDispose(database.close);
  final identity = await database.loadIdentity();
  return AppRuntime(
    database: database,
    locations: locations,
    identity: identity,
    initialize: InitializeFoundation(
      store: database,
      clock: const SystemClock(),
      ids: const UuidIdGenerator(),
    ),
  );
});

final class AppRuntime {
  const AppRuntime({
    required this.database,
    required this.locations,
    required this.identity,
    required this.initialize,
  });

  final FoundationDatabase database;
  final AppFileLocations locations;
  final FoundationIdentity? identity;
  final InitializeFoundation initialize;
}
