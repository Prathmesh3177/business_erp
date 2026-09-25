import 'package:erp_domain/erp_domain.dart';

import 'command_context.dart';
import 'party_store.dart';

final class CreatePartyUseCase {
  const CreatePartyUseCase(this._partyStore);

  final PartyStore _partyStore;

  Future<Party> execute(
    CommandContext context,
    Party party, {
    List<PartyAddress>? addresses,
    List<PartyContact>? contacts,
  }) async {
    context.requireCapability(Capability.partyManage);

    if (party.gstin != null && party.gstin!.isNotEmpty) {
      final existing = await _partyStore.getPartyByGstin(party.organizationId, party.gstin!);
      if (existing != null) {
        throw ConflictFailure('duplicate_gstin', 'A party with GSTIN "${party.gstin}" already exists.');
      }
    }

    await _partyStore.saveParty(party, addresses: addresses, contacts: contacts);
    return party;
  }
}

final class SearchPartiesUseCase {
  const SearchPartiesUseCase(this._partyStore);

  final PartyStore _partyStore;

  Future<List<Party>> execute(
    CommandContext context,
    String organizationId, {
    String? query,
    bool? isCustomer,
    bool? isSupplier,
  }) async {
    context.requireCapability(Capability.partyManage);
    return _partyStore.searchParties(
      organizationId,
      query: query,
      isCustomer: isCustomer,
      isSupplier: isSupplier,
    );
  }
}
