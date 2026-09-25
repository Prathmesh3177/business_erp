import 'package:flutter/material.dart';

class MobileNavigationShell extends StatefulWidget {
  const MobileNavigationShell({super.key});

  @override
  State<MobileNavigationShell> createState() => _MobileNavigationShellState();
}

class _MobileNavigationShellState extends State<MobileNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shree Krushna Sales — Mobile Drafts'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: Column(
        children: [
          // Persistent Isolated Mobile Data Mode Banner
          Container(
            width: double.infinity,
            color: Colors.amber.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Isolated Mobile Data Mode — Local Offline Drafts',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildMobileHomeTab(),
                _buildScanTab(),
                _buildStockTab(),
                _buildCustomersTab(),
                _buildMoreTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF990000),
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  Widget _buildMobileHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Icon(Icons.phone_android, color: Colors.red.shade900),
                      const SizedBox(width: 8),
                      const Text(
                        'Mobile Task Flow Notice',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mobile devices operate in local offline draft mode. Stock posting requires branch LAN connectivity to the desktop authority.',
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Quick Mobile Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004D40),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Camera capture / nameplate photo flow initialized.')),
              );
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Capture Nameplate Photo'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Serial lookup initialized.')),
              );
            },
            icon: const Icon(Icons.search),
            label: const Text('Lookup Serial & Stock'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 64, color: Color(0xFF990000)),
          SizedBox(height: 16),
          Text(
            'Camera Barcode & Serial Scanner',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Deterministic camera barcode decoding active', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStockTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 64, color: Color(0xFF004D40)),
          SizedBox(height: 16),
          Text(
            'Mobile Stock Inspection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Read-only local stock cached view', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCustomersTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: Colors.indigo),
          SizedBox(height: 16),
          Text(
            'Customer Directory',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.verified_user),
          title: const Text('Warranty & Reminders'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: const Icon(Icons.print),
          title: const Text('Bluetooth / Network Printer Setup'),
          subtitle: const Text('Bluetooth SPP, Wi-Fi TCP Port 9100'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
    );
  }
}
