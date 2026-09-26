import 'package:flutter/material.dart';

/// VicobaPlus Color Design Tokens - Matching Web Tokens & Strict WCAG AA Standards
class AppColors {
  AppColors._();

  // Brand Primary: Deep African Emerald Green
  static const Color primary = Color(0xFF087F5B);
  static const Color primaryDark = Color(0xFF056B4D);
  static const Color primaryHover = Color(0xFF067252);
  static const Color primaryLight = Color(0xFFE8F7F1);
  static const Color primaryLightDark = Color(0xFF16362B);

  // Accent: Tanzanian Gold
  static const Color accent = Color(0xFFF4B942);
  static const Color accentHover = Color(0xFFE0A32E);
  static const Color accentLight = Color(0xFFFEF7E8);
  static const Color accentLightDark = Color(0xFF382A0B);

  // Light Mode Surfaces
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightBgSecondary = Color(0xFFF7F9F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightGlass = Color(0xD9FFFFFF); // 85% opacity
  static const Color lightBorder = Color(0xFFE5EAE8);
  static const Color lightBorderFocus = Color(0xFF087F5B);

  // Light Mode Typography
  static const Color lightText = Color(0xFF17221E);
  static const Color lightTextSecondary = Color(0xFF4A5B54);
  static const Color lightTextMuted = Color(0xFF6E8078);

  // Dark Mode Surfaces
  static const Color darkBg = Color(0xFF0B1411);
  static const Color darkBgSecondary = Color(0xFF13221C);
  static const Color darkCard = Color(0xFF182B24);
  static const Color darkGlass = Color(0xD9182B24); // 85% opacity
  static const Color darkBorder = Color(0xFF233C32);
  static const Color darkBorderFocus = Color(0xFF10B981);

  // Dark Mode Typography
  static const Color darkText = Color(0xFFF0F6F2);
  static const Color darkTextSecondary = Color(0xFFA0B9AC);
  static const Color darkTextMuted = Color(0xFF738C81);

  // Semantic Colors (Light)
  static const Color danger = Color(0xFFD64545);
  static const Color dangerLight = Color(0xFFFEECEB);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color success = Color(0xFF087F5B);
  static const Color successLight = Color(0xFFE8F7F1);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFEFF6FF);

  // Semantic Colors (Dark adjustments)
  static const Color darkDanger = Color(0xFFF87171);
  static const Color darkDangerLight = Color(0xFF3E1616);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkWarningLight = Color(0xFF3A2E0F);
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkSuccessLight = Color(0xFF14382B);
  static const Color darkInfo = Color(0xFF60A5FA);
  static const Color darkInfoLight = Color(0xFF172B4D);

  // Aliases for compatibility
  static const Color error = danger;
  static const Color errorLight = dangerLight;
  static const Color lightTextPrimary = lightText;
  static const Color darkTextPrimary = darkText;
  static const Color darkSurface = darkCard;
  static const Color lightSurface = lightCard;
}
