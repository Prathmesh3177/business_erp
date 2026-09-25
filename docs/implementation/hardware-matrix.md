# Hardware & Device Integration Matrix

## Overview
This document specifies device support, integration adapters, driver/OS requirements, and manual test procedures for printers and barcode scanners in **Shree Krushna Sales ERP**.

---

## 1. Supported Device & Transport Matrix

| Platform | Device Category | Supported Transport / Protocol | Tested / Verified Path | Status |
|---|---|---|---|---|
| **macOS** | Desktop A4 Printer | OS Print Spooler / System PDF Renderer | `PdfInvoiceRenderer` + `DesktopPrintAdapter` | **Verified** |
| **macOS** | Desktop Thermal POS (80mm / 58mm) | ESC/POS & Text Raster Stream | `ThermalInvoiceRenderer` + `DesktopPrintAdapter` | **Verified** |
| **macOS** | Desktop Barcode Scanner | USB / Bluetooth Keyboard-Wedge | `BarcodeScannerBuffer` (50ms pulse, 500ms debounce) | **Verified** |
| **Windows** | Desktop A4 Printer | Win32 Print Spooler / PDF Printer Driver | `PdfInvoiceRenderer` + `DesktopPrintAdapter` | **Verified** |
| **Windows** | Desktop Thermal POS (80mm / 58mm) | Virtual COM / Direct USB Spooler | `ThermalInvoiceRenderer` + `DesktopPrintAdapter` | **Verified** |
| **Windows** | Desktop Barcode Scanner | USB Keyboard-Wedge | `BarcodeScannerBuffer` (50ms pulse) | **Verified** |
| **Android** | Portable Thermal Printer | Bluetooth SPP / LE | `MobilePrintTransportManager` + `ThermalInvoiceRenderer` | **Verified (Adapter)** |
| **Android** | Network Thermal Printer | Wi-Fi / Direct TCP Port 9100 | `MobilePrintTransportManager` + `ThermalInvoiceRenderer` | **Verified (Adapter)** |
| **Android** | POS Thermal Printer | USB OTG Serial | `MobilePrintTransportManager` + `ThermalInvoiceRenderer` | **Verified (Adapter)** |
| **Android** | Camera Barcode & Photo Capture | Camera Stream / HID Keyboard-Wedge | `MobileCameraAdapter` + `BarcodeScannerBuffer` | **Verified** |


---

## 2. Concrete Manual Test Procedures

### Test Procedure A: A4 PDF & Spooler Printer Verification
1. Open POS or Sales History tab.
2. Select a completed sales invoice and tap **Print / Preview Invoice**.
3. Select **A4 Standard Invoice** format.
4. Verify seller details (`Shree Krushna Sales`), GSTIN, customer details, HSN codes, tax breakdown (CGST, SGST, IGST), total in words, and serial appendix.
5. Tap **Export PDF**. Verify SHA-256 checksum is generated and valid.
6. Select target OS printer and tap **Spool to Printer**. Verify status transitions from `queued` -> `sending` -> `accepted`.

### Test Procedure B: Thermal POS Receipt Printer Verification (58 mm / 80 mm)
1. In **Invoice Preview Dialog**, select **80 mm Thermal POS** or **58 mm Thermal POS**.
2. Verify column widths: 80 mm (48 chars wide), 58 mm (32 chars wide).
3. Confirm alignment of shop header, invoice number, date, item quantities, and grand total.
4. Toggle **Reprint Copy**. Confirm `*** DUPLICATE REPRINT ***` banner is displayed prominently on the thermal output.

### Test Procedure C: Keyboard-Wedge Desktop Barcode Scanner
1. Connect a USB or Bluetooth HID barcode scanner (e.g. Honeywell / Zebra / TVS Gold).
2. Scan a product barcode (e.g. `SP-540` or `INV-3KVA`).
3. Verify scanner input pulse (keystrokes < 50ms apart terminated by Enter key) is captured by `BarcodeScannerBuffer`.
4. Confirm product is automatically added to cart without leaking raw characters into focused text inputs.
5. Scan identical barcode twice within 500ms. Confirm second scan is debounced and ignored.

---

## 3. Delivery Distinction & Audit Safety
- `accepted`: Driver accepted print payload. Note: Driver acceptance is NOT proof of physical paper output.
- `failed` / `unknown`: Offline printer or driver timeout. Retrying a print job **NEVER** re-posts stock movements or financial journal entries.
- Reprints from history automatically append the `isReprint` duplicate watermark.
