import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import '../models/user.dart';
import '../auth_screen.dart';
import '../widgets/shared/app_sidebar.dart';
import '../constants/app_colors.dart';

class DriverDashboard extends StatefulWidget {
  final User user;

  const DriverDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _selectedTab = 0;
  bool _isMonitoring = false;
  Process? _monitorProcess;
  bool _isCameraTesting = false;
  double _alertness = 82.0;
  double _ear = 0.0;
  double _mar = 0.0;
  double _eyeClosurePercentage = 0.0;
  Timer? _updateTimer;
  final Random _random = Random();
  // make emergency contacts part of state so UI can modify them
  final List<Map<String, dynamic>> _emergencyContacts = [
    {
      'name': 'Sarah Johnson',
      'relationship': 'Spouse',
      'phone': '+1 (555) 123-4567',
      'email': 'sarah@example.com',
      'priority': 'primary',
      'methods': ['call', 'sms', 'email'],
      'enabled': true,
    },
    {
      'name': 'Mike Chen',
      'relationship': 'Fleet Manager',
      'phone': '+1 (555) 987-6543',
      'email': 'mike@company.com',
      'priority': 'secondary',
      'methods': ['sms', 'email'],
      'enabled': true,
    },
    {
      'name': 'Emergency Services',
      'relationship': '911',
      'phone': '911',
      'email': '',
      'priority': 'primary',
      'methods': ['call'],
      'enabled': true,
    },
  ];
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Alert Settings
  bool _audioAlertsEnabled = true;
  bool _vibrationAlertsEnabled = true;
  String _sensitivityLevel = 'Medium';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startMonitoring() {
    setState(() {
      _isMonitoring = true;
    });

    // Desktop-only integration
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _launchPythonMonitor();
    } else {
      // Fallback: mock stats on mobile/web
      _updateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          _alertness = 70 + _random.nextDouble() * 25;
          _ear = _random.nextDouble() * 0.3;
          _mar = _random.nextDouble() * 0.3;
          _eyeClosurePercentage = _random.nextDouble() * 30;
        });
      });
    }
  }

  void _stopMonitoring() {
    setState(() {
      _isMonitoring = false;
    });
    _updateTimer?.cancel();
    _killPythonMonitor();
  }

  Future<void> _launchPythonMonitor() async {
    try {
      // Adjust paths as needed. Model path provided by user.
      final scriptPath = Platform.isWindows
          ? '${Directory.current.path}\\python\\drowsiness_monitor.py'
          : '${Directory.current.path}/python/drowsiness_monitor.py';
      final modelPath = r"C:\\Users\\123\\Downloads"; // TODO: point to your actual model file

      _monitorProcess = await Process.start(
        'python',
        [scriptPath, '--model', modelPath, '--size', '128', '--camera', '0'],
        runInShell: true,
        mode: ProcessStartMode.normal,
      );

      // Listen to stdout lines (JSON stats)
      _monitorProcess!.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        try {
          final data = json.decode(line) as Map<String, dynamic>;
          if (data.containsKey('error')) {
            // ignore errors for now or surface via snackbar
            return;
          }
          setState(() {
            _alertness = (data['alertness'] as num?)?.toDouble() ?? _alertness;
            _ear = (data['ear'] as num?)?.toDouble() ?? _ear;
            _mar = (data['mar'] as num?)?.toDouble() ?? _mar;
            _eyeClosurePercentage = (data['eyeClosure'] as num?)?.toDouble() ?? _eyeClosurePercentage;
          });
        } catch (_) {
          // ignore malformed lines
        }
      });

      // Optionally listen to stderr for debugging
      _monitorProcess!.stderr.transform(utf8.decoder).listen((_) {});

      // When process exits, stop monitoring state if still active
      _monitorProcess!.exitCode.then((_) {
        if (mounted && _isMonitoring) {
          setState(() {
            _isMonitoring = false;
          });
        }
      });
    } catch (e) {
      // Fallback to mock data if launching fails
      _updateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          _alertness = 70 + _random.nextDouble() * 25;
          _ear = _random.nextDouble() * 0.3;
          _mar = _random.nextDouble() * 0.3;
          _eyeClosurePercentage = _random.nextDouble() * 30;
        });
      });
    }
  }

  void _killPythonMonitor() {
    try {
      _monitorProcess?.kill(ProcessSignal.sigint);
      _monitorProcess = null;
    } catch (_) {}
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AppSidebar(
            role: 'driver',
            user: widget.user,
            selectedIndex: _selectedIndex,
            onMenuItemTap: (index) => setState(() => _selectedIndex = index),
            menuItems: const [
              MenuItem(icon: Icons.home_outlined, title: 'Dashboard'),
              MenuItem(icon: Icons.phone_outlined, title: 'Emergency'),
            ],
            accentColor: AppColors.driverPrimary,
            accentLightColor: AppColors.driverLight,
          ),
          Expanded(
            child: _selectedIndex == 0 ? _buildDashboard() : _buildEmergency(),
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredItem(Widget child, int index) {
    final Animation<double> fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
      ),
    );
    final Animation<Offset> slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }



  Widget _buildDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 900;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 20.0 : 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Driver Dashboard',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 28 : 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Real-time drowsiness monitoring',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _isMonitoring
                          ? _stopMonitoring
                          : _startMonitoring,
                      icon: Icon(
                          _isMonitoring ? Icons.pause : Icons.visibility),
                      label: Text(_isMonitoring
                          ? 'Stop Monitoring'
                          : 'Start Monitoring'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.driverPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                isSmallScreen
                    ? Column(
                  children: [
                    _buildAlertCard(),
                    const SizedBox(height: 20),
                    _buildEARMARCard(),
                    const SizedBox(height: 20),
                    _buildSystemStatusCard(),
                  ],
                )
                    : Row(
                  children: [
                    Expanded(child: _buildAlertCard()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildEARMARCard()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildSystemStatusCard()),
                  ],
                ),
                const SizedBox(height: 32),
                _buildTabBar(),
                const SizedBox(height: 32),
                _buildTabContent(isSmallScreen),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertCard() {
    return Container(
      padding: const EdgeInsets.all(28),
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
              const Flexible(
                child: Text(
                  'Current Alertness',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.show_chart, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '${_alertness.toInt()}%',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Good',
              style: TextStyle(
                color: Color(0xFFFFA726),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _alertness / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.driverPrimary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEARMARCard() {
    return Container(
      padding: const EdgeInsets.all(28),
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
              const Flexible(
                child: Text(
                  'EAR / MAR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.timeline, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'EAR ${_ear.toStringAsFixed(2)} • MAR ${_mar.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Live from camera',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatusCard() {
    return Container(
      padding: const EdgeInsets.all(28),
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
              const Flexible(
                child: Text(
                  'System Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.shield_outlined, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Flexible(
                child: Text(
                  'All Systems Active',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.battery_full, color: Colors.grey[600], size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Battery: 87%',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
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
          _buildTab('Live Monitoring', 0),
          const SizedBox(width: 8),
          _buildTab('Alert Settings', 1),
          const SizedBox(width: 8),
          _buildTab('Camera Test', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isActive = _selectedTab == index;
    return AnimatedScale(
      scale: isActive ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? const Border(
              bottom: BorderSide(color: AppColors.driverPrimary, width: 2),
            )
                : null,
            boxShadow: isActive ? [
              BoxShadow(
                color: AppColors.driverPrimary.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppColors.driverPrimary : Colors.black54,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(bool isSmallScreen) {
    switch (_selectedTab) {
      case 0:
        return _buildLiveMonitoringTab(isSmallScreen);
      case 1:
        return _buildAlertSettingsTab();
      case 2:
        return _buildCameraTestTab();
      default:
        return _buildLiveMonitoringTab(isSmallScreen);
    }
  }

  Widget _buildLiveMonitoringTab(bool isSmallScreen) {
    return isSmallScreen
        ? Column(
      children: [
        _buildRealtimeAlertness(),
        const SizedBox(height: 20),
        _buildEyeClosureDetection(),
      ],
    )
        : Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildRealtimeAlertness()),
        const SizedBox(width: 20),
        Expanded(child: _buildEyeClosureDetection()),
      ],
    );
  }

  Widget _buildAlertSettingsTab() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alert Configuration',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Customize your drowsiness detection alerts',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 32),
          _buildSettingRow(
            'Audio Alerts',
            'Sound alarm when drowsiness detected',
            _audioAlertsEnabled,
                (value) => setState(() => _audioAlertsEnabled = value),
            actionWidget: Text(
              'Enabled',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Divider(height: 48),
          _buildSettingRow(
            'Vibration Alerts',
            'Device vibration for alerts',
            _vibrationAlertsEnabled,
                (value) => setState(() => _vibrationAlertsEnabled = value),
            actionWidget: Text(
              'Enabled',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Divider(height: 48),
          _buildSettingRowWithButton(
            'Emergency Contacts',
            'Auto-notify contacts on critical alerts',
            'Configure',
                () {
              // Handle configure action
            },
          ),
          const Divider(height: 48),
          _buildSettingRowWithButton(
            'Sensitivity Level',
            'Adjust detection sensitivity',
            _sensitivityLevel,
                () {
              _showSensitivityDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title,
      String subtitle,
      bool value,
      Function(bool) onChanged, {
        Widget? actionWidget,
      }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (actionWidget != null) actionWidget,
      ],
    );
  }

  Widget _buildSettingRowWithButton(String title,
      String subtitle,
      String buttonText,
      VoidCallback onPressed,) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            side: BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showSensitivityDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Sensitivity Level'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  title: const Text('Low'),
                  value: 'Low',
                  groupValue: _sensitivityLevel,
                  onChanged: (value) {
                    setState(() => _sensitivityLevel = value.toString());
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('Medium'),
                  value: 'Medium',
                  groupValue: _sensitivityLevel,
                  onChanged: (value) {
                    setState(() => _sensitivityLevel = value.toString());
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: const Text('High'),
                  value: 'High',
                  groupValue: _sensitivityLevel,
                  onChanged: (value) {
                    setState(() => _sensitivityLevel = value.toString());
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildCameraTestTab() {
    return Container(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Camera Test',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Test camera access separately from face detection',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isCameraTesting = !_isCameraTesting);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(_isCameraTesting ? 'Stop Test' : 'Test Camera'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text(
                'Status: ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _isCameraTesting ? 'Testing...' : 'Ready to test',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 480,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: Center(
              child: _isCameraTesting
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Camera is testing...',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              )
                  : Text(
                'Click "Test Camera" to start',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeAlertness() {
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
            'Real-time Alertness',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Live drowsiness detection from the camera',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 420,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Camera feed will appear here',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEyeClosureDetection() {
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
            'Eye Closure Detection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Percentage of time with eyes closed',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 420,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_eyeClosurePercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Eyes Closed',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add this method to your dashboard state class
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

  Widget _buildEmergencyServiceCard(String title, String number, IconData icon,
      Color color, Color bgColor) {
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

  // Add Contact Dialog
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
              onPressed: () {
                if (nameController.text.isEmpty || 
                    relationshipController.text.isEmpty || 
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }
                
                setState(() {
                  _emergencyContacts.add({
                    'name': nameController.text,
                    'relationship': relationshipController.text,
                    'phone': phoneController.text,
                    'email': emailController.text,
                    'priority': priority,
                    'methods': methods,
                    'enabled': true,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${nameController.text} added to emergency contacts')),
                );
              },
              child: const Text('Add Contact'),
            ),
          ],
        ),
      ),
    );
  }

  // Edit Contact Dialog
  void _showEditContactDialog(int index) {
    final contact = _emergencyContacts[index];
    final nameController = TextEditingController(text: contact['name']);
    final relationshipController = TextEditingController(text: contact['relationship']);
    final phoneController = TextEditingController(text: contact['phone']);
    final emailController = TextEditingController(text: contact['email']);
    String priority = contact['priority'];
    List<String> methods = List<String>.from(contact['methods']);

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
              onPressed: () {
                if (nameController.text.isEmpty || 
                    relationshipController.text.isEmpty || 
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }
                
                setState(() {
                  _emergencyContacts[index] = {
                    'name': nameController.text,
                    'relationship': relationshipController.text,
                    'phone': phoneController.text,
                    'email': emailController.text,
                    'priority': priority,
                    'methods': methods,
                    'enabled': contact['enabled'],
                  };
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${nameController.text} updated successfully')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsTable() {
    // uses the stateful _emergencyContacts defined on the State
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
              onPressed: () {
                _showAddContactDialog();
              },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Contact'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
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
          onPressed: () {
            _showEditContactDialog(index);
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
}