import 'package:erp_domain/erp_domain.dart';

final class OrderSaleDraft {
  const OrderSaleDraft({required this.customerPartyId, required this.lines});

  final String customerPartyId;
  final List<SaleOrderLine> lines;
}

OrderSaleDraft? _pendingOrderSaleDraft;

void stageOrderForSale(OrderSaleDraft draft) => _pendingOrderSaleDraft = draft;

OrderSaleDraft? takeStagedOrderForSale() {
  final draft = _pendingOrderSaleDraft;
  _pendingOrderSaleDraft = null;
  return draft;
}
