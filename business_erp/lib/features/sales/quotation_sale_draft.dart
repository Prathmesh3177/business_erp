import 'package:erp_domain/erp_domain.dart';

/// Carries an accepted quotation into the POS until the sales screen consumes it.
final class QuotationSaleDraft {
  const QuotationSaleDraft({
    required this.customerPartyId,
    required this.lines,
  });

  final String customerPartyId;
  final List<QuotationLine> lines;
}

QuotationSaleDraft? _pendingQuotationSaleDraft;

void stageQuotationForSale(QuotationSaleDraft draft) {
  _pendingQuotationSaleDraft = draft;
}

QuotationSaleDraft? takeStagedQuotationForSale() {
  final draft = _pendingQuotationSaleDraft;
  _pendingQuotationSaleDraft = null;
  return draft;
}
