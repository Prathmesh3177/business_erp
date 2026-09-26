import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

part 'foundation_database.g.dart';

@DataClassName('OrganizationRow')
class Organizations extends Table {
  TextColumn get id => text()();
  TextColumn get legalName => text()();
  TextColumn get displayName => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('BranchRow')
class Branches extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #id, onDelete: KeyAction.restrict)();
  TextColumn get name => text()();
  TextColumn get timeZone => text()();
  TextColumn get locale => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {id, organizationId},
  ];
}

@DataClassName('FinancialPeriodRow')
class FinancialPeriods extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId =>
      text().references(Organizations, #id, onDelete: KeyAction.restrict)();
  TextColumn get branchId => text()();
  TextColumn get startsOn => text()();
  TextColumn get endsOn => text()();
  BoolColumn get locked => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (branch_id, organization_id) '
        'REFERENCES branches(id, organization_id) ON DELETE RESTRICT',
    'CHECK (ends_on > starts_on)',
  ];
}

@DataClassName('AppMetadataRow')
class AppMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text().unique()();
  TextColumn get fullName => text()();
  TextColumn get roleId => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('UserCredentialRow')
class UserCredentials extends Table {
  TextColumn get userId =>
      text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get passwordHash => text()();
  TextColumn get salt => text()();
  TextColumn get hashAlgorithm => text()();
  IntColumn get iterations => integer()();
  TextColumn get recoveryKeyHash => text()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

@DataClassName('RoleRow')
class Roles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get capabilitiesJson => text()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get username => text()();
  TextColumn get roleId => text()();
  TextColumn get branchId => text()();
  TextColumn get token => text()();
  IntColumn get expiresAtUtcMs => integer()();
  IntColumn get lastActivityUtcMs => integer()();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AuditEventRow')
class AuditEvents extends Table {
  TextColumn get id => text()();
  TextColumn get actorUserId => text()();
  TextColumn get actorUsername => text()();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get detailsJson => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LoginAttemptRow')
class LoginAttempts extends Table {
  TextColumn get username => text()();
  IntColumn get failedAttempts => integer().withDefault(const Constant(0))();
  IntColumn get lockedUntilUtcMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {username};
}

// ---------------------------------------------------------------------
// Schema V3 Tables: Catalog, Parties & Attachments
// ---------------------------------------------------------------------

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get name => text()();
  TextColumn get parentCategoryId => text().nullable()();
  TextColumn get type => text().withDefault(const Constant('other'))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get createdAtUtcMs => integer()();
  IntColumn get updatedAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('BrandRow')
class Brands extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get name => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get createdAtUtcMs => integer()();
  IntColumn get updatedAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('UnitRow')
class Units extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  IntColumn get precisionScale => integer().withDefault(const Constant(0))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProductUnitConversionRow')
class ProductUnitConversions extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get unitId => text()();
  RealColumn get conversionFactor => real()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get sku => text()();
  TextColumn get normalizedSku => text()();
  TextColumn get name => text()();
  TextColumn get categoryId => text()();
  TextColumn get brandId => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get baseUnitId => text()();
  TextColumn get serialPolicy => text().withDefault(const Constant('none'))();
  TextColumn get batchPolicy => text().withDefault(const Constant('none'))();
  RealColumn get minStock => real().withDefault(const Constant(0.0))();
  TextColumn get hsnCode => text()();
  IntColumn get defaultTaxRateBps =>
      integer().withDefault(const Constant(1800))();
  IntColumn get costPricePaise => integer().withDefault(const Constant(0))();
  IntColumn get sellingPricePaise => integer().withDefault(const Constant(0))();
  TextColumn get attributesJson => text().withDefault(const Constant('{}'))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  BoolColumn get isMadeToOrder =>
      boolean().withDefault(const Constant(false))();
  IntColumn get createdAtUtcMs => integer()();
  IntColumn get updatedAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {organizationId, normalizedSku},
  ];
}

@DataClassName('BarcodeRow')
class Barcodes extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get code => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProductSupplierLinkRow')
class ProductSupplierLinks extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get partyId => text()();
  TextColumn get supplierProductCode => text().nullable()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PartyRow')
class Parties extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get name => text()();
  BoolColumn get isCustomer => boolean().withDefault(const Constant(true))();
  BoolColumn get isSupplier => boolean().withDefault(const Constant(false))();
  TextColumn get gstin => text().nullable()();
  TextColumn get pan => text().nullable()();
  IntColumn get paymentTermsDays => integer().withDefault(const Constant(30))();
  IntColumn get creditLimitPaise => integer().withDefault(const Constant(0))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get createdAtUtcMs => integer()();
  IntColumn get updatedAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PartyAddressRow')
class PartyAddresses extends Table {
  TextColumn get id => text()();
  TextColumn get partyId => text()();
  TextColumn get addressLine1 => text()();
  TextColumn get addressLine2 => text().nullable()();
  TextColumn get city => text()();
  TextColumn get state => text()();
  TextColumn get pincode => text()();
  TextColumn get stateCode => text()();
  BoolColumn get isBilling => boolean().withDefault(const Constant(true))();
  BoolColumn get isShipping => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PartyContactRow')
class PartyContacts extends Table {
  TextColumn get id => text()();
  TextColumn get partyId => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AttachmentRow')
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get fileName => text()();
  TextColumn get mimeType => text()();
  IntColumn get fileSizeBytes => integer()();
  TextColumn get sha256Hash => text()();
  TextColumn get storagePath => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AttachmentLinkRow')
class AttachmentLinks extends Table {
  TextColumn get id => text()();
  TextColumn get attachmentId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get linkType => text().withDefault(const Constant('document'))();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ImportCommandRow')
class ImportCommands extends Table {
  TextColumn get id => text()();
  TextColumn get commandId => text().unique()();
  TextColumn get entityType => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------
// Schema V4 Tables: Money, Tax & Chart of Accounts
// ---------------------------------------------------------------------

@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get controlRole => text().withDefault(const Constant('none'))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {organizationId, code},
  ];
}

@DataClassName('JournalEntryRow')
class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get documentId => text()();
  IntColumn get postingDateUtcMs => integer()();
  TextColumn get reversalOfId => text().nullable()();
  TextColumn get memo => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('JournalLineRow')
class JournalLines extends Table {
  TextColumn get id => text()();
  TextColumn get journalEntryId =>
      text().references(JournalEntries, #id, onDelete: KeyAction.cascade)();
  TextColumn get accountId => text()();
  IntColumn get debitPaise => integer().withDefault(const Constant(0))();
  IntColumn get creditPaise => integer().withDefault(const Constant(0))();
  TextColumn get partyId => text().nullable()();
  TextColumn get projectId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DocumentHeaderRow')
class DocumentHeaders extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get kind => text()();
  TextColumn get status => text().withDefault(const Constant('posted'))();
  IntColumn get businessDateUtcMs => integer()();
  TextColumn get documentNumber => text()();
  TextColumn get fiscalYear => text()();
  TextColumn get sourceCommandId => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DocumentSequenceRow')
class DocumentSequences extends Table {
  TextColumn get id => text()();
  TextColumn get registrationId => text()();
  TextColumn get fiscalYear => text()();
  TextColumn get series => text()();
  IntColumn get nextValue => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {registrationId, fiscalYear, series},
  ];
}

@DataClassName('CommandResultRow')
class CommandResults extends Table {
  TextColumn get id => text()();
  TextColumn get commandId => text().unique()();
  TextColumn get payloadHash => text()();
  TextColumn get resultJson => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------
// Schema V5 Tables: Stock Locations, Movements, Balances, Serials & Batches
// ---------------------------------------------------------------------

@DataClassName('LocationRow')
class Locations extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get name => text()();
  TextColumn get type => text().withDefault(const Constant('sellable'))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('StockMovementRow')
class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get documentId => text()();
  TextColumn get lineId => text()();
  TextColumn get productId => text()();
  TextColumn get locationId => text()();
  TextColumn get batchId => text().nullable()();
  IntColumn get quantityMicroUnits => integer()();
  IntColumn get valueDeltaPaise => integer()();
  IntColumn get costSnapshotMicroRupees => integer()();
  TextColumn get movementKind => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('StockBalanceRow')
class StockBalances extends Table {
  TextColumn get productId => text()();
  TextColumn get locationId => text()();
  IntColumn get quantityMicroUnits =>
      integer().withDefault(const Constant(0))();
  IntColumn get valuePaise => integer().withDefault(const Constant(0))();
  IntColumn get updatedAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {productId, locationId};
}

@DataClassName('SerialRecordRow')
class Serials extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get productId => text()();
  TextColumn get serialNumber => text()();
  TextColumn get state => text().withDefault(const Constant('inStock'))();
  TextColumn get locationId => text().nullable()();
  TextColumn get batchId => text().nullable()();
  IntColumn get updatedAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {organizationId, productId, serialNumber},
  ];
}

@DataClassName('SerialEventRow')
class SerialEvents extends Table {
  TextColumn get id => text()();
  TextColumn get serialId =>
      text().references(Serials, #id, onDelete: KeyAction.cascade)();
  TextColumn get fromState => text()();
  TextColumn get toState => text()();
  TextColumn get documentId => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('BatchRecordRow')
class Batches extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get productId => text()();
  TextColumn get lotNumber => text()();
  IntColumn get expiryDateUtcMs => integer().nullable()();
  TextColumn get supplierPartyId => text().nullable()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ReservationRow')
class Reservations extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get productId => text()();
  IntColumn get quantityMicroUnits => integer()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get expiresAtUtcMs => integer().nullable()();
  TextColumn get projectId => text().nullable()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('StockAdjustmentRow')
class StockAdjustments extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get productId => text()();
  TextColumn get locationId => text()();
  IntColumn get quantityDeltaMicroUnits => integer()();
  IntColumn get valueDeltaPaise => integer()();
  TextColumn get reason => text()();
  TextColumn get approvedByUserId => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------
// Schema V6 Tables: Procurement (Purchases & Payments)
// ---------------------------------------------------------------------

@DataClassName('PurchaseHeaderRow')
class PurchaseHeaders extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get documentHeaderId => text()();
  TextColumn get supplierId => text()();
  TextColumn get supplierName => text()();
  TextColumn get externalInvoiceNumber => text()();
  TextColumn get normalizedExternalInvoiceNumber => text()();
  IntColumn get invoiceDateMs => integer()();
  TextColumn get locationId => text()();
  TextColumn get status => text().withDefault(const Constant('posted'))();
  IntColumn get subtotalPaise => integer()();
  IntColumn get landedCostTotalPaise => integer()();
  IntColumn get totalTaxPaise => integer()();
  IntColumn get netTotalPaise => integer()();
  IntColumn get amountPaidPaise => integer()();
  IntColumn get balanceDuePaise => integer()();
  IntColumn get createdAtUtcMs => integer()();
  TextColumn get paymentTerms => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PurchaseLineRow')
class PurchaseLines extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get sku => text()();
  IntColumn get quantityMicroUnits => integer()();
  IntColumn get unitPurchasePriceMicroRupees => integer()();
  IntColumn get discountPaise => integer()();
  TextColumn get taxSnapshotJson => text()();
  IntColumn get landedCostAllocationPaise => integer()();
  IntColumn get netTotalPaise => integer()();
  TextColumn get serialsJson => text().withDefault(const Constant('[]'))();
  TextColumn get batchLot => text().nullable()();
  IntColumn get expiryDateMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PaymentRow')
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get partyId => text()();
  TextColumn get partyName => text()();
  TextColumn get direction => text()();
  TextColumn get paymentMethod => text()();
  IntColumn get amountPaise => integer()();
  IntColumn get paymentDateMs => integer()();
  IntColumn get createdAtUtcMs => integer()();
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PaymentAllocationRow')
class PaymentAllocations extends Table {
  TextColumn get id => text()();
  TextColumn get paymentId => text()();
  TextColumn get documentId => text()();
  IntColumn get allocatedAmountPaise => integer()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------
// Schema V7 Tables: Sales & Counter POS
// ---------------------------------------------------------------------

@DataClassName('SaleHeaderRow')
class SaleHeaders extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get documentHeaderId => text()();
  TextColumn get customerPartyId => text()();
  TextColumn get customerName => text()();
  IntColumn get businessDateMs => integer()();
  TextColumn get locationId => text()();
  TextColumn get status => text().withDefault(const Constant('posted'))();
  IntColumn get subtotalPaise => integer()();
  IntColumn get allocatedDiscountPaise => integer()();
  IntColumn get totalTaxPaise => integer()();
  IntColumn get grandTotalPaise => integer()();
  IntColumn get amountPaidPaise => integer()();
  IntColumn get balanceDuePaise => integer()();
  IntColumn get createdAtUtcMs => integer()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SaleLineRow')
class SaleLines extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get sku => text()();
  TextColumn get hsnCode => text()();
  TextColumn get baseUnit => text()();
  IntColumn get quantityMicroUnits => integer()();
  IntColumn get unitPriceMicroRupees => integer()();
  IntColumn get lineDiscountPaise => integer()();
  TextColumn get taxSnapshotJson => text()();
  IntColumn get costSnapshotMicroRupees => integer()();
  IntColumn get netTotalPaise => integer()();
  TextColumn get serialsJson => text().withDefault(const Constant('[]'))();
  TextColumn get batchLot => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SaleDraftRow')
class SaleDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get customerPartyId => text().nullable()();
  TextColumn get customerName => text()();
  TextColumn get linesJson => text()();
  IntColumn get updatedAtUtcMs => integer()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SaleOrderRow')
class SaleOrders extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get customerPartyId => text()();
  TextColumn get customerName => text()();
  TextColumn get customerPhone => text().withDefault(const Constant(''))();
  IntColumn get orderDateMs => integer()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get quotationId => text().nullable()();
  TextColumn get saleHeaderId => text().nullable()();
  IntColumn get grandTotalPaise => integer()();
  IntColumn get expectedDeliveryDateMs => integer().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SaleOrderLineRow')
class SaleOrderLines extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  IntColumn get quantityMicroUnits => integer()();
  IntColumn get unitPriceMicroRupees => integer()();
  IntColumn get taxRateBps => integer()();
  BoolColumn get isInStock => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('WarrantyRow')
class Warranties extends Table {
  TextColumn get id => text()();
  TextColumn get serialId => text()();
  TextColumn get productId => text()();
  TextColumn get serialNumber => text()();
  TextColumn get partyId => text()();
  TextColumn get saleDocumentId => text()();
  IntColumn get startDateMs => integer()();
  IntColumn get endDateMs => integer()();
  TextColumn get termsSnapshot => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------
// Schema V8 Tables: Payments, Returns, Expenses & Cash Sessions
// ---------------------------------------------------------------------

@DataClassName('SalesReturnHeaderRow')
class SalesReturnHeaders extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get documentHeaderId => text()();
  TextColumn get originalSaleId => text()();
  TextColumn get customerPartyId => text()();
  TextColumn get customerName => text()();
  IntColumn get returnDateMs => integer()();
  TextColumn get locationId => text()();
  TextColumn get status => text().withDefault(const Constant('posted'))();
  IntColumn get subtotalPaise => integer()();
  IntColumn get totalTaxPaise => integer()();
  IntColumn get grandTotalPaise => integer()();
  IntColumn get refundedAmountPaise => integer()();
  IntColumn get createdAtUtcMs => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SalesReturnLineRow')
class SalesReturnLines extends Table {
  TextColumn get id => text()();
  TextColumn get salesReturnId => text()();
  TextColumn get saleLineId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get sku => text()();
  IntColumn get quantityMicroUnits => integer()();
  IntColumn get unitPriceMicroRupees => integer()();
  IntColumn get lineDiscountPaise => integer()();
  TextColumn get taxSnapshotJson => text()();
  IntColumn get costSnapshotMicroRupees => integer()();
  IntColumn get netTotalPaise => integer()();
  TextColumn get serialsJson => text().withDefault(const Constant('[]'))();
  TextColumn get disposition =>
      text().withDefault(const Constant('returnToStock'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PurchaseReturnHeaderRow')
class PurchaseReturnHeaders extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get documentHeaderId => text()();
  TextColumn get originalPurchaseId => text()();
  TextColumn get supplierId => text()();
  TextColumn get supplierName => text()();
  IntColumn get returnDateMs => integer()();
  TextColumn get locationId => text()();
  TextColumn get status => text().withDefault(const Constant('posted'))();
  IntColumn get subtotalPaise => integer()();
  IntColumn get totalTaxPaise => integer()();
  IntColumn get grandTotalPaise => integer()();
  IntColumn get createdAtUtcMs => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PurchaseReturnLineRow')
class PurchaseReturnLines extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseReturnId => text()();
  TextColumn get purchaseLineId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get sku => text()();
  IntColumn get quantityMicroUnits => integer()();
  IntColumn get unitPurchasePriceMicroRupees => integer()();
  TextColumn get taxSnapshotJson => text()();
  IntColumn get netTotalPaise => integer()();
  TextColumn get serialsJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ExpenseCategoryRow')
class ExpenseCategories extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get name => text()();
  TextColumn get accountCode => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ExpenseEntryRow')
class ExpenseEntries extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get categoryId => text()();
  TextColumn get categoryName => text()();
  TextColumn get accountCode => text()();
  IntColumn get amountPaise => integer()();
  IntColumn get expenseDateMs => integer()();
  TextColumn get paymentMethod => text()();
  IntColumn get createdAtUtcMs => integer()();
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CashSessionRow')
class CashSessions extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get userId => text()();
  TextColumn get username => text()();
  IntColumn get openedAtUtcMs => integer()();
  IntColumn get closedAtUtcMs => integer().nullable()();
  IntColumn get openingCashPaise => integer()();
  IntColumn get expectedCashPaise => integer()();
  IntColumn get countedCashPaise => integer()();
  IntColumn get variancePaise => integer()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------
// Schema V9 Tables: Projects, Quotations & Material Issues
// ---------------------------------------------------------------------

@DataClassName('QuotationHeaderRow')
class Quotations extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get quotationNumber => text()();
  IntColumn get revisionNumber => integer()();
  TextColumn get customerPartyId => text()();
  TextColumn get customerName => text()();
  IntColumn get validUntilMs => integer()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  IntColumn get subtotalPaise => integer()();
  IntColumn get allocatedDiscountPaise => integer()();
  IntColumn get totalTaxPaise => integer()();
  IntColumn get grandTotalPaise => integer()();
  IntColumn get installationChargesPaise => integer()();
  TextColumn get termsSnapshot => text()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('QuotationLineRow')
class QuotationLines extends Table {
  TextColumn get id => text()();
  TextColumn get quotationId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get sku => text()();
  TextColumn get hsnCode => text()();
  IntColumn get quantityMicroUnits => integer()();
  IntColumn get unitPriceMicroRupees => integer()();
  IntColumn get lineDiscountPaise => integer()();
  TextColumn get taxSnapshotJson => text()();
  IntColumn get netTotalPaise => integer()();
  BoolColumn get isServiceLine =>
      boolean().withDefault(const Constant(false))();
  TextColumn get bomSnapshotJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SolarProjectRow')
class SolarProjects extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get projectNumber => text()();
  TextColumn get name => text()();
  TextColumn get customerPartyId => text()();
  TextColumn get customerName => text()();
  TextColumn get siteAddress => text()();
  TextColumn get acceptedQuotationId => text()();
  IntColumn get acceptedQuotationRevision => integer()();
  TextColumn get status => text().withDefault(const Constant('inProgress'))();
  IntColumn get budgetMaterialsPaise => integer()();
  IntColumn get budgetLaborPaise => integer()();
  IntColumn get actualMaterialsPaise => integer()();
  IntColumn get actualExpensesPaise => integer()();
  IntColumn get invoicedPaise => integer()();
  IntColumn get wipBalancePaise => integer()();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProjectMaterialIssueRow')
class ProjectMaterialIssues extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get projectId => text()();
  TextColumn get locationId => text()();
  IntColumn get issueDateMs => integer()();
  IntColumn get totalCostPaise => integer()();
  IntColumn get createdAtUtcMs => integer()();
  TextColumn get notes => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ProjectMaterialIssueLineRow')
class ProjectMaterialIssueLines extends Table {
  TextColumn get id => text()();
  TextColumn get issueId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get sku => text()();
  IntColumn get quantityMicroUnits => integer()();
  IntColumn get costSnapshotMicroRupees => integer()();
  TextColumn get serialsJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------
// Schema V10 Tables: Service Jobs, Visits, AMC Contracts & Serial Replacements
// ---------------------------------------------------------------------

@DataClassName('ServiceJobRow')
class ServiceJobs extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get jobTicketNumber => text()();
  TextColumn get customerPartyId => text()();
  TextColumn get customerName => text()();
  TextColumn get siteAddress => text()();
  TextColumn get equipmentSerialId => text()();
  TextColumn get issueDescription => text()();
  TextColumn get assignedTechnicianUserId => text().nullable()();
  TextColumn get assignedTechnicianName => text().nullable()();
  BoolColumn get isCoveredByWarranty =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isCoveredByAmc =>
      boolean().withDefault(const Constant(false))();
  TextColumn get status => text().withDefault(const Constant('logged'))();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ServiceJobVisitRow')
class ServiceJobVisits extends Table {
  TextColumn get id => text()();
  TextColumn get jobId => text()();
  TextColumn get technicianUserId => text()();
  TextColumn get technicianName => text()();
  IntColumn get visitDateMs => integer()();
  TextColumn get workPerformed => text()();
  IntColumn get travelExpensesPaise => integer()();
  IntColumn get laborCostPaise => integer()();
  IntColumn get billableAmountPaise => integer()();
  TextColumn get sparesUsedJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AmcContractRow')
class AmcContracts extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get branchId => text()();
  TextColumn get contractNumber => text()();
  TextColumn get customerPartyId => text()();
  TextColumn get customerName => text()();
  TextColumn get siteAddress => text()();
  IntColumn get startDateMs => integer()();
  IntColumn get endDateMs => integer()();
  IntColumn get contractValuePaise => integer()();
  IntColumn get visitLimitPerYear => integer()();
  IntColumn get visitsCompleted => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get createdAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SerialReplacementRow')
class SerialReplacements extends Table {
  TextColumn get id => text()();
  TextColumn get jobId => text()();
  TextColumn get oldSerialId => text()();
  TextColumn get newSerialId => text()();
  IntColumn get replacementDateMs => integer()();
  TextColumn get reason => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('KitRow')
class Kits extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  RealColumn get capacityKw => real().withDefault(const Constant(0))();
  IntColumn get installationChargesPaise => integer().withDefault(const Constant(0))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get createdAtUtcMs => integer()();
  IntColumn get updatedAtUtcMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('KitLineRow')
class KitLines extends Table {
  TextColumn get id => text()();
  TextColumn get kitId => text()();
  TextColumn get productId => text()();
  IntColumn get quantityMicroUnits => integer()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Organizations,
    Branches,
    FinancialPeriods,
    AppMetadata,
    Users,
    UserCredentials,
    Roles,
    Sessions,
    AuditEvents,
    LoginAttempts,
    Categories,
    Brands,
    Units,
    ProductUnitConversions,
    Products,
    Barcodes,
    ProductSupplierLinks,
    Parties,
    PartyAddresses,
    PartyContacts,
    Attachments,
    AttachmentLinks,
    ImportCommands,
    Accounts,
    JournalEntries,
    JournalLines,
    DocumentHeaders,
    DocumentSequences,
    CommandResults,
    Locations,
    StockMovements,
    StockBalances,
    Serials,
    SerialEvents,
    Batches,
    Reservations,
    StockAdjustments,
    PurchaseHeaders,
    PurchaseLines,
    Payments,
    PaymentAllocations,
    SaleHeaders,
    SaleLines,
    SaleDrafts,
    SaleOrders,
    SaleOrderLines,
    Warranties,
    SalesReturnHeaders,
    SalesReturnLines,
    PurchaseReturnHeaders,
    PurchaseReturnLines,
    ExpenseCategories,
    ExpenseEntries,
    CashSessions,
    Quotations,
    QuotationLines,
    SolarProjects,
    ProjectMaterialIssues,
    ProjectMaterialIssueLines,
    ServiceJobs,
    ServiceJobVisits,
    AmcContracts,
    SerialReplacements,
    Kits,
    KitLines,
  ],
)
final class FoundationDatabase extends _$FoundationDatabase
    implements
        FoundationStore,
        IdentityStore,
        AuditStore,
        CatalogStore,
        PartyStore,
        AttachmentStore,
        AccountingStore,
        InventoryStore,
        PurchasingStore,
        SalesStore,
        FinanceStore,
        ProjectStore,
        KitStore,
        ServiceStore {
  FoundationDatabase._(super.executor, this._file, this._key);

  final File _file;
  final List<int> _key;

  static FoundationDatabase open({
    required File file,
    List<int> key = const [],
  }) {
    if (key.isNotEmpty && key.length != 32) {
      throw const SecurityFailure(
        'database.invalid_key_length',
        'The protected database key is invalid.',
      );
    }
    file.parent.createSync(recursive: true);
    final immutableKey = List<int>.unmodifiable(key);
    final executor = NativeDatabase.createInBackground(
      file,
      setup: (database) =>
          _configureEncryptedConnection(database, immutableKey),
    );
    return FoundationDatabase._(executor, file, immutableKey);
  }

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _seedDefaultRoles();
      await _seedDefaultUnitsAndCategories();
      await _seedDefaultAccounts();
      await _seedDefaultLocations();
      await _seedDefaultExpenseCategories();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 1) {
        await migrator.createAll();
      }
      if (from < 2) {
        await migrator.createTable(users);
        await migrator.createTable(userCredentials);
        await migrator.createTable(roles);
        await migrator.createTable(sessions);
        await migrator.createTable(auditEvents);
        await migrator.createTable(loginAttempts);
        await _seedDefaultRoles();
      }
      if (from < 3) {
        await migrator.createTable(categories);
        await migrator.createTable(brands);
        await migrator.createTable(units);
        await migrator.createTable(productUnitConversions);
        await migrator.createTable(products);
        await migrator.createTable(barcodes);
        await migrator.createTable(productSupplierLinks);
        await migrator.createTable(parties);
        await migrator.createTable(partyAddresses);
        await migrator.createTable(partyContacts);
        await migrator.createTable(attachments);
        await migrator.createTable(attachmentLinks);
        await migrator.createTable(importCommands);
        await _seedDefaultUnitsAndCategories();
      }
      if (from < 4) {
        await migrator.createTable(accounts);
        await migrator.createTable(journalEntries);
        await migrator.createTable(journalLines);
        await migrator.createTable(documentHeaders);
        await migrator.createTable(documentSequences);
        await migrator.createTable(commandResults);
        await _seedDefaultAccounts();
      }
      if (from < 5) {
        await migrator.createTable(locations);
        await migrator.createTable(stockMovements);
        await migrator.createTable(stockBalances);
        await migrator.createTable(serials);
        await migrator.createTable(serialEvents);
        await migrator.createTable(batches);
        await migrator.createTable(reservations);
        await migrator.createTable(stockAdjustments);
        await _seedDefaultLocations();
      }
      if (from < 6) {
        await migrator.createTable(purchaseHeaders);
        await migrator.createTable(purchaseLines);
        await migrator.createTable(payments);
        await migrator.createTable(paymentAllocations);
      }
      if (from < 7) {
        await migrator.createTable(saleHeaders);
        await migrator.createTable(saleLines);
        await migrator.createTable(saleDrafts);
        await migrator.createTable(warranties);
      }
      if (from < 8) {
        await migrator.createTable(salesReturnHeaders);
        await migrator.createTable(salesReturnLines);
        await migrator.createTable(purchaseReturnHeaders);
        await migrator.createTable(purchaseReturnLines);
        await migrator.createTable(expenseCategories);
        await migrator.createTable(expenseEntries);
        await migrator.createTable(cashSessions);
        await _seedDefaultExpenseCategories();
      }
      if (from < 9) {
        await migrator.createTable(quotations);
        await migrator.createTable(quotationLines);
        await migrator.createTable(solarProjects);
        await migrator.createTable(projectMaterialIssues);
        await migrator.createTable(projectMaterialIssueLines);
      }
      if (from < 10) {
        await migrator.createTable(serviceJobs);
        await migrator.createTable(serviceJobVisits);
        await migrator.createTable(amcContracts);
        await migrator.createTable(serialReplacements);
      }
      if (from < 11) {
        await migrator.addColumn(products, products.isMadeToOrder);
      }
      if (from < 12) {
        await migrator.createTable(saleOrders);
        await migrator.createTable(saleOrderLines);
      }
      if (from < 13) {
        await migrator.createTable(kits);
        await migrator.createTable(kitLines);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _seedDefaultUnitsAndCategories() async {
    const orgId = 'default_org';
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final defaultUnits = [
      UnitsCompanion.insert(
        id: 'unit_pcs',
        organizationId: orgId,
        code: 'Pcs',
        name: 'Pieces',
        precisionScale: const Value(0),
      ),
      UnitsCompanion.insert(
        id: 'unit_nos',
        organizationId: orgId,
        code: 'Nos',
        name: 'Numbers',
        precisionScale: const Value(0),
      ),
      UnitsCompanion.insert(
        id: 'unit_mtr',
        organizationId: orgId,
        code: 'Mtr',
        name: 'Meters',
        precisionScale: const Value(2),
      ),
      UnitsCompanion.insert(
        id: 'unit_set',
        organizationId: orgId,
        code: 'Set',
        name: 'Sets',
        precisionScale: const Value(0),
      ),
      UnitsCompanion.insert(
        id: 'unit_kg',
        organizationId: orgId,
        code: 'Kg',
        name: 'Kilograms',
        precisionScale: const Value(3),
      ),
    ];

    for (final unitCompanion in defaultUnits) {
      await into(units).insertOnConflictUpdate(unitCompanion);
    }

    final defaultCategories = [
      CategoriesCompanion.insert(
        id: 'cat_panels',
        organizationId: orgId,
        name: 'Solar Panels',
        type: const Value('solarPanel'),
        createdAtUtcMs: nowMs,
        updatedAtUtcMs: nowMs,
      ),
      CategoriesCompanion.insert(
        id: 'cat_inverters',
        organizationId: orgId,
        name: 'Solar Inverters',
        type: const Value('solarInverter'),
        createdAtUtcMs: nowMs,
        updatedAtUtcMs: nowMs,
      ),
      CategoriesCompanion.insert(
        id: 'cat_batteries',
        organizationId: orgId,
        name: 'Solar Batteries',
        type: const Value('solarBattery'),
        createdAtUtcMs: nowMs,
        updatedAtUtcMs: nowMs,
      ),
      CategoriesCompanion.insert(
        id: 'cat_cables',
        organizationId: orgId,
        name: 'Solar Cables & Wires',
        type: const Value('solarCable'),
        createdAtUtcMs: nowMs,
        updatedAtUtcMs: nowMs,
      ),
      CategoriesCompanion.insert(
        id: 'cat_pumps',
        organizationId: orgId,
        name: 'Solar Pumps',
        type: const Value('solarPump'),
        createdAtUtcMs: nowMs,
        updatedAtUtcMs: nowMs,
      ),
    ];

    for (final catCompanion in defaultCategories) {
      await into(categories).insertOnConflictUpdate(catCompanion);
    }
  }

  Future<void> _seedDefaultRoles() async {
    for (final role in Role.defaultRoles) {
      await into(roles).insertOnConflictUpdate(
        RolesCompanion.insert(
          id: role.id,
          name: role.name,
          capabilitiesJson: jsonEncode(
            role.capabilities.map((c) => c.identifier).toList(),
          ),
          isSystem: Value(role.isSystem),
          createdAtUtcMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  Future<void> _seedDefaultExpenseCategories() async {
    for (final cat in ExpenseCategory.defaultCategories) {
      await saveExpenseCategory(cat);
    }
  }

  @override
  Future<FoundationIdentity?> loadIdentity() async {
    final rows = await customSelect('''
      SELECT
        o.id AS organization_id,
        o.legal_name,
        o.display_name,
        o.created_at_utc_ms AS organization_created_at,
        b.id AS branch_id,
        b.name AS branch_name,
        b.time_zone,
        b.locale,
        b.created_at_utc_ms AS branch_created_at,
        f.id AS period_id,
        f.starts_on,
        f.ends_on,
        f.created_at_utc_ms AS period_created_at
      FROM organizations o
      JOIN branches b ON b.organization_id = o.id
      JOIN financial_periods f
        ON f.organization_id = o.id AND f.branch_id = b.id
      ORDER BY o.created_at_utc_ms, b.created_at_utc_ms, f.starts_on
      LIMIT 1
    ''').getSingleOrNull();
    if (rows == null) return null;
    final data = rows.data;
    final organizationId = OrganizationId(data['organization_id']! as String);
    final branchId = BranchId(data['branch_id']! as String);
    return FoundationIdentity(
      organization: Organization(
        id: organizationId,
        legalName: data['legal_name']! as String,
        displayName: data['display_name']! as String,
        createdAtUtc: _fromEpoch(data['organization_created_at']! as int),
      ),
      branch: Branch(
        id: branchId,
        organizationId: organizationId,
        name: data['branch_name']! as String,
        timeZone: data['time_zone']! as String,
        locale: data['locale']! as String,
        createdAtUtc: _fromEpoch(data['branch_created_at']! as int),
      ),
      financialPeriod: FinancialPeriod(
        id: FinancialPeriodId(data['period_id']! as String),
        organizationId: organizationId,
        branchId: branchId,
        startsOn: DateTime.parse(data['starts_on']! as String),
        endsOn: DateTime.parse(data['ends_on']! as String),
        createdAtUtc: _fromEpoch(data['period_created_at']! as int),
      ),
    );
  }

  @override
  Future<T> inTransaction<T>(
    Future<T> Function(FoundationTransaction transaction) action,
  ) {
    return transaction(() => action(_FoundationDriftTransaction(this)));
  }

  // --- IdentityStore implementation ---

  @override
  Future<User?> getUserByUsername(String username) async {
    final row =
        await (select(users)
              ..where((u) => u.username.equals(username.toLowerCase())))
            .getSingleOrNull();
    if (row == null) return null;
    return User(
      id: UserId(row.id),
      username: row.username,
      fullName: row.fullName,
      roleId: row.roleId,
      isActive: row.isActive,
      createdAtUtc: _fromEpoch(row.createdAtUtcMs),
    );
  }

  @override
  Future<User?> getUserById(UserId id) async {
    final row = await (select(
      users,
    )..where((u) => u.id.equals(id.value))).getSingleOrNull();
    if (row == null) return null;
    return User(
      id: UserId(row.id),
      username: row.username,
      fullName: row.fullName,
      roleId: row.roleId,
      isActive: row.isActive,
      createdAtUtc: _fromEpoch(row.createdAtUtcMs),
    );
  }

  @override
  Future<UserCredential?> getUserCredential(UserId id) async {
    final row = await (select(
      userCredentials,
    )..where((c) => c.userId.equals(id.value))).getSingleOrNull();
    if (row == null) return null;
    return UserCredential(
      userId: UserId(row.userId),
      passwordHash: row.passwordHash,
      salt: row.salt,
      hashAlgorithm: row.hashAlgorithm,
      iterations: row.iterations,
      recoveryKeyHash: row.recoveryKeyHash,
    );
  }

  @override
  Future<List<User>> getAllUsers() async {
    final rows = await select(users).get();
    return rows
        .map(
          (r) => User(
            id: UserId(r.id),
            username: r.username,
            fullName: r.fullName,
            roleId: r.roleId,
            isActive: r.isActive,
            createdAtUtc: _fromEpoch(r.createdAtUtcMs),
          ),
        )
        .toList();
  }

  @override
  Future<void> createUser(User user, UserCredential credential) async {
    await transaction(() async {
      await into(users).insert(
        UsersCompanion.insert(
          id: user.id.value,
          username: user.username,
          fullName: user.fullName,
          roleId: user.roleId,
          isActive: Value(user.isActive),
          createdAtUtcMs: user.createdAtUtc.millisecondsSinceEpoch,
        ),
      );
      await into(userCredentials).insert(
        UserCredentialsCompanion.insert(
          userId: credential.userId.value,
          passwordHash: credential.passwordHash,
          salt: credential.salt,
          hashAlgorithm: credential.hashAlgorithm,
          iterations: credential.iterations,
          recoveryKeyHash: credential.recoveryKeyHash,
        ),
      );
    });
  }

  @override
  Future<void> updateUserStatus(UserId id, bool isActive) async {
    await (update(users)..where((u) => u.id.equals(id.value))).write(
      UsersCompanion(isActive: Value(isActive)),
    );
  }

  @override
  Future<void> updateUserRole(UserId id, String roleId) async {
    await (update(users)..where((u) => u.id.equals(id.value))).write(
      UsersCompanion(roleId: Value(roleId)),
    );
  }

  @override
  Future<void> updateUserCredential(
    UserId id,
    UserCredential credential,
  ) async {
    await (update(
      userCredentials,
    )..where((c) => c.userId.equals(id.value))).write(
      UserCredentialsCompanion(
        passwordHash: Value(credential.passwordHash),
        salt: Value(credential.salt),
        hashAlgorithm: Value(credential.hashAlgorithm),
        iterations: Value(credential.iterations),
        recoveryKeyHash: Value(credential.recoveryKeyHash),
      ),
    );
  }

  @override
  Future<Role?> getRoleById(String roleId) async {
    final row = await (select(
      roles,
    )..where((r) => r.id.equals(roleId))).getSingleOrNull();
    if (row == null) return null;
    final capList = (jsonDecode(row.capabilitiesJson) as List)
        .map((e) => Capability.fromIdentifier(e as String))
        .whereType<Capability>()
        .toSet();
    return Role(
      id: row.id,
      name: row.name,
      capabilities: capList,
      isSystem: row.isSystem,
    );
  }

  @override
  Future<List<Role>> getAllRoles() async {
    final rows = await select(roles).get();
    return rows.map((row) {
      final capList = (jsonDecode(row.capabilitiesJson) as List)
          .map((e) => Capability.fromIdentifier(e as String))
          .whereType<Capability>()
          .toSet();
      return Role(
        id: row.id,
        name: row.name,
        capabilities: capList,
        isSystem: row.isSystem,
      );
    }).toList();
  }

  @override
  Future<void> createRole(Role role) async {
    await into(roles).insert(
      RolesCompanion.insert(
        id: role.id,
        name: role.name,
        capabilitiesJson: jsonEncode(
          role.capabilities.map((c) => c.identifier).toList(),
        ),
        isSystem: Value(role.isSystem),
        createdAtUtcMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<void> saveSession(UserSession session) async {
    await into(sessions).insertOnConflictUpdate(
      SessionsCompanion.insert(
        id: session.id.value,
        userId: session.userId.value,
        username: session.username,
        roleId: session.roleId,
        branchId: session.branchId.value,
        token: session.token,
        expiresAtUtcMs: session.expiresAtUtc.millisecondsSinceEpoch,
        lastActivityUtcMs: session.lastActivityAtUtc.millisecondsSinceEpoch,
        isLocked: Value(session.isLocked),
        createdAtUtcMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<UserSession?> getSessionById(SessionId id) async {
    final row = await (select(
      sessions,
    )..where((s) => s.id.equals(id.value))).getSingleOrNull();
    if (row == null) return null;
    final role = await getRoleById(row.roleId) ?? Role.admin;
    return UserSession(
      id: SessionId(row.id),
      userId: UserId(row.userId),
      username: row.username,
      roleId: row.roleId,
      branchId: BranchId(row.branchId),
      capabilities: role.capabilities,
      token: row.token,
      expiresAtUtc: _fromEpoch(row.expiresAtUtcMs),
      lastActivityAtUtc: _fromEpoch(row.lastActivityUtcMs),
      isLocked: row.isLocked,
    );
  }

  @override
  Future<void> deleteSession(SessionId id) async {
    await (delete(sessions)..where((s) => s.id.equals(id.value))).go();
  }

  @override
  Future<LoginThrottleStatus> getThrottleStatus(
    String username,
    DateTime nowUtc,
  ) async {
    final row =
        await (select(loginAttempts)
              ..where((a) => a.username.equals(username.toLowerCase())))
            .getSingleOrNull();
    if (row == null) {
      return const LoginThrottleStatus(failedAttempts: 0, isLockedOut: false);
    }
    final lockedUntil = row.lockedUntilUtcMs != null
        ? _fromEpoch(row.lockedUntilUtcMs!)
        : null;
    final isLockedOut = lockedUntil != null && nowUtc.isBefore(lockedUntil);
    return LoginThrottleStatus(
      failedAttempts: row.failedAttempts,
      isLockedOut: isLockedOut,
      lockedUntilUtc: lockedUntil,
    );
  }

  @override
  Future<void> recordLoginAttempt(
    String username,
    bool success,
    DateTime nowUtc,
  ) async {
    final lowerUsername = username.toLowerCase();
    if (success) {
      await (delete(
        loginAttempts,
      )..where((a) => a.username.equals(lowerUsername))).go();
      return;
    }

    final current = await (select(
      loginAttempts,
    )..where((a) => a.username.equals(lowerUsername))).getSingleOrNull();
    final newCount = (current?.failedAttempts ?? 0) + 1;

    DateTime? lockedUntil;
    if (newCount >= 5) {
      // 15-minute lockout after 5 consecutive failures
      lockedUntil = nowUtc.add(const Duration(minutes: 15));
    }

    await into(loginAttempts).insertOnConflictUpdate(
      LoginAttemptsCompanion.insert(
        username: lowerUsername,
        failedAttempts: Value(newCount),
        lockedUntilUtcMs: Value(lockedUntil?.millisecondsSinceEpoch),
      ),
    );
  }

  // --- AuditStore implementation ---

  @override
  Future<void> appendAuditEvent(AuditEvent event) async {
    await into(auditEvents).insert(
      AuditEventsCompanion.insert(
        id: event.id.value,
        actorUserId: event.actorUserId.value,
        actorUsername: event.actorUsername,
        action: event.action,
        entityType: event.entityType,
        entityId: event.entityId,
        detailsJson: event.detailsJson,
        createdAtUtcMs: event.createdAtUtc.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<List<AuditEvent>> getAuditEvents({
    int limit = 100,
    int offset = 0,
  }) async {
    final query = select(auditEvents)
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.createdAtUtcMs, mode: OrderingMode.desc),
      ])
      ..limit(limit, offset: offset);
    final rows = await query.get();
    return rows
        .map(
          (r) => AuditEvent(
            id: AuditEventId(r.id),
            actorUserId: UserId(r.actorUserId),
            actorUsername: r.actorUsername,
            action: r.action,
            entityType: r.entityType,
            entityId: r.entityId,
            detailsJson: r.detailsJson,
            createdAtUtc: _fromEpoch(r.createdAtUtcMs),
          ),
        )
        .toList();
  }

  // --- CatalogStore implementation ---

  @override
  Future<void> saveCategory(Category category) async {
    await into(categories).insertOnConflictUpdate(
      CategoriesCompanion.insert(
        id: category.id,
        organizationId: category.organizationId,
        name: category.name,
        parentCategoryId: Value(category.parentCategoryId),
        type: Value(category.type.name),
        active: Value(category.active),
        createdAtUtcMs: category.createdAt.millisecondsSinceEpoch,
        updatedAtUtcMs: category.updatedAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<List<Category>> getCategories(String organizationId) async {
    final rows = await (select(
      categories,
    )..where((c) => c.organizationId.equals(organizationId))).get();
    return rows
        .map(
          (r) => Category(
            id: r.id,
            organizationId: r.organizationId,
            name: r.name,
            parentCategoryId: r.parentCategoryId,
            type: SolarCategoryType.values.firstWhere(
              (e) => e.name == r.type,
              orElse: () => SolarCategoryType.other,
            ),
            active: r.active,
            createdAt: _fromEpoch(r.createdAtUtcMs),
            updatedAt: _fromEpoch(r.updatedAtUtcMs),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveBrand(Brand brand) async {
    await into(brands).insertOnConflictUpdate(
      BrandsCompanion.insert(
        id: brand.id,
        organizationId: brand.organizationId,
        name: brand.name,
        active: Value(brand.active),
        createdAtUtcMs: brand.createdAt.millisecondsSinceEpoch,
        updatedAtUtcMs: brand.updatedAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<List<Brand>> getBrands(String organizationId) async {
    final rows = await (select(
      brands,
    )..where((b) => b.organizationId.equals(organizationId))).get();
    return rows
        .map(
          (r) => Brand(
            id: r.id,
            organizationId: r.organizationId,
            name: r.name,
            active: r.active,
            createdAt: _fromEpoch(r.createdAtUtcMs),
            updatedAt: _fromEpoch(r.updatedAtUtcMs),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveUnit(Unit unit) async {
    await into(units).insertOnConflictUpdate(
      UnitsCompanion.insert(
        id: unit.id,
        organizationId: unit.organizationId,
        code: unit.code,
        name: unit.name,
        precisionScale: Value(unit.precisionScale),
        active: Value(unit.active),
      ),
    );
  }

  @override
  Future<List<Unit>> getUnits(String organizationId) async {
    final rows = await (select(
      units,
    )..where((u) => u.organizationId.equals(organizationId))).get();
    return rows
        .map(
          (r) => Unit(
            id: r.id,
            organizationId: r.organizationId,
            code: r.code,
            name: r.name,
            precisionScale: r.precisionScale,
            active: r.active,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveProduct(Product product) async {
    await into(products).insertOnConflictUpdate(
      ProductsCompanion.insert(
        id: product.id,
        organizationId: product.organizationId,
        sku: product.sku,
        normalizedSku: product.normalizedSku,
        name: product.name,
        categoryId: product.categoryId,
        brandId: Value(product.brandId),
        model: Value(product.model),
        baseUnitId: product.baseUnitId,
        serialPolicy: Value(product.serialPolicy.name),
        batchPolicy: Value(product.batchPolicy.name),
        minStock: Value(product.minStock),
        hsnCode: product.hsnCode,
        defaultTaxRateBps: Value(product.defaultTaxRateBps),
        costPricePaise: Value(product.costPricePaise),
        sellingPricePaise: Value(product.sellingPricePaise),
        attributesJson: Value(jsonEncode(product.attributes)),
        active: Value(product.active),
        isMadeToOrder: Value(product.isMadeToOrder),
        createdAtUtcMs: product.createdAt.millisecondsSinceEpoch,
        updatedAtUtcMs: product.updatedAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<Product?> getProductById(String organizationId, String id) async {
    final row =
        await (select(products)..where(
              (p) => p.organizationId.equals(organizationId) & p.id.equals(id),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return _mapProductRow(row);
  }

  @override
  Future<Product?> getProductBySku(String organizationId, String sku) async {
    final normalized = Product.normalizeSku(sku);
    final row =
        await (select(products)..where(
              (p) =>
                  p.organizationId.equals(organizationId) &
                  p.normalizedSku.equals(normalized),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return _mapProductRow(row);
  }

  @override
  Future<List<Product>> searchProducts(
    String organizationId, {
    String? query,
    String? categoryId,
    String? brandId,
    bool includeInactive = false,
  }) async {
    final q = select(products)
      ..where((p) => p.organizationId.equals(organizationId));
    if (!includeInactive) {
      q.where((p) => p.active.equals(true));
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      q.where((p) => p.categoryId.equals(categoryId));
    }
    if (brandId != null && brandId.isNotEmpty) {
      q.where((p) => p.brandId.equals(brandId));
    }
    if (query != null && query.trim().isNotEmpty) {
      final term = '%${query.trim().toLowerCase()}%';
      q.where(
        (p) =>
            p.name.lower().like(term) |
            p.normalizedSku.like(term) |
            p.hsnCode.like(term),
      );
    }

    final rows = await q.get();
    return rows.map(_mapProductRow).toList();
  }

  @override
  Future<void> saveBarcode(Barcode barcode) async {
    await into(barcodes).insertOnConflictUpdate(
      BarcodesCompanion.insert(
        id: barcode.id,
        productId: barcode.productId,
        code: barcode.code,
        active: Value(barcode.active),
      ),
    );
  }

  @override
  Future<Product?> getProductByBarcode(
    String organizationId,
    String barcode,
  ) async {
    final bRow =
        await (select(barcodes)
              ..where((b) => b.code.equals(barcode.trim().toUpperCase())))
            .getSingleOrNull();
    if (bRow == null) return null;
    return getProductById(organizationId, bRow.productId);
  }

  @override
  Future<void> saveProductSupplierLink(ProductSupplierLink link) async {
    await into(productSupplierLinks).insertOnConflictUpdate(
      ProductSupplierLinksCompanion.insert(
        id: link.id,
        productId: link.productId,
        partyId: link.partyId,
        supplierProductCode: Value(link.supplierProductCode),
        isPrimary: Value(link.isPrimary),
      ),
    );
  }

  @override
  Future<List<ProductSupplierLink>> getProductSupplierLinks(String productId) async {
    final rows = await (select(productSupplierLinks)
          ..where((l) => l.productId.equals(productId)))
        .get();
    return rows
        .map(
          (r) => ProductSupplierLink(
            id: r.id,
            productId: r.productId,
            partyId: r.partyId,
            supplierProductCode: r.supplierProductCode,
            isPrimary: r.isPrimary,
          ),
        )
        .toList();
  }

  Product _mapProductRow(ProductRow r) {
    Map<String, String> attrs = {};
    try {
      final decoded = jsonDecode(r.attributesJson) as Map<String, dynamic>;
      attrs = decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {}

    return Product(
      id: r.id,
      organizationId: r.organizationId,
      sku: r.sku,
      name: r.name,
      categoryId: r.categoryId,
      brandId: r.brandId,
      model: r.model,
      baseUnitId: r.baseUnitId,
      serialPolicy: SerialPolicy.values.firstWhere(
        (e) => e.name == r.serialPolicy,
        orElse: () => SerialPolicy.none,
      ),
      batchPolicy: BatchPolicy.values.firstWhere(
        (e) => e.name == r.batchPolicy,
        orElse: () => BatchPolicy.none,
      ),
      minStock: r.minStock,
      hsnCode: r.hsnCode,
      defaultTaxRateBps: r.defaultTaxRateBps,
      costPricePaise: r.costPricePaise,
      sellingPricePaise: r.sellingPricePaise,
      active: r.active,
      isMadeToOrder: r.isMadeToOrder,
      attributes: attrs,
      createdAt: _fromEpoch(r.createdAtUtcMs),
      updatedAt: _fromEpoch(r.updatedAtUtcMs),
    );
  }

  // --- PartyStore implementation ---

  @override
  Future<void> saveParty(
    Party party, {
    List<PartyAddress>? addresses,
    List<PartyContact>? contacts,
  }) async {
    await transaction(() async {
      await into(parties).insertOnConflictUpdate(
        PartiesCompanion.insert(
          id: party.id,
          organizationId: party.organizationId,
          name: party.name,
          isCustomer: Value(party.isCustomer),
          isSupplier: Value(party.isSupplier),
          gstin: Value(party.gstin),
          pan: Value(party.pan),
          paymentTermsDays: Value(party.paymentTermsDays),
          creditLimitPaise: Value(party.creditLimitPaise),
          active: Value(party.active),
          createdAtUtcMs: party.createdAt.millisecondsSinceEpoch,
          updatedAtUtcMs: party.updatedAt.millisecondsSinceEpoch,
        ),
      );

      if (addresses != null) {
        for (final addr in addresses) {
          await into(partyAddresses).insertOnConflictUpdate(
            PartyAddressesCompanion.insert(
              id: addr.id,
              partyId: addr.partyId,
              addressLine1: addr.addressLine1,
              addressLine2: Value(addr.addressLine2),
              city: addr.city,
              state: addr.state,
              pincode: addr.pincode,
              stateCode: addr.stateCode,
              isBilling: Value(addr.isBilling),
              isShipping: Value(addr.isShipping),
            ),
          );
        }
      }

      if (contacts != null) {
        for (final c in contacts) {
          await into(partyContacts).insertOnConflictUpdate(
            PartyContactsCompanion.insert(
              id: c.id,
              partyId: c.partyId,
              name: c.name,
              phone: c.phone,
              email: Value(c.email),
              isPrimary: Value(c.isPrimary),
            ),
          );
        }
      }
    });
  }

  @override
  Future<Party?> getPartyById(String organizationId, String id) async {
    final row =
        await (select(parties)..where(
              (p) => p.organizationId.equals(organizationId) & p.id.equals(id),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return _mapPartyRow(row);
  }

  @override
  Future<Party?> getPartyByGstin(String organizationId, String gstin) async {
    final row =
        await (select(parties)..where(
              (p) =>
                  p.organizationId.equals(organizationId) &
                  p.gstin.equals(gstin.trim().toUpperCase()),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return _mapPartyRow(row);
  }

  @override
  Future<List<Party>> searchParties(
    String organizationId, {
    String? query,
    bool? isCustomer,
    bool? isSupplier,
    bool includeInactive = false,
  }) async {
    final q = select(parties)
      ..where((p) => p.organizationId.equals(organizationId));
    if (!includeInactive) {
      q.where((p) => p.active.equals(true));
    }
    if (isCustomer != null) {
      q.where((p) => p.isCustomer.equals(isCustomer));
    }
    if (isSupplier != null) {
      q.where((p) => p.isSupplier.equals(isSupplier));
    }
    if (query != null && query.trim().isNotEmpty) {
      final term = '%${query.trim().toLowerCase()}%';
      q.where((p) => p.name.lower().like(term) | p.gstin.like(term));
    }

    final rows = await q.get();
    return rows.map(_mapPartyRow).toList();
  }

  @override
  Future<List<PartyAddress>> getPartyAddresses(String partyId) async {
    final rows = await (select(
      partyAddresses,
    )..where((a) => a.partyId.equals(partyId))).get();
    return rows
        .map(
          (r) => PartyAddress(
            id: r.id,
            partyId: r.partyId,
            addressLine1: r.addressLine1,
            addressLine2: r.addressLine2,
            city: r.city,
            state: r.state,
            pincode: r.pincode,
            stateCode: r.stateCode,
            isBilling: r.isBilling,
            isShipping: r.isShipping,
          ),
        )
        .toList();
  }

  @override
  Future<List<PartyContact>> getPartyContacts(String partyId) async {
    final rows = await (select(
      partyContacts,
    )..where((c) => c.partyId.equals(partyId))).get();
    return rows
        .map(
          (r) => PartyContact(
            id: r.id,
            partyId: r.partyId,
            name: r.name,
            phone: r.phone,
            email: r.email,
            isPrimary: r.isPrimary,
          ),
        )
        .toList();
  }

  Party _mapPartyRow(PartyRow r) {
    return Party(
      id: r.id,
      organizationId: r.organizationId,
      name: r.name,
      isCustomer: r.isCustomer,
      isSupplier: r.isSupplier,
      gstin: r.gstin,
      pan: r.pan,
      paymentTermsDays: r.paymentTermsDays,
      creditLimitPaise: r.creditLimitPaise,
      active: r.active,
      createdAt: _fromEpoch(r.createdAtUtcMs),
      updatedAt: _fromEpoch(r.updatedAtUtcMs),
    );
  }

  // --- AttachmentStore implementation ---

  @override
  Future<void> saveAttachment(Attachment attachment) async {
    await into(attachments).insertOnConflictUpdate(
      AttachmentsCompanion.insert(
        id: attachment.id,
        organizationId: attachment.organizationId,
        fileName: attachment.fileName,
        mimeType: attachment.mimeType,
        fileSizeBytes: attachment.fileSizeBytes,
        sha256Hash: attachment.sha256Hash,
        storagePath: attachment.storagePath,
        status: Value(attachment.status.name),
        createdAtUtcMs: attachment.createdAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<Attachment?> getAttachmentByHash(
    String organizationId,
    String hash,
  ) async {
    final row =
        await (select(attachments)..where(
              (a) =>
                  a.organizationId.equals(organizationId) &
                  a.sha256Hash.equals(hash),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return _mapAttachmentRow(row);
  }

  @override
  Future<Attachment?> getAttachmentById(String id) async {
    final row = await (select(
      attachments,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _mapAttachmentRow(row);
  }

  @override
  Future<void> linkAttachment(AttachmentLink link) async {
    await into(attachmentLinks).insertOnConflictUpdate(
      AttachmentLinksCompanion.insert(
        id: link.id,
        attachmentId: link.attachmentId,
        entityType: link.entityType,
        entityId: link.entityId,
        linkType: Value(link.linkType),
        createdAtUtcMs: link.createdAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<List<Attachment>> getAttachmentsForEntity(
    String entityType,
    String entityId,
  ) async {
    final query = select(attachments).join([
      innerJoin(
        attachmentLinks,
        attachmentLinks.attachmentId.equalsExp(attachments.id),
      ),
    ]);
    query.where(
      attachmentLinks.entityType.equals(entityType) &
          attachmentLinks.entityId.equals(entityId),
    );

    final rows = await query.get();
    return rows
        .map((r) => _mapAttachmentRow(r.readTable(attachments)))
        .toList();
  }

  @override
  Future<List<Attachment>> getOrphanedAttachments() async {
    final rows = await (select(
      attachments,
    )..where((a) => a.status.equals('orphaned'))).get();
    return rows.map(_mapAttachmentRow).toList();
  }

  @override
  Future<void> deleteAttachment(String id) async {
    await (delete(
      attachmentLinks,
    )..where((l) => l.attachmentId.equals(id))).go();
    await (delete(attachments)..where((a) => a.id.equals(id))).go();
  }

  Attachment _mapAttachmentRow(AttachmentRow r) {
    return Attachment(
      id: r.id,
      organizationId: r.organizationId,
      fileName: r.fileName,
      mimeType: r.mimeType,
      fileSizeBytes: r.fileSizeBytes,
      sha256Hash: r.sha256Hash,
      storagePath: r.storagePath,
      status: AttachmentStatus.values.firstWhere(
        (e) => e.name == r.status,
        orElse: () => AttachmentStatus.active,
      ),
      createdAt: _fromEpoch(r.createdAtUtcMs),
    );
  }

  Future<void> _seedDefaultAccounts() async {
    const orgId = 'default_org';
    final defaultAccs = Account.defaultAccounts(orgId);
    for (final acc in defaultAccs) {
      await into(accounts).insertOnConflictUpdate(
        AccountsCompanion.insert(
          id: acc.id,
          organizationId: acc.organizationId,
          code: acc.code,
          name: acc.name,
          type: acc.type.name,
          controlRole: Value(acc.controlRole.name),
          active: Value(acc.active),
        ),
      );
    }
  }

  // --- AccountingStore implementation ---

  @override
  Future<void> saveAccount(Account account) async {
    await into(accounts).insertOnConflictUpdate(
      AccountsCompanion.insert(
        id: account.id,
        organizationId: account.organizationId,
        code: account.code,
        name: account.name,
        type: account.type.name,
        controlRole: Value(account.controlRole.name),
        active: Value(account.active),
      ),
    );
  }

  @override
  Future<List<Account>> getAccounts(String organizationId) async {
    final rows = await (select(
      accounts,
    )..where((a) => a.organizationId.equals(organizationId))).get();
    return rows.map(_mapAccountRow).toList();
  }

  @override
  Future<Account?> getAccountByCode(String organizationId, String code) async {
    final row =
        await (select(accounts)..where(
              (a) =>
                  a.organizationId.equals(organizationId) & a.code.equals(code),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return _mapAccountRow(row);
  }

  Account _mapAccountRow(AccountRow r) {
    return Account(
      id: r.id,
      organizationId: r.organizationId,
      code: r.code,
      name: r.name,
      type: AccountType.values.firstWhere(
        (e) => e.name == r.type,
        orElse: () => AccountType.asset,
      ),
      controlRole: AccountControlRole.values.firstWhere(
        (e) => e.name == r.controlRole,
        orElse: () => AccountControlRole.none,
      ),
      active: r.active,
    );
  }

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    await transaction(() async {
      await into(journalEntries).insertOnConflictUpdate(
        JournalEntriesCompanion.insert(
          id: entry.id,
          organizationId: entry.organizationId,
          branchId: entry.branchId,
          documentId: entry.documentId,
          postingDateUtcMs: entry.postingDate.millisecondsSinceEpoch,
          reversalOfId: Value(entry.reversalOfId),
          memo: entry.memo,
          createdAtUtcMs: entry.createdAt.millisecondsSinceEpoch,
        ),
      );

      await (delete(
        journalLines,
      )..where((l) => l.journalEntryId.equals(entry.id))).go();

      for (final line in entry.lines) {
        await into(journalLines).insert(
          JournalLinesCompanion.insert(
            id: line.id,
            journalEntryId: entry.id,
            accountId: line.accountId,
            debitPaise: Value(line.debitPaise),
            creditPaise: Value(line.creditPaise),
            partyId: Value(line.partyId),
            projectId: Value(line.projectId),
          ),
        );
      }
    });
  }

  @override
  Future<List<JournalEntry>> getJournalEntries(
    String organizationId, {
    String? partyId,
    int limit = 100,
  }) async {
    final query = select(journalEntries)
      ..where((e) => e.organizationId.equals(organizationId));
    if (partyId != null && partyId.isNotEmpty) {
      final matchingEntryIdsQuery = selectOnly(journalLines)
        ..addColumns([journalLines.journalEntryId])
        ..where(journalLines.partyId.equals(partyId));
      final matchingRows = await matchingEntryIdsQuery.get();
      final ids = matchingRows
          .map((r) => r.read(journalLines.journalEntryId)!)
          .toSet();
      if (ids.isEmpty) return [];
      query.where((e) => e.id.isIn(ids));
    }
    query.orderBy([
      (t) =>
          OrderingTerm(expression: t.postingDateUtcMs, mode: OrderingMode.desc),
    ]);
    query.limit(limit);

    final entryRows = await query.get();
    final result = <JournalEntry>[];

    for (final eRow in entryRows) {
      final lineRows = await (select(
        journalLines,
      )..where((l) => l.journalEntryId.equals(eRow.id))).get();
      final lines = lineRows
          .map(
            (l) => JournalLine(
              id: l.id,
              journalEntryId: l.journalEntryId,
              accountId: l.accountId,
              debitPaise: l.debitPaise,
              creditPaise: l.creditPaise,
              partyId: l.partyId,
              projectId: l.projectId,
            ),
          )
          .toList();

      result.add(
        JournalEntry(
          id: eRow.id,
          organizationId: eRow.organizationId,
          branchId: eRow.branchId,
          documentId: eRow.documentId,
          postingDate: _fromEpoch(eRow.postingDateUtcMs),
          reversalOfId: eRow.reversalOfId,
          memo: eRow.memo,
          lines: lines,
          createdAt: _fromEpoch(eRow.createdAtUtcMs),
        ),
      );
    }

    return result;
  }

  @override
  Future<int> getPartyBalancePaise(
    String organizationId,
    String partyId,
  ) async {
    final query = customSelect(
      '''
      SELECT
        COALESCE(SUM(jl.debit_paise), 0) - COALESCE(SUM(jl.credit_paise), 0) AS net_balance
      FROM journal_lines jl
      JOIN journal_entries je ON je.id = jl.journal_entry_id
      WHERE je.organization_id = ? AND jl.party_id = ?
    ''',
      readsFrom: {journalEntries, journalLines},
      variables: [
        Variable.withString(organizationId),
        Variable.withString(partyId),
      ],
    );

    final row = await query.getSingle();
    final val = row.data['net_balance'];
    if (val is int) return val;
    if (val is num) return val.toInt();
    return 0;
  }

  @override
  Future<void> saveDocumentHeader(DocumentHeader header) async {
    await into(documentHeaders).insertOnConflictUpdate(
      DocumentHeadersCompanion.insert(
        id: header.id,
        organizationId: header.organizationId,
        branchId: header.branchId,
        kind: header.kind.name,
        status: Value(header.status.name),
        businessDateUtcMs: header.businessDate.millisecondsSinceEpoch,
        documentNumber: header.documentNumber,
        fiscalYear: header.fiscalYear,
        sourceCommandId: header.sourceCommandId,
        createdAtUtcMs: header.createdAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<DocumentHeader?> getDocumentHeaderById(String id) async {
    final row = await (select(
      documentHeaders,
    )..where((h) => h.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return DocumentHeader(
      id: row.id,
      organizationId: row.organizationId,
      branchId: row.branchId,
      kind: DocumentKind.values.firstWhere(
        (e) => e.name == row.kind,
        orElse: () => DocumentKind.journal,
      ),
      status: DocumentStatus.values.firstWhere(
        (e) => e.name == row.status,
        orElse: () => DocumentStatus.posted,
      ),
      businessDate: _fromEpoch(row.businessDateUtcMs),
      documentNumber: row.documentNumber,
      fiscalYear: row.fiscalYear,
      sourceCommandId: row.sourceCommandId,
      createdAt: _fromEpoch(row.createdAtUtcMs),
    );
  }

  @override
  Future<String> allocateNextDocumentNumber({
    required String registrationId,
    required String fiscalYear,
    required String series,
  }) async {
    return transaction(() async {
      final existing =
          await (select(documentSequences)..where(
                (s) =>
                    s.registrationId.equals(registrationId) &
                    s.fiscalYear.equals(fiscalYear) &
                    s.series.equals(series),
              ))
              .getSingleOrNull();

      final currentVal = existing?.nextValue ?? 1;
      final seqId =
          existing?.id ?? 'seq_${registrationId}_${fiscalYear}_$series';

      final seq = DocumentSequence(
        id: seqId,
        registrationId: registrationId,
        fiscalYear: fiscalYear,
        series: series,
        nextValue: currentVal,
      );

      final formattedNumber = seq.formatNextNumber();

      await into(documentSequences).insertOnConflictUpdate(
        DocumentSequencesCompanion.insert(
          id: seqId,
          registrationId: registrationId,
          fiscalYear: fiscalYear,
          series: series,
          nextValue: Value(currentVal + 1),
        ),
      );

      return formattedNumber;
    });
  }

  @override
  Future<void> saveCommandResult(CommandResultRecord result) async {
    await into(commandResults).insertOnConflictUpdate(
      CommandResultsCompanion.insert(
        id: result.id,
        commandId: result.commandId,
        payloadHash: result.payloadHash,
        resultJson: result.resultJson,
        createdAtUtcMs: result.createdAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<CommandResultRecord?> getCommandResult(String commandId) async {
    final row = await (select(
      commandResults,
    )..where((c) => c.commandId.equals(commandId))).getSingleOrNull();
    if (row == null) return null;
    return CommandResultRecord(
      id: row.id,
      commandId: row.commandId,
      payloadHash: row.payloadHash,
      resultJson: row.resultJson,
      createdAt: _fromEpoch(row.createdAtUtcMs),
    );
  }

  Future<void> _seedDefaultLocations() async {
    const orgId = 'default_org';
    await into(locations).insertOnConflictUpdate(
      LocationsCompanion.insert(
        id: 'loc_default_sellable',
        organizationId: orgId,
        branchId: 'main_branch',
        name: 'Main Warehouse / Sellable Store',
        type: const Value('sellable'),
        active: const Value(true),
      ),
    );
    await into(locations).insertOnConflictUpdate(
      LocationsCompanion.insert(
        id: 'loc_default_quarantine',
        organizationId: orgId,
        branchId: 'main_branch',
        name: 'Quarantine / Damaged Store',
        type: const Value('quarantine'),
        active: const Value(true),
      ),
    );
  }

  // --- InventoryStore implementation ---

  @override
  Future<void> saveLocation(Location location) async {
    await into(locations).insertOnConflictUpdate(
      LocationsCompanion.insert(
        id: location.id,
        organizationId: location.organizationId,
        branchId: location.branchId,
        name: location.name,
        type: Value(location.type.name),
        active: Value(location.active),
      ),
    );
  }

  @override
  Future<List<Location>> getLocations(
    String organizationId, {
    String? branchId,
  }) async {
    final query = select(locations)
      ..where((l) => l.organizationId.equals(organizationId));
    if (branchId != null && branchId.isNotEmpty) {
      query.where((l) => l.branchId.equals(branchId));
    }
    final rows = await query.get();
    return rows.map(_mapLocationRow).toList();
  }

  @override
  Future<Location?> getLocationById(String id) async {
    final row = await (select(
      locations,
    )..where((l) => l.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _mapLocationRow(row);
  }

  Location _mapLocationRow(LocationRow r) {
    return Location(
      id: r.id,
      organizationId: r.organizationId,
      branchId: r.branchId,
      name: r.name,
      type: LocationType.values.firstWhere(
        (e) => e.name == r.type,
        orElse: () => LocationType.sellable,
      ),
      active: r.active,
    );
  }

  @override
  Future<void> saveStockMovement(StockMovement movement) async {
    await into(stockMovements).insert(
      StockMovementsCompanion.insert(
        id: movement.id,
        organizationId: movement.organizationId,
        branchId: movement.branchId,
        documentId: movement.documentId,
        lineId: movement.lineId,
        productId: movement.productId,
        locationId: movement.locationId,
        batchId: Value(movement.batchId),
        quantityMicroUnits: movement.quantityMicroUnits,
        valueDeltaPaise: movement.valueDeltaPaise,
        costSnapshotMicroRupees: movement.costSnapshotMicroRupees,
        movementKind: movement.movementKind.name,
        createdAtUtcMs: movement.createdAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<List<StockMovement>> getStockMovements(
    String organizationId, {
    String? productId,
    String? locationId,
    int limit = 100,
  }) async {
    final query = select(stockMovements)
      ..where((m) => m.organizationId.equals(organizationId));
    if (productId != null && productId.isNotEmpty) {
      query.where((m) => m.productId.equals(productId));
    }
    if (locationId != null && locationId.isNotEmpty) {
      query.where((m) => m.locationId.equals(locationId));
    }
    query.orderBy([
      (t) =>
          OrderingTerm(expression: t.createdAtUtcMs, mode: OrderingMode.desc),
    ]);
    query.limit(limit);

    final rows = await query.get();
    return rows
        .map(
          (r) => StockMovement(
            id: r.id,
            organizationId: r.organizationId,
            branchId: r.branchId,
            documentId: r.documentId,
            lineId: r.lineId,
            productId: r.productId,
            locationId: r.locationId,
            batchId: r.batchId,
            quantityMicroUnits: r.quantityMicroUnits,
            valueDeltaPaise: r.valueDeltaPaise,
            costSnapshotMicroRupees: r.costSnapshotMicroRupees,
            movementKind: MovementKind.values.firstWhere(
              (e) => e.name == r.movementKind,
              orElse: () => MovementKind.openingStock,
            ),
            createdAt: _fromEpoch(r.createdAtUtcMs),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveStockBalance(StockBalance balance) async {
    await into(stockBalances).insertOnConflictUpdate(
      StockBalancesCompanion.insert(
        productId: balance.productId,
        locationId: balance.locationId,
        quantityMicroUnits: Value(balance.quantityMicroUnits),
        valuePaise: Value(balance.valuePaise),
        updatedAtUtcMs: balance.updatedAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<StockBalance?> getStockBalance(
    String productId,
    String locationId,
  ) async {
    final row =
        await (select(stockBalances)..where(
              (b) =>
                  b.productId.equals(productId) &
                  b.locationId.equals(locationId),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return StockBalance(
      productId: row.productId,
      locationId: row.locationId,
      quantityMicroUnits: row.quantityMicroUnits,
      valuePaise: row.valuePaise,
      updatedAt: _fromEpoch(row.updatedAtUtcMs),
    );
  }

  @override
  Future<List<StockBalance>> getStockBalancesForProduct(
    String organizationId,
    String productId,
  ) async {
    final rows = await (select(
      stockBalances,
    )..where((b) => b.productId.equals(productId))).get();
    return rows
        .map(
          (r) => StockBalance(
            productId: r.productId,
            locationId: r.locationId,
            quantityMicroUnits: r.quantityMicroUnits,
            valuePaise: r.valuePaise,
            updatedAt: _fromEpoch(r.updatedAtUtcMs),
          ),
        )
        .toList();
  }

  @override
  Future<List<StockBalance>> getAllStockBalances(
    String organizationId, {
    String? locationId,
  }) async {
    final query = select(stockBalances);
    if (locationId != null && locationId.isNotEmpty) {
      query.where((b) => b.locationId.equals(locationId));
    }
    final rows = await query.get();
    return rows
        .map(
          (r) => StockBalance(
            productId: r.productId,
            locationId: r.locationId,
            quantityMicroUnits: r.quantityMicroUnits,
            valuePaise: r.valuePaise,
            updatedAt: _fromEpoch(r.updatedAtUtcMs),
          ),
        )
        .toList();
  }

  @override
  Future<List<StockBalance>> rebuildStockBalances(String organizationId) async {
    return transaction(() async {
      await delete(stockBalances).go();

      final movements =
          await (select(stockMovements)
                ..where((m) => m.organizationId.equals(organizationId))
                ..orderBy([
                  (t) => OrderingTerm(
                    expression: t.createdAtUtcMs,
                    mode: OrderingMode.asc,
                  ),
                ]))
              .get();

      final map = <String, StockBalance>{};
      for (final r in movements) {
        final key = '${r.productId}_${r.locationId}';
        final movement = StockMovement(
          id: r.id,
          organizationId: r.organizationId,
          branchId: r.branchId,
          documentId: r.documentId,
          lineId: r.lineId,
          productId: r.productId,
          locationId: r.locationId,
          batchId: r.batchId,
          quantityMicroUnits: r.quantityMicroUnits,
          valueDeltaPaise: r.valueDeltaPaise,
          costSnapshotMicroRupees: r.costSnapshotMicroRupees,
          movementKind: MovementKind.values.firstWhere(
            (e) => e.name == r.movementKind,
            orElse: () => MovementKind.openingStock,
          ),
          createdAt: _fromEpoch(r.createdAtUtcMs),
        );

        final current =
            map[key] ??
            StockBalance(
              productId: r.productId,
              locationId: r.locationId,
              quantityMicroUnits: 0,
              valuePaise: 0,
              updatedAt: _fromEpoch(r.createdAtUtcMs),
            );

        map[key] = current.applyMovement(
          movement: movement,
          updatedAt: _fromEpoch(r.createdAtUtcMs),
        );
      }

      for (final bal in map.values) {
        await saveStockBalance(bal);
      }

      return map.values.toList();
    });
  }

  @override
  Future<void> saveSerialRecord(SerialRecord serial) async {
    await into(serials).insertOnConflictUpdate(
      SerialsCompanion.insert(
        id: serial.id,
        organizationId: serial.organizationId,
        productId: serial.productId,
        serialNumber: serial.serialNumber,
        state: Value(serial.state.name),
        locationId: Value(serial.locationId),
        batchId: Value(serial.batchId),
        updatedAtUtcMs: serial.updatedAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<SerialRecord?> getSerialByNumber(
    String organizationId,
    String productId,
    String serialNumber,
  ) async {
    final row =
        await (select(serials)..where(
              (s) =>
                  s.organizationId.equals(organizationId) &
                  s.productId.equals(productId) &
                  s.serialNumber.equals(serialNumber.trim().toUpperCase()),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return _mapSerialRow(row);
  }

  @override
  Future<List<SerialRecord>> getSerialsForProduct(
    String organizationId,
    String productId, {
    SerialState? state,
  }) async {
    final query = select(serials)
      ..where(
        (s) =>
            s.organizationId.equals(organizationId) &
            s.productId.equals(productId),
      );
    if (state != null) {
      query.where((s) => s.state.equals(state.name));
    }
    final rows = await query.get();
    return rows.map(_mapSerialRow).toList();
  }

  SerialRecord _mapSerialRow(SerialRecordRow r) {
    return SerialRecord(
      id: r.id,
      organizationId: r.organizationId,
      productId: r.productId,
      serialNumber: r.serialNumber,
      state: SerialState.values.firstWhere(
        (e) => e.name == r.state,
        orElse: () => SerialState.inStock,
      ),
      locationId: r.locationId,
      batchId: r.batchId,
      updatedAt: _fromEpoch(r.updatedAtUtcMs),
    );
  }

  @override
  Future<void> saveSerialEvent(SerialEvent event) async {
    await into(serialEvents).insert(
      SerialEventsCompanion.insert(
        id: event.id,
        serialId: event.serialId,
        fromState: event.fromState.name,
        toState: event.toState.name,
        documentId: event.documentId,
        createdAtUtcMs: event.createdAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<List<SerialEvent>> getSerialEvents(String serialId) async {
    final rows = await (select(
      serialEvents,
    )..where((e) => e.serialId.equals(serialId))).get();
    return rows
        .map(
          (r) => SerialEvent(
            id: r.id,
            serialId: r.serialId,
            fromState: SerialState.values.firstWhere(
              (e) => e.name == r.fromState,
              orElse: () => SerialState.inStock,
            ),
            toState: SerialState.values.firstWhere(
              (e) => e.name == r.toState,
              orElse: () => SerialState.inStock,
            ),
            documentId: r.documentId,
            createdAt: _fromEpoch(r.createdAtUtcMs),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveBatchRecord(BatchRecord batch) async {
    await into(batches).insertOnConflictUpdate(
      BatchesCompanion.insert(
        id: batch.id,
        organizationId: batch.organizationId,
        productId: batch.productId,
        lotNumber: batch.lotNumber,
        expiryDateUtcMs: Value(batch.expiryDate?.millisecondsSinceEpoch),
        supplierPartyId: Value(batch.supplierPartyId),
        createdAtUtcMs: batch.createdAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<List<BatchRecord>> getBatchesForProduct(
    String organizationId,
    String productId,
  ) async {
    final rows =
        await (select(batches)..where(
              (b) =>
                  b.organizationId.equals(organizationId) &
                  b.productId.equals(productId),
            ))
            .get();
    return rows
        .map(
          (r) => BatchRecord(
            id: r.id,
            organizationId: r.organizationId,
            productId: r.productId,
            lotNumber: r.lotNumber,
            expiryDate: r.expiryDateUtcMs != null
                ? _fromEpoch(r.expiryDateUtcMs!)
                : null,
            supplierPartyId: r.supplierPartyId,
            createdAt: _fromEpoch(r.createdAtUtcMs),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveReservation(Reservation reservation) async {
    await into(reservations).insertOnConflictUpdate(
      ReservationsCompanion.insert(
        id: reservation.id,
        organizationId: reservation.organizationId,
        branchId: reservation.branchId,
        productId: reservation.productId,
        quantityMicroUnits: reservation.quantityMicroUnits,
        status: Value(reservation.status.name),
        expiresAtUtcMs: Value(reservation.expiresAt?.millisecondsSinceEpoch),
        projectId: Value(reservation.projectId),
        createdAtUtcMs: reservation.createdAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<List<Reservation>> getActiveReservationsForProduct(
    String organizationId,
    String productId,
  ) async {
    final rows =
        await (select(reservations)..where(
              (r) =>
                  r.organizationId.equals(organizationId) &
                  r.productId.equals(productId) &
                  r.status.equals('active'),
            ))
            .get();
    return rows
        .map(
          (r) => Reservation(
            id: r.id,
            organizationId: r.organizationId,
            branchId: r.branchId,
            productId: r.productId,
            quantityMicroUnits: r.quantityMicroUnits,
            status: ReservationStatus.values.firstWhere(
              (e) => e.name == r.status,
              orElse: () => ReservationStatus.active,
            ),
            expiresAt: r.expiresAtUtcMs != null
                ? _fromEpoch(r.expiresAtUtcMs!)
                : null,
            projectId: r.projectId,
            createdAt: _fromEpoch(r.createdAtUtcMs),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveStockAdjustment(StockAdjustment adjustment) async {
    await into(stockAdjustments).insertOnConflictUpdate(
      StockAdjustmentsCompanion.insert(
        id: adjustment.id,
        organizationId: adjustment.organizationId,
        branchId: adjustment.branchId,
        productId: adjustment.productId,
        locationId: adjustment.locationId,
        quantityDeltaMicroUnits: adjustment.quantityDeltaMicroUnits,
        valueDeltaPaise: adjustment.valueDeltaPaise,
        reason: adjustment.reason,
        approvedByUserId: adjustment.approvedByUserId,
        createdAtUtcMs: adjustment.createdAt.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<List<StockAdjustment>> getStockAdjustments(
    String organizationId, {
    int limit = 100,
  }) async {
    final query = select(stockAdjustments)
      ..where((a) => a.organizationId.equals(organizationId));
    query.orderBy([
      (t) =>
          OrderingTerm(expression: t.createdAtUtcMs, mode: OrderingMode.desc),
    ]);
    query.limit(limit);
    final rows = await query.get();
    return rows
        .map(
          (r) => StockAdjustment(
            id: r.id,
            organizationId: r.organizationId,
            branchId: r.branchId,
            productId: r.productId,
            locationId: r.locationId,
            quantityDeltaMicroUnits: r.quantityDeltaMicroUnits,
            valueDeltaPaise: r.valueDeltaPaise,
            reason: r.reason,
            approvedByUserId: r.approvedByUserId,
            createdAt: _fromEpoch(r.createdAtUtcMs),
          ),
        )
        .toList();
  }

  // ---------------------------------------------------------------------
  // PurchasingStore Implementation
  // ---------------------------------------------------------------------

  @override
  Future<void> savePurchase({
    required PurchaseHeader header,
    required List<PurchaseLine> lines,
  }) async {
    await into(purchaseHeaders).insertOnConflictUpdate(
      PurchaseHeadersCompanion.insert(
        id: header.id,
        organizationId: header.organizationId,
        branchId: header.branchId,
        documentHeaderId: header.documentHeaderId,
        supplierId: header.supplierId,
        supplierName: header.supplierName,
        externalInvoiceNumber: header.externalInvoiceNumber,
        normalizedExternalInvoiceNumber: header.normalizedExternalInvoiceNumber,
        invoiceDateMs: header.invoiceDate.millisecondsSinceEpoch,
        locationId: header.locationId,
        status: Value(header.status.name),
        subtotalPaise: header.subtotalPaise.paise,
        landedCostTotalPaise: header.landedCostTotalPaise.paise,
        totalTaxPaise: header.totalTaxPaise.paise,
        netTotalPaise: header.netTotalPaise.paise,
        amountPaidPaise: header.amountPaidPaise.paise,
        balanceDuePaise: header.balanceDuePaise.paise,
        createdAtUtcMs: header.createdAtUtc.millisecondsSinceEpoch,
        paymentTerms: Value(header.paymentTerms),
        notes: Value(header.notes),
      ),
    );

    for (final line in lines) {
      await into(purchaseLines).insertOnConflictUpdate(
        PurchaseLinesCompanion.insert(
          id: line.id,
          purchaseId: line.purchaseId,
          productId: line.productId,
          productName: line.productName,
          sku: line.sku,
          quantityMicroUnits: line.quantity.microUnits,
          unitPurchasePriceMicroRupees: line.unitPurchasePrice.microRupees,
          discountPaise: line.discountPaise.paise,
          taxSnapshotJson: jsonEncode({
            'lineId': line.taxSnapshot.lineId,
            'taxableAmount': line.taxSnapshot.taxableAmount.paise,
            'cgst': line.taxSnapshot.cgst.paise,
            'sgst': line.taxSnapshot.sgst.paise,
            'igst': line.taxSnapshot.igst.paise,
            'totalTax': line.taxSnapshot.totalTax.paise,
            'totalAmount': line.taxSnapshot.totalAmount.paise,
          }),
          landedCostAllocationPaise: line.landedCostAllocationPaise.paise,
          netTotalPaise: line.netTotalPaise.paise,
          serialsJson: Value(jsonEncode(line.serials)),
          batchLot: Value(line.batchLot),
          expiryDateMs: Value(line.expiryDate?.millisecondsSinceEpoch),
        ),
      );
    }
  }

  @override
  Future<PurchaseHeader?> getPurchaseHeader(String id) async {
    final query = select(purchaseHeaders)..where((p) => p.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapPurchaseHeaderRow(row);
  }

  @override
  Future<List<PurchaseLine>> getPurchaseLines(String purchaseId) async {
    final query = select(purchaseLines)
      ..where((l) => l.purchaseId.equals(purchaseId));
    final rows = await query.get();
    return rows.map(_mapPurchaseLineRow).toList();
  }

  @override
  Future<List<PurchaseHeader>> listPurchases({
    required String organizationId,
    String? supplierId,
  }) async {
    final query = select(purchaseHeaders)
      ..where((p) => p.organizationId.equals(organizationId));
    if (supplierId != null) {
      query.where((p) => p.supplierId.equals(supplierId));
    }
    query.orderBy([
      (t) =>
          OrderingTerm(expression: t.createdAtUtcMs, mode: OrderingMode.desc),
    ]);
    final rows = await query.get();
    return rows.map(_mapPurchaseHeaderRow).toList();
  }

  @override
  Future<bool> hasDuplicateSupplierInvoice({
    required String organizationId,
    required String supplierId,
    required String financialYear,
    required String externalInvoiceNumber,
  }) async {
    final norm = PurchaseHeader.normalizeExternalInvoiceNumber(
      externalInvoiceNumber,
    );
    final query = select(purchaseHeaders)
      ..where(
        (p) =>
            p.organizationId.equals(organizationId) &
            p.supplierId.equals(supplierId) &
            p.normalizedExternalInvoiceNumber.equals(norm),
      );
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  @override
  Future<void> savePayment({
    required Payment payment,
    required List<PaymentAllocation> allocations,
  }) async {
    await into(payments).insertOnConflictUpdate(
      PaymentsCompanion.insert(
        id: payment.id,
        organizationId: payment.organizationId,
        branchId: payment.branchId,
        partyId: payment.partyId,
        partyName: payment.partyName,
        direction: payment.direction.name,
        paymentMethod: payment.paymentMethod.name,
        amountPaise: payment.amountPaise.paise,
        paymentDateMs: payment.paymentDate.millisecondsSinceEpoch,
        createdAtUtcMs: payment.createdAtUtc.millisecondsSinceEpoch,
        referenceNumber: Value(payment.referenceNumber),
        notes: Value(payment.notes),
      ),
    );

    for (final alloc in allocations) {
      await into(paymentAllocations).insertOnConflictUpdate(
        PaymentAllocationsCompanion.insert(
          id: alloc.id,
          paymentId: alloc.paymentId,
          documentId: alloc.documentId,
          allocatedAmountPaise: alloc.allocatedAmountPaise.paise,
          createdAtUtcMs: alloc.createdAtUtc.millisecondsSinceEpoch,
        ),
      );
    }
  }

  @override
  Future<Money> getSupplierOutstandingBalance({
    required String organizationId,
    required String supplierId,
  }) async {
    final query = select(purchaseHeaders)
      ..where(
        (p) =>
            p.organizationId.equals(organizationId) &
            p.supplierId.equals(supplierId) &
            p.status.equals('posted'),
      );
    final rows = await query.get();
    var sumPaise = 0;
    for (final r in rows) {
      sumPaise += r.balanceDuePaise;
    }
    return Money.fromPaise(sumPaise);
  }

  PurchaseHeader _mapPurchaseHeaderRow(PurchaseHeaderRow r) {
    return PurchaseHeader(
      id: r.id,
      organizationId: r.organizationId,
      branchId: r.branchId,
      documentHeaderId: r.documentHeaderId,
      supplierId: r.supplierId,
      supplierName: r.supplierName,
      externalInvoiceNumber: r.externalInvoiceNumber,
      normalizedExternalInvoiceNumber: r.normalizedExternalInvoiceNumber,
      invoiceDate: _fromEpoch(r.invoiceDateMs),
      locationId: r.locationId,
      status: PurchaseStatus.values.firstWhere(
        (s) => s.name == r.status,
        orElse: () => PurchaseStatus.posted,
      ),
      subtotalPaise: Money.fromPaise(r.subtotalPaise),
      landedCostTotalPaise: Money.fromPaise(r.landedCostTotalPaise),
      totalTaxPaise: Money.fromPaise(r.totalTaxPaise),
      netTotalPaise: Money.fromPaise(r.netTotalPaise),
      amountPaidPaise: Money.fromPaise(r.amountPaidPaise),
      balanceDuePaise: Money.fromPaise(r.balanceDuePaise),
      createdAtUtc: _fromEpoch(r.createdAtUtcMs),
      paymentTerms: r.paymentTerms,
      notes: r.notes,
    );
  }

  PurchaseLine _mapPurchaseLineRow(PurchaseLineRow r) {
    final taxMap = jsonDecode(r.taxSnapshotJson) as Map<String, dynamic>;
    final taxSnapshot = TaxLineResult(
      lineId: taxMap['lineId'] as String? ?? r.id,
      taxableAmount: Money.fromPaise(taxMap['taxableAmount'] as int? ?? 0),
      cgst: Money.fromPaise(taxMap['cgst'] as int? ?? 0),
      sgst: Money.fromPaise(taxMap['sgst'] as int? ?? 0),
      igst: Money.fromPaise(taxMap['igst'] as int? ?? 0),
      totalTax: Money.fromPaise(taxMap['totalTax'] as int? ?? 0),
      totalAmount: Money.fromPaise(taxMap['totalAmount'] as int? ?? 0),
    );

    final serialsList = (jsonDecode(r.serialsJson) as List<dynamic>)
        .map((e) => e.toString())
        .toList();

    return PurchaseLine(
      id: r.id,
      purchaseId: r.purchaseId,
      productId: r.productId,
      productName: r.productName,
      sku: r.sku,
      quantity: Quantity.fromUnits(r.quantityMicroUnits / 1000000.0),
      unitPurchasePrice: UnitPrice.fromRupees(
        r.unitPurchasePriceMicroRupees / 1000000.0,
      ),
      discountPaise: Money.fromPaise(r.discountPaise),
      taxSnapshot: taxSnapshot,
      landedCostAllocationPaise: Money.fromPaise(r.landedCostAllocationPaise),
      netTotalPaise: Money.fromPaise(r.netTotalPaise),
      serials: serialsList,
      batchLot: r.batchLot,
      expiryDate: r.expiryDateMs != null ? _fromEpoch(r.expiryDateMs!) : null,
    );
  }

  // ---------------------------------------------------------------------
  // SalesStore Implementation
  // ---------------------------------------------------------------------

  @override
  Future<void> saveSale({
    required SaleHeader header,
    required List<SaleLine> lines,
  }) async {
    await into(saleHeaders).insertOnConflictUpdate(
      SaleHeadersCompanion.insert(
        id: header.id,
        organizationId: header.organizationId,
        branchId: header.branchId,
        documentHeaderId: header.documentHeaderId,
        customerPartyId: header.customerPartyId,
        customerName: header.customerName,
        businessDateMs: header.businessDate.millisecondsSinceEpoch,
        locationId: header.locationId,
        status: Value(header.status.name),
        subtotalPaise: header.subtotalPaise.paise,
        allocatedDiscountPaise: header.allocatedDiscountPaise.paise,
        totalTaxPaise: header.totalTaxPaise.paise,
        grandTotalPaise: header.grandTotalPaise.paise,
        amountPaidPaise: header.amountPaidPaise.paise,
        balanceDuePaise: header.balanceDuePaise.paise,
        createdAtUtcMs: header.createdAtUtc.millisecondsSinceEpoch,
        notes: Value(header.notes),
      ),
    );

    for (final line in lines) {
      final taxSnapshotJson = jsonEncode({
        'lineId': line.taxSnapshot.lineId,
        'taxableAmount': line.taxSnapshot.taxableAmount.paise,
        'cgst': line.taxSnapshot.cgst.paise,
        'sgst': line.taxSnapshot.sgst.paise,
        'igst': line.taxSnapshot.igst.paise,
        'totalTax': line.taxSnapshot.totalTax.paise,
        'totalAmount': line.taxSnapshot.totalAmount.paise,
      });

      await into(saleLines).insertOnConflictUpdate(
        SaleLinesCompanion.insert(
          id: line.id,
          saleId: line.saleId,
          productId: line.productId,
          productName: line.productName,
          sku: line.sku,
          hsnCode: line.hsnCode,
          baseUnit: line.baseUnit,
          quantityMicroUnits: line.quantity.microUnits,
          unitPriceMicroRupees: line.unitPrice.microRupees,
          lineDiscountPaise: line.lineDiscountPaise.paise,
          taxSnapshotJson: taxSnapshotJson,
          costSnapshotMicroRupees: line.costSnapshotMicroRupees,
          netTotalPaise: line.netTotalPaise.paise,
          serialsJson: Value(jsonEncode(line.serials)),
          batchLot: Value(line.batchLot),
        ),
      );
    }
  }

  @override
  Future<SaleHeader?> getSaleHeader(String id) async {
    final query = select(saleHeaders)..where((s) => s.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapSaleHeaderRow(row);
  }

  @override
  Future<List<SaleLine>> getSaleLines(String saleId) async {
    final query = select(saleLines)..where((l) => l.saleId.equals(saleId));
    final rows = await query.get();
    return rows.map(_mapSaleLineRow).toList();
  }

  @override
  Future<List<SaleHeader>> listSales({
    required String organizationId,
    String? customerPartyId,
  }) async {
    final query = select(saleHeaders)
      ..where((s) {
        var expr = s.organizationId.equals(organizationId);
        if (customerPartyId != null) {
          expr = expr & s.customerPartyId.equals(customerPartyId);
        }
        return expr;
      })
      ..orderBy([(s) => OrderingTerm.desc(s.createdAtUtcMs)]);
    final rows = await query.get();
    return rows.map(_mapSaleHeaderRow).toList();
  }

  @override
  Future<void> saveSaleDraft(SaleDraft draft) async {
    await into(saleDrafts).insertOnConflictUpdate(
      SaleDraftsCompanion.insert(
        id: draft.id,
        organizationId: draft.organizationId,
        branchId: draft.branchId,
        customerPartyId: Value(draft.customerPartyId),
        customerName: draft.customerName,
        linesJson: draft.linesJson,
        updatedAtUtcMs: draft.updatedAtUtc.millisecondsSinceEpoch,
        notes: Value(draft.notes),
      ),
    );
  }

  @override
  Future<SaleDraft?> getSaleDraft(String id) async {
    final query = select(saleDrafts)..where((d) => d.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapSaleDraftRow(row);
  }

  @override
  Future<void> deleteSaleDraft(String id) async {
    await (delete(saleDrafts)..where((d) => d.id.equals(id))).go();
  }

  @override
  Future<List<SaleDraft>> listSaleDrafts(String organizationId) async {
    final query = select(saleDrafts)
      ..where((d) => d.organizationId.equals(organizationId))
      ..orderBy([(d) => OrderingTerm.desc(d.updatedAtUtcMs)]);
    final rows = await query.get();
    return rows.map(_mapSaleDraftRow).toList();
  }

  @override
  Future<void> saveSaleOrder({
    required SaleOrder order,
    required List<SaleOrderLine> lines,
  }) async {
    await transaction(() async {
      await into(saleOrders).insertOnConflictUpdate(
        SaleOrdersCompanion.insert(
          id: order.id,
          organizationId: order.organizationId,
          branchId: order.branchId,
          customerPartyId: order.customerPartyId,
          customerName: order.customerName,
          customerPhone: Value(order.customerPhone),
          orderDateMs: order.orderDate.millisecondsSinceEpoch,
          status: Value(order.status.name),
          quotationId: Value(order.quotationId),
          saleHeaderId: Value(order.saleHeaderId),
          grandTotalPaise: order.grandTotalPaise.paise,
          expectedDeliveryDateMs: Value(
            order.expectedDeliveryDate?.millisecondsSinceEpoch,
          ),
          notes: Value(order.notes),
          createdAtUtcMs: order.createdAtUtc.millisecondsSinceEpoch,
        ),
      );
      await (delete(
        saleOrderLines,
      )..where((line) => line.orderId.equals(order.id))).go();
      for (final line in lines) {
        await into(saleOrderLines).insert(
          SaleOrderLinesCompanion.insert(
            id: line.id,
            orderId: line.orderId,
            productId: line.productId,
            productName: line.productName,
            quantityMicroUnits: line.quantity.microUnits,
            unitPriceMicroRupees: line.unitPrice.microRupees,
            taxRateBps: line.taxRate.bps,
            isInStock: Value(line.isInStock),
          ),
        );
      }
    });
  }

  @override
  Future<SaleOrder?> getSaleOrder(String id) async {
    final row = await (select(
      saleOrders,
    )..where((order) => order.id.equals(id))).getSingleOrNull();
    return row == null ? null : _mapSaleOrderRow(row);
  }

  @override
  Future<List<SaleOrderLine>> getSaleOrderLines(String orderId) async {
    final rows = await (select(
      saleOrderLines,
    )..where((line) => line.orderId.equals(orderId))).get();
    return rows.map(_mapSaleOrderLineRow).toList();
  }

  @override
  Future<List<SaleOrder>> listSaleOrders({
    required String organizationId,
    OrderStatus? status,
  }) async {
    final query = select(saleOrders)
      ..where((order) {
        var expression = order.organizationId.equals(organizationId);
        if (status != null) {
          expression = expression & order.status.equals(status.name);
        }
        return expression;
      })
      ..orderBy([(order) => OrderingTerm.desc(order.createdAtUtcMs)]);
    return (await query.get()).map(_mapSaleOrderRow).toList();
  }

  Future<List<SaleOrder>> getOrdersByCustomer(
    String organizationId,
    String partyId,
  ) async =>
      (await listSaleOrders(organizationId: organizationId))
          .where((order) => order.customerPartyId == partyId)
          .toList();

  @override
  Future<void> saveWarrantyEntitlement(WarrantyEntitlement entitlement) async {
    await into(warranties).insertOnConflictUpdate(
      WarrantiesCompanion.insert(
        id: entitlement.id,
        serialId: entitlement.serialId,
        productId: entitlement.productId,
        serialNumber: entitlement.serialNumber,
        partyId: entitlement.partyId,
        saleDocumentId: entitlement.saleDocumentId,
        startDateMs: entitlement.startDate.millisecondsSinceEpoch,
        endDateMs: entitlement.endDate.millisecondsSinceEpoch,
        termsSnapshot: entitlement.termsSnapshot,
        createdAtUtcMs: entitlement.createdAtUtc.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<List<WarrantyEntitlement>> getWarrantyEntitlementsForCustomer({
    required String organizationId,
    required String partyId,
  }) async {
    final query = select(warranties)..where((w) => w.partyId.equals(partyId));
    final rows = await query.get();
    return rows.map(_mapWarrantyRow).toList();
  }

  @override
  Future<List<WarrantyEntitlement>> getAllWarrantyEntitlements({
    required String organizationId,
  }) async {
    final query = select(warranties);
    final rows = await query.get();
    return rows.map(_mapWarrantyRow).toList();
  }

  SaleHeader _mapSaleHeaderRow(SaleHeaderRow r) {
    return SaleHeader(
      id: r.id,
      organizationId: r.organizationId,
      branchId: r.branchId,
      documentHeaderId: r.documentHeaderId,
      customerPartyId: r.customerPartyId,
      customerName: r.customerName,
      businessDate: _fromEpoch(r.businessDateMs),
      locationId: r.locationId,
      status: SaleStatus.values.firstWhere(
        (s) => s.name == r.status,
        orElse: () => SaleStatus.posted,
      ),
      subtotalPaise: Money.fromPaise(r.subtotalPaise),
      allocatedDiscountPaise: Money.fromPaise(r.allocatedDiscountPaise),
      totalTaxPaise: Money.fromPaise(r.totalTaxPaise),
      grandTotalPaise: Money.fromPaise(r.grandTotalPaise),
      amountPaidPaise: Money.fromPaise(r.amountPaidPaise),
      balanceDuePaise: Money.fromPaise(r.balanceDuePaise),
      createdAtUtc: _fromEpoch(r.createdAtUtcMs),
      notes: r.notes,
    );
  }

  SaleLine _mapSaleLineRow(SaleLineRow r) {
    final taxMap = jsonDecode(r.taxSnapshotJson) as Map<String, dynamic>;
    final taxSnapshot = TaxLineResult(
      lineId: taxMap['lineId'] as String? ?? r.id,
      taxableAmount: Money.fromPaise(taxMap['taxableAmount'] as int? ?? 0),
      cgst: Money.fromPaise(taxMap['cgst'] as int? ?? 0),
      sgst: Money.fromPaise(taxMap['sgst'] as int? ?? 0),
      igst: Money.fromPaise(taxMap['igst'] as int? ?? 0),
      totalTax: Money.fromPaise(taxMap['totalTax'] as int? ?? 0),
      totalAmount: Money.fromPaise(taxMap['totalAmount'] as int? ?? 0),
    );

    final serialsList = (jsonDecode(r.serialsJson) as List<dynamic>)
        .map((e) => e.toString())
        .toList();

    return SaleLine(
      id: r.id,
      saleId: r.saleId,
      productId: r.productId,
      productName: r.productName,
      sku: r.sku,
      hsnCode: r.hsnCode,
      baseUnit: r.baseUnit,
      quantity: Quantity.fromUnits(r.quantityMicroUnits / 1000000.0),
      unitPrice: UnitPrice.fromRupees(r.unitPriceMicroRupees / 1000000.0),
      lineDiscountPaise: Money.fromPaise(r.lineDiscountPaise),
      taxSnapshot: taxSnapshot,
      costSnapshotMicroRupees: r.costSnapshotMicroRupees,
      netTotalPaise: Money.fromPaise(r.netTotalPaise),
      serials: serialsList,
      batchLot: r.batchLot,
    );
  }

  SaleDraft _mapSaleDraftRow(SaleDraftRow r) {
    return SaleDraft(
      id: r.id,
      organizationId: r.organizationId,
      branchId: r.branchId,
      customerPartyId: r.customerPartyId,
      customerName: r.customerName,
      linesJson: r.linesJson,
      updatedAtUtc: _fromEpoch(r.updatedAtUtcMs),
      notes: r.notes,
    );
  }

  SaleOrder _mapSaleOrderRow(SaleOrderRow r) {
    return SaleOrder(
      id: r.id,
      organizationId: r.organizationId,
      branchId: r.branchId,
      customerPartyId: r.customerPartyId,
      customerName: r.customerName,
      customerPhone: r.customerPhone,
      orderDate: _fromEpoch(r.orderDateMs),
      status: OrderStatus.values.firstWhere(
        (status) => status.name == r.status,
        orElse: () => OrderStatus.pending,
      ),
      quotationId: r.quotationId,
      saleHeaderId: r.saleHeaderId,
      grandTotalPaise: Money.fromPaise(r.grandTotalPaise),
      expectedDeliveryDate: r.expectedDeliveryDateMs == null
          ? null
          : _fromEpoch(r.expectedDeliveryDateMs!),
      notes: r.notes,
      createdAtUtc: _fromEpoch(r.createdAtUtcMs),
    );
  }

  SaleOrderLine _mapSaleOrderLineRow(SaleOrderLineRow r) {
    return SaleOrderLine(
      id: r.id,
      orderId: r.orderId,
      productId: r.productId,
      productName: r.productName,
      quantity: Quantity.fromUnits(r.quantityMicroUnits / 1000000.0),
      unitPrice: UnitPrice.fromRupees(r.unitPriceMicroRupees / 1000000.0),
      taxRate: TaxRate.fromBps(r.taxRateBps),
      isInStock: r.isInStock,
    );
  }

  WarrantyEntitlement _mapWarrantyRow(WarrantyRow r) {
    return WarrantyEntitlement(
      id: r.id,
      serialId: r.serialId,
      productId: r.productId,
      serialNumber: r.serialNumber,
      partyId: r.partyId,
      saleDocumentId: r.saleDocumentId,
      startDate: _fromEpoch(r.startDateMs),
      endDate: _fromEpoch(r.endDateMs),
      termsSnapshot: r.termsSnapshot,
      createdAtUtc: _fromEpoch(r.createdAtUtcMs),
    );
  }

  // ---------------------------------------------------------------------
  // FinanceStore Implementation
  // ---------------------------------------------------------------------

  @override
  Future<void> saveSalesReturn({
    required SalesReturnHeader header,
    required List<SalesReturnLine> lines,
  }) async {
    await transaction(() async {
      await into(salesReturnHeaders).insert(
        SalesReturnHeadersCompanion.insert(
          id: header.id,
          organizationId: header.organizationId,
          branchId: header.branchId,
          documentHeaderId: header.documentHeaderId,
          originalSaleId: header.originalSaleId,
          customerPartyId: header.customerPartyId,
          customerName: header.customerName,
          returnDateMs: header.returnDate.millisecondsSinceEpoch,
          locationId: header.locationId,
          status: Value(header.status.name),
          subtotalPaise: header.subtotalPaise.paise,
          totalTaxPaise: header.totalTaxPaise.paise,
          grandTotalPaise: header.grandTotalPaise.paise,
          refundedAmountPaise: header.refundedAmountPaise.paise,
          createdAtUtcMs: header.createdAtUtc.millisecondsSinceEpoch,
          reason: Value(header.reason),
          notes: Value(header.notes),
        ),
      );
      for (final line in lines) {
        final taxJson = jsonEncode({
          'lineId': line.id,
          'taxableAmount': line.taxSnapshot.taxableAmount.paise,
          'cgst': line.taxSnapshot.cgst.paise,
          'sgst': line.taxSnapshot.sgst.paise,
          'igst': line.taxSnapshot.igst.paise,
          'totalTax': line.taxSnapshot.totalTax.paise,
          'totalAmount': line.taxSnapshot.totalAmount.paise,
        });
        await into(salesReturnLines).insert(
          SalesReturnLinesCompanion.insert(
            id: line.id,
            salesReturnId: line.salesReturnId,
            saleLineId: line.saleLineId,
            productId: line.productId,
            productName: line.productName,
            sku: line.sku,
            quantityMicroUnits: line.quantity.microUnits,
            unitPriceMicroRupees: line.unitPrice.microRupees,
            lineDiscountPaise: line.lineDiscountPaise.paise,
            taxSnapshotJson: taxJson,
            costSnapshotMicroRupees: line.costSnapshotMicroRupees,
            netTotalPaise: line.netTotalPaise.paise,
            serialsJson: Value(jsonEncode(line.serials)),
            disposition: Value(line.disposition.name),
          ),
        );
      }
    });
  }

  @override
  Future<SalesReturnHeader?> getSalesReturnHeader(String id) async {
    final query = select(salesReturnHeaders)..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapSalesReturnHeaderRow(row);
  }

  @override
  Future<List<SalesReturnLine>> getSalesReturnLines(
    String salesReturnId,
  ) async {
    final query = select(salesReturnLines)
      ..where((tbl) => tbl.salesReturnId.equals(salesReturnId));
    final rows = await query.get();
    return rows.map(_mapSalesReturnLineRow).toList();
  }

  @override
  Future<List<SalesReturnHeader>> listSalesReturns(
    String organizationId,
  ) async {
    final query = select(salesReturnHeaders)
      ..where((tbl) => tbl.organizationId.equals(organizationId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.returnDateMs)]);
    final rows = await query.get();
    return rows.map(_mapSalesReturnHeaderRow).toList();
  }

  @override
  Future<void> savePurchaseReturn({
    required PurchaseReturnHeader header,
    required List<PurchaseReturnLine> lines,
  }) async {
    await transaction(() async {
      await into(purchaseReturnHeaders).insert(
        PurchaseReturnHeadersCompanion.insert(
          id: header.id,
          organizationId: header.organizationId,
          branchId: header.branchId,
          documentHeaderId: header.documentHeaderId,
          originalPurchaseId: header.originalPurchaseId,
          supplierId: header.supplierId,
          supplierName: header.supplierName,
          returnDateMs: header.returnDate.millisecondsSinceEpoch,
          locationId: header.locationId,
          status: Value(header.status.name),
          subtotalPaise: header.subtotalPaise.paise,
          totalTaxPaise: header.totalTaxPaise.paise,
          grandTotalPaise: header.grandTotalPaise.paise,
          createdAtUtcMs: header.createdAtUtc.millisecondsSinceEpoch,
          reason: Value(header.reason),
          notes: Value(header.notes),
        ),
      );
      for (final line in lines) {
        final taxJson = jsonEncode({
          'lineId': line.id,
          'taxableAmount': line.taxSnapshot.taxableAmount.paise,
          'cgst': line.taxSnapshot.cgst.paise,
          'sgst': line.taxSnapshot.sgst.paise,
          'igst': line.taxSnapshot.igst.paise,
          'totalTax': line.taxSnapshot.totalTax.paise,
          'totalAmount': line.taxSnapshot.totalAmount.paise,
        });
        await into(purchaseReturnLines).insert(
          PurchaseReturnLinesCompanion.insert(
            id: line.id,
            purchaseReturnId: line.purchaseReturnId,
            purchaseLineId: line.purchaseLineId,
            productId: line.productId,
            productName: line.productName,
            sku: line.sku,
            quantityMicroUnits: line.quantity.microUnits,
            unitPurchasePriceMicroRupees: line.unitPurchasePrice.microRupees,
            taxSnapshotJson: taxJson,
            netTotalPaise: line.netTotalPaise.paise,
            serialsJson: Value(jsonEncode(line.serials)),
          ),
        );
      }
    });
  }

  @override
  Future<PurchaseReturnHeader?> getPurchaseReturnHeader(String id) async {
    final query = select(purchaseReturnHeaders)
      ..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapPurchaseReturnHeaderRow(row);
  }

  @override
  Future<List<PurchaseReturnLine>> getPurchaseReturnLines(
    String purchaseReturnId,
  ) async {
    final query = select(purchaseReturnLines)
      ..where((tbl) => tbl.purchaseReturnId.equals(purchaseReturnId));
    final rows = await query.get();
    return rows.map(_mapPurchaseReturnLineRow).toList();
  }

  @override
  Future<List<PurchaseReturnHeader>> listPurchaseReturns(
    String organizationId,
  ) async {
    final query = select(purchaseReturnHeaders)
      ..where((tbl) => tbl.organizationId.equals(organizationId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.returnDateMs)]);
    final rows = await query.get();
    return rows.map(_mapPurchaseReturnHeaderRow).toList();
  }

  @override
  Future<void> saveExpenseCategory(ExpenseCategory category) async {
    await into(expenseCategories).insertOnConflictUpdate(
      ExpenseCategoriesCompanion.insert(
        id: category.id,
        organizationId: category.organizationId,
        name: category.name,
        accountCode: category.accountCode,
        active: Value(category.active),
      ),
    );
  }

  @override
  Future<List<ExpenseCategory>> getExpenseCategories(
    String organizationId,
  ) async {
    final query = select(expenseCategories)
      ..where(
        (tbl) =>
            tbl.organizationId.equals(organizationId) |
            tbl.organizationId.equals('default_org') |
            tbl.organizationId.equals(''),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.accountCode)]);
    final rows = await query.get();
    return rows.map(_mapExpenseCategoryRow).toList();
  }

  @override
  Future<void> saveExpenseEntry(ExpenseEntry entry) async {
    await into(expenseEntries).insert(
      ExpenseEntriesCompanion.insert(
        id: entry.id,
        organizationId: entry.organizationId,
        branchId: entry.branchId,
        categoryId: entry.categoryId,
        categoryName: entry.categoryName,
        accountCode: entry.accountCode,
        amountPaise: entry.amountPaise.paise,
        expenseDateMs: entry.expenseDate.millisecondsSinceEpoch,
        paymentMethod: entry.paymentMethod,
        createdAtUtcMs: entry.createdAtUtc.millisecondsSinceEpoch,
        referenceNumber: Value(entry.referenceNumber),
        notes: Value(entry.notes),
      ),
    );
  }

  @override
  Future<List<ExpenseEntry>> listExpenseEntries(
    String organizationId, {
    String? categoryId,
  }) async {
    final query = select(expenseEntries)
      ..where((tbl) {
        var expr = tbl.organizationId.equals(organizationId);
        if (categoryId != null && categoryId.isNotEmpty) {
          expr = expr & tbl.categoryId.equals(categoryId);
        }
        return expr;
      })
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.expenseDateMs)]);
    final rows = await query.get();
    return rows.map(_mapExpenseEntryRow).toList();
  }

  @override
  Future<void> saveCashSession(CashSession session) async {
    await into(cashSessions).insertOnConflictUpdate(
      CashSessionsCompanion.insert(
        id: session.id,
        organizationId: session.organizationId,
        branchId: session.branchId,
        userId: session.userId,
        username: session.username,
        openedAtUtcMs: session.openedAtUtc.millisecondsSinceEpoch,
        closedAtUtcMs: Value(session.closedAtUtc?.millisecondsSinceEpoch),
        openingCashPaise: session.openingCashPaise.paise,
        expectedCashPaise: session.expectedCashPaise.paise,
        countedCashPaise: session.countedCashPaise.paise,
        variancePaise: session.variancePaise.paise,
        status: Value(session.status.name),
        notes: Value(session.notes),
      ),
    );
  }

  @override
  Future<CashSession?> getActiveCashSession(
    String organizationId,
    String userId,
  ) async {
    final query = select(cashSessions)
      ..where(
        (tbl) =>
            tbl.organizationId.equals(organizationId) &
            tbl.userId.equals(userId) &
            tbl.status.equals(CashSessionStatus.open.name),
      );
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapCashSessionRow(row);
  }

  @override
  Future<List<CashSession>> listCashSessions(String organizationId) async {
    final query = select(cashSessions)
      ..where((tbl) => tbl.organizationId.equals(organizationId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.openedAtUtcMs)]);
    final rows = await query.get();
    return rows.map(_mapCashSessionRow).toList();
  }

  @override
  Future<List<PartyAgingBucket>> getPartyAgingBuckets(
    String organizationId, {
    required bool isCustomer,
  }) async {
    final partiesQuery = select(parties)
      ..where(
        (tbl) =>
            tbl.organizationId.equals(organizationId) &
            (isCustomer
                ? tbl.isCustomer.equals(true)
                : tbl.isSupplier.equals(true)),
      );
    final partyRows = await partiesQuery.get();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final List<PartyAgingBucket> buckets = [];

    for (final p in partyRows) {
      int d0to30 = 0;
      int d31to60 = 0;
      int d61to90 = 0;
      int d90Plus = 0;

      if (isCustomer) {
        final salesQuery = select(saleHeaders)
          ..where(
            (tbl) =>
                tbl.organizationId.equals(organizationId) &
                tbl.customerPartyId.equals(p.id) &
                tbl.balanceDuePaise.isBiggerThanValue(0),
          );
        final sales = await salesQuery.get();
        for (final s in sales) {
          final diffDays = ((nowMs - s.businessDateMs) / (1000 * 3600 * 24))
              .floor();
          final bal = s.balanceDuePaise;
          if (diffDays <= 30) {
            d0to30 += bal;
          } else if (diffDays <= 60) {
            d31to60 += bal;
          } else if (diffDays <= 90) {
            d61to90 += bal;
          } else {
            d90Plus += bal;
          }
        }
      } else {
        final purchasesQuery = select(purchaseHeaders)
          ..where(
            (tbl) =>
                tbl.organizationId.equals(organizationId) &
                tbl.supplierId.equals(p.id) &
                tbl.balanceDuePaise.isBiggerThanValue(0),
          );
        final purchases = await purchasesQuery.get();
        for (final pur in purchases) {
          final diffDays = ((nowMs - pur.invoiceDateMs) / (1000 * 3600 * 24))
              .floor();
          final bal = pur.balanceDuePaise;
          if (diffDays <= 30) {
            d0to30 += bal;
          } else if (diffDays <= 60) {
            d31to60 += bal;
          } else if (diffDays <= 90) {
            d61to90 += bal;
          } else {
            d90Plus += bal;
          }
        }
      }

      buckets.add(
        PartyAgingBucket(
          partyId: p.id,
          partyName: p.name,
          days0To30: Money.fromPaise(d0to30),
          days31To60: Money.fromPaise(d31to60),
          days61To90: Money.fromPaise(d61to90),
          days90Plus: Money.fromPaise(d90Plus),
        ),
      );
    }
    return buckets;
  }

  SalesReturnHeader _mapSalesReturnHeaderRow(SalesReturnHeaderRow r) {
    return SalesReturnHeader(
      id: r.id,
      organizationId: r.organizationId,
      branchId: r.branchId,
      documentHeaderId: r.documentHeaderId,
      originalSaleId: r.originalSaleId,
      customerPartyId: r.customerPartyId,
      customerName: r.customerName,
      returnDate: _fromEpoch(r.returnDateMs),
      locationId: r.locationId,
      status: SalesReturnStatus.values.firstWhere(
        (e) => e.name == r.status,
        orElse: () => SalesReturnStatus.posted,
      ),
      subtotalPaise: Money.fromPaise(r.subtotalPaise),
      totalTaxPaise: Money.fromPaise(r.totalTaxPaise),
      grandTotalPaise: Money.fromPaise(r.grandTotalPaise),
      refundedAmountPaise: Money.fromPaise(r.refundedAmountPaise),
      createdAtUtc: _fromEpoch(r.createdAtUtcMs),
      reason: r.reason,
      notes: r.notes,
    );
  }

  SalesReturnLine _mapSalesReturnLineRow(SalesReturnLineRow r) {
    final taxMap = jsonDecode(r.taxSnapshotJson) as Map<String, dynamic>;
    final taxSnapshot = TaxLineResult(
      lineId: taxMap['lineId'] as String? ?? r.id,
      taxableAmount: Money.fromPaise(taxMap['taxableAmount'] as int? ?? 0),
      cgst: Money.fromPaise(taxMap['cgst'] as int? ?? 0),
      sgst: Money.fromPaise(taxMap['sgst'] as int? ?? 0),
      igst: Money.fromPaise(taxMap['igst'] as int? ?? 0),
      totalTax: Money.fromPaise(taxMap['totalTax'] as int? ?? 0),
      totalAmount: Money.fromPaise(taxMap['totalAmount'] as int? ?? 0),
    );

    final serialsList = (jsonDecode(r.serialsJson) as List<dynamic>)
        .map((e) => e.toString())
        .toList();

    return SalesReturnLine(
      id: r.id,
      salesReturnId: r.salesReturnId,
      saleLineId: r.saleLineId,
      productId: r.productId,
      productName: r.productName,
      sku: r.sku,
      quantity: Quantity.fromUnits(r.quantityMicroUnits / 1000000.0),
      unitPrice: UnitPrice.fromRupees(r.unitPriceMicroRupees / 1000000.0),
      lineDiscountPaise: Money.fromPaise(r.lineDiscountPaise),
      taxSnapshot: taxSnapshot,
      costSnapshotMicroRupees: r.costSnapshotMicroRupees,
      netTotalPaise: Money.fromPaise(r.netTotalPaise),
      serials: serialsList,
      disposition: ReturnDisposition.values.firstWhere(
        (e) => e.name == r.disposition,
        orElse: () => ReturnDisposition.returnToStock,
      ),
    );
  }

  PurchaseReturnHeader _mapPurchaseReturnHeaderRow(PurchaseReturnHeaderRow r) {
    return PurchaseReturnHeader(
      id: r.id,
      organizationId: r.organizationId,
      branchId: r.branchId,
      documentHeaderId: r.documentHeaderId,
      originalPurchaseId: r.originalPurchaseId,
      supplierId: r.supplierId,
      supplierName: r.supplierName,
      returnDate: _fromEpoch(r.returnDateMs),
      locationId: r.locationId,
      status: PurchaseReturnStatus.values.firstWhere(
        (e) => e.name == r.status,
        orElse: () => PurchaseReturnStatus.posted,
      ),
      subtotalPaise: Money.fromPaise(r.subtotalPaise),
      totalTaxPaise: Money.fromPaise(r.totalTaxPaise),
      grandTotalPaise: Money.fromPaise(r.grandTotalPaise),
      createdAtUtc: _fromEpoch(r.createdAtUtcMs),
      reason: r.reason,
      notes: r.notes,
    );
  }

  PurchaseReturnLine _mapPurchaseReturnLineRow(PurchaseReturnLineRow r) {
    final taxMap = jsonDecode(r.taxSnapshotJson) as Map<String, dynamic>;
    final taxSnapshot = TaxLineResult(
      lineId: taxMap['lineId'] as String? ?? r.id,
      taxableAmount: Money.fromPaise(taxMap['taxableAmount'] as int? ?? 0),
      cgst: Money.fromPaise(taxMap['cgst'] as int? ?? 0),
      sgst: Money.fromPaise(taxMap['sgst'] as int? ?? 0),
      igst: Money.fromPaise(taxMap['igst'] as int? ?? 0),
      totalTax: Money.fromPaise(taxMap['totalTax'] as int? ?? 0),
      totalAmount: Money.fromPaise(taxMap['totalAmount'] as int? ?? 0),
    );

    final serialsList = (jsonDecode(r.serialsJson) as List<dynamic>)
        .map((e) => e.toString())
        .toList();

    return PurchaseReturnLine(
      id: r.id,
      purchaseReturnId: r.purchaseReturnId,
      purchaseLineId: r.purchaseLineId,
      productId: r.productId,
      productName: r.productName,
      sku: r.sku,
      quantity: Quantity.fromUnits(r.quantityMicroUnits / 1000000.0),
      unitPurchasePrice: UnitPrice.fromRupees(
        r.unitPurchasePriceMicroRupees / 1000000.0,
      ),
      taxSnapshot: taxSnapshot,
      netTotalPaise: Money.fromPaise(r.netTotalPaise),
      serials: serialsList,
    );
  }

  ExpenseCategory _mapExpenseCategoryRow(ExpenseCategoryRow r) {
    return ExpenseCategory(
      id: r.id,
      organizationId: r.organizationId,
      name: r.name,
      accountCode: r.accountCode,
      active: r.active,
    );
  }

  ExpenseEntry _mapExpenseEntryRow(ExpenseEntryRow r) {
    return ExpenseEntry(
      id: r.id,
      organizationId: r.organizationId,
      branchId: r.branchId,
      categoryId: r.categoryId,
      categoryName: r.categoryName,
      accountCode: r.accountCode,
      amountPaise: Money.fromPaise(r.amountPaise),
      expenseDate: _fromEpoch(r.expenseDateMs),
      paymentMethod: r.paymentMethod,
      createdAtUtc: _fromEpoch(r.createdAtUtcMs),
      referenceNumber: r.referenceNumber,
      notes: r.notes,
    );
  }

  CashSession _mapCashSessionRow(CashSessionRow r) {
    return CashSession(
      id: r.id,
      organizationId: r.organizationId,
      branchId: r.branchId,
      userId: r.userId,
      username: r.username,
      openedAtUtc: _fromEpoch(r.openedAtUtcMs),
      closedAtUtc: r.closedAtUtcMs != null
          ? _fromEpoch(r.closedAtUtcMs!)
          : null,
      openingCashPaise: Money.fromPaise(r.openingCashPaise),
      expectedCashPaise: Money.fromPaise(r.expectedCashPaise),
      countedCashPaise: Money.fromPaise(r.countedCashPaise),
      variancePaise: Money.fromPaise(r.variancePaise),
      status: CashSessionStatus.values.firstWhere(
        (e) => e.name == r.status,
        orElse: () => CashSessionStatus.open,
      ),
      notes: r.notes,
    );
  }

  @override
  Future<void> createVerifiedSnapshot(String targetPath) async {
    final target = File(targetPath).absolute;
    if (target.path == _file.absolute.path) {
      throw const StorageFailure(
        'snapshot.invalid_target',
        'Choose a different recovery snapshot location.',
      );
    }
    target.parent.createSync(recursive: true);
    final staging = File('${target.path}.staging');
    if (staging.existsSync()) staging.deleteSync();
    if (target.existsSync()) {
      throw const StorageFailure(
        'snapshot.target_exists',
        'A recovery snapshot already exists at that location.',
      );
    }
    try {
      await customStatement('PRAGMA wal_checkpoint(FULL)');
      await customStatement('VACUUM INTO ?', [staging.path]);
      _verifyEncryptedFile(staging, _key);
      staging.renameSync(target.path);
    } catch (_) {
      if (staging.existsSync()) staging.deleteSync();
      rethrow;
    }
  }

  // ---------------------------------------------------------------------
  // ProjectStore Implementation
  // ---------------------------------------------------------------------

  // ---------------------------------------------------------------------
  // KitStore Implementation
  // ---------------------------------------------------------------------

  @override
  Future<void> saveKit({required Kit kit, required List<KitLine> lines}) async {
    await transaction(() async {
      await into(kits).insertOnConflictUpdate(
        KitsCompanion.insert(
          id: kit.id,
          organizationId: kit.organizationId,
          name: kit.name,
          category: kit.category,
          capacityKw: Value(kit.capacityKw),
          installationChargesPaise: Value(kit.installationChargesPaise.paise),
          active: Value(kit.active),
          createdAtUtcMs: kit.createdAtUtc.millisecondsSinceEpoch,
          updatedAtUtcMs: kit.updatedAtUtc.millisecondsSinceEpoch,
        ),
      );
      await (delete(kitLines)..where((line) => line.kitId.equals(kit.id))).go();
      for (final line in lines) {
        await into(kitLines).insert(
          KitLinesCompanion.insert(
            id: line.id,
            kitId: line.kitId,
            productId: line.productId,
            quantityMicroUnits: line.quantity.microUnits,
            sortOrder: line.sortOrder,
          ),
        );
      }
    });
  }

  @override
  Future<Kit?> getKit(String organizationId, String kitId) async {
    final row = await (select(kits)..where(
      (kit) => kit.organizationId.equals(organizationId) & kit.id.equals(kitId),
    )).getSingleOrNull();
    return row == null ? null : _mapKit(row);
  }

  @override
  Future<List<Kit>> listKits(String organizationId, {bool includeInactive = false}) async {
    final query = select(kits)..where((kit) => kit.organizationId.equals(organizationId));
    if (!includeInactive) query.where((kit) => kit.active.equals(true));
    final rows = await (query..orderBy([(kit) => OrderingTerm.asc(kit.name)])).get();
    return rows.map(_mapKit).toList();
  }

  @override
  Future<List<KitLine>> getKitLines(String kitId) async {
    final rows = await (select(kitLines)
          ..where((line) => line.kitId.equals(kitId))
          ..orderBy([(line) => OrderingTerm.asc(line.sortOrder)]))
        .get();
    return rows.map(_mapKitLine).toList();
  }

  @override
  Future<void> deleteKit(String organizationId, String kitId) async {
    await transaction(() async {
      await (delete(kitLines)..where((line) => line.kitId.equals(kitId))).go();
      await (delete(kits)..where(
        (kit) => kit.organizationId.equals(organizationId) & kit.id.equals(kitId),
      )).go();
    });
  }

  @override
  Future<void> saveQuotation({
    required QuotationHeader header,
    required List<QuotationLine> lines,
  }) async {
    await into(quotations).insertOnConflictUpdate(
      QuotationsCompanion.insert(
        id: header.id,
        organizationId: header.organizationId,
        branchId: header.branchId,
        quotationNumber: header.quotationNumber,
        revisionNumber: header.revisionNumber,
        customerPartyId: header.customerPartyId,
        customerName: header.customerName,
        validUntilMs: header.validUntil.millisecondsSinceEpoch,
        status: Value(header.status.name),
        subtotalPaise: header.subtotalPaise.paise,
        allocatedDiscountPaise: header.allocatedDiscountPaise.paise,
        totalTaxPaise: header.totalTaxPaise.paise,
        grandTotalPaise: header.grandTotalPaise.paise,
        installationChargesPaise: header.installationChargesPaise.paise,
        termsSnapshot: header.termsSnapshot,
        createdAtUtcMs: header.createdAtUtc.millisecondsSinceEpoch,
      ),
    );

    for (final line in lines) {
      final taxSnapshotJson = jsonEncode({
        'lineId': line.taxSnapshot.lineId,
        'taxableAmount': line.taxSnapshot.taxableAmount.paise,
        'cgst': line.taxSnapshot.cgst.paise,
        'sgst': line.taxSnapshot.sgst.paise,
        'igst': line.taxSnapshot.igst.paise,
        'totalTax': line.taxSnapshot.totalTax.paise,
        'totalAmount': line.taxSnapshot.totalAmount.paise,
      });

      await into(quotationLines).insertOnConflictUpdate(
        QuotationLinesCompanion.insert(
          id: line.id,
          quotationId: line.quotationId,
          productId: line.productId,
          productName: line.productName,
          sku: line.sku,
          hsnCode: line.hsnCode,
          quantityMicroUnits: line.quantity.microUnits,
          unitPriceMicroRupees: line.unitPrice.microRupees,
          lineDiscountPaise: line.lineDiscountPaise.paise,
          taxSnapshotJson: taxSnapshotJson,
          netTotalPaise: line.netTotalPaise.paise,
          isServiceLine: Value(line.isServiceLine),
          bomSnapshotJson: Value(line.bomSnapshotJson),
        ),
      );
    }
  }

  @override
  Future<QuotationHeader?> getQuotationHeader(String id) async {
    final row = await (select(
      quotations,
    )..where((q) => q.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _mapQuotationHeader(row);
  }

  @override
  Future<List<QuotationLine>> getQuotationLines(String quotationId) async {
    final rows = await (select(
      quotationLines,
    )..where((q) => q.quotationId.equals(quotationId))).get();
    return rows.map(_mapQuotationLine).toList();
  }

  @override
  Future<List<QuotationHeader>> listQuotations(String organizationId) async {
    final rows = await (select(
      quotations,
    )..where((q) => q.organizationId.equals(organizationId))).get();
    return rows.map(_mapQuotationHeader).toList();
  }

  Future<List<QuotationHeader>> getQuotationsByCustomer(
    String organizationId,
    String partyId,
  ) async =>
      (await listQuotations(organizationId))
          .where((quote) => quote.customerPartyId == partyId)
          .toList();

  @override
  Future<void> saveProject(SolarProject project) async {
    await into(solarProjects).insertOnConflictUpdate(
      SolarProjectsCompanion.insert(
        id: project.id,
        organizationId: project.organizationId,
        branchId: project.branchId,
        projectNumber: project.projectNumber,
        name: project.name,
        customerPartyId: project.customerPartyId,
        customerName: project.customerName,
        siteAddress: project.siteAddress,
        acceptedQuotationId: project.acceptedQuotationId,
        acceptedQuotationRevision: project.acceptedQuotationRevision,
        status: Value(project.status.name),
        budgetMaterialsPaise: project.budgetMaterialsPaise.paise,
        budgetLaborPaise: project.budgetLaborPaise.paise,
        actualMaterialsPaise: project.actualMaterialsPaise.paise,
        actualExpensesPaise: project.actualExpensesPaise.paise,
        invoicedPaise: project.invoicedPaise.paise,
        wipBalancePaise: project.wipBalancePaise.paise,
        createdAtUtcMs: project.createdAtUtc.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<SolarProject?> getProject(String id) async {
    final row = await (select(
      solarProjects,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _mapSolarProject(row);
  }

  @override
  Future<List<SolarProject>> listProjects(String organizationId) async {
    final rows = await (select(
      solarProjects,
    )..where((p) => p.organizationId.equals(organizationId))).get();
    return rows.map(_mapSolarProject).toList();
  }

  Future<List<SolarProject>> getProjectsByCustomer(
    String organizationId,
    String partyId,
  ) async =>
      (await listProjects(organizationId))
          .where((project) => project.customerPartyId == partyId)
          .toList();

  @override
  Future<void> saveMaterialIssue({required ProjectMaterialIssue issue}) async {
    await into(projectMaterialIssues).insertOnConflictUpdate(
      ProjectMaterialIssuesCompanion.insert(
        id: issue.id,
        organizationId: issue.organizationId,
        branchId: issue.branchId,
        projectId: issue.projectId,
        locationId: issue.locationId,
        issueDateMs: issue.issueDate.millisecondsSinceEpoch,
        totalCostPaise: issue.totalCostPaise.paise,
        createdAtUtcMs: issue.createdAtUtc.millisecondsSinceEpoch,
        notes: Value(issue.notes),
      ),
    );

    for (final line in issue.lines) {
      await into(projectMaterialIssueLines).insertOnConflictUpdate(
        ProjectMaterialIssueLinesCompanion.insert(
          id: line.id,
          issueId: line.issueId,
          productId: line.productId,
          productName: line.productName,
          sku: line.sku,
          quantityMicroUnits: line.quantity.microUnits,
          costSnapshotMicroRupees: line.costSnapshotMicroRupees,
          serialsJson: Value(jsonEncode(line.serials)),
        ),
      );
    }
  }

  @override
  Future<List<ProjectMaterialIssue>> getMaterialIssues(String projectId) async {
    final issueRows = await (select(
      projectMaterialIssues,
    )..where((i) => i.projectId.equals(projectId))).get();
    final issues = <ProjectMaterialIssue>[];

    for (final issueRow in issueRows) {
      final lineRows = await (select(
        projectMaterialIssueLines,
      )..where((l) => l.issueId.equals(issueRow.id))).get();
      final lines = lineRows.map(_mapProjectMaterialIssueLine).toList();
      issues.add(_mapProjectMaterialIssue(issueRow, lines));
    }

    return issues;
  }

  Kit _mapKit(KitRow r) => Kit(
    id: r.id,
    organizationId: r.organizationId,
    name: r.name,
    category: r.category,
    capacityKw: r.capacityKw,
    installationChargesPaise: Money.fromPaise(r.installationChargesPaise),
    active: r.active,
    createdAtUtc: DateTime.fromMillisecondsSinceEpoch(r.createdAtUtcMs),
    updatedAtUtc: DateTime.fromMillisecondsSinceEpoch(r.updatedAtUtcMs),
  );

  KitLine _mapKitLine(KitLineRow r) => KitLine(
    id: r.id,
    kitId: r.kitId,
    productId: r.productId,
    quantity: Quantity.fromUnits(r.quantityMicroUnits / 1000000),
    sortOrder: r.sortOrder,
  );

  QuotationHeader _mapQuotationHeader(QuotationHeaderRow r) {
    return QuotationHeader(
      id: r.id,
      organizationId: r.organizationId,
      branchId: r.branchId,
      quotationNumber: r.quotationNumber,
      revisionNumber: r.revisionNumber,
      customerPartyId: r.customerPartyId,
      customerName: r.customerName,
      validUntil: _fromEpoch(r.validUntilMs),
      status: QuotationStatus.values.firstWhere(
        (s) => s.name == r.status,
        orElse: () => QuotationStatus.draft,
      ),
      subtotalPaise: Money.fromPaise(r.subtotalPaise),
      allocatedDiscountPaise: Money.fromPaise(r.allocatedDiscountPaise),
      totalTaxPaise: Money.fromPaise(r.totalTaxPaise),
      grandTotalPaise: Money.fromPaise(r.grandTotalPaise),
      installationChargesPaise: Money.fromPaise(r.installationChargesPaise),
      termsSnapshot: r.termsSnapshot,
      createdAtUtc: _fromEpoch(r.createdAtUtcMs),
    );
  }

  QuotationLine _mapQuotationLine(QuotationLineRow r) {
    final taxMap = jsonDecode(r.taxSnapshotJson) as Map<String, dynamic>;
    final taxSnapshot = TaxLineResult(
      lineId: taxMap['lineId'] as String? ?? r.id,
      taxableAmount: Money.fromPaise(taxMap['taxableAmount'] as int? ?? 0),
      cgst: Money.fromPaise(taxMap['cgst'] as int? ?? 0),
      sgst: Money.fromPaise(taxMap['sgst'] as int? ?? 0),
      igst: Money.fromPaise(taxMap['igst'] as int? ?? 0),
      totalTax: Money.fromPaise(taxMap['totalTax'] as int? ?? 0),
      totalAmount: Money.fromPaise(taxMap['totalAmount'] as int? ?? 0),
    );

    return QuotationLine(
      id: r.id,
      quotationId: r.quotationId,
      productId: r.productId,
      productName: r.productName,
      sku: r.sku,
      hsnCode: r.hsnCode,
      quantity: Quantity.fromUnits(r.quantityMicroUnits / 1000000.0),
      unitPrice: UnitPrice.fromRupees(r.unitPriceMicroRupees / 1000000.0),
      lineDiscountPaise: Money.fromPaise(r.lineDiscountPaise),
      taxSnapshot: taxSnapshot,
      netTotalPaise: Money.fromPaise(r.netTotalPaise),
      isServiceLine: r.isServiceLine,
      bomSnapshotJson: r.bomSnapshotJson,
    );
  }

  SolarProject _mapSolarProject(SolarProjectRow r) {
    return SolarProject(
      id: r.id,
      organizationId: r.organizationId,
      branchId: r.branchId,
      projectNumber: r.projectNumber,
      name: r.name,
      customerPartyId: r.customerPartyId,
      customerName: r.customerName,
      siteAddress: r.siteAddress,
      acceptedQuotationId: r.acceptedQuotationId,
      acceptedQuotationRevision: r.acceptedQuotationRevision,
      status: ProjectStatus.values.firstWhere(
        (s) => s.name == r.status,
        orElse: () => ProjectStatus.draft,
      ),
      budgetMaterialsPaise: Money.fromPaise(r.budgetMaterialsPaise),
      budgetLaborPaise: Money.fromPaise(r.budgetLaborPaise),
      actualMaterialsPaise: Money.fromPaise(r.actualMaterialsPaise),
      actualExpensesPaise: Money.fromPaise(r.actualExpensesPaise),
      invoicedPaise: Money.fromPaise(r.invoicedPaise),
      wipBalancePaise: Money.fromPaise(r.wipBalancePaise),
      createdAtUtc: _fromEpoch(r.createdAtUtcMs),
    );
  }

  ProjectMaterialIssue _mapProjectMaterialIssue(
    ProjectMaterialIssueRow r,
    List<ProjectMaterialIssueLine> lines,
  ) {
    return ProjectMaterialIssue(
      id: r.id,
      organizationId: r.organizationId,
      branchId: r.branchId,
      projectId: r.projectId,
      locationId: r.locationId,
      issueDate: _fromEpoch(r.issueDateMs),
      lines: lines,
      totalCostPaise: Money.fromPaise(r.totalCostPaise),
      createdAtUtc: _fromEpoch(r.createdAtUtcMs),
      notes: r.notes,
    );
  }

  ProjectMaterialIssueLine _mapProjectMaterialIssueLine(
    ProjectMaterialIssueLineRow r,
  ) {
    final List<dynamic> serialsList =
        jsonDecode(r.serialsJson) as List<dynamic>;
    return ProjectMaterialIssueLine(
      id: r.id,
      issueId: r.issueId,
      productId: r.productId,
      productName: r.productName,
      sku: r.sku,
      quantity: Quantity.fromUnits(r.quantityMicroUnits / 1000000.0),
      costSnapshotMicroRupees: r.costSnapshotMicroRupees,
      serials: serialsList.cast<String>(),
    );
  }

  // ---------------------------------------------------------------------
  // ServiceStore Implementation
  // ---------------------------------------------------------------------

  @override
  Future<void> saveServiceJob({
    required ServiceJob job,
    List<ServiceJobVisit> visits = const [],
  }) async {
    await into(serviceJobs).insertOnConflictUpdate(
      ServiceJobsCompanion.insert(
        id: job.id,
        organizationId: job.organizationId,
        branchId: job.branchId,
        jobTicketNumber: job.jobTicketNumber,
        customerPartyId: job.customerPartyId,
        customerName: job.customerName,
        siteAddress: job.siteAddress,
        equipmentSerialId: job.equipmentSerialId,
        issueDescription: job.issueDescription,
        assignedTechnicianUserId: Value(job.assignedTechnicianUserId),
        assignedTechnicianName: Value(job.assignedTechnicianName),
        isCoveredByWarranty: Value(job.isCoveredByWarranty),
        isCoveredByAmc: Value(job.isCoveredByAmc),
        status: Value(job.status.name),
        createdAtUtcMs: job.createdAtUtc.millisecondsSinceEpoch,
      ),
    );

    for (final visit in visits) {
      final sparesJson = jsonEncode(
        visit.sparesUsed
            .map(
              (s) => {
                'productId': s.productId,
                'productName': s.productName,
                'sku': s.sku,
                'quantityMicroUnits': s.quantity.microUnits,
                'unitCostPaise': s.unitCostPaise.paise,
              },
            )
            .toList(),
      );

      await into(serviceJobVisits).insertOnConflictUpdate(
        ServiceJobVisitsCompanion.insert(
          id: visit.id,
          jobId: visit.jobId,
          technicianUserId: visit.technicianUserId,
          technicianName: visit.technicianName,
          visitDateMs: visit.visitDate.millisecondsSinceEpoch,
          workPerformed: visit.workPerformed,
          travelExpensesPaise: visit.travelExpensesPaise.paise,
          laborCostPaise: visit.laborCostPaise.paise,
          billableAmountPaise: visit.billableAmountPaise.paise,
          sparesUsedJson: Value(sparesJson),
          isCompleted: Value(visit.isCompleted),
        ),
      );
    }
  }

  @override
  Future<ServiceJob?> getServiceJob(String id) async {
    final row = await (select(
      serviceJobs,
    )..where((j) => j.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _mapServiceJob(row);
  }

  @override
  Future<List<ServiceJobVisit>> getServiceJobVisits(String jobId) async {
    final rows = await (select(
      serviceJobVisits,
    )..where((v) => v.jobId.equals(jobId))).get();
    return rows.map(_mapServiceJobVisit).toList();
  }

  @override
  Future<List<ServiceJob>> listServiceJobs({
    required String organizationId,
    String? assignedTechnicianUserId,
    String? customerPartyId,
  }) async {
    final query = select(serviceJobs)
      ..where((j) => j.organizationId.equals(organizationId));
    if (assignedTechnicianUserId != null) {
      query.where(
        (j) => j.assignedTechnicianUserId.equals(assignedTechnicianUserId),
      );
    }
    if (customerPartyId != null) {
      query.where((j) => j.customerPartyId.equals(customerPartyId));
    }
    final rows = await query.get();
    return rows.map(_mapServiceJob).toList();
  }

  @override
  Future<void> saveAmcContract(AmcContract contract) async {
    await into(amcContracts).insertOnConflictUpdate(
      AmcContractsCompanion.insert(
        id: contract.id,
        organizationId: contract.organizationId,
        branchId: contract.branchId,
        contractNumber: contract.contractNumber,
        customerPartyId: contract.customerPartyId,
        customerName: contract.customerName,
        siteAddress: contract.siteAddress,
        startDateMs: contract.startDate.millisecondsSinceEpoch,
        endDateMs: contract.endDate.millisecondsSinceEpoch,
        contractValuePaise: contract.contractValuePaise.paise,
        visitLimitPerYear: contract.visitLimitPerYear,
        visitsCompleted: Value(contract.visitsCompleted),
        status: Value(contract.status.name),
        createdAtUtcMs: contract.createdAtUtc.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<AmcContract?> getAmcContract(String id) async {
    final row = await (select(
      amcContracts,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _mapAmcContract(row);
  }

  @override
  Future<List<AmcContract>> listAmcContracts(String organizationId) async {
    final rows = await (select(
      amcContracts,
    )..where((c) => c.organizationId.equals(organizationId))).get();
    return rows.map(_mapAmcContract).toList();
  }

  @override
  Future<void> saveSerialReplacement(SerialReplacement replacement) async {
    await into(serialReplacements).insertOnConflictUpdate(
      SerialReplacementsCompanion.insert(
        id: replacement.id,
        jobId: replacement.jobId,
        oldSerialId: replacement.oldSerialId,
        newSerialId: replacement.newSerialId,
        replacementDateMs: replacement.replacementDate.millisecondsSinceEpoch,
        reason: replacement.reason,
      ),
    );
  }

  @override
  Future<List<SerialReplacement>> getSerialReplacements(String serialId) async {
    final rows =
        await (select(serialReplacements)..where(
              (r) =>
                  r.oldSerialId.equals(serialId) |
                  r.newSerialId.equals(serialId),
            ))
            .get();
    return rows.map(_mapSerialReplacement).toList();
  }

  ServiceJob _mapServiceJob(ServiceJobRow r) {
    return ServiceJob(
      id: r.id,
      organizationId: r.organizationId,
      branchId: r.branchId,
      jobTicketNumber: r.jobTicketNumber,
      customerPartyId: r.customerPartyId,
      customerName: r.customerName,
      siteAddress: r.siteAddress,
      equipmentSerialId: r.equipmentSerialId,
      issueDescription: r.issueDescription,
      assignedTechnicianUserId: r.assignedTechnicianUserId,
      assignedTechnicianName: r.assignedTechnicianName,
      isCoveredByWarranty: r.isCoveredByWarranty,
      isCoveredByAmc: r.isCoveredByAmc,
      status: ServiceJobStatus.values.firstWhere(
        (s) => s.name == r.status,
        orElse: () => ServiceJobStatus.logged,
      ),
      createdAtUtc: _fromEpoch(r.createdAtUtcMs),
    );
  }

  ServiceJobVisit _mapServiceJobVisit(ServiceJobVisitRow r) {
    final List<dynamic> sparesList =
        jsonDecode(r.sparesUsedJson) as List<dynamic>;
    final spares = sparesList.map((item) {
      final map = item as Map<String, dynamic>;
      return ServiceJobSpareItem(
        productId: map['productId'] as String,
        productName: map['productName'] as String,
        sku: map['sku'] as String,
        quantity: Quantity.fromUnits(
          (map['quantityMicroUnits'] as int) / 1000000.0,
        ),
        unitCostPaise: Money.fromPaise(map['unitCostPaise'] as int),
      );
    }).toList();

    return ServiceJobVisit(
      id: r.id,
      jobId: r.jobId,
      technicianUserId: r.technicianUserId,
      technicianName: r.technicianName,
      visitDate: _fromEpoch(r.visitDateMs),
      workPerformed: r.workPerformed,
      travelExpensesPaise: Money.fromPaise(r.travelExpensesPaise),
      laborCostPaise: Money.fromPaise(r.laborCostPaise),
      billableAmountPaise: Money.fromPaise(r.billableAmountPaise),
      sparesUsed: spares,
      isCompleted: r.isCompleted,
    );
  }

  AmcContract _mapAmcContract(AmcContractRow r) {
    return AmcContract(
      id: r.id,
      organizationId: r.organizationId,
      branchId: r.branchId,
      contractNumber: r.contractNumber,
      customerPartyId: r.customerPartyId,
      customerName: r.customerName,
      siteAddress: r.siteAddress,
      startDate: _fromEpoch(r.startDateMs),
      endDate: _fromEpoch(r.endDateMs),
      contractValuePaise: Money.fromPaise(r.contractValuePaise),
      visitLimitPerYear: r.visitLimitPerYear,
      visitsCompleted: r.visitsCompleted,
      status: AmcContractStatus.values.firstWhere(
        (s) => s.name == r.status,
        orElse: () => AmcContractStatus.active,
      ),
      createdAtUtc: _fromEpoch(r.createdAtUtcMs),
    );
  }

  SerialReplacement _mapSerialReplacement(SerialReplacementRow r) {
    return SerialReplacement(
      id: r.id,
      jobId: r.jobId,
      oldSerialId: r.oldSerialId,
      newSerialId: r.newSerialId,
      replacementDate: _fromEpoch(r.replacementDateMs),
      reason: r.reason,
    );
  }
}

final class _FoundationDriftTransaction implements FoundationTransaction {
  const _FoundationDriftTransaction(this.database);

  final FoundationDatabase database;

  @override
  Future<void> insertIdentity(FoundationIdentity identity) async {
    final organization = identity.organization;
    final branch = identity.branch;
    final period = identity.financialPeriod;
    await database
        .into(database.organizations)
        .insert(
          OrganizationsCompanion.insert(
            id: organization.id.value,
            legalName: organization.legalName,
            displayName: organization.displayName,
            createdAtUtcMs: organization.createdAtUtc.millisecondsSinceEpoch,
          ),
        );
    await database
        .into(database.branches)
        .insert(
          BranchesCompanion.insert(
            id: branch.id.value,
            organizationId: branch.organizationId.value,
            name: branch.name,
            timeZone: branch.timeZone,
            locale: branch.locale,
            createdAtUtcMs: branch.createdAtUtc.millisecondsSinceEpoch,
          ),
        );
    await database
        .into(database.financialPeriods)
        .insert(
          FinancialPeriodsCompanion.insert(
            id: period.id.value,
            organizationId: period.organizationId.value,
            branchId: period.branchId.value,
            startsOn: _date(period.startsOn),
            endsOn: _date(period.endsOn),
            createdAtUtcMs: period.createdAtUtc.millisecondsSinceEpoch,
          ),
        );
    await database
        .into(database.appMetadata)
        .insert(
          AppMetadataCompanion.insert(
            key: 'authority_mode',
            value: 'single_branch',
          ),
        );
  }
}

void _configureEncryptedConnection(sqlite.Database database, List<int> key) {
  if (key.isNotEmpty) {
    try {
      final cipher = database.select('PRAGMA cipher;');
      if (cipher.isNotEmpty && cipher.first.values.firstOrNull != null) {
        final keyHex = key
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join();
        database.execute('PRAGMA key = "x\'$keyHex\'";');
      }
    } catch (_) {
      // PRAGMA cipher not present (standard normal SQLite)
    }
  }
  database.execute('PRAGMA temp_store = MEMORY;');
  database.execute('PRAGMA foreign_keys = ON;');
  database.select('SELECT count(*) FROM sqlite_master;');
}

void _verifyEncryptedFile(File file, List<int> key) {
  final database = sqlite.sqlite3.open(file.path);
  try {
    _configureEncryptedConnection(database, key);
    final integrity = database.select('PRAGMA integrity_check;');
    if (integrity.single.values.single != 'ok') {
      throw const StorageFailure(
        'snapshot.integrity_failed',
        'The recovery snapshot failed verification.',
      );
    }
    final version = database.userVersion;
    if (version < 1) {
      throw const StorageFailure(
        'snapshot.schema_mismatch',
        'The recovery snapshot schema is unsupported.',
      );
    }
  } finally {
    database.close();
  }
}

DateTime _fromEpoch(int value) =>
    DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
