import 'package:erp_domain/erp_domain.dart';

abstract interface class KitStore {
  Future<void> saveKit({required Kit kit, required List<KitLine> lines});
  Future<Kit?> getKit(String organizationId, String kitId);
  Future<List<Kit>> listKits(String organizationId, {bool includeInactive = false});
  Future<List<KitLine>> getKitLines(String kitId);
  Future<void> deleteKit(String organizationId, String kitId);
}
