import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:erp_local_data/erp_local_data.dart';
import 'package:erp_platform/erp_platform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final runtimeProvider = FutureProvider<AppRuntime>((ref) async {
  const configuration = AppConfiguration.production;
  final locations = AppFileLocations(configuration);
  final databaseFile = await locations.databaseFile();
  List<int> key = const [];
  try {
    key = await DatabaseKeyProvisioner(
      vault: const PlatformDatabaseKeyVault(),
      random: PlatformSecureRandom(),
    ).loadOrCreate(databaseExists: databaseFile.existsSync());
  } catch (_) {
    key = const [];
  }
  final database = FoundationDatabase.open(file: databaseFile, key: key);
  ref.onDispose(database.close);
  final identity = await database.loadIdentity();
  final clock = const SystemClock();
  final ids = const UuidIdGenerator();
  const passwordHasher = PlatformPasswordHasher();

  return AppRuntime(
    database: database,
    locations: locations,
    identity: identity,
    clock: clock,
    ids: ids,
    passwordHasher: passwordHasher,
    initialize: InitializeFoundation(store: database, clock: clock, ids: ids),
    authenticateUser: AuthenticateUser(
      identityStore: database,
      passwordHasher: passwordHasher,
      auditStore: database,
      clock: clock,
      idGenerator: ids,
    ),
    createFirstAdmin: CreateFirstAdmin(
      identityStore: database,
      passwordHasher: passwordHasher,
      auditStore: database,
      clock: clock,
      idGenerator: ids,
    ),
    createUser: CreateUserUseCase(
      identityStore: database,
      passwordHasher: passwordHasher,
      auditStore: database,
      clock: clock,
      idGenerator: ids,
    ),
    toggleUserStatus: ToggleUserStatusUseCase(
      identityStore: database,
      auditStore: database,
      clock: clock,
      idGenerator: ids,
    ),
    resetAdminPassword: ResetAdminPasswordWithRecoveryKey(
      identityStore: database,
      passwordHasher: passwordHasher,
      auditStore: database,
      clock: clock,
      idGenerator: ids,
    ),
  );
});

final class AppRuntime {
  const AppRuntime({
    required this.database,
    required this.locations,
    required this.identity,
    required this.clock,
    required this.ids,
    required this.passwordHasher,
    required this.initialize,
    required this.authenticateUser,
    required this.createFirstAdmin,
    required this.createUser,
    required this.toggleUserStatus,
    required this.resetAdminPassword,
  });

  final FoundationDatabase database;
  final AppFileLocations locations;
  final FoundationIdentity? identity;
  final Clock clock;
  final IdGenerator ids;
  final PasswordHasher passwordHasher;
  final InitializeFoundation initialize;
  final AuthenticateUser authenticateUser;
  final CreateFirstAdmin createFirstAdmin;
  final CreateUserUseCase createUser;
  final ToggleUserStatusUseCase toggleUserStatus;
  final ResetAdminPasswordWithRecoveryKey resetAdminPassword;
}
