import 'package:flutter/material.dart';

class AppColors {
  // Primary palette — deep indigo + electric teal
  static const Color primary = Color(0xFF3D5AF1);
  static const Color primaryDark = Color(0xFF2541C4);
  static const Color accent = Color(0xFF00D4B4);
  static const Color accentLight = Color(0xFFE0FBF7);

  // Backgrounds
  static const Color background = Color(0xFFF5F7FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1D3D);
  static const Color textSecondary = Color(0xFF6B7299);
  static const Color textLight = Color(0xFFADB5D3);

  // Status
  static const Color success = Color(0xFF00C896);
  static const Color error = Color(0xFFFF4D6A);
  static const Color warning = Color(0xFFFFB800);
  static const Color info = Color(0xFF5B8DEF);

  // Module colors
  static const Color quizColor = Color(0xFFFF6B6B);
  static const Color timetableColor = Color(0xFF6B5CF6);
  static const Color aiColor = Color(0xFF00D4B4);
  static const Color gamesColor = Color(0xFFFFB800);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3D5AF1), Color(0xFF6B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D4B4), Color(0xFF3D5AF1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
