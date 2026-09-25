# UX, localization and device integration

## Design system

Use a restrained solar-business identity: warm amber accent, dark neutral text, light neutral surfaces, clear semantic success/warning/error states. Pick accessible contrast and visible keyboard focus; color never carries meaning alone. Use scalable type, 44–48 logical-pixel touch targets, consistent spacing and tabular numeric alignment. Monetary values use Indian grouping and INR; edits accept a clearly defined decimal syntax and never parse formatted currency with string hacks.

English and Marathi ARB messages include validation, empty states, errors, menus, reports and print labels. Bundle a licensed Devanagari-capable TTF and verify shaping in app, PDF and rasterized thermal output. P00 proved HarfBuzz-shaped Marathi PDF output with an OFL Noto Sans Devanagari TTF; the host Nirmala TTC was incompatible with the selected PDF parser and must not be a runtime dependency. Persist stable codes, not translated labels. Preserve entered customer/product names; do not machine-translate user data. Invoice language is a separate per-document preference.

## Desktop information architecture

Admin: Dashboard, POS, Sales/Returns, Purchases/Returns, Products, Inventory, Customers, Suppliers, Payments, Expenses, Reports, then Users and Settings. Add Projects and Service in V3. Counter navigation: New Sale, Sales, Products, Customers, Payments, permitted returns. Unauthorized modules are hidden but commands are independently secured.

```text
DESKTOP POS
+----------------------+--------------------------------------+----------------+
| Branch / user        | Search SKU / name / scan barcode    | Customer       |
| Connection / backup  |                                      | Credit balance |
| status               | Item | Qty | Price | Disc | Tax | Sum|                |
|                      | Pump |  1  | ...                  ...| Tax summary    |
| Product results      | Cable|12.5 | ...                  ...| Discount       |
| stock + unit + image |                                      | Grand total    |
|                      | Serial selection required for pump   | Split tender   |
|                      | Hold draft / Resume / Clear          | POST AND PRINT |
+----------------------+--------------------------------------+----------------+
```

Search remains focused for a keyboard scanner; enter adds item, escape closes dialog, configurable shortcuts navigate, and destructive actions require explicit intent. Avoid browser-style shortcuts conflicting with OS/accessibility keys. Show scanner input errors and duplicate scans. A held draft is not a stock reservation unless explicitly reserved. Revalidate price, stock and permission on posting.

```text
PRODUCT DETAIL                        INVENTORY ADJUSTMENT
Photos / name / SKU / attributes       Location -> Product -> Serial/batch
Available | Reserved | Quarantine     Counted quantity / delta preview
Location stock + serial list          Reason -> approval -> ledger preview
Prices (permission filtered)          Confirm creates adjustment document
Movement history / warranty links
```

Dashboard cards drill down to their underlying report. Show date range and timezone. Mark provisional/current-day values and replication age in cloud mode. Never label recorded UPI receipts as bank-confirmed. Profit cards state their definition and hide from unauthorized users.

## Android task flows

Bottom navigation: Home, Scan, Stock, Customers, More. Focus on camera capture, photo organization, serial/barcode lookup, inventory inspection and authorized job tasks. Stock-in/out buttons open real purchase/adjustment/material issue workflows; they do not edit quantities directly.

```text
PRODUCT ON ANDROID
[photo gallery]
5 HP Solar Pump / SKU
Available 12 | cached at 10:42
[Scan serial] [Add photo]
[Locations] [History]
[Prepare stock operation]
Posting requires branch connection
```

Request camera/storage/Bluetooth permissions just in time, explain denials and provide manual entry. Crop/compress images locally; store originals only if configured, preserve readable nameplate images. Camera barcode scanning is deterministic decoding, not AI. P12 uses isolated local data; P14 enables real paired branch operations. Offline user work remains visibly a draft, with per-item validation after reconnect.

## Essential UI states

Every screen needs loading, empty, validation, permission denied, recoverable error and offline/stale states. POS additionally needs insufficient stock, serial already sold, price changed, credit exceeded, period locked, posting in progress, commit result unknown and committed/print failed. Prevent duplicate clicks with command identity, not merely a disabled button. Recovery screens retain the command ID and let the user retrieve the result.

Forms preserve drafts on navigation/crash where practical. Date filters, keyboard flow, screen-reader labels and 200% text scaling receive explicit checks. A second user cannot silently overwrite a changed draft. Financial confirmation screens show the exact totals and effects before commit.

## Printing pipeline

`InvoiceSnapshot -> InvoiceViewModel -> PDF/raster/ESC-POS renderer -> PrintJob -> Transport`. The domain knows neither printer drivers nor page layout. Save the template/font version and optionally the generated PDF hash so reprints remain traceable. Print jobs track queued/sending/accepted/failed/unknown; accepted by a driver is not proof of paper output.

| Platform | Baseline | Conditional support |
|---|---|---|
| Windows | PDF and OS-spooled A4/installed USB/network printer | Raw/network thermal on named tested devices |
| macOS | PDF and OS print dialog | USB/network/AirPrint only through supported OS/driver path |
| Android | PDF/share/system print | Bluetooth thermal, Wi-Fi, USB OTG after adapter/device proof |

A4 layout includes shop legal details, approved invoice fields, buyer and place-of-supply details, item/HSN/unit/quantity/tax columns, component totals, round-off, payment status, serial appendix and terms. Multi-page headers repeat; totals and signatures do not collide with footers. Test long Marathi names and 100-line invoices. Thermal supports configured 58/80 mm widths. For Marathi, use verified rasterized output when printer code pages cannot shape Devanagari; test readability and speed on real hardware.

Automatic retry after ambiguous transport failure can produce duplicate paper. Mark delivery unknown, ask operator to inspect, and allow an audited copy reprint. Reprint never posts stock/revenue again. User-mediated PDF sharing/export is available without forcing a cloud service.

P00 printer evidence is limited to a running Windows Print Spooler with no installed printer and a visually verified PDF render. No paper, driver dialog, USB/network, thermal, Bluetooth, scanner or Android print test ran. The declared package/platform support in the [platform matrix](implementation/platform-matrix.md) is not proof of actual printing.

P01 adds English and Marathi ARB catalogs, an in-app locale toggle, a first-run organization/branch/financial-year form, a single-authority notice, retryable startup-failure UI and a manual snapshot action. Static analysis passed. The locale widget test and an actual app launch are not evidence yet because the Flutter SDK lock blocked the CLI.
