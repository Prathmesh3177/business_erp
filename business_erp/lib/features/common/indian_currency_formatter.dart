/// Utility functions for formatting Indian currency (₹) and converting numbers
/// to words using the Indian numbering system (Crores, Lakhs, Thousands, Hundreds).
library;

String formatIndianCurrency(double amount, {bool showSymbol = true}) {
  final isNegative = amount < 0;
  final absAmount = amount.abs();
  final fixed = absAmount.toStringAsFixed(2);
  final parts = fixed.split('.');
  final integerPart = parts[0];
  final decimalPart = parts[1];

  final symbol = showSymbol ? '₹ ' : '';

  if (integerPart.length <= 3) {
    return '${isNegative ? '-' : ''}$symbol$integerPart.$decimalPart';
  }

  final lastThree = integerPart.substring(integerPart.length - 3);
  String remaining = integerPart.substring(0, integerPart.length - 3);

  final List<String> segments = [];
  while (remaining.length > 2) {
    segments.insert(0, remaining.substring(remaining.length - 2));
    remaining = remaining.substring(0, remaining.length - 2);
  }
  if (remaining.isNotEmpty) {
    segments.insert(0, remaining);
  }

  final formattedInteger = '${segments.join(',')},$lastThree';
  return '${isNegative ? '-' : ''}$symbol$formattedInteger.$decimalPart';
}

String numberToIndianWords(
  double amount, {
  String prefix = 'INR',
  String suffix = 'Only',
}) {
  if (amount == 0) return '$prefix Zero $suffix'.trim();
  final isNegative = amount < 0;
  final absAmount = amount.abs();
  final intPart = absAmount.floor();
  final paise = ((absAmount - intPart) * 100).round();

  final words = _convertNumberToWords(intPart);
  var result = '$prefix $words';
  if (paise > 0) {
    result += ' and ${_convertNumberToWords(paise)} Paise';
  }
  if (suffix.isNotEmpty) {
    result += ' $suffix';
  }
  if (isNegative) {
    result = 'Minus $result';
  }
  return result.trim();
}

String _convertNumberToWords(int n) {
  if (n == 0) return 'Zero';

  const units = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];
  const tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  String helper(int num) {
    if (num < 20) return units[num];
    if (num < 100) {
      final t = tens[num ~/ 10];
      final u = units[num % 10];
      return u.isEmpty ? t : '$t $u';
    }
    if (num < 1000) {
      final rem = num % 100;
      final h = '${units[num ~/ 100]} Hundred';
      return rem > 0 ? '$h ${helper(rem)}' : h;
    }
    if (num < 100000) {
      // Up to 99,999 (Thousands)
      final rem = num % 1000;
      final th = '${helper(num ~/ 1000)} Thousand';
      return rem > 0 ? '$th ${helper(rem)}' : th;
    }
    if (num < 10000000) {
      // Up to 99,99,999 (Lakhs)
      final rem = num % 100000;
      final lk = '${helper(num ~/ 100000)} Lakh';
      return rem > 0 ? '$lk ${helper(rem)}' : lk;
    }
    // Crores (>= 1,00,00,000)
    final rem = num % 10000000;
    final cr = '${helper(num ~/ 10000000)} Crore';
    return rem > 0 ? '$cr ${helper(rem)}' : cr;
  }

  return helper(n);
}
