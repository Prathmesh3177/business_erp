# P18 — Final production readiness check (Mac & Windows)

Release: Production gate. Prerequisites: P17.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P18: Final production readiness check for Solar Shop ERP on Mac and Windows.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. No AI/ML features are in scope for this application. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed. Use local SQLite database; cloud/Firebase migration is deferred.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 01-requirements.md, 04-business-rules.md, 06-security-and-operations.md, 08-quality-gates.md.
Prerequisites: P17.

Implementation tasks:

1. Cross-platform verification — Mac and Windows
   a. Build, install and launch the application on both macOS and Windows. Verify clean first-run setup, database creation and default configuration on each platform.
   b. Test all core screens, navigation, window management, keyboard shortcuts and system tray/menu bar behavior on both platforms. Record OS versions, screen resolutions and any platform-specific UI differences.
   c. Verify file system paths, permissions, temp directories, log locations and backup destinations work correctly on both Mac (~/Library or Application Support) and Windows (%APPDATA% or equivalent).
   d. Confirm printing, barcode scanning, PDF generation and export features function on both platforms with their respective drivers and print dialogs.

2. GST admin and rate management
   a. Verify admin can add, edit and delete GST tax rates (e.g. 5%, 12%, 18%, 28%) and map them to product categories and HSN/SAC codes. Admin can set default rates per category and override per product.
   b. Verify admin can configure company GST details (GSTIN, state, registration type) and these appear correctly on all GST invoices.
   c. Verify admin can toggle the billing mode: GST-inclusive pricing, GST-exclusive pricing, or without-GST billing. This setting should be configurable at the company level with per-invoice override capability.

3. GST-inclusive pricing and automatic back-calculation
   a. When a product sell price is defined as GST-inclusive (e.g. MRP ₹1000 with 18% GST), the bill must automatically back-calculate: base price = ₹847.46, CGST 9% = ₹76.27, SGST 9% = ₹76.27, total = ₹1000.00. The invoice total must equal the defined sell price exactly — not a paisa more or less.
   b. For GST-exclusive pricing, verify forward calculation: base price ₹1000 + CGST 9% ₹90 + SGST 9% ₹90 = total ₹1180. Both modes must use fixed-point arithmetic with correct rounding to nearest paisa.
   c. Test mixed invoices with products at different GST rates (5%, 12%, 18%, 28%, exempt) on the same bill. Verify per-line tax calculation and invoice-level tax summary both reconcile.
   d. Verify inter-state billing switches to IGST automatically based on customer state vs company state. CGST/SGST must never appear on inter-state invoices and IGST must never appear on intra-state invoices.

4. Counter person discount and automatic GST recalculation
   a. Verify counter person can apply discount (percentage or fixed amount) on individual line items or the entire invoice. When a discount is applied, GST must recalculate automatically on the discounted amount — not on the original price.
   b. Example: product MRP ₹1000 (18% GST inclusive), counter gives 10% discount → discounted price ₹900, back-calculate base = ₹762.71, CGST = ₹68.64, SGST = ₹68.65, total = ₹900.00. Verify this calculation is correct and the total matches exactly.
   c. Verify discount permissions: admin can set maximum discount percentage per user role or per counter person. Counter person cannot exceed their allowed discount limit. Attempts to exceed must show a clear error and require admin override.
   d. Verify discount appears on the printed invoice with original price, discount amount and final price clearly shown. GST breakup on the invoice must reflect the discounted amounts.

5. Non-GST billing and billing mode toggle
   a. Verify non-GST billing: create invoices without GST (bill of supply, exempt sales, composition scheme). Confirm the application allows toggling between GST and without-GST billing per invoice. No tax lines, tax numbers or GST breakup should appear on non-GST invoices.
   b. Test billing edge cases: zero-value line items, discount before/after tax, rounding to nearest paisa, multi-line invoices exceeding one page, credit notes, debit notes and revised invoices. Verify invoice numbering is sequential and gap-free.
   c. Verify GST reports: GSTR-1 summary, GSTR-3B summary, HSN-wise summary and tax liability reconciliation. Confirm reports match posted invoices exactly with no orphaned or double-counted entries.

6. Inventory product images
   a. Verify desktop users can add one or more images to each product/inventory item via file picker or drag-and-drop. Supported formats: JPG, PNG, WEBP. Images should be compressed/resized automatically to a reasonable size (e.g. max 1024px, under 500KB) to avoid bloating the database or storage.
   b. When no image is added, the product must display a clean default placeholder image (generic product icon) — never a broken image link or empty space. The default image should be consistent across all views (catalog list, product detail, POS search, invoice line).
   c. Verify image appears in all relevant screens: product catalog grid/list view, product detail/edit page, POS product search/selection, and printed invoices (if configured). Images should load quickly without blocking the UI.
   d. Verify image update and delete: user can replace an existing image or remove it (reverts to default placeholder). Deleted images should be cleaned from storage and not leave orphan files.
   e. Verify product images are included in database backup and survive app updates. Images restored from backup must display correctly. Test that image storage does not degrade performance with 10,000+ products.

7. Database integrity and operations
   a. Verify local SQLite database creation, schema integrity, table relationships and constraint enforcement on both platforms. Run PRAGMA integrity_check and PRAGMA foreign_key_check on a populated database.
   b. Test CRUD operations across all modules: products, parties, invoices, payments, inventory, expenses and returns. Verify atomic posting — partial failures must roll back completely without corrupt data.
   c. Verify database backup and restore: create a backup, modify data, restore from backup and confirm all records match the backup state. Test backup on one platform and restore on the other (Mac → Windows and Windows → Mac).
   d. Test database size limits and performance: load at least 10,000 products, 5,000 parties, 50,000 invoices and verify query response time stays under 500ms for common operations (product lookup, invoice search, report generation).

8. App update and data preservation
   a. Install the current production version, populate with realistic business data (products, parties, invoices, payments, inventory, settings, user preferences, attachments).
   b. Install the new version over the existing installation on both Mac and Windows. Verify the update process does not delete, corrupt or reset existing data. All products, parties, invoices, payments, inventory, settings, preferences and attachments must survive the update intact.
   c. Verify database schema migration: if the new version adds or modifies tables/columns, confirm migrations run automatically on first launch after update. Old data must be preserved and new fields populated with correct defaults.
   d. Test rollback scenario: if the update fails mid-process, verify the application can recover to the previous working state without data loss. Document the rollback procedure.
   e. Verify that user-configured settings (company details, GST numbers, print templates, tax rates, payment modes, bank details) persist across updates without requiring reconfiguration.

Expected artifacts: docs/releases/production-readiness.md; platform test matrix; GST billing test evidence; update migration evidence.
Acceptance checks: Application installs, runs and passes all billing/database tests on both macOS and Windows; admin can manage GST rates and map to HSN codes; GST-inclusive back-calculation produces exact totals with no paisa difference; counter discount triggers automatic GST recalculation on discounted amount; discount limits enforced per role; GST and non-GST invoices generate correctly; IGST/CGST+SGST switch automatically by state; database passes integrity checks; app update preserves all existing data including GST settings; no platform-specific crash or data corruption; invoice numbering is sequential; reports reconcile with posted transactions.
Exit gate: Production-ready application verified on Mac and Windows with proven data preservation across updates.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```


