import 'package:flutter/material.dart';

/// Couleurs du design Next.js à reproduire exactement
class AppColors {
  // Couleur principale #00BFA5 (cyan professionnel)
  static const Color primary = Color(0xFF00BFA5);
  static const Color primaryLight = Color(0xFF4FFCD2);
  static const Color primaryDark = Color(0xFF00A693);

  // Variations de la couleur principale
  static const Color primary50 = Color(0xFFE6FFFA);
  static const Color primary100 = Color(0xFFB3FFF0);
  static const Color primary200 = Color(0xFF80FFE6);
  static const Color primary300 = Color(0xFF4DFFD6);
  static const Color primary400 = Color(0xFF1AFFC6);
  static const Color primary500 = Color(0xFF00BFA5);
  static const Color primary600 = Color(0xFF00A693);
  static const Color primary700 = Color(0xFF008F7F);
  static const Color primary800 = Color(0xFF00786B);
  static const Color primary900 = Color(0xFF006157);

  // Couleurs du design system
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Couleurs de texte
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceVariant = Color(0xFF737373);

  // Couleurs d'état
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Couleurs spéciales pour les cartes
  static const Color cardCurrent = Color(0xFF00BFA5);
  static const Color cardSavings = Color(0xFF3B82F6);

  // Couleurs pour le glassmorphism
  static const Color glassWhite = Color(0x4DFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Gradients pour la page de connexion
  static const LinearGradient loginBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF8FAFC), // purple-50
      Color(0xFFEFF6FF), // blue-50
      Color(0xFFEEF2FF), // indigo-50
    ],
  );

  // Gradient pour les cartes de crédit current
  static const LinearGradient cardCurrentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00BFA5), Color(0xFF00A693), Color(0xFF008777)],
  );

  // Gradient pour les cartes de crédit savings
  static const LinearGradient cardSavingsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1D4ED8)],
  );

  // Couleurs pour la sidebar dark
  static const Color sidebarBackground = Color(0xFF111827); // gray-900
  static const Color sidebarText = Color(0xFFFFFFFF);
  static const Color sidebarTextMuted = Color(0xFF9CA3AF); // gray-400
  static const Color sidebarHover = Color(0xFF374151); // gray-700
}
