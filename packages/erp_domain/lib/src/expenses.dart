import 'money.dart';

final class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.accountCode,
    this.active = true,
  });

  final String id;
  final String organizationId;
  final String name;
  final String accountCode;
  final bool active;

  static const defaultCategories = [
    ExpenseCategory(id: 'exp_cat_rent', organizationId: 'default_org', name: 'Office Rent & Maintenance', accountCode: '6100'),
    ExpenseCategory(id: 'exp_cat_util', organizationId: 'default_org', name: 'Electricity & Water Utilities', accountCode: '6200'),
    ExpenseCategory(id: 'exp_cat_freight', organizationId: 'default_org', name: 'Freight & Transport', accountCode: '6300'),
    ExpenseCategory(id: 'exp_cat_office', organizationId: 'default_org', name: 'Printing, Stationery & Supplies', accountCode: '6400'),
    ExpenseCategory(id: 'exp_cat_salary', organizationId: 'default_org', name: 'Salaries & Wages', accountCode: '6500'),
    ExpenseCategory(id: 'exp_cat_tea', organizationId: 'default_org', name: 'Tea & Refreshments', accountCode: '6600'),
    ExpenseCategory(id: 'exp_cat_misc', organizationId: 'default_org', name: 'Miscellaneous Expenses', accountCode: '6900'),
  ];
}

final class ExpenseEntry {
  const ExpenseEntry({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.categoryId,
    required this.categoryName,
    required this.accountCode,
    required this.amountPaise,
    required this.expenseDate,
    required this.paymentMethod,
    required this.createdAtUtc,
    this.referenceNumber,
    this.notes,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String categoryId;
  final String categoryName;
  final String accountCode;
  final Money amountPaise;
  final DateTime expenseDate;
  final String paymentMethod;
  final DateTime createdAtUtc;
  final String? referenceNumber;
  final String? notes;
}

enum CashSessionStatus { open, closed }

final class CashSession {
  const CashSession({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.userId,
    required this.username,
    required this.openedAtUtc,
    this.closedAtUtc,
    required this.openingCashPaise,
    required this.expectedCashPaise,
    required this.countedCashPaise,
    required this.variancePaise,
    required this.status,
    this.notes,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String userId;
  final String username;
  final DateTime openedAtUtc;
  final DateTime? closedAtUtc;
  final Money openingCashPaise;
  final Money expectedCashPaise;
  final Money countedCashPaise;
  final Money variancePaise;
  final CashSessionStatus status;
  final String? notes;
}
