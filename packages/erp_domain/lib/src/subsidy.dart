import 'money.dart';

enum SubsidyCategory { residential, agriculture, commercial }

final class SubsidySlab {
  const SubsidySlab({
    required this.fromKw,
    required this.toKw,
    this.subsidyPerKwPaise = 0,
    this.percentageOfCost = 0,
    this.isPercentageBased = false,
  });

  final double fromKw;
  final double toKw;
  final int subsidyPerKwPaise;
  final double percentageOfCost;
  final bool isPercentageBased;
}

final class SubsidyScheme {
  const SubsidyScheme({
    required this.id,
    required this.name,
    required this.category,
    required this.state,
    required this.slabs,
    required this.effectiveFrom,
    this.isActive = true,
    this.effectiveUntil,
  });

  final String id;
  final String name;
  final SubsidyCategory category;
  final String state;
  final List<SubsidySlab> slabs;
  final bool isActive;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;

  static final pmSuryaGhar = SubsidyScheme(
    id: 'pm_surya_ghar_maharashtra',
    name: 'PM Surya Ghar',
    category: SubsidyCategory.residential,
    state: 'Maharashtra',
    effectiveFrom: DateTime(2024, 1, 1),
    slabs: const [
      SubsidySlab(fromKw: 0, toKw: 2, subsidyPerKwPaise: 3000000),
      SubsidySlab(fromKw: 2, toKw: 3, subsidyPerKwPaise: 1800000),
    ],
  );
  static final pmKusumSmallFarmer = SubsidyScheme(
    id: 'pm_kusum_b_small_farmer',
    name: 'PM-KUSUM B (small/marginal farmer)',
    category: SubsidyCategory.agriculture,
    state: 'Maharashtra',
    effectiveFrom: DateTime(2024, 1, 1),
    slabs: const [
      SubsidySlab(
        fromKw: 0,
        toKw: double.infinity,
        percentageOfCost: .60,
        isPercentageBased: true,
      ),
    ],
  );
  static final pmKusumOtherFarmer = SubsidyScheme(
    id: 'pm_kusum_b_other_farmer',
    name: 'PM-KUSUM B (other farmer)',
    category: SubsidyCategory.agriculture,
    state: 'Maharashtra',
    effectiveFrom: DateTime(2024, 1, 1),
    slabs: const [
      SubsidySlab(
        fromKw: 0,
        toKw: double.infinity,
        percentageOfCost: .50,
        isPercentageBased: true,
      ),
    ],
  );
}

final class SubsidyCalculation {
  const SubsidyCalculation({
    required this.scheme,
    required this.capacityKw,
    required this.projectCost,
    required this.subsidy,
    required this.customerPayable,
  });
  final SubsidyScheme scheme;
  final double capacityKw;
  final Money projectCost;
  final Money subsidy;
  final Money customerPayable;
}

SubsidyCalculation calculateSubsidy({
  required SubsidyScheme scheme,
  required double capacityKw,
  required Money projectCost,
}) {
  var paise = 0;
  for (final slab in scheme.slabs) {
    final coveredKw = (capacityKw.clamp(slab.fromKw, slab.toKw) - slab.fromKw)
        .clamp(0, double.infinity);
    paise += slab.isPercentageBased
        ? projectCost.times(slab.percentageOfCost).paise
        : (coveredKw * slab.subsidyPerKwPaise).round();
  }
  final subsidy = Money.fromPaise(
    paise > projectCost.paise ? projectCost.paise : paise,
  );
  return SubsidyCalculation(
    scheme: scheme,
    capacityKw: capacityKw,
    projectCost: projectCost,
    subsidy: subsidy,
    customerPayable: projectCost - subsidy,
  );
}
