import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/vehicle.dart';
import '../models/emergency_contact.dart';
import '../services/vehicle_service.dart';
import '../services/emergency_contact_service.dart';
import '../constants/app_colors.dart';
import '../widgets/shared/app_sidebar.dart';
import '../auth_screen.dart';

class OwnerDashboard extends StatefulWidget {
  final User user;

  const OwnerDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> with TickerProviderStateMixin {
  final VehicleService _vehicleService = VehicleService();
  late EmergencyContactService _emergencyContactService;
  
  int _selectedIndex = 0;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All Status';
   bool _showClearButton = false;
  

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
void initState() {
  super.initState();
  _emergencyContactService = EmergencyContactService();
  _isLoading = false;
  
  // Add listener for search controller
  _searchController.addListener(() {
    setState(() {
      _showClearButton = _searchController.text.isNotEmpty;
    });
  });
  
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
}

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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
      builder: (context,  setDialogState) {
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
                    setDialogState(() {
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
      },
    ),
  );
}
  void _showDriverRegistrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Driver Registration Required'),
        content: const Text(
          'You need to register as a driver before you can be assigned to a vehicle. '
          'Would you like to register as a driver now?'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vehicle added to your fleet. It will be auto-assigned when a driver signs up.'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 4),
                ),
              );
             
            },
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(
                    initialDashboardIndex: 0,
                    initialIsSignIn: false,
                    isOwnerBecomingDriver: true,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Register as Driver'),
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
StreamBuilder<List<Vehicle>>(
  stream: _vehicleService.getVehiclesByOwnerStream(widget.user.id),
  builder: (context, snapshot) {
    final vehicles = snapshot.data ?? [];
    
    return _buildStaggeredItem(
      isMobile
          ? Column(
              children: [
                _buildStatCard(
                  'Total Vehicles',
                  vehicles.length.toString(),
                  'Fleet size',
                  Icons.directions_car_outlined,
                  AppColors.primary,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  'Active Drivers',
                  vehicles.where((v) => v.status == 'Active').length.toString(),
                  'Currently driving',
                  Icons.people_outline,
                  AppColors.success,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  'Critical Alerts',
                  vehicles.where((v) => v.status == 'Critical').length.toString(),
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
                  vehicles.length.toString(),
                  'Fleet size',
                  Icons.directions_car_outlined,
                  AppColors.primary,
                )),
                const SizedBox(width: 20),
                Expanded(child: _buildStatCard(
                  'Active Drivers',
                  vehicles.where((v) => v.status == 'Active').length.toString(),
                  'Currently driving',
                  Icons.people_outline,
                  AppColors.success,
                )),
                const SizedBox(width: 20),
                Expanded(child: _buildStatCard(
                  'Critical Alerts',
                  vehicles.where((v) => v.status == 'Critical').length.toString(),
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
    );
  },
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
          return Container(
            padding: const EdgeInsets.all(28),
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
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final vehicles = snapshot.data ?? [];

        // --- FILTERING ---
        List<Vehicle> filteredVehicles = vehicles.where((vehicle) {
          bool matchesSearch = _searchController.text.isEmpty ||
    vehicle.licensePlate.toLowerCase().contains(_searchController.text.toLowerCase()) ||
    (vehicle.driverName?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false) ||
    vehicle.status.toLowerCase().contains(_searchController.text.toLowerCase()) ||
    (vehicle.location?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false) ||
    '${vehicle.make} ${vehicle.model}'.toLowerCase().contains(_searchController.text.toLowerCase());

          bool matchesFilter = _statusFilter == 'All Status' || vehicle.status == _statusFilter;

          return matchesSearch && matchesFilter;
        }).toList();

        return Container(
          padding: const EdgeInsets.all(28),
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
                  const Text(
                    'Fleet Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 250,
                        child: TextField(
                          key: const Key('fleet_search_field'),
                           controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search vehicles...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _showClearButton  // ✅ Use state variable instead
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                     _searchController.clear();
                                    setState(() {});
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _statusFilter,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: const [
                            DropdownMenuItem(value: 'All Status', child: Text('All Status')),
                            DropdownMenuItem(value: 'Active', child: Text('Active')),
                            DropdownMenuItem(value: 'Break', child: Text('Break')),
                            DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _statusFilter = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            if (_searchController.text.isNotEmpty || _statusFilter != 'All Status')
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(
                        'Found ${filteredVehicles.length} vehicle${filteredVehicles.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_searchController.text.isNotEmpty || _statusFilter != 'All Status') ...[
  const SizedBox(width: 8),
  TextButton.icon(
    onPressed: () {
      setState(() {
        _searchController.clear();
        _statusFilter = 'All Status';
      });
    },
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear filters'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 8),
             if (filteredVehicles.isEmpty)
  Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            _searchController.text.isNotEmpty || _statusFilter != 'All Status'
                ? Icons.search_off
                : Icons.directions_car_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty || _statusFilter != 'All Status'
                ? 'No vehicles match your search'
                : 'No vehicles found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ), // ✅ Remove the extra ), after this line
          if (_searchController.text.isNotEmpty || _statusFilter != 'All Status') ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _statusFilter = 'All Status';
                });
              },
              child: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    ),
  )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 160,
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FixedColumnWidth(120),
                        1: FixedColumnWidth(150),
                        2: FixedColumnWidth(100),
                        3: FixedColumnWidth(150),
                        4: FixedColumnWidth(150),
                        5: FixedColumnWidth(120),
                        6: FixedColumnWidth(100),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          children: [
                            _buildTableHeader('License Plate'),
                            _buildTableHeader('Driver'),
                            _buildTableHeader('Status'),
                            _buildTableHeader('Alertness'),
                            _buildTableHeader('Location'),
                            _buildTableHeader('Last Update'),
                            _buildTableHeader('Actions'),
                          ],
                        ),
                        ...filteredVehicles.map((vehicle) => _buildVehicleRow(vehicle)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
              'Emergency Services',
              style: TextStyle(
                fontSize: 32,
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
                Expanded(
                  child: _buildEmergencyServiceCard(
                    'Police',
                    '15',
                    Icons.local_police_outlined,
                    Colors.blue[700]!,
                    Colors.blue[50]!,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildEmergencyServiceCard(
                    'Ambulance',
                    '1122',
                    Icons.local_hospital_outlined,
                    Colors.red[700]!,
                    Colors.red[50]!,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildEmergencyServiceCard(
                    'Fire Department',
                    '16',
                    Icons.local_fire_department_outlined,
                    Colors.orange[700]!,
                    Colors.orange[50]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildEmergencyContactsTable(),
          ],
        ),
      ),
    );
  }
  Widget _buildEmergencyContactsTable() {
    return StreamBuilder<List<EmergencyContact>>(
      stream: _emergencyContactService.getEmergencyContactsStream(widget.user.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text('Error loading contacts: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final contacts = snapshot.data ?? [];

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fleet Contacts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddContactDialog();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Contact'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
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
                  ...contacts.map((contact) => _buildEmergencyContactRow(contact)),
                ],
              ),
            ],
          ),
        );
      },
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 24),
          Text(
            number,
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
        ],
      ),
    );
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final relationshipController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    String priority = 'secondary';
    List<String> methods = ['call'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: relationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'primary', child: Text('Primary')),
                    DropdownMenuItem(value: 'secondary', child: Text('Secondary')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      priority = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Contact Methods:', style: TextStyle(fontWeight: FontWeight.bold)),
                CheckboxListTile(
                  title: const Text('Phone Call'),
                  value: methods.contains('call'),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        methods.add('call');
                      } else {
                        methods.remove('call');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('SMS'),
                  value: methods.contains('sms'),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        methods.add('sms');
                      } else {
                        methods.remove('sms');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Email'),
                  value: methods.contains('email'),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        methods.add('email');
                      } else {
                        methods.remove('email');
                      }
                    });
                  },
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
                if (nameController.text.isEmpty || 
                    relationshipController.text.isEmpty || 
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }
                
                try {
                  await _emergencyContactService.addEmergencyContact(
                    userId: widget.user.id,
                    userRole: 'owner',
                    contactData: {
                      'name': nameController.text,
                      'relationship': relationshipController.text,
                      'phone': phoneController.text,
                      'email': emailController.text,
                      'priority': priority,
                      'methods': methods,
                      'enabled': true,
                    },
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${nameController.text} added to emergency contacts')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding contact: $e')),
                    );
                  }
                }
              },
              child: const Text('Add Contact'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditContactDialog(EmergencyContact contact) {
    final nameController = TextEditingController(text: contact.name);
    final relationshipController = TextEditingController(text: contact.relationship);
    final phoneController = TextEditingController(text: contact.phone);
    final emailController = TextEditingController(text: contact.email);
    String priority = contact.priority;
    List<String> methods = List<String>.from(contact.methods);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Emergency Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: relationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'primary', child: Text('Primary')),
                    DropdownMenuItem(value: 'secondary', child: Text('Secondary')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      priority = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Contact Methods:', style: TextStyle(fontWeight: FontWeight.bold)),
                CheckboxListTile(
                  title: const Text('Phone Call'),
                  value: methods.contains('call'),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        methods.add('call');
                      } else {
                        methods.remove('call');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('SMS'),
                  value: methods.contains('sms'),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        methods.add('sms');
                      } else {
                        methods.remove('sms');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Email'),
                  value: methods.contains('email'),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        methods.add('email');
                      } else {
                        methods.remove('email');
                      }
                    });
                  },
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
                if (nameController.text.isEmpty || 
                    relationshipController.text.isEmpty || 
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }
                
                try {
                  await _emergencyContactService.updateEmergencyContact(
                    contactId: contact.id,
                    contactData: {
                      'name': nameController.text,
                      'relationship': relationshipController.text,
                      'phone': phoneController.text,
                      'email': emailController.text,
                      'priority': priority,
                      'methods': methods,
                      'enabled': contact.enabled,
                    },
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${nameController.text} updated successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating contact: $e')),
                    );
                  }
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildEmergencyContactRow(EmergencyContact contact) {
    return TableRow(
      children: [
        _buildTableCell(contact.name),
        _buildTableCell(contact.relationship),
        _buildContactInfoCell(contact.phone, contact.email),
        _buildPriorityBadgeCell(contact.priority),
        _buildMethodsCell(contact.methods),
        _buildStatusToggleCell(contact),
        _buildContactActionsCell(contact),
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

  Widget _buildStatusToggleCell(EmergencyContact contact) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Switch(
        value: contact.enabled,
        onChanged: (value) async {
          try {
            await _emergencyContactService.toggleContactEnabled(contact.id, value);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating contact: $e')),
              );
            }
          }
        },
        activeColor: const Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildContactActionsCell(EmergencyContact contact) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () {
              _showEditContactDialog(contact);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Contact'),
                  content: Text('Delete ${contact.name} from emergency contacts?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  await _emergencyContactService.deleteEmergencyContact(contact.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${contact.name} removed')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting contact: $e')),
                    );
                  }
                }
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
  
  // Helper methods for fleet overview table
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

  TableRow _buildVehicleRow(Vehicle vehicle) {
    return TableRow(
      children: [
        _buildTableCell(vehicle.licensePlate),
        _buildTableCell(vehicle.driverName ?? 'Unassigned'),
        _buildStatusBadge(vehicle.status),
        _buildAlertnessCell(vehicle.alertness),
        _buildTableCell(vehicle.location ?? 'Unknown'),
        _buildTableCell(vehicle.lastUpdate ?? 'N/A'),
        _buildActionsCell(),
      ],
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
}