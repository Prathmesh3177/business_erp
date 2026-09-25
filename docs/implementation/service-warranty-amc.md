# Warranty, Technician, Service & AMC Workflows Architecture

## Overview
This document specifies the architecture, data models, workflows, serial lineage tracking, and AMC contract management for Prompt 16 (`P16-service-amc.md`).

## Core Domain Models

### Service Jobs & Visits
- **`ServiceJob`**: Service job ticket representing a breakdown or routine maintenance request. Tracks:
  - Customer party, site address, equipment serial ID, issue description.
  - Technician assignment (`assignedTechnicianUserId`, `assignedTechnicianName`).
  - Coverage flags: `isCoveredByWarranty`, `isCoveredByAmc`.
  - Status: `logged`, `assigned`, `inProgress`, `resolved`, `closed`, `cancelled`.
- **`ServiceJobVisit`**: Logged service visit capturing:
  - Visit date, technician details, work performed notes.
  - Spares consumed (`List<ServiceJobSpareItem>`), travel expenses, labor charges, billable amount.
- **`ServiceJobSpareItem`**: Spare part used during visit with product ID, SKU, quantity, unit cost.

### Serial Replacement & Lineage Tracking
- **`SerialReplacement`**: Records serial swap lineage (`oldSerialId` -> `newSerialId`).
- **Inventory Integration**:
  - Updates old serial record state to `scrapped` / defective.
  - Updates new replacement serial record state to `sold` / installed at site.

### AMC Contracts & Reminders
- **`AmcContract`**: Annual Maintenance Contract containing:
  - Contract number, customer details, site address, start & end dates.
  - Contract value, visit limit per year, completed visits count.
  - Status: `active`, `expired`, `renewed`, `cancelled`.
- **`AmcReminder`**: Deterministic reminder for contract expiry (within 30 days / overdue) or visit limit reaching.

## Application Workflows & Use Cases

1. **`CreateServiceJobUseCase`**:
   - Creates service ticket with unique `jobTicketNumber`.
   - Evaluates active warranty & AMC contract coverage for customer equipment.

2. **`AssignTechnicianUseCase`**:
   - Assigns technician user ID & name to job ticket, updating status to `assigned`.

3. **`RecordServiceVisitUseCase`**:
   - Records technician visit details, labor costs, travel expenses, and billable amounts.
   - Deducts consumed spare parts from storage location stock balance in `InventoryStore`.
   - Updates job status to `resolved` if job is marked complete.

4. **`ReplaceSerializedComponentUseCase`**:
   - Tracks replacement lineage of faulty serialized component (`oldSerialId` -> `newSerialId`).
   - Interacts with `InventoryStore` to update old serial state to `scrapped` and new serial state to `sold`.

5. **`CreateAmcContractUseCase` & `RenewAmcContractUseCase`**:
   - Registers new AMC contracts and handles contract renewals with price/period extensions.

6. **`GenerateAmcRemindersUseCase`**:
   - Evaluates active contracts deterministically to surface visit limit reached alerts and contract expiry reminders within 30 days.

## Drift Data Layer & Schema Version 10
- Schema Version updated to `10`.
- Added Drift tables: `ServiceJobs`, `ServiceJobVisits`, `AmcContracts`, `SerialReplacements`.
- Full persistence and retrieval supported via `ServiceStore` implementation in `FoundationDatabase`.

## UI & Technician Workflows
- **`ServiceAmcPage`**: 3-tab responsive interface:
  - **Service Tickets Tab**: Service ticket dashboard, ticket logging, technician assignment, visit recording with spares deduction, serial component replacement dialogs.
  - **AMC Contracts Tab**: List active/expired AMC contracts, contract creation and renewal workflows.
  - **Reminders & My Jobs Tab**: Real-time alerts for expiring AMC contracts and visit limits.
