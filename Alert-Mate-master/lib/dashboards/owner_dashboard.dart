import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../auth_screen.dart';
import '../widgets/shared/app_sidebar.dart';
import '../constants/app_colors.dart';
import '../models/user.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../services/firebase_auth_service.dart';

class OwnerDashboard extends StatefulWidget {
  final dynamic user;

  const OwnerDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String _searchQuery = '';
  String _statusFilter = 'All Status';
  
  late VehicleService _vehicleService;
  late List<Vehicle> _vehicles = [];
  late bool _isLoading;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  final List<Map<String, dynamic>> _emergencyContacts = [
    {'name': 'Sarah Johnson', 'relationship': 'Spouse', 'phone': '+1 (555) 123-4567', 'email': 'sarah@example.com', 'priority': 'primary', 'methods': ['call', 'sms', 'email'], 'enabled': true},
    {'name': 'Mike Chen', 'relationship': 'Fleet Manager', 'phone': '+1 (555) 987-6543', 'email': 'mike@company.com', 'priority': 'secondary', 'methods': ['sms', 'email'], 'enabled': true},
    {'name': 'Emergency Services', 'relationship': '911', 'phone': '911', 'email': '', 'priority': 'primary', 'methods': ['call'], 'enabled': true},
  ];

  @override
  void initState() {
    super.initState();
    _vehicleService = VehicleService();
    _isLoading = false;
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController.forward();
    _slideController.forward();
    _loadVehicles();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    try {
      print('Loading vehicles for owner: ${widget.user.id}');
      List<Vehicle> vehicles = await _vehicleService.getVehiclesForOwner(widget.user.id);
      setState(() {
        _vehicles = vehicles;
      });
      print('✅ Loaded ${vehicles.length} vehicles');
    } catch (e) {
      print('❌ Error loading vehicles: $e');
    }
  }

  Future<void> _showAddVehicleDialog() async {
    final formKey = GlobalKey<FormState>();
    String make = '';
    String model = '';
    String year = '';
    String licensePlate = '';
    bool willDrive = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add New Vehicle'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Make'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => make = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Model'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => model = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Year'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => year = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'License Plate'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => licensePlate = value!,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('I will be driving this vehicle'),
                    subtitle: const Text('Assign this vehicle to me'),
                    value: willDrive,
                    onChanged: (value) {
                      setState(() {
                        willDrive = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    Navigator.pop(context);
                    
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Adding vehicle...')),
                      );

                      final result = await _vehicleService.addVehicleWithDriverCheck(
                        make: make,
                        model: model,
                        year: year,
                        licensePlate: licensePlate,
                        ownerId: widget.user.id,
                        ownerEmail: widget.user.email,
                        willOwnerDrive: willDrive,
                      );

                      if (result == null && willDrive) {
                        if (mounted) {
                          _showDriverRegistrationDialog();
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(willDrive 
                                ? 'Vehicle added and assigned to you!' 
                                : 'Vehicle added successfully'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          _loadVehicles();
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                        );
                      }
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showDriverRegistrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Driver Registration Required'),
        content: const Text(
          'To drive this vehicle, you need to be registered as a driver. '
          'Would you like to register now?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthScreen(
                    isOwnerBecomingDriver: true,
                    initialIsSignIn: false,
                  ),
                ),
              );
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AppSidebar(
            role: 'owner',
            user: widget.user is User ? widget.user : null,
            selectedIndex: _selectedIndex,
            onMenuItemTap: (index) => setState(() => _selectedIndex = index),
            menuItems: const [
              MenuItem(icon: Icons.home_outlined, title: 'Dashboard'),
              MenuItem(icon: Icons.phone_outlined, title: 'Emergency'),
            ],
            accentColor: AppColors.primary,
            accentLightColor: AppColors.primaryLight,
          ),
          Expanded(
            child: _selectedIndex == 0 ? _buildDashboard() : _buildEmergency(),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStaggeredItem(
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
                      if (!isMobile)
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _showAddVehicleDialog,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Vehicle'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Export report'))
                                );
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Open settings'))
                                );
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
                  0,
                ),
                const SizedBox(height: 32),
                _buildStaggeredItem(
                  isMobile
                      ? Column(
                          children: [
                            _buildStatCard(
                              'Total Vehicles',
                              _vehicles.length.toString(),
                              'Fleet size',
                              Icons.directions_car_outlined,
                              AppColors.primary,
                            ),
                            const SizedBox(height: 16),
                            _buildStatCard(
                              'Active Drivers',
                              _vehicles.where((v) => v.status == 'Active').length.toString(),
                              'Currently driving',
                              Icons.people_outline,
                              AppColors.success,
                            ),
                            const SizedBox(height: 16),
                            _buildStatCard(
                              'Critical Alerts',
                              _vehicles.where((v) => v.status == 'Critical').length.toString(),
                              'Requires attention',
                              Icons.warning_amber_rounded,
                              AppColors.danger,
                            ),
                            const SizedBox(height: 16),
                            _buildStatCard(
                              'Safety Score',
                              '8.4/10',
                              'Overall performance',
                              Icons.shield_outlined,
                              AppColors.success,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: _buildStatCard(
                              'Total Vehicles',
                              _vehicles.length.toString(),
                              'Fleet size',
                              Icons.directions_car_outlined,
                              AppColors.primary,
                            )),
                            const SizedBox(width: 20),
                            Expanded(child: _buildStatCard(
                              'Active Drivers',
                              _vehicles.where((v) => v.status == 'Active').length.toString(),
                              'Currently driving',
                              Icons.people_outline,
                              AppColors.success,
                            )),
                            const SizedBox(width: 20),
                            Expanded(child: _buildStatCard(
                              'Critical Alerts',
                              _vehicles.where((v) => v.status == 'Critical').length.toString(),
                              'Requires attention',
                              Icons.warning_amber_rounded,
                              AppColors.danger,
                            )),
                            const SizedBox(width: 20),
                            Expanded(child: _buildStatCard(
                              'Safety Score',
                              '8.4/10',
                              'Overall performance',
                              Icons.shield_outlined,
                              AppColors.success,
                            )),
                          ],
                        ),
                  1,
                ),
                const SizedBox(height: 32),
                _buildStaggeredItem(
                  _buildFleetOverview(),
                  2,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaggeredItem(Widget child, int index) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, _) {
        final double slideValue = Curves.easeOutQuad.transform(_slideController.value);
        final double fadeValue = Curves.easeOut.transform(_fadeController.value);
        final double itemDelay = index * 0.1;
        final double itemSlide = (slideValue - itemDelay).clamp(0.0, 1.0);
        final double itemFade = (fadeValue - itemDelay).clamp(0.0, 1.0);

        return Opacity(
          opacity: itemFade,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - itemSlide)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Icon(Icons.more_horiz, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetOverview() {
    return StreamBuilder<List<Vehicle>>(
      stream: _vehicleService.getVehiclesByOwnerStream(widget.user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final vehicles = snapshot.data ?? [];
        
        List<Vehicle> filteredVehicles = vehicles.where((vehicle) {
          bool matchesSearch = _searchQuery.isEmpty ||
              (vehicle.driverName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              vehicle.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              vehicle.status.toLowerCase().contains(_searchQuery.toLowerCase());

          bool matchesFilter = _statusFilter == 'All Status' || vehicle.status == _statusFilter;

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
                        fillColor: AppColors.background,
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
                          items: ['All Status', 'Active', 'Break', 'Critical', 'Offline']
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
              if (filteredVehicles.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('No vehicles found')),
                )
              else
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
      },
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

  TableRow _buildVehicleRow(Vehicle vehicle) {
    return TableRow(
      children: [
        _buildTableCell(vehicle.id),
        _buildTableCell(vehicle.driverName ?? 'Unassigned'),
        _buildStatusBadge(vehicle.status),
        _buildAlertnessCell(vehicle.alertness),
        _buildTableCell(vehicle.location ?? 'Unknown'),
        _buildTableCell(vehicle.lastUpdate ?? 'N/A'),
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
        color = AppColors.success;
        break;
      case 'Break':
        color = AppColors.primary;
        break;
      case 'Critical':
        color = AppColors.danger;
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

  Widget _buildAlertnessCell(int alertnessValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            '$alertnessValue%',
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
                value: alertnessValue / 100,
                minHeight: 6,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  alertnessValue >= 80 ? AppColors.success :
                  alertnessValue >= 70 ? AppColors.warning : AppColors.danger,
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('View vehicle details'))
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.phone_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling driver...'))
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling $number...'))
                );
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fleet Contacts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                children: [
                  _buildTableHeader('Name'),
                  _buildTableHeader('Role'),
                  _buildTableHeader('Phone'),
                  _buildTableHeader('Actions'),
                ],
              ),
              ..._emergencyContacts.map((contact) => TableRow(
                children: [
                  _buildTableCell(contact['name']),
                  _buildTableCell(contact['relationship']),
                  _buildTableCell(contact['phone']),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.call, color: AppColors.primary),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling ${contact['name']}...'))
                        );
                      },
                    ),
                  ),
                ],
              )).toList(),
            ],
          ),
        ],
      ),
    );
  }
}