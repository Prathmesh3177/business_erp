import 'package:flutter/material.dart';
import '../common/indian_currency_formatter.dart';

/// Reusable Indian GST Tax Invoice / Bill of Supply widget matching
/// professional retail and distribution invoice standards.
class TaxInvoiceWidget extends StatelessWidget {
  const TaxInvoiceWidget({
    super.key,
    required this.sellerName,
    required this.sellerAddress,
    required this.sellerPhone,
    this.sellerGstin,
    this.sellerState = 'Maharashtra',
    this.sellerStateCode = '27',
    required this.invoiceNo,
    required this.invoiceDate,
    this.ewayBillNo,
    this.deliveryNote,
    this.paymentMode = 'Cash / UPI',
    this.dispatchDocNo,
    this.vehicleNo,
    this.destination,
    required this.customerName,
    this.customerAddress,
    this.customerPhone,
    this.customerGstin,
    this.customerState = 'Maharashtra',
    this.customerStateCode = '27',
    this.placeOfSupply = 'Maharashtra',
    required this.items,
    this.discountAmount = 0.0,
    this.additionalCharges = 0.0,
    required this.isWithGst,
    this.termsAndConditions = const [
      'Goods once sold will not be taken back or exchanged.',
      'Warranty as per manufacturer policies only.',
      'Subject to Kalamb jurisdiction.',
    ],
    this.remarks,
  });

  final String sellerName;
  final String sellerAddress;
  final String sellerPhone;
  final String? sellerGstin;
  final String sellerState;
  final String sellerStateCode;

  final String invoiceNo;
  final String invoiceDate;
  final String? ewayBillNo;
  final String? deliveryNote;
  final String paymentMode;
  final String? dispatchDocNo;
  final String? vehicleNo;
  final String? destination;

  final String customerName;
  final String? customerAddress;
  final String? customerPhone;
  final String? customerGstin;
  final String customerState;
  final String customerStateCode;
  final String placeOfSupply;

  final List<TaxInvoiceItemData> items;
  final double discountAmount;
  final double additionalCharges;
  final bool isWithGst;
  final List<String> termsAndConditions;
  final String? remarks;

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.amount);
  double get totalQuantity => items.fold(0.0, (sum, i) => sum + i.quantity);

  // Group by HSN for tax calculation
  Map<String, HsnTaxAggregate> get hsnTaxMap {
    final map = <String, HsnTaxAggregate>{};
    for (final item in items) {
      final hsn = item.hsnCode.isEmpty ? '85414011' : item.hsnCode;
      final current = map.putIfAbsent(
        hsn,
        () => HsnTaxAggregate(hsnCode: hsn, gstRate: isWithGst ? item.gstRate : 0.0),
      );
      current.taxableValue += item.amount;
    }
    return map;
  }

  double get totalCgst {
    if (!isWithGst) return 0.0;
    return hsnTaxMap.values.fold(0.0, (sum, h) => sum + h.cgstAmount);
  }

  double get totalSgst {
    if (!isWithGst) return 0.0;
    return hsnTaxMap.values.fold(0.0, (sum, h) => sum + h.sgstAmount);
  }

  double get totalTax => totalCgst + totalSgst;

  double get grandTotal => subtotal - discountAmount + additionalCharges + totalTax;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF222222);
    const borderSide = BorderSide(color: borderColor, width: 1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Invoice Top Header Title
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: const BoxDecoration(
              border: Border(bottom: borderSide),
              color: Color(0xFFF9F9F9),
            ),
            alignment: Alignment.center,
            child: Text(
              isWithGst ? 'Tax Invoice' : 'Bill of Supply (Retail / Cash Memo)',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: Colors.black87,
              ),
            ),
          ),

          // 2. Seller Info (Left) & Invoice Meta Grid (Right)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Seller Details
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      border: Border(right: borderSide, bottom: borderSide),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sellerName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sellerAddress,
                          style: const TextStyle(fontSize: 10, color: Colors.black87),
                        ),
                        if (sellerPhone.isNotEmpty)
                          Text(
                            'Phone: $sellerPhone',
                            style: const TextStyle(fontSize: 10, color: Colors.black87),
                          ),
                        if (isWithGst && (sellerGstin?.isNotEmpty ?? false)) ...[
                          const SizedBox(height: 3),
                          Text(
                            'GSTIN/UIN: $sellerGstin',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        Text(
                          'State Name: $sellerState, Code: $sellerStateCode',
                          style: const TextStyle(fontSize: 10, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),

                // Invoice Meta 2-column Grid
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: borderSide),
                    ),
                    child: Column(
                      children: [
                        _buildMetaRow(
                          leftLabel: 'Invoice No.',
                          leftValue: invoiceNo,
                          rightLabel: 'Dated',
                          rightValue: invoiceDate,
                          borderSide: borderSide,
                        ),
                        _buildMetaRow(
                          leftLabel: 'e-Way Bill No.',
                          leftValue: ewayBillNo ?? '-',
                          rightLabel: 'Mode of Payment',
                          rightValue: paymentMode,
                          borderSide: borderSide,
                        ),
                        _buildMetaRow(
                          leftLabel: 'Delivery Note',
                          leftValue: deliveryNote ?? '-',
                          rightLabel: 'Motor Vehicle No.',
                          rightValue: vehicleNo ?? '-',
                          borderSide: borderSide,
                        ),
                        _buildMetaRow(
                          leftLabel: 'Dispatched through',
                          leftValue: dispatchDocNo ?? '-',
                          rightLabel: 'Destination',
                          rightValue: destination ?? 'Kalamb Local',
                          borderSide: borderSide,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Buyer (Bill to) Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: const BoxDecoration(
              border: Border(bottom: borderSide),
              color: Color(0xFFFAFAFA),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Buyer (Bill to)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (customerAddress != null && customerAddress!.isNotEmpty)
                        Text(
                          customerAddress!,
                          style: const TextStyle(fontSize: 10),
                        ),
                      if (customerPhone != null && customerPhone!.isNotEmpty)
                        Text(
                          'Contact No: $customerPhone',
                          style: const TextStyle(fontSize: 10),
                        ),
                      if (isWithGst && (customerGstin?.isNotEmpty ?? false))
                        Text(
                          'GSTIN/UIN: $customerGstin',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else if (isWithGst)
                        const Text(
                          'GSTIN/UIN: Unregistered / Consumer',
                          style: TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      Text(
                        'State Name: $customerState, Code: $customerStateCode | Place of Supply: $placeOfSupply',
                        style: const TextStyle(fontSize: 10, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Description of Goods Table
          _buildGoodsTable(borderSide),

          // 5. Amount in words + E. & O.E.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: const BoxDecoration(
              border: Border(bottom: borderSide),
              color: Color(0xFFFBFBFB),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount Chargeable (in words)',
                        style: TextStyle(fontSize: 9, color: Colors.black54),
                      ),
                      Text(
                        numberToIndianWords(grandTotal),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'E. & O.E.',
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 6. HSN/SAC Tax Summary Table (Only when With GST)
          if (isWithGst && hsnTaxMap.isNotEmpty) ...[
            _buildHsnSummaryTable(borderSide),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                border: Border(bottom: borderSide),
              ),
              child: Row(
                children: [
                  const Text(
                    'Tax Amount (in words) : ',
                    style: TextStyle(fontSize: 9, color: Colors.black54),
                  ),
                  Expanded(
                    child: Text(
                      numberToIndianWords(totalTax),
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 7. Declaration & Signatory
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left: Declaration & Remarks
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      border: Border(right: borderSide),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Declaration',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'We declare that this invoice shows the actual price of the goods described and that all particulars are true and correct.',
                          style: TextStyle(fontSize: 8.5, color: Colors.black87),
                        ),
                        if (remarks != null && remarks!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Remarks: $remarks',
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                        const Spacer(),
                        const Text(
                          'This is a Computer Generated Invoice',
                          style: TextStyle(
                            fontSize: 8,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right: Authorised Signatory
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'for $sellerName',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 38), // Space for digital or physical stamp/signature
                        const Text(
                          'Authorised Signatory',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
    required BorderSide borderSide,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: borderSide),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  border: Border(right: borderSide),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leftLabel,
                      style: const TextStyle(fontSize: 8, color: Colors.black54),
                    ),
                    Text(
                      leftValue,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rightLabel,
                      style: const TextStyle(fontSize: 8, color: Colors.black54),
                    ),
                    Text(
                      rightValue,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoodsTable(BorderSide borderSide) {
    const tableHeaderBg = Color(0xFFF2F4F7);

    return Column(
      children: [
        // Table Header
        Container(
          decoration: BoxDecoration(
            color: tableHeaderBg,
            border: Border(bottom: borderSide),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _th('#', width: 28, borderSide: borderSide),
                _th('Description of Goods', flex: 4, borderSide: borderSide, align: TextAlign.left),
                _th('HSN/SAC', width: 68, borderSide: borderSide),
                if (isWithGst) _th('GST Rate', width: 55, borderSide: borderSide),
                _th('Quantity', width: 62, borderSide: borderSide),
                _th('Rate (₹)', width: 65, borderSide: borderSide),
                _th('per', width: 36, borderSide: borderSide),
                _th('Amount (₹)', width: 75, borderSide: null, align: TextAlign.right),
              ],
            ),
          ),
        ),

        // Product Rows
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            child: const Text(
              'No items added yet. Search or tap "+ Add Products".',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          )
        else
          ...items.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final item = entry.value;
            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: borderSide),
                color: idx.isEven ? const Color(0xFFFCFCFC) : Colors.white,
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    _td('$idx', width: 28, borderSide: borderSide),
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(border: Border(right: borderSide)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.sku.isNotEmpty)
                              Text(
                                'SKU: ${item.sku}',
                                style: const TextStyle(fontSize: 8, color: Colors.black54),
                              ),
                            if (item.serials.isNotEmpty)
                              Text(
                                'S/N: ${item.serials.join(", ")}',
                                style: const TextStyle(fontSize: 8, color: Colors.black54),
                              ),
                          ],
                        ),
                      ),
                    ),
                    _td(item.hsnCode.isEmpty ? '-' : item.hsnCode, width: 68, borderSide: borderSide),
                    if (isWithGst)
                      _td('${item.gstRate.toStringAsFixed(0)} %', width: 55, borderSide: borderSide),
                    _td(
                      '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 2)} ${item.unit}',
                      width: 62,
                      borderSide: borderSide,
                    ),
                    _td(
                      item.rate.toStringAsFixed(2),
                      width: 65,
                      borderSide: borderSide,
                      align: TextAlign.right,
                    ),
                    _td(item.unit, width: 36, borderSide: borderSide),
                    _td(
                      item.amount.toStringAsFixed(2),
                      width: 75,
                      borderSide: null,
                      align: TextAlign.right,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            );
          }),

        // Tax Rows (CGST / SGST) if With GST
        if (isWithGst && items.isNotEmpty) ...[
          _buildSummaryLine('CGST', totalCgst, borderSide),
          _buildSummaryLine('SGST', totalSgst, borderSide),
        ],

        // Subtotal row if discount or charges exist
        if (discountAmount > 0)
          _buildSummaryLine('Less: Discount', -discountAmount, borderSide, isNegative: true),
        if (additionalCharges > 0)
          _buildSummaryLine('Add: Charges / Freight', additionalCharges, borderSide),

        // Total Row
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6F8),
            border: Border(bottom: borderSide),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _td('', width: 28, borderSide: borderSide),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(border: Border(right: borderSide)),
                    child: const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _td('', width: 68, borderSide: borderSide),
                if (isWithGst) _td('', width: 55, borderSide: borderSide),
                _td(
                  '${totalQuantity.toStringAsFixed(totalQuantity % 1 == 0 ? 0 : 2)} pcs',
                  width: 62,
                  borderSide: borderSide,
                  isBold: true,
                ),
                _td('', width: 65, borderSide: borderSide),
                _td('', width: 36, borderSide: borderSide),
                _td(
                  '₹ ${grandTotal.toStringAsFixed(2)}',
                  width: 75,
                  borderSide: null,
                  align: TextAlign.right,
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryLine(String label, double amount, BorderSide borderSide, {bool isNegative = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: borderSide),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _td('', width: 28, borderSide: borderSide),
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(border: Border(right: borderSide)),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isNegative ? Colors.red.shade900 : Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            _td('', width: 68, borderSide: borderSide),
            if (isWithGst) _td('', width: 55, borderSide: borderSide),
            _td('', width: 62, borderSide: borderSide),
            _td('', width: 65, borderSide: borderSide),
            _td('', width: 36, borderSide: borderSide),
            _td(
              amount.abs().toStringAsFixed(2),
              width: 75,
              borderSide: null,
              align: TextAlign.right,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHsnSummaryTable(BorderSide borderSide) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: borderSide),
      ),
      child: Column(
        children: [
          Container(
            color: const Color(0xFFF4F6F8),
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                _th('HSN/SAC', flex: 2, borderSide: borderSide),
                _th('Taxable Value', flex: 2, borderSide: borderSide, align: TextAlign.right),
                _th('Central Tax', flex: 3, borderSide: borderSide),
                _th('State Tax', flex: 3, borderSide: borderSide),
                _th('Total Tax Amount', flex: 2, borderSide: null, align: TextAlign.right),
              ],
            ),
          ),
          // Subheader for Rate & Amount
          Container(
            decoration: BoxDecoration(color: const Color(0xFFF9FAFB), border: Border(bottom: borderSide)),
            child: Row(
              children: [
                _td('', flex: 2, borderSide: borderSide),
                _td('', flex: 2, borderSide: borderSide),
                _td('Rate', flex: 1, borderSide: borderSide),
                _td('Amount', flex: 2, borderSide: borderSide, align: TextAlign.right),
                _td('Rate', flex: 1, borderSide: borderSide),
                _td('Amount', flex: 2, borderSide: borderSide, align: TextAlign.right),
                _td('', flex: 2, borderSide: null),
              ],
            ),
          ),
          ...hsnTaxMap.values.map((hsn) {
            final halfRate = (hsn.gstRate / 2).toStringAsFixed(hsn.gstRate % 2 == 0 ? 0 : 1);
            return Container(
              decoration: BoxDecoration(border: Border(bottom: borderSide)),
              child: Row(
                children: [
                  _td(hsn.hsnCode, flex: 2, borderSide: borderSide),
                  _td(hsn.taxableValue.toStringAsFixed(2), flex: 2, borderSide: borderSide, align: TextAlign.right),
                  _td('$halfRate%', flex: 1, borderSide: borderSide),
                  _td(hsn.cgstAmount.toStringAsFixed(2), flex: 2, borderSide: borderSide, align: TextAlign.right),
                  _td('$halfRate%', flex: 1, borderSide: borderSide),
                  _td(hsn.sgstAmount.toStringAsFixed(2), flex: 2, borderSide: borderSide, align: TextAlign.right),
                  _td(hsn.totalTaxAmount.toStringAsFixed(2), flex: 2, borderSide: null, align: TextAlign.right, isBold: true),
                ],
              ),
            );
          }),
          // Total HSN Row
          Container(
            color: const Color(0xFFF4F6F8),
            child: Row(
              children: [
                _td('Total', flex: 2, borderSide: borderSide, isBold: true),
                _td(subtotal.toStringAsFixed(2), flex: 2, borderSide: borderSide, align: TextAlign.right, isBold: true),
                _td('', flex: 1, borderSide: borderSide),
                _td(totalCgst.toStringAsFixed(2), flex: 2, borderSide: borderSide, align: TextAlign.right, isBold: true),
                _td('', flex: 1, borderSide: borderSide),
                _td(totalSgst.toStringAsFixed(2), flex: 2, borderSide: borderSide, align: TextAlign.right, isBold: true),
                _td(totalTax.toStringAsFixed(2), flex: 2, borderSide: null, align: TextAlign.right, isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _th(
    String text, {
    double? width,
    int? flex,
    BorderSide? borderSide,
    TextAlign align = TextAlign.center,
  }) {
    final child = Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        border: borderSide != null ? Border(right: borderSide) : null,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: align,
      ),
    );
    if (flex != null) return Expanded(flex: flex, child: child);
    return child;
  }

  Widget _td(
    String text, {
    double? width,
    int? flex,
    BorderSide? borderSide,
    TextAlign align = TextAlign.center,
    bool isBold = false,
  }) {
    final child = Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        border: borderSide != null ? Border(right: borderSide) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
        textAlign: align,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    if (flex != null) return Expanded(flex: flex, child: child);
    return child;
  }
}

class TaxInvoiceItemData {
  const TaxInvoiceItemData({
    required this.productName,
    this.sku = '',
    this.hsnCode = '',
    required this.quantity,
    required this.rate,
    this.unit = 'pcs',
    this.gstRate = 18.0,
    this.discount = 0.0,
    this.serials = const [],
  });

  final String productName;
  final String sku;
  final String hsnCode;
  final double quantity;
  final double rate;
  final String unit;
  final double gstRate;
  final double discount;
  final List<String> serials;

  double get amount => (quantity * rate) - discount;
}

class HsnTaxAggregate {
  HsnTaxAggregate({
    required this.hsnCode,
    required this.gstRate,
  });

  final String hsnCode;
  final double gstRate;
  double taxableValue = 0.0;

  double get cgstAmount => taxableValue * (gstRate / 200.0);
  double get sgstAmount => taxableValue * (gstRate / 200.0);
  double get totalTaxAmount => cgstAmount + sgstAmount;
}
