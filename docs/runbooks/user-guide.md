# Shree Krushna Sales ERP — User Operational Guide

## Overview
Welcome to the operational user guide for **Shree Krushna Sales ERP** (`श्री कृष्णा सेल्स ईआरपी`). This document provides step-by-step instructions for daily operations across Counter POS, Purchasing, Inventory, Solar Projects, Service & AMC, and Reporting.

---

## 1. System Access & Security

### 1.1 Logging In
1. Launch the **Shree Krushna Sales ERP** application desktop icon.
2. Enter your **Username** and **Password**.
3. Click **Sign In**.

### 1.2 Lock Screen Security
- If the system remains idle, the screen automatically locks to protect financial and customer data.
- Re-enter your user password in the lock screen modal to resume work without losing open sales carts or drafts.

---

## 2. Counter POS & Sales Operations

### 2.1 Processing a Retail / Counter Sale
1. Click **Counter POS & Sales** (`/sales`) from the main navigation screen.
2. **Item Entry**:
   - Use a USB barcode scanner to scan the product barcode directly into the search bar, OR
   - Type product SKU / name into the item search box and select the product.
3. **Quantity & Pricing**:
   - Adjust quantities. Applicable GST rates (e.g. 18% or 12%) are computed automatically using fixed-point arithmetic.
4. **Customer Details**:
   - Select an existing customer party or enter walk-in customer details.
5. **Split Tender & Payment**:
   - Enter payment amounts across Cash, UPI, Card, or Credit.
   - Click **Complete Sale & Print Invoice**.
6. **Invoice Printing**:
   - The invoice preview modal displays A4 or thermal receipt views in English or Marathi.
   - Click **Print** to send to spooler or thermal printer.

### 2.2 Holding and Resuming Sales Carts
- Click **Hold Draft** to temporarily store an incomplete sales cart when a customer steps away.
- Click **Resume Draft** from the POS header to reload and complete held transactions.

---

## 3. Purchasing & Supplier Receipts

### 3.1 Recording Supplier Purchase Bills
1. Click **Purchases & Receipts** (`/purchases`).
2. Click **New Supplier Purchase**.
3. Select **Supplier Party** and enter the **Supplier Invoice Number**.
4. Add line items with quantities, cost prices, and serial numbers (for serialized solar panels or inverters).
5. Enter any **Landed Costs** (e.g. freight or transit insurance) to allocate costs across products automatically.
6. Click **Post Purchase Receipt**. Stock balances and Accounts Payable ledgers update immediately.

---

## 4. Solar Projects & Quotations

### 4.1 Creating & Approving Solar Quotations
1. Click **Solar Projects & Quotations** (`/projects`).
2. Click **New Solar Quotation**.
3. Enter customer details, installation charges, and equipment line items (e.g. 540W Mono PERC Panels, 5kW Solar Inverter).
4. Click **Create Quotation**.
5. When the customer approves, click **Approve & Accept**. A new **Solar Project Site** record is created automatically without double-issuing inventory.

### 4.2 Issuing & Returning Site Materials
- **Issue Materials**: Select the project, enter items/serials being dispatched to the site, and click **Issue Site Materials**. The material cost is debited to asset account `1400 Work In Progress`.
- **Return Unused Materials**: If panels or cables remain unused after installation, click **Return Unused Materials**. Stock is restored to storage and `1400 Work In Progress` is credited.
- **Complete Project & Invoice**: Upon commissioning, click **Complete & Post Final Invoice**. Revenue and GST are billed, and accumulated WIP costs transfer to COGS (`5000`).

---

## 5. Service & AMC Workflows

### 5.1 Logging & Managing Service Tickets
1. Click **Service & AMC Workflows** (`/service`).
2. **Log Service Ticket**: Click **Log Service Ticket**, enter customer name, site address, equipment serial ID, and issue description. Warranty and AMC coverage are evaluated automatically.
3. **Assign Technician**: Click **Assign Technician** on a ticket card to delegate the job to a field technician.
4. **Record Visit & Deduct Spares**: Click **Record Visit & Deduct Spares** to enter work performed, travel expenses, labor charges, and spare parts used. Consumed spares stock is deducted from inventory.
5. **Serial Replacement**: If a component (e.g. solar inverter) is defective, click **Replace Serial Component**. Enter the faulty serial number and replacement serial number to maintain full serial lineage.

### 5.2 AMC Contracts & Expiry Reminders
- **Create AMC**: Under the **AMC Contracts** tab, click **Create AMC Contract**. Enter validity dates, contract price, and visit limits per year.
- **Renew AMC**: Click **Renew AMC** on an expiring contract to extend coverage and visit limits.
- **Reminders**: View active alerts under the **Reminders & My Jobs** tab for contracts expiring within 30 days or contracts reaching visit limits.

---

## 6. Reports & Executive Dashboard

1. Click **Executive Dashboard** (`/dashboard`) or **Reports & BI** (`/reports`).
2. Access financial and inventory reports:
   - **Sales Summary**: Revenue breakdown by date and payment method.
   - **GSTR-1 & GSTR-3B**: GST return summaries for tax filing.
   - **Stock Valuation**: Inventory balances valued at weighted-average cost.
   - **Party Ageing**: Receivable (AR) and payable (AP) ageing buckets.
   - **Project BI Report**: Budget vs actual material cost, WIP balance, and gross profit margins per solar project site.
3. Click **Export CSV** on any report to save tabular data safely (with automatic formula-injection protection).
