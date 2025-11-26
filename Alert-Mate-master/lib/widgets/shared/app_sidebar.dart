import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/user.dart';
import '../../auth_screen.dart';

/// Reusable sidebar widget for all dashboards
/// Eliminates code duplication across admin, driver, owner, and passenger dashboards
class AppSidebar extends StatelessWidget {
  final String role;
  final User? user;
  final int selectedIndex;
  final Function(int) onMenuItemTap;
  final List<MenuItem> menuItems;
  final bool isCollapsible;

  const AppSidebar({
    Key? key,
    required this.role,
    this.user,
    required this.selectedIndex,
    required this.onMenuItemTap,
    required this.menuItems,
    this.isCollapsible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: collapse sidebar on small screens if enabled
        final shouldCollapse = isCollapsible && MediaQuery.of(context).size.width < 768;
        
        return Container(
          width: shouldCollapse ? 80 : 290,
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(shouldCollapse),
              const SizedBox(height: 8),
              _buildBackButton(context, shouldCollapse),
              const SizedBox(height: 16),
              ...menuItems.asMap().entries.map((entry) {
                return _buildMenuItem(
                  entry.value.icon,
                  entry.value.title,
                  entry.key,
                  shouldCollapse,
                );
              }).toList(),
              const Spacer(),
              _buildUserProfile(context, shouldCollapse),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool collapsed) {
    return Padding(
      padding: EdgeInsets.fromLTRB(collapsed ? 12 : 24, 32, collapsed ? 12 : 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!collapsed) ...[
            const Text(
              'ALERT MATE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Drowsiness Detection',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
          if (collapsed) ...[
            const Text(
              'AM',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              collapsed ? role[0].toUpperCase() : role,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool collapsed) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 18),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthScreen()),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back, size: 18, color: Colors.black87),
              if (!collapsed) ...[
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Back to Role Selection',
                    style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index, bool collapsed) {
    final bool isSelected = selectedIndex == index;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 18, vertical: 2),
      child: InkWell(
        onTap: () => onMenuItemTap(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: collapsed ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey[700],
                size: 20,
              ),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, bool collapsed) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(collapsed ? 8 : 16),
          padding: EdgeInsets.all(collapsed ? 8 : 12),
          child: Column(
            children: [
              Row(
                mainAxisSize: collapsed ? MainAxisSize.min : MainAxisSize.max,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.firstName[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'User',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            user?.email ?? 'user@example.com',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.notifications_outlined, size: 20, color: Colors.grey[600]),
                  ],
                ],
              ),
              if (!collapsed) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app, size: 18, color: Colors.grey[700]),
                        const SizedBox(width: 10),
                        const Text(
                          'Sign Out',
                          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Menu item model for sidebar
class MenuItem {
  final IconData icon;
  final String title;

  const MenuItem({
    required this.icon,
    required this.title,
  });
}
