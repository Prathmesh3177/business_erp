# Invoices, Printing & Desktop Barcode Scanners

## Overview
This specification details the architecture, domain view models, rendering engines, print job lifecycle, and desktop barcode scanner integration for **Module P09** of **Shree Krushna Sales ERP**.

---

## 1. Frozen Invoice View Model & Templates
- **`InvoiceViewModel`**: Immutable snapshot extracted from sales transaction records (`SaleHeader`, `SaleLine`, `Party`, `Organization`, `Branch`).
- **Approved Invoice Fields**:
  - Shop Legal Name: `Shree Krushna Sales Private Limited`
  - Shop Display Name: `Shree Krushna Sales`
  - Address: `Rajmata Jijau Chowk, Jantre Plaza, Dhoki Road, Kalamb- 413507`
  - Phone: `7020422291 / 9881630001`
  - Seller GSTIN: `27AAAAA0000A1Z5` | State: `27-Maharashtra`
  - Customer Details: Name, GSTIN, Address, Phone
  - Document Details: Document Number (e.g. `SKS/2627/000001`), Date, Payment Status (`PAID`, `PARTIAL`, `UNPAID`)
  - Line Items: SKU, Product Name, HSN Code, Quantity, Unit Price, Taxable Amount, Tax Rate %, CGST, SGST, IGST, Line Total
  - Summary: Subtotal, Discount, Taxable Total, CGST, SGST, IGST, Round-Off, Grand Total
  - Serial Appendix: Item serial numbers per line item
  - Audit & Traceability: Template version `v1.0`, SHA-256 checksum, `isReprint` duplicate copy flag.

---

## 2. Rendering Engines & Localization
- **`PdfInvoiceRenderer`**: Renders A4 PDF pages with multi-page pagination. Page headers repeat on pages 2+; footers and signatures stay at the bottom without colliding with table items. Calculates SHA-256 checksum for PDF export.
- **`ThermalInvoiceRenderer`**: Formats 58 mm (32 cols) and 80 mm (48 cols) ESC/POS & text raster output with shop banner, line items table, totals summary, serial appendix, and `*** DUPLICATE REPRINT ***` warning watermark.
- **Multilingual Support**: Supports English (`en`), Marathi (`mr`), and Bilingual (`bilingual`) labels with licensed Devanagari font rendering (`Noto Sans Devanagari` TTF).

---

## 3. Print Job Queue & Audit Reprints
- **`PrintJob`**: Tracks `id`, `documentId`, `printerName`, `printFormat`, `status` (`queued`, `sending`, `accepted`, `failed`, `unknown`), `isReprint`, and `printedAtUtc`.
- **Delivery Distinction**: `accepted` by driver is distinguished from physical delivery. Offline printers yield `failed` or `unknown`.
- **Reprint Safety Rule**: Reprinting an invoice creates an audited print job with `isReprint = true`. Reprinting **NEVER** re-posts sales, stock movements, or journal entries!

---

## 4. Keyboard-Wedge Desktop Barcode Scanner
- **`BarcodeScannerBuffer`**:
  - Buffers hardware scanner keystrokes arriving within 50ms of each other.
  - Normalizes barcode text (trims whitespace, converts to uppercase).
  - Debounces duplicate scans within a 500ms window.
  - Automatically matches scanned SKU or barcode against product catalog and populates POS cart.

---

## 5. Verification Evidence
- Domain & Platform Unit Tests: 29 PASS (`packages/erp_domain/test/printing_barcode_test.dart`, `packages/erp_platform/test/printing_barcode_platform_test.dart`).
- Application Use Case Tests: 2 PASS (`packages/erp_application/test/printing_barcode_use_cases_test.dart`).
- App Analysis & Widget Tests: Clean analysis (0 errors), 100% tests PASS (`business_erp`).
- System Integrity: `dart run tool/check_all.dart` PASSED (0 boundary violations, 0 broken links).
