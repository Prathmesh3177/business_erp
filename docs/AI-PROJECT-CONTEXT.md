# PROJECT OVERVIEW

Solar Shop ERP — A local-first desktop+mobile ERP for solar retail and installation business in India.
- Built with Flutter/Dart (cross-platform: Windows, macOS, Android)
- Local SQLite database via Drift ORM (cloud/Firebase deferred)
- No AI/ML product features — conventional business software
- Offline-first: works fully without internet
- Languages: English + Marathi (मराठी)
- Currency: INR (₹), Indian number formatting (12,34,567.89)

# REPOSITORY STRUCTURE

```
ERP/
├── business_erp/              # Flutter app (presentation layer)
│   ├── lib/
│   │   ├── main.dart          # Entry point
│   │   ├── app/
│   │   │   ├── app.dart       # Root app widget
│   │   │   ├── di/service_locator.dart  # Dependency injection
│   │   │   ├── router/app_router.dart   # GoRouter navigation
│   │   │   └── theme/app_theme.dart     # Material 3 theme
│   │   ├── features/
│   │   │   └── home/presentation/home_screen.dart
│   │   └── l10n/              # Localization (English + Marathi ARB)
│   ├── pubspec.yaml
│   ├── android/               # Android platform files
│   ├── macos/                 # macOS platform files
│   ├── windows/               # Windows platform files
│   └── web/                   # Web platform files
├── packages/
│   ├── erp_domain/            # Pure Dart domain layer
│   │   └── lib/erp_domain.dart
│   ├── erp_application/       # Use cases, commands, queries
│   │   └── lib/erp_application.dart
│   ├── erp_local_data/        # Drift/SQLite repositories
│   │   └── lib/erp_local_data.dart
│   └── erp_platform/          # Printing, file I/O, platform services
│       └── lib/erp_platform.dart
├── docs/                      # All design documentation
│   ├── 01-requirements.md     # R01-R22 functional requirements
│   ├── 02-architecture.md     # Clean architecture, layers, tech stack
│   ├── 03-data-model.md       # Entity schemas, relations, migrations
│   ├── 04-business-rules.md   # GST, accounting, inventory rules
│   ├── 05-sync-and-cloud.md   # Cloud sync design (deferred)
│   ├── 06-security-and-operations.md  # Auth, backup, deployment
│   ├── 07-ux-and-printing.md  # UI wireframes, printing, localization
│   ├── 08-quality-gates.md    # Test scenarios T01-T24, release gates
│   ├── 09-roadmap.md          # Phase plan P00-P18
│   ├── 10-decisions-and-risks.md  # ADRs, risks, trade-offs
│   ├── prompts/               # Implementation prompts P00-P18
│   ├── tracking/              # Status, work log, test evidence, issues
│   ├── implementation/        # Module implementation notes
│   ├── releases/              # Release notes per version
│   ├── runbooks/              # Operational guides
│   └── adr/                   # Architecture Decision Records
├── spikes/                    # P00 feasibility tests (Drift, printer)
├── tool/                      # Scripts and utilities
└── output/                    # Build outputs
```

# ARCHITECTURE (Clean Architecture with Package Boundaries)

```
┌─────────────────────────────────────────┐
│     business_erp (Flutter App/UI)       │  Screens, BLoC/Cubit, GoRouter, DI
├─────────────────────────────────────────┤
│          erp_platform                   │  Printing, file I/O, barcode, OS adapters
├─────────────────────────────────────────┤
│          erp_application                │  Commands, queries, services, transactions
├─────────────────────────────────────────┤
│          erp_local_data                 │  Drift/SQLite, DAOs, migrations, repos
├─────────────────────────────────────────┤
│          erp_domain                     │  Entities, value objects, repository ports
└─────────────────────────────────────────┘
```

Dependency rules:
1. Domain depends on NOTHING — pure Dart, no Flutter
2. Data depends only on domain — implements repository ports
3. Application depends only on domain — uses repository ports
4. Platform depends on domain and application
5. App depends on everything — wires it all together
6. No circular dependencies

# TECHNOLOGY STACK

| Component | Technology |
|---|---|
| Framework | Flutter 3.x / Dart 3.x |
| Local DB | SQLite via Drift ORM |
| State management | BLoC/Cubit (Riverpod in architecture docs) |
| DI | GetIt service locator |
| Navigation | GoRouter |
| PDF generation | pdf package + HarfBuzz for Marathi |
| Printing | Platform channels (OS-specific) |
| Barcode | barcode package (Code128, EAN-13) |
| Localization | Flutter ARB (English + Marathi) |
| DB Mode | WAL mode, foreign keys enforced |

# DATABASE DESIGN

Key conventions:
- All money stored as INTEGER in paisa (1 rupee = 100 paisa) — NO floating point
- GST rates in basis points (1800 = 18%)
- Timestamps: ISO 8601 UTC strings
- Soft delete via deleted_at timestamp
- UUIDs for IDs (client-generated)
- Foreign keys enforced, cascades documented

Core tables: users, branches, products, categories, parties, invoices, invoice_lines, payments, accounts, journal_entries, journal_lines, stock_entries, serial_numbers, expenses, settings, audit_log

Solar/project tables: quotations, projects, warranty_terms, service_jobs, amc_contracts

Key relationships:
- products → categories (category_id FK)
- invoices → parties (party_id FK), branches (branch_id FK)
- invoice_lines → invoices, products
- payments → parties, invoices
- journal_entries → source document
- journal_lines → accounts, parties
- stock_entries → products, branches
- serial_numbers → products

# GST AND BILLING RULES (Critical Business Logic)

1. Tax determination:
   - Intra-state (same state): CGST + SGST (equal halves)
   - Inter-state (different state): IGST (full rate)
   - Rates: 0%, 5%, 12%, 18%, 28% plus cess

2. GST-inclusive pricing (back-calculation):
   - MRP includes GST → base_price = selling_price × 10000 / (10000 + gst_rate)
   - Total must equal original MRP exactly — not a paisa more or less

3. GST-exclusive pricing (forward-calculation):
   - tax = base_price × gst_rate / 10000
   - Total = base_price + tax

4. Discount interaction:
   - Discount applied BEFORE tax calculation
   - Tax calculated on discounted amount, not original
   - Admin sets max discount % per role

5. Invoice types:
   - GST invoice (is_gst_invoice = 1): full tax breakup, GSTIN, HSN
   - Non-GST (is_gst_invoice = 0): no tax lines, no GSTIN
   - Toggleable per invoice

6. Fixed-point arithmetic EVERYWHERE:
   - All calculations use integer paisa
   - Rounding: half-up to nearest paisa for line tax
   - Invoice total: round to nearest rupee (configurable)
   - Same inputs MUST always produce identical outputs

# ACCOUNTING RULES (Double-Entry)

Every financial transaction creates balanced journal entries (debits = credits):
- Cash sale: Debit Cash → Credit Sales + GST Payable
- Credit sale: Debit Accounts Receivable → Credit Sales + GST Payable
- Payment received: Debit Cash/Bank → Credit Accounts Receivable
- Purchase: Debit Inventory + GST Receivable → Credit Accounts Payable
- Expense: Debit Expense → Credit Cash/Bank

Atomic posting: invoice + lines + stock + journal ALL committed in single transaction.

# INVENTORY RULES

- Stock = SUM of all stock_entries (no separate counter)
- Serial tracking for high-value items (pumps, inverters)
- Weighted average costing per product per location
- Reorder alerts when stock < reorder_level
- No negative stock allowed

# ROLES AND PERMISSIONS

| Role | Can do |
|---|---|
| Admin | Everything, manage users, override limits, backup/restore |
| Counter | Sales, payments, view products, limited discount |
| Store | Products, inventory, purchases |
| Technician | Service jobs, warranty checks |
| Readonly | View reports only |

# IMPLEMENTATION PHASES (Current Status)

| Phase | Goal | Status |
|---|---|---|
| P00 | Validate design | ✅ Complete |
| P01 | Flutter + persistence foundation | 🔄 In Progress |
| P02 | Identity, authorization, auditing | Not started |
| P03 | Product catalog, parties | Not started |
| P04 | Money, GST, accounting engines | Not started |
| P05 | Inventory, valuation, serial control | Not started |
| P06 | Purchases | Not started |
| P07 | Sales & POS | Not started |
| P08 | Payments, returns, expenses | Not started |
| P09 | Printing & barcode | Not started |
| P10 | Reports & dashboard | Not started |
| P11 | V1 hardening, backup/restore | Not started |
| P12 | Android companion | Not started |
| P13 | Cloud platform | ⏸️ DEFERRED |
| P14 | Sync & branches | ⏸️ DEFERRED |
| P15 | Solar projects & quotations | Not started |
| P16 | Service, warranty, AMC | Not started |
| P17 | V3 final acceptance | Not started |
| P18 | Production readiness (Mac/Win) | Not started |

Current path (skipping deferred cloud): P01→P02→...→P12→P15→P16→P17→P18

# KEY DESIGN DECISIONS (ADRs)

1. Flutter for cross-platform (Win/Mac/Android)
2. SQLite + Drift for local database (no encryption yet — deferred)
3. Fixed-point arithmetic for all money (integers in paisa)
4. Event sourcing for sync (deferred to V2)
5. BLoC/Cubit for state management
6. Clean architecture with package boundaries (compile-time enforcement)
7. No AI product features in any release
8. Local-first, cloud-deferred
9. GST-inclusive pricing with automatic back-calculation
10. Single-branch authority (one writer per branch)

# UI/UX DESIGN

Desktop layout:
- Side navigation: Dashboard, POS, Inventory, Sales, Purchases, Payments, Expenses, Parties, Reports, Service, Settings
- POS screen: product search/scan + cart + tax summary + payment + Post&Print
- Keyboard-driven for speed (F1-F10 shortcuts)
- Material 3 design, warm amber accent, dark neutral text

Android layout:
- Bottom navigation: Home, Scan, Stock, Customers, More
- Camera barcode scanning, photo capture
- Offline draft capability

# PRINTING

- Thermal receipt (58mm/80mm): POS receipts
- A4/A5 tax invoice: full GST-compliant format
- Delivery challan, quotation, credit/debit notes
- Barcode labels: configurable layouts
- Both English and Marathi printing
- PDF generation with HarfBuzz Devanagari shaping

# FEATURE MODULES

1. Identity & Access: Multi-user, RBAC, audit log, session management
2. Product Catalog: Categories, HSN, images, barcodes, bulk import
3. Party Management: Customers/suppliers, GSTIN, credit limits, ledgers
4. GST & Tax Engine: Inclusive/exclusive pricing, auto calculation, GSTR reports
5. Accounting: Double-entry, chart of accounts, trial balance, P&L
6. Inventory: Serial tracking, weighted average, reorder alerts, stock transfers
7. Purchases: PO → GRN → Invoice → Payment flow
8. Sales/POS: Scan → Cart → Discount → Payment → Post (atomic)
9. Payments: Multi-mode, partial, advance, reconciliation
10. Returns: Sales/purchase returns with credit/debit notes
11. Expenses: Categorized, with optional GST
12. Printing: Thermal + A4, barcodes, labels
13. Reports: Sales, stock, GST, party ledger, P&L, dashboard
14. Backup/Restore: Automatic daily, manual, external drive export
15. Solar Projects: Quotation → Project → Materials → Installation → Invoice
16. Service/AMC: Warranty lookup, service jobs, technician assignment, AMC contracts

# IMPORTANT CONSTRAINTS

1. ALL money is in paisa (integers) — NEVER use floating point for money
2. ALL transactions are atomic — if any part fails, nothing saves
3. Invoice numbers are sequential and gap-free
4. Posted documents are immutable — corrections create new linked documents
5. No AI/ML/OCR/chatbot features
6. Local SQLite database only (cloud/Firebase deferred)
7. Same inputs must always produce same outputs (deterministic)
8. Foreign keys enforced on every SQLite connection
9. WAL mode for concurrent read/write
10. Audit trail for all sensitive actions (append-only, never deleted)

# DEFERRED FEATURES (for future implementation)

- Database encryption (SQLCipher/SQLite3MultipleCiphers)
- Cloud/Firebase migration (P13)
- Multi-branch sync (P14)
- AI/ML features (OCR, chatbots, forecasting)
- E-invoice/e-way-bill integration
- Payroll, manufacturing MRP, ecommerce

# HOW TO USE THIS CONTEXT

When working on this project:
1. Read this document first to understand the full scope
2. Check docs/tracking/project-status.md for current progress
3. Check docs/tracking/work-log.md for latest changes
4. Check docs/tracking/known-issues.md for blockers
5. Follow the prompt files in docs/prompts/ for implementation
6. Always update tracking docs after making changes
7. Never add AI features — they are explicitly excluded
8. Always use fixed-point paisa for money calculations
9. Always make database writes atomic (all-or-nothing)
10. Test on both macOS and Windows
