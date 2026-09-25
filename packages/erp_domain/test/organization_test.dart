import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  test('first-run setup rejects an inverted financial year', () {
    expect(
      () => FirstRunSetup.validate(
        legalName: 'Solar Shop',
        displayName: 'Solar Shop',
        branchName: 'Main',
        timeZone: 'Asia/Kolkata',
        locale: 'en',
        financialYearStartsOn: DateTime.utc(2026, 4),
        financialYearEndsOn: DateTime.utc(2026, 3, 31),
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });
}
