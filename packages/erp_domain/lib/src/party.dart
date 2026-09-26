import 'errors.dart';

final class PartyAddress {
  const PartyAddress({
    required this.id,
    required this.partyId,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.stateCode, // E.g., "27" for Maharashtra
    this.isBilling = true,
    this.isShipping = true,
  });

  final String id;
  final String partyId;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String stateCode;
  final bool isBilling;
  final bool isShipping;
}

final class PartyContact {
  const PartyContact({
    required this.id,
    required this.partyId,
    required this.name,
    required this.phone,
    this.email,
    this.isPrimary = true,
  });

  final String id;
  final String partyId;
  final String name;
  final String phone;
  final String? email;
  final bool isPrimary;
}

final class Party {
  Party({
    required this.id,
    required this.organizationId,
    required this.name,
    this.isCustomer = true,
    this.isSupplier = false,
    this.gstin,
    this.pan,
    this.paymentTermsDays = 30,
    this.creditLimitPaise = 0,
    this.active = true,
    required this.createdAt,
    required this.updatedAt,
  }) {
    if (name.trim().isEmpty) {
      throw const ValidationFailure('invalid_name', 'Party name cannot be empty');
    }
    if (!isCustomer && !isSupplier) {
      throw const ValidationFailure('invalid_role', 'Party must be at least a Customer or Supplier');
    }
    if (gstin != null && gstin!.isNotEmpty) {
      final normalizedGstin = gstin!.trim().toUpperCase();
      if (!_gstinRegex.hasMatch(normalizedGstin)) {
        throw const ValidationFailure('invalid_gstin', 'Invalid GSTIN format (must be 15 alphanumeric characters)');
      }
    }
    if (creditLimitPaise < 0) {
      throw const ValidationFailure('invalid_credit_limit', 'Credit limit cannot be negative');
    }
  }

  final String id;
  final String organizationId;
  final String name;
  final bool isCustomer;
  final bool isSupplier;
  final String? gstin;
  final String? pan;
  final int paymentTermsDays;
  final int creditLimitPaise;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  static final RegExp _gstinRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Party && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
