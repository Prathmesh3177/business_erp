import 'package:erp_domain/erp_domain.dart';

abstract interface class InventoryStore {
  // Locations
  Future<void> saveLocation(Location location);
  Future<List<Location>> getLocations(String organizationId, {String? branchId});
  Future<Location?> getLocationById(String id);

  // Stock Movements & Balances
  Future<void> saveStockMovement(StockMovement movement);
  Future<List<StockMovement>> getStockMovements(
    String organizationId, {
    String? productId,
    String? locationId,
    int limit = 100,
  });

  Future<void> saveStockBalance(StockBalance balance);
  Future<StockBalance?> getStockBalance(String productId, String locationId);
  Future<List<StockBalance>> getStockBalancesForProduct(String organizationId, String productId);
  Future<List<StockBalance>> getAllStockBalances(String organizationId, {String? locationId});

  Future<List<StockBalance>> rebuildStockBalances(String organizationId);

  // Serials & Batches
  Future<void> saveSerialRecord(SerialRecord serial);
  Future<SerialRecord?> getSerialByNumber(String organizationId, String productId, String serialNumber);
  Future<List<SerialRecord>> getSerialsForProduct(String organizationId, String productId, {SerialState? state});
  Future<void> saveSerialEvent(SerialEvent event);
  Future<List<SerialEvent>> getSerialEvents(String serialId);

  Future<void> saveBatchRecord(BatchRecord batch);
  Future<List<BatchRecord>> getBatchesForProduct(String organizationId, String productId);

  // Reservations
  Future<void> saveReservation(Reservation reservation);
  Future<List<Reservation>> getActiveReservationsForProduct(String organizationId, String productId);

  // Stock Adjustments
  Future<void> saveStockAdjustment(StockAdjustment adjustment);
  Future<List<StockAdjustment>> getStockAdjustments(String organizationId, {int limit = 100});
}
