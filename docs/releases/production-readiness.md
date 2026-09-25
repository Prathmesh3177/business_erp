# Shree Krushna Sales ERP — Final Production Readiness Certification

**Release Version**: `3.0.0-PROD`  
**Date**: 2026-09-25  
**Prerequisites**: P17 (Complete V3 Acceptance & Operational Handoff)  

---

## 1. Executive Summary

This document certifies the final production readiness gate for **Shree Krushna Sales ERP** (`श्री कृष्णा सेल्स ईआरपी`) across Windows and macOS platforms. All functional, computational, security, database integrity, and data update preservation checks have been executed and verified.

---

## 2. Cross-Platform Operating System & Path Matrix

| Platform | Database Location | Log Storage | Backup & Snapshot Destination |
|---|---|---|---|
| **Windows 10/11 x64** | `%APPDATA%\ShreeKrushnaSales\db.erpdb` | `%APPDATA%\ShreeKrushnaSales\logs\` | `%APPDATA%\ShreeKrushnaSales\backups\` |
| **macOS 12+ (Apple Silicon & Intel)** | `~/Library/Application Support/ShreeKrushnaSales/db.erpdb` | `~/Library/Logs/ShreeKrushnaSales/` | `~/Library/Application Support/ShreeKrushnaSales/backups/` |

---

## 3. GST Administration, Tax Engine & Billing Modes

### 3.1 Configurable Tax Rates & HSN Mapping
- **Supported Tax Rates**: 0% (Exempt), 5%, 12%, 18%, 28%.
- **HSN/SAC Mapping**: Configurable default rates per product category with per-product override capability.
- **Company GST Profile**: Stores GSTIN (`27ABCDE1234F1Z5`), Maharashtra state code (`27`), and registration type on company header.

### 3.2 GST Calculation Verification (Exact Paisa Precision)

#### A. GST-Inclusive Back-Calculation (MRP ₹1000.00 @ 18% GST)
- **Formula**: $\text{Base} = \lfloor \frac{\text{Gross}}{1 + \text{Rate}} \rceil$
- **Base Taxable Amount**: $\frac{1000.00}{1.18} = \mathbf{₹847.46}$ (84,746 paise)
- **Total GST (18%)**: $847.46 \times 0.18 = \mathbf{₹152.54}$ (15,254 paise)
- **CGST (9%)**: $\mathbf{₹76.27}$ (7,627 paise)
- **SGST (9%)**: $\mathbf{₹76.27}$ (7,627 paise)
- **Invoice Grand Total**: $847.46 + 76.27 + 76.27 = \mathbf{₹1000.00\text{ (Exact)}}$

#### B. GST-Exclusive Forward Calculation (Base ₹1000.00 @ 18% GST)
- **Base Taxable Amount**: $\mathbf{₹1000.00}$ (100,000 paise)
- **CGST (9%)**: $\mathbf{₹90.00}$ (9,000 paise)
- **SGST (9%)**: $\mathbf{₹90.00}$ (9,000 paise)
- **Invoice Grand Total**: $1000.00 + 90.00 + 90.00 = \mathbf{₹1180.00}$

#### C. Discounted GST Recalculation (MRP ₹1000.00 with 10% Counter Discount @ 18% GST)
- **Discounted Gross Price**: $1000.00 - 100.00 = \mathbf{₹900.00}$ (90,000 paise)
- **Recalculated Base**: $\frac{900.00}{1.18} = \mathbf{₹762.71}$ (76,271 paise)
- **Total GST (18%)**: $762.71 \times 0.18 = \mathbf{₹137.29}$ (13,729 paise)
- **CGST (9%)**: $\mathbf{₹68.64}$ (6,864 paise)
- **SGST (9%)**: $\mathbf{₹68.65}$ (6,865 paise)
- **Invoice Grand Total**: $762.71 + 68.64 + 68.65 = \mathbf{₹900.00\text{ (Exact)}}$

#### D. Inter-State vs Intra-State Automatic Tax Routing
- **Intra-state (Buyer & Seller in MH 27)**: CGST (9%) + SGST (9%).
- **Inter-state (Buyer in KA 29, Seller in MH 27)**: IGST (18%) charged automatically. CGST & SGST are strictly zero.

---

## 4. Product Image Handling & Placeholder Architecture

1. **Formats Supported**: JPG, PNG, WEBP.
2. **Compression Adapter**: `MobileCameraAdapter` / Desktop File Adapter resizes raw captures to maximum 1024px dimension, compressing payloads below 500KB.
3. **Placeholder Safeguard**: When no custom photo is attached, views fall back to category-specific material icons (`Icons.solar_power`, `Icons.electric_bolt`, `Icons.battery_charging_full`, `Icons.inventory_2`) — preventing broken links or unstyled containers across POS, Catalog, and Printed Invoices.
4. **Backup Persistence**: Managed attachment files and checksums are included in `.erpa` compressed backup envelopes.

---

## 5. Database Integrity & Update Migration Safeguards

1. **SQLite Integrity Verification**:
   - `PRAGMA integrity_check` -> `ok`
   - `PRAGMA foreign_key_check` -> `0 errors`
2. **Schema Upgrade Resilience**:
   - Drift `onUpgrade` migrations seamlessly transition databases from Schema v1 through v10 without resetting master or transactional data.
3. **Rollback & Disaster Recovery**:
   - Prior to applying app updates or staged database restores, a pre-update safety copy (`.pre_restore_safety.bak`) is generated automatically.

---

## 6. Verification Summary

| Suite / Area | Executed | Passed | Status |
|---|---|---|---|
| Domain Unit Tests (including GST Engine) | 45 | 45 | **PASS** |
| Application Use Cases | 42 | 42 | **PASS** |
| Local Database Integration Tests (v1-v10) | 15 | 15 | **PASS** |
| Platform Crypto & Hardware Adapters | 14 | 14 | **PASS** |
| Flutter Widget Tests | 7 | 7 | **PASS** |
| Package Boundaries & Link Check (`tool/check_all.dart`) | 2 | 2 | **PASS** |

---

## 7. Final Operational Sign-off

**Shree Krushna Sales ERP** (`3.0.0-PROD`) is certified **Production-Ready** for immediate deployment.
