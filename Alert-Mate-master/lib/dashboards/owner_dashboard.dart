import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../auth_screen.dart';

class OwnerDashboard extends StatefulWidget {
  final dynamic user;

  const OwnerDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _selectedIndex = 0;
  int _selectedTab = 0;
  String _searchQuery = '';
  String _statusFilter = 'All Status';
  Timer? _updateTimer;
  final Random _random = Random();

  final List<Map<String, dynamic>> _emergencyContacts = [
    {'name': 'Sarah Johnson', 'relationship': 'Spouse', 'phone': '+1 (555) 123-4567', 'email': 'sarah@example.com', 'priority': 'primary', 'methods': ['call', 'sms', 'email'], 'enabled': true},
    {'name': 'Mike Chen', 'relationship': 'Fleet Manager', 'phone': '+1 (555) 987-6543', 'email': 'mike@company.com', 'priority': 'secondary', 'methods': ['sms', 'email'], 'enabled': true},
    {'name': 'Emergency Services', 'relationship': '911', 'phone': '911', 'email': '', 'priority': 'primary', 'methods': ['call'], 'enabled': true},
  ];

  final List<Map<String, dynamic>> _vehicles = [
    {
      'id': 'V001',
      'driver': 'John Smith',
      'status': 'Active',
      'alertness': 85,
      'location': 'Highway 101',
      'lastUpdate': '2 min ago',
    },
    {
      'id': 'V002',
      'driver': 'Sarah Johnson',
      'status': 'Break',
      'alertness': 92,
      'location': 'Rest Area',
      'lastUpdate': '15 min ago',
    },
    {
      'id': 'V003',
      'driver': 'Mike Chen',
      'status': 'Active',
      'alertness': 78,
      'location': 'I-5 South',
      'lastUpdate': '1 min ago',
    },
    {
      'id': 'V004',
      'driver': 'Lisa Wong',
      'status': 'Critical',
      'alertness': 65,
      'location': 'Highway 99',
      'lastUpdate': '30 sec ago',
    },
    {
      'id': 'V005',
      'driver': 'David Brown',
      'status': 'Active',
      'alertness': 88,
      'location': 'I-405',
      'lastUpdate': '3 min ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startDataUpdate();
  }

  void _startDataUpdate() {
    _updateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        for (var vehicle in _vehicles) {
          vehicle['alertness'] = 65 + _random.nextInt(30);
        }
      });
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  int get _totalVehicles => 25;
  int get _activeDrivers => 18;
  int get _criticalAlerts => _vehicles.where((v) => v['status'] == 'Critical').length;
  String get _fleetSafetyScore => '8.4/10';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: _selectedIndex == 0 ? _buildDashboard() : _buildEmergency(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 290,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ALERT MATE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Drowsiness Detection',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'owner',
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, size: 18, color: Colors.black87),
                    const SizedBox(width: 10),
                    Text(
                      'Back to Role Selection',
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuItem(Icons.home_outlined, 'Dashboard', 0),
          _buildMenuItem(Icons.phone_outlined, 'Emergency', 1),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF2196F3),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user?.firstName ?? 'John Doe',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.user?.email ?? 'wahb@gmail.com',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.notifications_outlined, size: 20, color: Colors.orange[400]),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 10),
                    Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE3F2FD) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF2196F3) : Colors.grey[700],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF2196F3) : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fleet Management',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Monitor and manage your vehicle fleet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export report')));
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Export Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        elevation: 0,
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open settings')));
                      },
                      icon: const Icon(Icons.settings),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: _buildStatCard(
                  'Total Vehicles',
                  _totalVehicles.toString(),
                  'Fleet size',
                  Icons.directions_car_outlined,
                  Colors.blue,
                )),
                const SizedBox(width: 20),
                Expanded(child: _buildStatCard(
                  'Active Drivers',
                  _activeDrivers.toString(),
                  'Currently driving',
                  Icons.people_outline,
                  Colors.green,
                )),
                const SizedBox(width: 20),
                Expanded(child: _buildStatCard(
                  'Critical Alerts',
                  _criticalAlerts.toString(),
                  'Require attention',
                  Icons.warning_amber_outlined,
                  Colors.red,
                )),
                const SizedBox(width: 20),
                Expanded(child: _buildStatCard(
                  'Fleet Safety Score',
                  _fleetSafetyScore,
                  'Overall performance',
                  Icons.shield_outlined,
                  const Color(0xFF4CAF50),
                )),
              ],
            ),
            const SizedBox(height: 32),
            _buildTabBar(),
            const SizedBox(height: 32),
            if (_selectedTab == 0) _buildLiveFleetTab(),
            if (_selectedTab == 1) _buildAnalyticsTab(),
            if (_selectedTab == 2) _buildDriverManagementTab(),
            if (_selectedTab == 3) _buildReportsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Icon(icon, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: title == 'Critical Alerts' ? Colors.red : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTab('Live Fleet', 0),
          const SizedBox(width: 8),
          _buildTab('Analytics', 1),
          const SizedBox(width: 8),
          _buildTab('Driver Management', 2),
          const SizedBox(width: 8),
          _buildTab('Reports', 3),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isActive = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? const Border(
            bottom: BorderSide(color: Colors.black87, width: 2),
          )
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.black87 : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildLiveFleetTab() {
    return Column(
      children: [
        _buildFleetOverview(),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildFleetStatusDistribution()),
            const SizedBox(width: 20),
            Expanded(child: _buildRealTimeAlerts()),
          ],
        ),
      ],
    );
  }

  Widget _buildFleetOverview() {
    List<Map<String, dynamic>> filteredVehicles = _vehicles.where((vehicle) {
      bool matchesSearch = _searchQuery.isEmpty ||
          vehicle['driver'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vehicle['id'].toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesFilter = _statusFilter == 'All Status' || vehicle['status'] == _statusFilter;

      return matchesSearch && matchesFilter;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fleet Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time monitoring of all vehicles',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by driver name or vehicle ID...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _statusFilter,
                      underline: const SizedBox(),
                      items: ['All Status', 'Active', 'Break', 'Critical']
                          .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() => _statusFilter = value!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.0),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.0),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.5),
              5: FlexColumnWidth(1.2),
              6: FlexColumnWidth(1.0),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                children: [
                  _buildTableHeader('Vehicle ID'),
                  _buildTableHeader('Driver'),
                  _buildTableHeader('Status'),
                  _buildTableHeader('Alertness'),
                  _buildTableHeader('Location'),
                  _buildTableHeader('Last Update'),
                  _buildTableHeader('Actions'),
                ],
              ),
              ...filteredVehicles.map((vehicle) => _buildVehicleRow(vehicle)).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  TableRow _buildVehicleRow(Map<String, dynamic> vehicle) {
    return TableRow(
      children: [
        _buildTableCell(vehicle['id']),
        _buildTableCell(vehicle['driver']),
        _buildStatusBadge(vehicle['status']),
        _buildAlertnessCell(vehicle['alertness']),
        _buildTableCell(vehicle['location']),
        _buildTableCell(vehicle['lastUpdate']),
        _buildActionsCell(),
      ],
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Active':
        color = const Color(0xFF4CAF50);
        break;
      case 'Break':
        color = const Color(0xFF2196F3);
        break;
      case 'Critical':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAlertnessCell(int alertness) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            '$alertness%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: alertness / 100,
                minHeight: 6,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  alertness >= 80 ? const Color(0xFF4CAF50) :
                  alertness >= 70 ? const Color(0xFFFFA726) : Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCell() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('View vehicle details')));
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.phone_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling driver...')));
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetStatusDistribution() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fleet Status Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Current status of all vehicles',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: CustomPaint(
                painter: PieChartPainter(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildLegendItem(const Color(0xFF4CAF50), 'Active', '72%'),
          const SizedBox(height: 12),
          _buildLegendItem(const Color(0xFF2196F3), 'Break', '20%'),
          const SizedBox(height: 12),
          _buildLegendItem(Colors.red, 'Critical', '5%'),
          const SizedBox(height: 12),
          _buildLegendItem(Colors.grey, 'Offline', '3%'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String percentage) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildRealTimeAlerts() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Real-time Alerts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Recent system notifications',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          _buildAlertItem(
            Icons.warning_amber,
            Colors.red,
            'Critical drowsiness detected',
            'Vehicle V004 - Lisa Wong - 30 sec ago',
            const Color(0xFFFFEBEE),
          ),
          const SizedBox(height: 16),
          _buildAlertItem(
            Icons.access_time,
            const Color(0xFFFFA726),
            'Driver break overdue',
            'Vehicle V003 - Mike Chen - 5 min ago',
            const Color(0xFFFFF3E0),
          ),
          const SizedBox(height: 16),
          _buildAlertItem(
            Icons.location_on,
            const Color(0xFF2196F3),
            'Vehicle entered rest area',
            'Vehicle V002 - Sarah Johnson - 15 min ago',
            const Color(0xFFE3F2FD),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(IconData icon, Color iconColor, String title, String subtitle, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMonthlyIncidentTrends()),
            const SizedBox(width: 20),
            Expanded(child: _buildAverageFleetAlertness()),
          ],
        ),
        const SizedBox(height: 24),
        _buildFleetPerformanceSummary(),
      ],
    );
  }

  Widget _buildMonthlyIncidentTrends() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Incident Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Drowsiness incidents over time',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: CustomPaint(
              painter: BarChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageFleetAlertness() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Average Fleet Alertness',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Monthly alertness trends',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: CustomPaint(
              painter: LineChartAnalyticsPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetPerformanceSummary() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fleet Performance Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Key metrics and insights',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildMetricCard(
                '94.2%',
                'On-time Performance',
                const Color(0xFF4CAF50),
              )),
              const SizedBox(width: 20),
              Expanded(child: _buildMetricCard(
                '2.3',
                'Avg Incidents/Month',
                const Color(0xFF2196F3),
              )),
              const SizedBox(width: 20),
              Expanded(child: _buildMetricCard(
                '847',
                'Total Miles (Today)',
                const Color(0xFF9C27B0),
              )),
              const SizedBox(width: 20),
              Expanded(child: _buildMetricCard(
                '\$2,340',
                'Cost Savings',
                const Color(0xFFFF6F00),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverManagementTab() {
    final List<Map<String, dynamic>> drivers = [
      {
        'name': 'Sarah Johnson',
        'totalTrips': 52,
        'avgAlertness': 92,
        'incidents': 0,
        'safetyScore': 9.8,
        'status': 'excellent',
      },
      {
        'name': 'David Brown',
        'totalTrips': 47,
        'avgAlertness': 88,
        'incidents': 1,
        'safetyScore': 9.2,
        'status': 'excellent',
      },
      {
        'name': 'John Smith',
        'totalTrips': 45,
        'avgAlertness': 85,
        'incidents': 2,
        'safetyScore': 8.5,
        'status': 'good',
      },
      {
        'name': 'Lisa Wong',
        'totalTrips': 41,
        'avgAlertness': 81,
        'incidents': 3,
        'safetyScore': 8.1,
        'status': 'good',
      },
      {
        'name': 'Mike Chen',
        'totalTrips': 38,
        'avgAlertness': 78,
        'incidents': 5,
        'safetyScore': 7.2,
        'status': 'warning',
      },
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Driver Performance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Individual driver statistics and scores',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.5),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1.2),
                  5: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    children: [
                      _buildTableHeader('Driver Name'),
                      _buildTableHeader('Total Trips'),
                      _buildTableHeader('Avg Alertness'),
                      _buildTableHeader('Incidents'),
                      _buildTableHeader('Safety Score'),
                      _buildTableHeader('Actions'),
                    ],
                  ),
                  ...drivers.map((driver) => _buildDriverRow(driver)).toList(),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTopPerformers(drivers)),
            const SizedBox(width: 20),
            Expanded(child: _buildTrainingRecommendations(drivers)),
          ],
        ),
      ],
    );
  }

  TableRow _buildDriverRow(Map<String, dynamic> driver) {
    return TableRow(
      children: [
        _buildTableCell(driver['name']),
        _buildTableCell(driver['totalTrips'].toString()),
        _buildAlertnessDriverCell(driver['avgAlertness']),
        _buildIncidentsCircleCell(driver['incidents']),
        _buildSafetyScoreCell(driver['safetyScore'], driver['status']),
        _buildDriverActionsCell(),
      ],
    );
  }

  Widget _buildAlertnessDriverCell(int alertness) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            '$alertness%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: alertness / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  alertness >= 90 ? const Color(0xFF2196F3) :
                  alertness >= 80 ? const Color(0xFF2196F3) :
                  const Color(0xFF2196F3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentsCircleCell(int incidents) {
    Color bgColor;
    if (incidents == 0) {
      bgColor = const Color(0xFF2196F3);
    } else if (incidents <= 2) {
      bgColor = Colors.grey;
    } else {
      bgColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            incidents.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyScoreCell(double score, String status) {
    Color dotColor;
    switch (status) {
      case 'excellent':
        dotColor = const Color(0xFF4CAF50);
        break;
      case 'good':
        dotColor = const Color(0xFFFFA726);
        break;
      default:
        dotColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            score.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverActionsCell() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 20),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers(List<Map<String, dynamic>> drivers) {
    final topDrivers = List<Map<String, dynamic>>.from(drivers)
      ..sort((a, b) => b['safetyScore'].compareTo(a['safetyScore']));

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Highest safety scores this month',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ...topDrivers.take(3).toList().asMap().entries.map((entry) {
            int index = entry.key;
            var driver = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTopPerformerItem(
                index + 1,
                driver['name'],
                driver['safetyScore'],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopPerformerItem(int rank, String name, double score) {
    Color rankColor;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
    } else {
      rankColor = const Color(0xFFCD7F32);
    }

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: rankColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              rank.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$score/10',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingRecommendations(List<Map<String, dynamic>> drivers) {
    final needsTraining = drivers.where((d) => d['status'] == 'warning').toList();

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Training Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Suggested improvements',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ...needsTraining.map((driver) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver['name'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recommend fatigue management training',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          if (needsTraining.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'All drivers performing well',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Generate Reports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create detailed fleet and driver reports',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _buildReportCard('Fleet Performance Report', Icons.trending_up, false)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildReportCard('Driver Safety Report', Icons.people_outline, false)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildReportCard('Incident Analysis', Icons.warning_amber_outlined, true)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildReportCard('Time & Attendance', Icons.access_time, false)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildReportCard('Route Analysis', Icons.location_on_outlined, false)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildReportCard('Compliance Report', Icons.shield_outlined, false)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Reports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Previously generated reports',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              _buildRecentReportItem('Monthly Fleet Performance - June 2024', 'Generated 2 days ago'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(String title, IconData icon, bool highlighted) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: highlighted ? const Color(0xFFE8E3FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlighted ? const Color(0xFF7C3AED).withOpacity(0.3) : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: highlighted ? Colors.white : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: highlighted ? const Color(0xFF7C3AED) : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: highlighted ? const Color(0xFF7C3AED) : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReportItem(String title, String date) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description_outlined, size: 24, color: Colors.grey[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergency() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quick access to emergency services and contacts',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 32),

            // Emergency Services Grid
            Row(
              children: [
                Expanded(child: _buildEmergencyServiceCard(
                  'Police',
                  '15',
                  Icons.local_police,
                  const Color(0xFF2196F3),
                  const Color(0xFFE3F2FD),
                )),
                const SizedBox(width: 20),
                Expanded(child: _buildEmergencyServiceCard(
                  'Ambulance',
                  '1122',
                  Icons.local_hospital,
                  Colors.red,
                  const Color(0xFFFFEBEE),
                )),
                const SizedBox(width: 20),
                Expanded(child: _buildEmergencyServiceCard(
                  'Fire Department',
                  '16',
                  Icons.local_fire_department,
                  const Color(0xFFFF6F00),
                  const Color(0xFFFFF3E0),
                )),
                const SizedBox(width: 20),
                Expanded(child: _buildEmergencyServiceCard(
                  'Motorway Police',
                  '130',
                  Icons.car_crash,
                  const Color(0xFF4CAF50),
                  const Color(0xFFE8F5E9),
                )),
              ],
            ),
            const SizedBox(height: 32),

            // Emergency Contacts Table
            _buildEmergencyContactsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyServiceCard(String title, String number, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            number,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final msg = number == '911' ? 'Calling emergency services...' : 'Calling $number...';
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
              },
              icon: const Icon(Icons.phone, size: 18),
              label: const Text('Call Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsTable() {
    // use stateful _emergencyContacts list

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emergency Contacts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your emergency contact list',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final newContact = await _showContactDialog(context: context);
                  if (newContact != null) {
                  setState(() {
                      _emergencyContacts.add(newContact);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact added')));
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Contact'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(1.8),
              3: FlexColumnWidth(1.0),
              4: FlexColumnWidth(1.0),
              5: FlexColumnWidth(0.8),
              6: FlexColumnWidth(1.0),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                children: [
                  _buildTableHeader('Name'),
                  _buildTableHeader('Relationship'),
                  _buildTableHeader('Contact'),
                  _buildTableHeader('Priority'),
                  _buildTableHeader('Methods'),
                  _buildTableHeader('Status'),
                  _buildTableHeader('Actions'),
                ],
              ),
              ...List.generate(_emergencyContacts.length, (i) => _buildEmergencyContactRow(i, _emergencyContacts[i])),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Last system test: Just now • ${_emergencyContacts.length} active contacts',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  TableRow _buildEmergencyContactRow(int index, Map<String, dynamic> contact) {
    return TableRow(
      children: [
        _buildTableCell(contact['name']),
        _buildTableCell(contact['relationship']),
        _buildContactInfoCell(contact['phone'], contact['email']),
        _buildPriorityBadgeCell(contact['priority']),
        _buildMethodsCell(contact['methods']),
        _buildStatusToggleCell(index),
        _buildContactActionsCell(index),
      ],
    );
  }

  Widget _buildContactInfoCell(String phone, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phone,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusToggleCell(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Switch(
        value: _emergencyContacts[index]['enabled'] as bool,
        onChanged: (value) {
          setState(() {
            _emergencyContacts[index]['enabled'] = value;
          });
        },
        activeColor: const Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildPriorityBadgeCell(String priority) {
    final isPrimary = priority == 'primary';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.red : const Color(0xFFFF6F00),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          priority,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContactActionsCell(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () async {
              final updated = await _showContactDialog(context: context, contact: _emergencyContacts[index]);
              if (updated != null) {
                setState(() {
                  _emergencyContacts[index] = updated;
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact updated')));
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () async {
              final name = _emergencyContacts[index]['name'];
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Contact'),
                  content: Text('Delete $name from emergency contacts?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirm == true) {
                setState(() {
                  _emergencyContacts.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name removed')));
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodsCell(List<dynamic> methods) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (methods.contains('call'))
            Icon(Icons.phone, size: 18, color: Colors.green[600]),
          if (methods.contains('call')) const SizedBox(width: 6),
          if (methods.contains('sms'))
            Icon(Icons.message, size: 18, color: Colors.blue[600]),
          if (methods.contains('sms')) const SizedBox(width: 6),
          if (methods.contains('email'))
            Icon(Icons.email, size: 18, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _showContactDialog({required BuildContext context, Map<String, dynamic>? contact}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: contact?['name'] ?? '');
    final relationshipController = TextEditingController(text: contact?['relationship'] ?? '');
    final phoneController = TextEditingController(text: contact?['phone'] ?? '');
    final emailController = TextEditingController(text: contact?['email'] ?? '');
    String priority = contact?['priority'] ?? 'primary';
    final methods = Set<String>.from(contact?['methods'] ?? <String>{});
    bool enabled = contact?['enabled'] ?? true;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: relationshipController,
                    decoration: const InputDecoration(labelText: 'Relationship'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email (optional)'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Priority:'),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: priority,
                        items: const [
                          DropdownMenuItem(value: 'primary', child: Text('Primary')),
                          DropdownMenuItem(value: 'secondary', child: Text('Secondary')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            priority = val;
                            (ctx as Element).markNeedsBuild();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
        children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(
                            value: methods.contains('call'),
                            onChanged: (val) {
                              if (val == true) { methods.add('call'); } else { methods.remove('call'); }
                              (ctx as Element).markNeedsBuild();
                            },
                          ),
                          const Text('Call'),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(
                            value: methods.contains('sms'),
                            onChanged: (val) {
                              if (val == true) { methods.add('sms'); } else { methods.remove('sms'); }
                              (ctx as Element).markNeedsBuild();
                            },
                          ),
                          const Text('SMS'),
                        ]),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Checkbox(
                            value: methods.contains('email'),
                            onChanged: (val) {
                              if (val == true) { methods.add('email'); } else { methods.remove('email'); }
                              (ctx as Element).markNeedsBuild();
                            },
                          ),
                          const Text('Email'),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Enabled'),
                      const SizedBox(width: 12),
                      Switch(
                        value: enabled,
                        onChanged: (val) {
                          enabled = val;
                          (ctx as Element).markNeedsBuild();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                if (methods.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select at least one method')),
                  );
                  return;
                }
                Navigator.pop(ctx, {
                  'name': nameController.text.trim(),
                  'relationship': relationshipController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'email': emailController.text.trim(),
                  'priority': priority,
                  'methods': methods.toList(),
                  'enabled': enabled,
                });
              },
              child: Text(contact == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );

    return result;
  }

  
}

class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Active - 72% (green)
    final activePaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * 0.72,
      true,
      activePaint,
    );

    // Break - 20% (blue)
    final breakPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + 2 * pi * 0.72,
      2 * pi * 0.20,
      true,
      breakPaint,
    );

    // Critical - 5% (red)
    final criticalPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + 2 * pi * 0.92,
      2 * pi * 0.05,
      true,
      criticalPaint,
    );

    // Offline - 3% (grey)
    final offlinePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + 2 * pi * 0.97,
      2 * pi * 0.03,
      true,
      offlinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnalyticsBarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(40, y),
        Offset(size.width - 20, y),
        gridPaint,
      );
    }

    // Y-axis labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 4; i++) {
      final y = size.height - (size.height * i / 4);
      final value = i * 4;
      textPainter.text = TextSpan(
        text: value.toString(),
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(10, y - 8));
    }

    // Bar data: Jan=12, Feb=8, Mar=16, Apr=6, May=10, Jun=4
    final barData = [12, 8, 16, 6, 10, 4];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final barWidth = (size.width - 80) / (barData.length * 2);
    final barPaint = Paint()..color = Colors.black87;

    for (int i = 0; i < barData.length; i++) {
      final x = 50 + (i * (size.width - 80) / barData.length);
      final barHeight = (barData[i] / 16) * size.height;
      final rect = Rect.fromLTWH(
        x,
        size.height - barHeight,
        barWidth * 1.2,
        barHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        barPaint,
      );

      // X-axis labels
      textPainter.text = TextSpan(
        text: months[i],
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 5, size.height + 10));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnalyticsLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(40, y),
        Offset(size.width - 20, y),
        gridPaint,
      );
    }

    // Y-axis labels (70-95 range)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 4; i++) {
      final y = size.height - (size.height * i / 4);
      final value = 70 + (i * 7); // 70, 77, 84, 91, 95
      textPainter.text = TextSpan(
        text: value.toString(),
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(10, y - 8));
    }

    // Data points: Jan=82, Feb=85, Mar=79, Apr=87, May=83, Jun=90
    final dataPoints = [82, 85, 79, 87, 83, 90];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final points = <Offset>[];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = 50 + (i * (size.width - 80) / (dataPoints.length - 1));
      final normalizedValue = (dataPoints[i] - 70) / 25; // Normalize to 0-1 (70-95 range)
      final y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y));

      // X-axis labels
      textPainter.text = TextSpan(
        text: months[i],
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 15, size.height + 10));
    }

    // Draw line
    final linePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(40, y),
        Offset(size.width - 20, y),
        gridPaint,
      );
    }

    // Y-axis labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 4; i++) {
      final y = size.height - (size.height * i / 4);
      final value = i * 4;
      textPainter.text = TextSpan(
        text: value.toString(),
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(10, y - 8));
    }

    // Bar data: Jan=12, Feb=8, Mar=16, Apr=6, May=10, Jun=4
    final barData = [12, 8, 16, 6, 10, 4];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final barWidth = (size.width - 80) / (barData.length * 2);
    final barPaint = Paint()..color = Colors.black87;

    for (int i = 0; i < barData.length; i++) {
      final x = 50 + (i * (size.width - 80) / barData.length);
      final barHeight = (barData[i] / 16) * size.height;
      final rect = Rect.fromLTWH(
        x,
        size.height - barHeight,
        barWidth * 1.2,
        barHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        barPaint,
      );

      // X-axis labels
      textPainter.text = TextSpan(
        text: months[i],
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 5, size.height + 10));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LineChartAnalyticsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(40, y),
        Offset(size.width - 20, y),
        gridPaint,
      );
    }

    // Y-axis labels (70-95 range)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 4; i++) {
      final y = size.height - (size.height * i / 4);
      final value = 70 + (i * 7); // 70, 77, 84, 91, 95
      textPainter.text = TextSpan(
        text: value.toString(),
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(10, y - 8));
    }

    // Data points: Jan=82, Feb=85, Mar=79, Apr=87, May=83, Jun=90
    final dataPoints = [82, 85, 79, 87, 83, 90];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final points = <Offset>[];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = 50 + (i * (size.width - 80) / (dataPoints.length - 1));
      final normalizedValue = (dataPoints[i] - 70) / 25; // Normalize to 0-1 (70-95 range)
      final y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y));

      // X-axis labels
      textPainter.text = TextSpan(
        text: months[i],
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 15, size.height + 10));
    }

    // Draw line
    final linePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}