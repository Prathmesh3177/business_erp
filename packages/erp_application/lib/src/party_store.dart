import 'package:erp_domain/erp_domain.dart';

abstract interface class PartyStore {
  Future<void> saveParty(Party party, {List<PartyAddress>? addresses, List<PartyContact>? contacts});
  Future<Party?> getPartyById(String organizationId, String id);
  Future<Party?> getPartyByGstin(String organizationId, String gstin);
  Future<List<Party>> searchParties(
    String organizationId, {
    String? query,
    bool? isCustomer,
    bool? isSupplier,
    bool includeInactive = false,
  });
  Future<List<PartyAddress>> getPartyAddresses(String partyId);
  Future<List<PartyContact>> getPartyContacts(String partyId);
}
