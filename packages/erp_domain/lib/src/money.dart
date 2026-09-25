import 'errors.dart';

final class Money {
  const Money._(this.paise);

  factory Money.fromPaise(int paise) {
    return Money._(paise);
  }

  factory Money.fromRupees(double rupees) {
    if (rupees.isNaN || rupees.isInfinite) {
      throw const ValidationFailure('invalid_money', 'Money rupees cannot be NaN or Infinite');
    }
    final paise = (rupees * 100).round();
    return Money._(paise);
  }

  final int paise;

  double get inRupees => paise / 100.0;

  Money operator +(Money other) {
    final result = paise + other.paise;
    return Money._(result);
  }

  Money operator -(Money other) {
    final result = paise - other.paise;
    return Money._(result);
  }

  Money times(double factor) {
    if (factor.isNaN || factor.isInfinite) {
      throw const ValidationFailure('invalid_factor', 'Multiplication factor cannot be NaN or Infinite');
    }
    final result = (paise * factor).round();
    return Money._(result);
  }

  static const Money zero = Money._(0);

  static List<Money> allocateProportionally({
    required List<Money> bases,
    required Money totalDiscount,
  }) {
    if (bases.isEmpty) return const [];
    if (totalDiscount.paise == 0) {
      return List.filled(bases.length, Money.zero);
    }

    final totalBasePaise = bases.fold<int>(0, (sum, b) => sum + b.paise);
    if (totalBasePaise <= 0) {
      return List.filled(bases.length, Money.zero);
    }

    final allocated = <int>[];
    final remainders = <_RemainderPair>[];
    int sumAllocatedPaise = 0;

    for (int i = 0; i < bases.length; i++) {
      final exact = (bases[i].paise * totalDiscount.paise) / totalBasePaise;
      final floorVal = exact.floor();
      final remainder = exact - floorVal;

      allocated.add(floorVal);
      sumAllocatedPaise += floorVal;
      remainders.add(_RemainderPair(index: i, remainder: remainder));
    }

    int unallocatedPaise = totalDiscount.paise - sumAllocatedPaise;

    remainders.sort((a, b) {
      final cmp = b.remainder.compareTo(a.remainder);
      if (cmp != 0) return cmp;
      return a.index.compareTo(b.index);
    });

    for (int i = 0; i < unallocatedPaise && i < remainders.length; i++) {
      final idx = remainders[i].index;
      allocated[idx] = allocated[idx] + 1;
    }

    return allocated.map((p) => Money._(p)).toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Money && runtimeType == other.runtimeType && paise == other.paise;

  @override
  int get hashCode => paise.hashCode;

  @override
  String toString() => '₹${inRupees.toStringAsFixed(2)}';
}

final class _RemainderPair {
  const _RemainderPair({required this.index, required this.remainder});
  final int index;
  final double remainder;
}

final class UnitPrice {
  const UnitPrice._(this.microRupees);

  factory UnitPrice.fromRupees(double rupees) {
    if (rupees.isNaN || rupees.isInfinite || rupees < 0) {
      throw const ValidationFailure('invalid_unit_price', 'Unit price cannot be negative, NaN or Infinite');
    }
    return UnitPrice._((rupees * 1000000).round());
  }

  final int microRupees;

  double get inRupees => microRupees / 1000000.0;
}

final class Quantity {
  const Quantity._(this.microUnits);

  factory Quantity.fromUnits(double units) {
    if (units.isNaN || units.isInfinite || units <= 0) {
      throw const ValidationFailure('invalid_quantity', 'Quantity must be positive');
    }
    return Quantity._((units * 1000000).round());
  }

  final int microUnits;

  double get inUnits => microUnits / 1000000.0;
}

final class TaxRate {
  const TaxRate._(this.bps);

  factory TaxRate.fromBps(int bps) {
    if (bps < 0 || bps > 10000) {
      throw const ValidationFailure('invalid_tax_rate', 'Tax rate bps must be between 0 (0%) and 10000 (100%)');
    }
    return TaxRate._(bps);
  }

  factory TaxRate.fromPercentage(double percentage) {
    final bps = (percentage * 100).round();
    return TaxRate.fromBps(bps);
  }

  final int bps;

  double get percentage => bps / 100.0;

  static const TaxRate zero = TaxRate._(0);
  static const TaxRate gst18 = TaxRate._(1800);
}
