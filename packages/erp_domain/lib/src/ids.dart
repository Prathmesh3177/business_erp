abstract interface class EntityId {
  String get value;
}

final class OrganizationId implements EntityId {
  const OrganizationId(this.value);
  @override
  final String value;
}

final class BranchId implements EntityId {
  const BranchId(this.value);
  @override
  final String value;
}

final class FinancialPeriodId implements EntityId {
  const FinancialPeriodId(this.value);
  @override
  final String value;
}

abstract interface class IdGenerator {
  String next();
}
