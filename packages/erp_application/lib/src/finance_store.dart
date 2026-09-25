import 'package:erp_domain/erp_domain.dart';

abstract interface class FinanceStore {
  Future<void> saveSalesReturn({
    required SalesReturnHeader header,
    required List<SalesReturnLine> lines,
  });

  Future<SalesReturnHeader?> getSalesReturnHeader(String id);
  Future<List<SalesReturnLine>> getSalesReturnLines(String salesReturnId);
  Future<List<SalesReturnHeader>> listSalesReturns(String organizationId);

  Future<void> savePurchaseReturn({
    required PurchaseReturnHeader header,
    required List<PurchaseReturnLine> lines,
  });

  Future<PurchaseReturnHeader?> getPurchaseReturnHeader(String id);
  Future<List<PurchaseReturnLine>> getPurchaseReturnLines(String purchaseReturnId);
  Future<List<PurchaseReturnHeader>> listPurchaseReturns(String organizationId);

  Future<void> saveExpenseCategory(ExpenseCategory category);
  Future<List<ExpenseCategory>> getExpenseCategories(String organizationId);

  Future<void> saveExpenseEntry(ExpenseEntry entry);
  Future<List<ExpenseEntry>> listExpenseEntries(String organizationId, {String? categoryId});

  Future<void> saveCashSession(CashSession session);
  Future<CashSession?> getActiveCashSession(String organizationId, String userId);
  Future<List<CashSession>> listCashSessions(String organizationId);

  Future<List<PartyAgingBucket>> getPartyAgingBuckets(String organizationId, {required bool isCustomer});
}
