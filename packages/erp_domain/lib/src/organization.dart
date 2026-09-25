import 'errors.dart';
import 'ids.dart';

final class Organization {
  const Organization({
    required this.id,
    required this.legalName,
    required this.displayName,
    required this.createdAtUtc,
  });

  final OrganizationId id;
  final String legalName;
  final String displayName;
  final DateTime createdAtUtc;
}

final class Branch {
  const Branch({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.timeZone,
    required this.locale,
    required this.createdAtUtc,
  });

  final BranchId id;
  final OrganizationId organizationId;
  final String name;
  final String timeZone;
  final String locale;
  final DateTime createdAtUtc;
}

final class FinancialPeriod {
  const FinancialPeriod({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.startsOn,
    required this.endsOn,
    required this.createdAtUtc,
  });

  final FinancialPeriodId id;
  final OrganizationId organizationId;
  final BranchId branchId;
  final DateTime startsOn;
  final DateTime endsOn;
  final DateTime createdAtUtc;
}

final class FoundationIdentity {
  const FoundationIdentity({
    required this.organization,
    required this.branch,
    required this.financialPeriod,
  });

  final Organization organization;
  final Branch branch;
  final FinancialPeriod financialPeriod;
}

final class FirstRunSetup {
  const FirstRunSetup._({
    required this.legalName,
    required this.displayName,
    required this.branchName,
    required this.timeZone,
    required this.locale,
    required this.financialYearStartsOn,
    required this.financialYearEndsOn,
  });

  final String legalName;
  final String displayName;
  final String branchName;
  final String timeZone;
  final String locale;
  final DateTime financialYearStartsOn;
  final DateTime financialYearEndsOn;

  static FirstRunSetup validate({
    required String legalName,
    required String displayName,
    required String branchName,
    required String timeZone,
    required String locale,
    required DateTime financialYearStartsOn,
    required DateTime financialYearEndsOn,
  }) {
    final normalizedLegalName = legalName.trim();
    final normalizedDisplayName = displayName.trim();
    final normalizedBranchName = branchName.trim();
    if (normalizedLegalName.isEmpty ||
        normalizedDisplayName.isEmpty ||
        normalizedBranchName.isEmpty) {
      throw const ValidationFailure(
        'foundation.required_name',
        'Organization and branch names are required.',
      );
    }
    if (timeZone != 'Asia/Kolkata') {
      throw const ValidationFailure(
        'foundation.unsupported_timezone',
        'Only Asia/Kolkata is supported during foundation setup.',
      );
    }
    if (locale != 'en' && locale != 'mr') {
      throw const ValidationFailure(
        'foundation.unsupported_locale',
        'Choose a supported language.',
      );
    }
    final start = DateTime.utc(
      financialYearStartsOn.year,
      financialYearStartsOn.month,
      financialYearStartsOn.day,
    );
    final end = DateTime.utc(
      financialYearEndsOn.year,
      financialYearEndsOn.month,
      financialYearEndsOn.day,
    );
    if (!end.isAfter(start)) {
      throw const ValidationFailure(
        'foundation.invalid_financial_year',
        'The financial year end must be after its start.',
      );
    }
    return FirstRunSetup._(
      legalName: normalizedLegalName,
      displayName: normalizedDisplayName,
      branchName: normalizedBranchName,
      timeZone: timeZone,
      locale: locale,
      financialYearStartsOn: start,
      financialYearEndsOn: end,
    );
  }
}
