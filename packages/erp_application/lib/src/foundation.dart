import 'package:erp_domain/erp_domain.dart';
import 'package:uuid/uuid.dart';

abstract interface class FoundationTransaction {
  Future<void> insertIdentity(FoundationIdentity identity);
}

abstract interface class FoundationStore {
  Future<FoundationIdentity?> loadIdentity();

  Future<T> inTransaction<T>(
    Future<T> Function(FoundationTransaction transaction) action,
  );

  Future<void> createVerifiedSnapshot(String targetPath);

  Future<void> close();
}

abstract interface class DatabaseKeyVault {
  Future<List<int>?> readDatabaseKey();

  Future<void> writeDatabaseKey(List<int> key);
}

abstract interface class SecureRandomBytes {
  List<int> nextBytes(int length);
}

final class UuidIdGenerator implements IdGenerator {
  const UuidIdGenerator();

  @override
  String next() => const Uuid().v4();
}

final class InitializeFoundation {
  const InitializeFoundation({
    required this.store,
    required this.clock,
    required this.ids,
  });

  final FoundationStore store;
  final Clock clock;
  final IdGenerator ids;

  Future<FoundationIdentity> call(FirstRunSetup setup) async {
    return store.inTransaction((transaction) async {
      if (await store.loadIdentity() != null) {
        throw const ConflictFailure(
          'foundation.already_initialized',
          'This installation has already been initialized.',
        );
      }
      final now = clock.nowUtc();
      final organizationId = OrganizationId(ids.next());
      final branchId = BranchId(ids.next());
      final identity = FoundationIdentity(
        organization: Organization(
          id: organizationId,
          legalName: setup.legalName,
          displayName: setup.displayName,
          createdAtUtc: now,
        ),
        branch: Branch(
          id: branchId,
          organizationId: organizationId,
          name: setup.branchName,
          timeZone: setup.timeZone,
          locale: setup.locale,
          createdAtUtc: now,
        ),
        financialPeriod: FinancialPeriod(
          id: FinancialPeriodId(ids.next()),
          organizationId: organizationId,
          branchId: branchId,
          startsOn: setup.financialYearStartsOn,
          endsOn: setup.financialYearEndsOn,
          createdAtUtc: now,
        ),
      );
      await transaction.insertIdentity(identity);
      return identity;
    });
  }
}
