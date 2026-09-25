import 'package:erp_domain/erp_domain.dart';

final class ThermalInvoiceRenderer {
  const ThermalInvoiceRenderer();

  /// Formats the [invoice] for a 58 mm (32 cols) or 80 mm (48 cols) thermal receipt printer.
  String renderThermalText(InvoiceViewModel invoice, {required InvoiceFormat format}) {
    final cols = format == InvoiceFormat.thermal58 ? 32 : 48;
    final sb = StringBuffer();

    final lineChar = '-'.padRight(cols, '-');
    final doubleLineChar = '='.padRight(cols, '=');

    // Header
    sb.writeln(_center(invoice.sellerDisplayName, cols));
    sb.writeln(_center(invoice.sellerAddress, cols));
    sb.writeln(_center('Mo. ${invoice.sellerPhone}', cols));
    if (invoice.sellerGstin != null) {
      sb.writeln(_center('GSTIN: ${invoice.sellerGstin}', cols));
    }
    sb.writeln(doubleLineChar);

    if (invoice.isReprint) {
      sb.writeln(_center('*** DUPLICATE REPRINT ***', cols));
      sb.writeln(doubleLineChar);
    }

    sb.writeln('Inv No : ${invoice.invoiceNumber}');
    sb.writeln('Date   : ${invoice.businessDate.day}/${invoice.businessDate.month}/${invoice.businessDate.year}');
    sb.writeln('Customer: ${invoice.customerName}');
    sb.writeln('Status : ${invoice.paymentStatus}');
    sb.writeln(lineChar);

    // Items
    if (cols == 32) {
      // 58 mm layout (32 chars)
      sb.writeln('Item Name           Qty   Amount');
      sb.writeln(lineChar);
      for (final line in invoice.lineItems) {
        final name = line.productName.length > 18 ? line.productName.substring(0, 18) : line.productName;
        final qty = line.quantityUnits.toStringAsFixed(1);
        final amt = line.lineTotalPaise.toString();
        sb.writeln('${name.padRight(18)} ${qty.padLeft(4)} ${amt.padLeft(8)}');
      }
    } else {
      // 80 mm layout (48 chars)
      sb.writeln('SKU / Description        Qty     Rate     Total');
      sb.writeln(lineChar);
      for (final line in invoice.lineItems) {
        final name = line.productName.length > 22 ? line.productName.substring(0, 22) : line.productName;
        final qty = line.quantityUnits.toStringAsFixed(1);
        final rate = line.unitPriceRupees.toStringAsFixed(2);
        final amt = line.lineTotalPaise.toString();
        sb.writeln('${name.padRight(22)} ${qty.padLeft(5)} ${rate.padLeft(8)} ${amt.padLeft(10)}');
      }
    }

    sb.writeln(lineChar);
    sb.writeln(_justify('Subtotal:', invoice.subtotalPaise.toString(), cols));
    sb.writeln(_justify('Total Tax:', invoice.totalTaxPaise.toString(), cols));
    sb.writeln(doubleLineChar);
    sb.writeln(_justify('GRAND TOTAL:', invoice.grandTotalPaise.toString(), cols));
    sb.writeln(_justify('Paid Amount:', invoice.amountPaidPaise.toString(), cols));
    sb.writeln(_justify('Balance Due:', invoice.balanceDuePaise.toString(), cols));
    sb.writeln(lineChar);

    if (invoice.serialsAppendix.isNotEmpty) {
      sb.writeln('Serials: ${invoice.serialsAppendix.join(", ")}');
      sb.writeln(lineChar);
    }

    sb.writeln(_center('Thank You! Visit Again!', cols));
    sb.writeln(_center('Shree Krushna Sales - Kalamb', cols));
    sb.writeln('\n\n\n'); // ESC/POS paper feed & cut padding

    return sb.toString();
  }

  String _center(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    final leftPadding = ((width - text.length) / 2).floor();
    return ' ' * leftPadding + text;
  }

  String _justify(String left, String right, int width) {
    final available = width - left.length - right.length;
    if (available <= 0) return '$left $right';
    return left + (' ' * available) + right;
  }
}
