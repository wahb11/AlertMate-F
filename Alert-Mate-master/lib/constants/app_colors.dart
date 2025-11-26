import 'package:flutter/material.dart';

/// Centralized color constants for the Alert-Mate application
/// Ensures consistent theming across all dashboards
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFFE3F2FD);
  static const Color primaryDark = Color(0xFF1976D2);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryLight = Color(0xFFE8F5E9);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color border = Color(0xFFE0E0E0);
  
  // Emergency Service Colors
  static const Color police = Color(0xFF2196F3);
  static const Color policeLight = Color(0xFFE3F2FD);
  static const Color ambulance = Colors.red;
  static const Color ambulanceLight = Color(0xFFFFEBEE);
  static const Color fire = Color(0xFFFF6F00);
  static const Color fireLight = Color(0xFFFFF3E0);
  static const Color motorway = Color(0xFF4CAF50);
  static const Color motorwayLight = Color(0xFFE8F5E9);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2196F3),
    Color(0xFF1976D2),
  ];
  
  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.04);
  static Color shadowMedium = Colors.black.withOpacity(0.08);
  static Color shadowDark = Colors.black.withOpacity(0.12);
}
