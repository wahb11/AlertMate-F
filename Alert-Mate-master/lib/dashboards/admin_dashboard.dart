import 'package:flutter/material.dart';
import 'dart:math';
import '../models/user.dart';
import '../auth_screen.dart';
import '../constants/app_colors.dart';
import '../widgets/shared/app_sidebar.dart';


class AdminDashboard extends StatefulWidget {
  final User user;

  const AdminDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0; // 0: Dashboard, 1: Emergency
  int _selectedTab = 0;
  String _selectedRoleFilter = 'All Roles';
  final Random _random = Random();
  // Emergency contacts (moved to state so actions can modify them)
  final List<Map<String, dynamic>> _emergencyContacts = [
    {'name': 'Sarah Johnson', 'relationship': 'Spouse', 'phone': '+1 (555) 123-4567', 'email': 'sarah@example.com', 'priority': 'primary', 'methods': ['call', 'sms', 'email'], 'enabled': true},
    {'name': 'Mike Chen', 'relationship': 'Fleet Manager', 'phone': '+1 (555) 987-6543', 'email': 'mike@company.com', 'priority': 'secondary', 'methods': ['sms', 'email'], 'enabled': true},
    {'name': 'Emergency Services', 'relationship': '911', 'phone': '911', 'email': '', 'priority': 'primary', 'methods': ['call'], 'enabled': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: _selectedIndex == 0 ? _buildMainContent() : _buildEmergency(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return AppSidebar(
      role: 'admin',
      user: widget.user,
      selectedIndex: _selectedIndex,
      onMenuItemTap: (index) => setState(() => _selectedIndex = index),
      menuItems: const [
        MenuItem(icon: Icons.dashboard_outlined, title: 'Dashboard'),
        MenuItem(icon: Icons.phone_outlined, title: 'Emergency'),
      ],
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
                Expanded(child: _buildEmergencyServiceCard('Police', '15', Icons.local_police, AppColors.primary, const Color(0xFFE3F2FD))),
                const SizedBox(width: 20),
                Expanded(child: _buildEmergencyServiceCard('Ambulance', '1122', Icons.local_hospital, Colors.red, const Color(0xFFFFEBEE))),
                const SizedBox(width: 20),
                Expanded(child: _buildEmergencyServiceCard('Fire Department', '16', Icons.local_fire_department, const Color(0xFFFF6F00), const Color(0xFFFFF3E0))),
                const SizedBox(width: 20),
                Expanded(child: _buildEmergencyServiceCard('Motorway Police', '130', Icons.car_crash, const Color(0xFF4CAF50), const Color(0xFFE8F5E9))),
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
              onPressed: () {},
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
                  backgroundColor: AppColors.primary,
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

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStatsCards(),
            const SizedBox(height: 32),
            _buildTabBar(),
            const SizedBox(height: 32),
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Administration',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage users, system settings, and monitor platform health',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting data...')));
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Export Data'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import dialog')));
                  },
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text('Import'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  icon: const Icon(Icons.settings_outlined),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active Users',
            '1,247',
            '+12% from last month',
            Icons.people_outline,
            Colors.black,
            Colors.green,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            'System Health',
            '98.5%',
            'All systems operational',
            Icons.favorite_border,
            Colors.green,
            Colors.green,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            'Active Alerts',
            '6',
            'Require attention',
            Icons.warning_amber_outlined,
            Colors.orange,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            'Data Storage',
            '2.4TB',
            '+8% this month',
            Icons.storage_outlined,
            Colors.black,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle,
      IconData icon, Color valueColor, Color subtitleColor) {
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
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      'User Management',
      'Fleet Overview',
      'System Settings',
      'Analytics',
      'Security'
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildTab(tabs[index], index),
          );
        }),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isActive = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? const Border(
            bottom: BorderSide(color: Color(0xFF6366F1), width: 2),
          )
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? const Color(0xFF6366F1) : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildUserManagement();
      case 1:
        return _buildFleetOverview();
      case 2:
        return _buildSystemSettings();
      case 3:
        return _buildAnalytics();
      case 4:
        return _buildSecurity();
      default:
        return _buildUserManagement();
    }
  }

  Widget _buildUserManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Management',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage user accounts and permissions',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add user dialog')));
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedRoleFilter,
                    items: ['All Roles', 'Admin', 'Driver', 'Passenger', 'Owner']
                        .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedRoleFilter = value!),
                    underline: Container(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildUserTable(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildUserRoleDistribution()),
            const SizedBox(width: 24),
            Expanded(child: _buildRecentUserActivity()),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTable() {
    final users = [
      {'name': 'John Smith', 'email': 'john@example.com', 'role': 'driver', 'status': 'Active', 'lastLogin': '2 hours ago'},
      {'name': 'Sarah Johnson', 'email': 'sarah@example.com', 'role': 'passenger', 'status': 'Active', 'lastLogin': '1 day ago'},
      {'name': 'Mike Chen', 'email': 'mike@example.com', 'role': 'owner', 'status': 'Active', 'lastLogin': '30 min ago'},
      {'name': 'Lisa Wong', 'email': 'lisa@example.com', 'role': 'driver', 'status': 'Inactive', 'lastLogin': '1 week ago'},
      {'name': 'David Brown', 'email': 'david@example.com', 'role': 'admin', 'status': 'Active', 'lastLogin': '5 min ago'},
    ];

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2.5),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(2),
        5: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          children: [
            _buildTableHeader('Name'),
            _buildTableHeader('Email'),
            _buildTableHeader('Role'),
            _buildTableHeader('Status'),
            _buildTableHeader('Last Login'),
            _buildTableHeader('Actions'),
          ],
        ),
        ...users.map((user) => TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
          ),
          children: [
            _buildTableCell(user['name']!),
            _buildTableCell(user['email']!),
            _buildRoleBadge(user['role']!),
            _buildStatusBadge(user['status']!),
            _buildTableCell(user['lastLogin']!),
            _buildActionButtons(),
          ],
        )),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final colors = {
      'driver': const Color(0xFF4CAF50),
      'passenger': const Color(0xFFFF9800),
      'owner': const Color(0xFF2196F3),
      'admin': const Color(0xFF9C27B0),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors[role]!,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          role,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status == 'Active';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4CAF50) : Colors.grey[400],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit user')));
            },
            color: Colors.grey[600],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted')));
            },
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildUserRoleDistribution() {
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
            'User Role Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Breakdown of user roles',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildRoleRow('Drivers', 847, const Color(0xFF4CAF50)),
          _buildRoleRow('Passengers', 234, const Color(0xFFFF9800)),
          _buildRoleRow('Owners', 156, const Color(0xFF2196F3)),
          _buildRoleRow('Admins', 10, const Color(0xFF9C27B0)),
        ],
      ),
    );
  }

  Widget _buildRoleRow(String role, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            role,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUserActivity() {
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
            'Recent User Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Latest user registrations and logins',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildActivityItem(
            Icons.person_add_outlined,
            'New user registered',
            'Alex Thompson - Driver - 2 min ago',
            const Color(0xFF2196F3),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            Icons.shield_outlined,
            'Admin login',
            'David Brown - 5 min ago',
            const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            Icons.swap_horiz,
            'Role updated',
            'Lisa Wong - Driver to Owner - 1 hour ago',
            const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
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

  Widget _buildFleetOverview() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildGlobalFleetStatus()),
            const SizedBox(width: 24),
            Expanded(child: _buildLiveFleetMap()),
          ],
        ),
        const SizedBox(height: 24),
        _buildFleetPerformanceMetrics(),
      ],
    );
  }

  Widget _buildGlobalFleetStatus() {
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
            'Global Fleet Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Real-time fleet monitoring across all regions',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
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

  Widget _buildLiveFleetMap() {
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
            'Live Fleet Map',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Global vehicle locations',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Interactive global fleet map',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '104 vehicles currently active',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    '78',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  Text(
                    'Active Vehicles',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    '6',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5722),
                    ),
                  ),
                  Text(
                    'Critical Alerts',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFleetPerformanceMetrics() {
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
            'Fleet Performance Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Key performance indicators across all fleets',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildMetricCard('104', 'Total Vehicles', Icons.directions_car_outlined, const Color(0xFF2196F3))),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('87.3%', 'Avg Alertness', Icons.show_chart, const Color(0xFF4CAF50))),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('23', 'Incidents Today', Icons.warning_amber_outlined, const Color(0xFFFF9800))),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('94.2%', 'Uptime', Icons.trending_up, const Color(0xFF9C27B0))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettings() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildSystemConfiguration()),
            const SizedBox(width: 24),
            Expanded(child: _buildAlertThresholds()),
          ],
        ),
        const SizedBox(height: 24),
        _buildSystemMaintenance(),
      ],
    );
  }

  Widget _buildSystemConfiguration() {
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
            'System Configuration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Core system settings and preferences',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildSettingToggle('Maintenance Mode', 'Enable system maintenance mode', false),
          const SizedBox(height: 20),
          _buildSettingToggle('Automatic Backups', 'Daily automated system backups', true),
          const SizedBox(height: 20),
          _buildSettingToggle('Real-time Alerts', 'Push notifications for critical events', true),
          const SizedBox(height: 20),
          _buildSettingToggle('Extended Data Retention', 'Keep data for 2 years instead of 1', false),
        ],
      ),
    );
  }

  Widget _buildSettingToggle(String title, String subtitle, bool value) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (val) {},
          activeColor: const Color(0xFF6366F1),
        ),
      ],
    );
  }

  Widget _buildAlertThresholds() {
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
            'Alert Thresholds',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Configure system alert sensitivity',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildThresholdDropdown('Drowsiness Alert Threshold', '75% (Medium Sensitivity)'),
          const SizedBox(height: 20),
          _buildThresholdDropdown('Critical Alert Threshold', '65% (Medium Sensitivity)'),
          const SizedBox(height: 20),
          _buildThresholdDropdown('Notification Delay', '30 seconds'),
        ],
      ),
    );
  }

  Widget _buildThresholdDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemMaintenance() {
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
            'System Maintenance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Database and system maintenance tools',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildMaintenanceButton('Database Backup', Icons.storage_outlined, '2 hours ago')),
              const SizedBox(width: 16),
              Expanded(child: _buildMaintenanceButton('System Health Check', Icons.favorite_border, 'All systems OK')),
              const SizedBox(width: 16),
              Expanded(child: _buildMaintenanceButton('Performance Monitor', Icons.show_chart, 'View metrics')),
              const SizedBox(width: 16),
              Expanded(child: _buildMaintenanceButton('Export Logs', Icons.download, 'Download')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceButton(String label, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.grey[600]),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPlatformUsageTrends()),
            const SizedBox(width: 24),
            Expanded(child: _buildSystemPerformance()),
          ],
        ),
        const SizedBox(height: 24),
        _buildGlobalStatistics(),
      ],
    );
  }

  Widget _buildPlatformUsageTrends() {
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
            'Platform Usage Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'User growth and incident trends over time',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: CustomPaint(
              painter: LineChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemPerformance() {
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
            'System Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Key performance metrics',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildPerformanceRow('API Response Time', '142ms', const Color(0xFF4CAF50)),
          _buildPerformanceRow('Database Query Time', '23ms', const Color(0xFF4CAF50)),
          _buildPerformanceRow('System Uptime', '99.97%', const Color(0xFF4CAF50)),
          _buildPerformanceRow('Error Rate', '0.03%', const Color(0xFF4CAF50)),
          _buildPerformanceRow('Active Connections', '1,247', Colors.black87),
          _buildPerformanceRow('Memory Usage', '67%', const Color(0xFFFF9800)),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalStatistics() {
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
            'Global Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Platform-wide metrics and insights',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatisticCard('1247', 'Total Users', '+12%', const Color(0xFF4CAF50)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatisticCard('89', 'Active Vehicles', '+5%', const Color(0xFF4CAF50)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatisticCard('99.9%', 'System Uptime', '0%', Colors.black54),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatisticCard('2.4TB', 'Data Storage', '+8%', const Color(0xFF2196F3)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard(String value, String label, String change, Color changeColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            change,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: changeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurity() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildSecuritySettings()),
            const SizedBox(width: 24),
            Expanded(child: _buildSecurityMonitoring()),
          ],
        ),
        const SizedBox(height: 24),
        _buildSystemBackupRecovery(),
      ],
    );
  }

  Widget _buildSecuritySettings() {
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
            'Security Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Configure system security policies',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildSecurityToggle('Require Two-Factor Authentication', 'Mandatory 2FA for all admin users', true),
          const SizedBox(height: 20),
          _buildSecurityToggle('Auto Session Timeout', 'Automatic logout after inactivity', true),
          const SizedBox(height: 20),
          _buildSecurityToggle('Enhanced Audit Logging', 'Detailed activity logging', true),
          const SizedBox(height: 20),
          _buildPasswordPolicy(),
        ],
      ),
    );
  }

  Widget _buildSecurityToggle(String title, String subtitle, bool value) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (val) {},
          activeColor: const Color(0xFF6366F1),
        ),
      ],
    );
  }

  Widget _buildPasswordPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password Policy',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Strong (12+ chars, mixed case, numbers)',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityMonitoring() {
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
            'Security Monitoring',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Recent security events and alerts',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildSecurityEvent('Successful admin login', 'David Brown - 5 min ago', Icons.lock_open, const Color(0xFF4CAF50)),
          const SizedBox(height: 16),
          _buildSecurityEvent('Failed login attempt', 'Unknown user - 2 hours ago', Icons.warning_amber, const Color(0xFFFF9800)),
          const SizedBox(height: 16),
          _buildSecurityEvent('Security scan completed', 'No vulnerabilities found - 1 day ago', Icons.shield_outlined, const Color(0xFF2196F3)),
        ],
      ),
    );
  }

  Widget _buildSecurityEvent(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
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

  Widget _buildSystemBackupRecovery() {
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
            'System Backup & Recovery',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Data backup and disaster recovery settings',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildBackupCard('Last Backup', '2 hours ago', Icons.storage_outlined, 'Create Backup', const Color(0xFF2196F3))),
              const SizedBox(width: 16),
              Expanded(child: _buildBackupCard('Backup Size', '2.4 TB', Icons.folder_outlined, 'View Details', const Color(0xFF4CAF50))),
              const SizedBox(width: 16),
              Expanded(child: _buildBackupCard('Recovery Time', '< 15 minutes', Icons.shield_outlined, 'Test Recovery', const Color(0xFF9C27B0))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCard(String title, String value, IconData icon, String buttonText, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(buttonText, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// Custom painter for bar chart
class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final data = [25, 18, 32, 24, 20, 19, 15];
    final regions = ['North', 'South', 'East', 'West'];
    final barWidth = size.width / (data.length + 1);

    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i] / 35) * size.height * 0.8;
      final rect = Rect.fromLTWH(
        barWidth * (i + 0.5),
        size.height - barHeight - 40,
        barWidth * 0.6,
        barHeight,
      );
      canvas.drawRect(rect, paint);
    }

    // Draw axis labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < regions.length; i++) {
      textPainter.text = TextSpan(
        text: regions[i],
        style: const TextStyle(color: Colors.black87, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(barWidth * (i * 1.75 + 1), size.height - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final points = [
      Offset(size.width * 0.1, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.7),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    for (var point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }

    // Draw axis labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

    for (int i = 0; i < months.length; i++) {
      textPainter.text = TextSpan(
        text: months[i],
        style: const TextStyle(color: Colors.black87, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width * (i / 6 + 0.05), size.height - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}