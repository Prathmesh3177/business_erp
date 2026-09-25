import 'package:erp_domain/erp_domain.dart';

abstract interface class ServiceStore {
  Future<void> saveServiceJob({
    required ServiceJob job,
    List<ServiceJobVisit> visits = const [],
  });

  Future<ServiceJob?> getServiceJob(String id);

  Future<List<ServiceJobVisit>> getServiceJobVisits(String jobId);

  Future<List<ServiceJob>> listServiceJobs({
    required String organizationId,
    String? assignedTechnicianUserId,
    String? customerPartyId,
  });

  Future<void> saveAmcContract(AmcContract contract);

  Future<AmcContract?> getAmcContract(String id);

  Future<List<AmcContract>> listAmcContracts(String organizationId);

  Future<void> saveSerialReplacement(SerialReplacement replacement);

  Future<List<SerialReplacement>> getSerialReplacements(String serialId);
}
