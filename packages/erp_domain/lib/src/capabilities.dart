enum Capability {
  userManage('user.manage', 'Manage application users and credentials'),
  roleManage('role.manage', 'Manage system and custom roles'),
  auditRead('audit.read', 'Read system security audit logs'),
  systemSnapshot('system.snapshot', 'Create database recovery snapshots'),
  costDataRead(
    'cost_data.read',
    'View purchase costs, margins and supplier pricing',
  ),
  salesCreate('sales.create', 'Create and post counter sales invoices'),
  salesRead('sales.read', 'Read sales history and receipts'),
  partyManage('party.manage', 'Create and edit customers and suppliers'),
  inventoryManage(
    'inventory.manage',
    'View inventory and record stock movements',
  ),
  purchaseManage(
    'purchase.manage',
    'Create and post supplier purchase bills',
  ),
  financeManage(
    'finance.manage',
    'Record payments, customer/supplier returns and party allocations',
  ),
  expensesManage(
    'expenses.manage',
    'Capture operating expenses and manage expense vouchers',
  ),
  cashSessionManage(
    'cash_session.manage',
    'Open, balance and close cash register counter sessions',
  );

  const Capability(this.identifier, this.description);

  final String identifier;
  final String description;

  static Capability? fromIdentifier(String value) {
    for (final cap in Capability.values) {
      if (cap.identifier == value) return cap;
    }
    return null;
  }
}

final class Role {
  const Role({
    required this.id,
    required this.name,
    required this.capabilities,
    this.isSystem = false,
  });

  final String id;
  final String name;
  final Set<Capability> capabilities;
  final bool isSystem;

  bool hasCapability(Capability capability) =>
      capabilities.contains(capability);

  static const String adminRoleId = 'role_admin';
  static const String counterRoleId = 'role_counter';

  static final Role admin = Role(
    id: adminRoleId,
    name: 'Administrator',
    capabilities: Capability.values.toSet(),
    isSystem: true,
  );

  static final Role counter = Role(
    id: counterRoleId,
    name: 'Counter Staff',
    capabilities: {
      Capability.salesCreate,
      Capability.salesRead,
      Capability.partyManage,
      Capability.inventoryManage,
      Capability.financeManage,
      Capability.expensesManage,
      Capability.cashSessionManage,
    },
    isSystem: true,
  );

  static List<Role> get defaultRoles => [admin, counter];
}
