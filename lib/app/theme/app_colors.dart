import 'package:flutter/material.dart';

/// Application Color Palette
abstract final class AppColors {
  // --- Raw Palette Values from Artwork Reference ---
  static const Color paletteMidnightAbyss = Color(0xFF060A12);
  static const Color paletteNeonCyan = Color(0xFF00B4FF);
  static const Color paletteHydroSlate = Color(0xFF0E1726);
  static const Color paletteSpecularIce = Color(0xFF78B7E8);
  static const Color paletteCyberNavy = Color(0xFF1B2D4A);
  static const Color paletteLaserGlow = Color(0xFF00E5FF);

  // Backward-compatibility aliases
  static const Color paletteObsidian = paletteMidnightAbyss;
  static const Color paletteCobalt = paletteNeonCyan;
  static const Color paletteCharcoal = paletteHydroSlate;
  static const Color paletteSteel = paletteSpecularIce;
  static const Color paletteOrange = paletteNeonCyan;
  static const Color paletteSatinViolet = paletteNeonCyan;
  static const Color paletteSlateViolet = paletteHydroSlate;
  static const Color paletteLuminousLilac = paletteSpecularIce;
  static const Color paletteMineralStone = paletteCyberNavy;
  static const Color paletteDeepPlum = paletteCyberNavy;

  // --- Semantic Dark Theme Roles (Dark Theme Exclusively) ---
  // Backgrounds & Surfaces
  static const Color background = paletteMidnightAbyss;
  static const Color surface = paletteHydroSlate;
  static const Color surfaceVariant = Color(0xFF142238);
  static const Color card = paletteHydroSlate;
  static const Color dialog = paletteHydroSlate;
  static const Color navBar = Color(0xFF080E18);

  // Brand & Interactive Accents
  static const Color primary = paletteNeonCyan;
  static const Color onPrimary = Color(0xFF04070E);
  static const Color secondary = paletteSpecularIce;
  static const Color onSecondary = Color(0xFF060A12);
  static const Color accent = paletteLaserGlow;

  // Text Colors
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8FA5BE);
  static const Color textMuted = Color(0xFF536882);

  // Borders, Dividers & Outlines
  static const Color border = Color(0xFF1C2F48);
  static const Color borderGlow = paletteNeonCyan;
  static const Color divider = Color(0xFF101C2B);

  // Functional / Status Colors
  static const Color error = Color(0xFFFF5252);
  static const Color onError = Colors.white;
  static const Color success = Color(0xFF00E676);
  static const Color onSuccess = Colors.black;
  static const Color warning = Color(0xFFFFB74D);
  static const Color onWarning = Colors.black;
  static const Color info = paletteNeonCyan;

  static const Color waColor = Color(0xFF25D366);
  static const Color igColor = Color(0xFFFF5FA2);

  static Color statusColor(String s) => switch (s) {
    'Running' ||
    'Subscribed' ||
    'Approved' ||
    'Active' ||
    'Connected' ||
    'Verified' => success,
    'Scheduled' || 'Pending' => primary,
    'Paused' || 'In review' => warning,
    'Unsubscribed' => error,
    'Completed' => secondary,
    _ => textMuted,
  };

  // Visual Sheen Gradients inspired by the glowing laser edge & hydro matte slabs
  static const LinearGradient neonLaserGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0066FF), Color(0xFF00B4FF), Color(0xFF00F0FF)],
  );

  static const LinearGradient hydroGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF16253D), Color(0xFF0E1726), Color(0xFF070C15)],
  );

  static const LinearGradient specularDropletGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF243B5C), Color(0xFF0F1A2B)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0072FF), Color(0xFF00B4FF)],
  );

  static const LinearGradient iconDarkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF192A42), Color(0xFF0E1726)],
  );

  static const LinearGradient iconGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00B4D8), Color(0xFF00E676)],
  );
}
