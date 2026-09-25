# Implementation Note: Catalog, Parties & Imports

This document details the P03 implementation of the product catalog, solar attribute definitions, party masters (customers & suppliers), managed file attachments, and CSV master import for Solar Shop ERP.

---

## 1. Catalog Architecture & Solar Attributes

### Core Entities (`packages/erp_domain/lib/src/catalog.dart`)
- **Product**: `id`, `organizationId`, `sku` (normalized uppercase), `name`, `categoryId`, `brandId`, `model`, `baseUnitId`, `serialPolicy`, `batchPolicy`, `minStock`, `hsnCode`, `defaultTaxRateBps` (default 1800 for 18%), `costPricePaise`, `sellingPricePaise`, `attributes` (Map of solar attribute keys & values).
- **Categories & Units**: Pre-seeded default categories (`solarPanel`, `solarInverter`, `solarBattery`, `solarCable`, `solarPump`) and standard units (`Pcs`, `Nos`, `Mtr`, `Set`, `Kg`).
- **Solar Attributes Specifications**:
  - `solarPanel`: Wattage (W), Cell Type (Mono PERC / Poly / Bifacial), Efficiency (%), Voc, Isc.
  - `solarInverter`: Capacity (kW/kVA), Phase (Single / Three), Waveform (Pure Sine Wave).
  - `solarBattery`: Capacity (Ah), Voltage (V), Battery Type (Lead Acid / LiFePO4), C-Rating.
  - `solarCable`: Thickness (sq mm), Core Count (1C/2C/3C/4C), Material (Copper/Aluminum).
  - `solarPump`: Power (HP), Head (M), Flow Rate (LPD).

---

## 2. Party Masters (Customers & Suppliers)

### Core Entities (`packages/erp_domain/lib/src/party.dart`)
- **Party**: `id`, `organizationId`, `name`, `isCustomer`, `isSupplier`, `gstin`, `pan`, `paymentTermsDays`, `creditLimitPaise`.
- **Validation**:
  - Mandatory name & at least one role (`isCustomer` or `isSupplier`).
  - Strict 15-character alphanumeric GSTIN regex validation (`^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$`).
- **Opening Balance Contract**: Parties do **NOT** have editable opening balance fields. Opening balances post strictly as financial journal entries in P06.

---

## 3. Managed Attachments & Deduplication

### Implementation (`packages/erp_application/lib/src/attachment_use_cases.dart`)
- **Deduplication**: SHA-256 hash comparison before saving. If content hash matches an existing file in the organization, an `AttachmentLink` is created to reference the existing file.
- **Security Constraints**: Maximum file size 10MB (`10 * 1024 * 1024` bytes); allowed MIME types: `image/jpeg`, `image/png`, `image/webp`, `application/pdf`.

---

## 4. CSV Master Import & Repeat-Safe Idempotency

### Implementation (`packages/erp_application/lib/src/csv_import_use_cases.dart`)
- **Repeat-Safe Import Command ID**: Keeps track of `importCommandId`. Re-submitting an already processed CSV import ID returns `isRepeatExecution = true` with zero duplicates created.
- **Cost Data Redaction**: Catalog search results enforce `Capability.costDataRead`. Counter staff lacking this capability receive `PublicProductCatalogDto` with purchase costs redacted, while Administrators receive `CostSensitiveProductDto`.

---

## 5. Verification & Test Evidence

| Test Suite | Command | Result |
|---|---|---|
| **Domain Unit Tests** | `dart test` in `packages/erp_domain` | **PASS** (9/9 tests passed: SKU normalization, GSTIN format, tax bps, attachment size limits) |
| **Application Unit Tests** | `dart test` in `packages/erp_application` | **PASS** (8/8 tests passed: Cost data filtering for Counter staff, repeat-safe CSV import ID) |
| **Drift Schema v3 Integration** | `dart test` in `packages/erp_local_data` | **PASS** (5/5 tests passed: Drift schema v0->v3 upgrade, product/party/attachment persistence) |
| **Flutter App & Static Analysis** | `flutter analyze` & `flutter test` in `business_erp` | **PASS** (0 issues found, 1/1 widget test passed) |
| **Monorepo Boundary Script** | `dart run tool/check_all.dart` | **PASS** (0 boundary errors, 0 broken links) |
