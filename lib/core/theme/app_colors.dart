import 'package:flutter/material.dart';

class AppColors {
  // Primary - Vibrant Royal Blue & Deep Indigo
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primarySurface = Color(0xFFEFF6FF);
  static const Color primaryBorder = Color(0xFFBFDBFE);

  // Semantic
  static const Color green = Color(0xFF10B981); // Emerald Green
  static const Color greenSurface = Color(0xFFECFDF5);
  static const Color amber = Color(0xFFF59E0B); // Amber Orange
  static const Color amberSurface = Color(0xFFFEF3C7);
  static const Color red = Color(0xFFEF4444); // Crimson Red
  static const Color redSurface = Color(0xFFFEF2F2);
  static const Color violet = Color(0xFF8B5CF6); // Royal Violet
  static const Color violetSurface = Color(0xFFF5F3FF);

  // Neutral - Sleek Slate / Ink Colors
  static const Color ink = Color(0xFF0F172A);      // Deep Slate
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color line = Color(0xFFE2E8F0);
  static const Color line2 = Color(0xFFF1F5F9);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB), // Royal Blue
      Color(0xFF4F46E5), // Deep Indigo
      Color(0xFF7C3AED), // Purple
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
    ],
  );

  // Premium Multi-Layered Soft Shadows
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x04000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 30,
      offset: Offset(0, 18),
    ),
  ];

  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x03000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: Color(0x352563EB),
      blurRadius: 20,
      spreadRadius: -2,
      offset: Offset(0, 8),
    ),
  ];

  // Tone map for FeatureIcon
  static Map<String, List<Color>> tones = {
    'blue': [primarySurface, primary],
    'green': [greenSurface, green],
    'amber': [amberSurface, amber],
    'red': [redSurface, red],
    'violet': [violetSurface, violet],
    'slate': [bg, slate600],
  };

  static List<Color> tone(String name) => tones[name] ?? tones['blue']!;
}
