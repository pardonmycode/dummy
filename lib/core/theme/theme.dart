import 'package:material_ui/material_ui.dart' as flutter;
import 'package:material_ui/material_ui.dart';

/// Design tokens for the Widgetly app.
class AppTheme {
  AppTheme._();

  // Primary color
  static const Color primary = Color(0xFF4361EE);
  static const Color primaryVariant = Color(0xFF3A56D4);
  static const Color secondary = Color(0xFF7209B7);
  static const Color accent = Color(0xFFF72585);

  // Colors - Light
  static const Color lightPrimary = Color(0xFF4361EE);
  static const Color lightPrimaryVariant = Color(0xFF3A56D4);
  static const Color lightSecondary = Color(0xFF7209B7);
  static const Color lightAccent = Color(0xFFF72585);
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6C757D);
  static const Color lightBorder = Color(0xFFE9ECEF);
  static const Color lightSuccess = Color(0xFF2ECC71);
  static const Color lightWarning = Color(0xFFF39C12);
  static const Color lightError = Color(0xFFE74C3C);
  static const Color lightInfo = Color(0xFF3498DB);

  // Colors - Dark
  static const Color darkPrimary = Color(0xFF7B93F4);
  static const Color darkPrimaryVariant = Color(0xFF6B82E8);
  static const Color darkSecondary = Color(0xFF9D4EDD);
  static const Color darkAccent = Color(0xFFFF6EB4);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2A2A2A);
  static const Color darkText = Color(0xFFF0F0F0);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkSuccess = Color(0xFF4CD964);
  static const Color darkWarning = Color(0xFFFF9500);
  static const Color darkError = Color(0xFFFF3B30);
  static const Color darkInfo = Color(0xFF0A84FF);
  static const Color success = Color(0xFF2ECC71);
  static const Color info = Color(0xFF3498DB);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);

  // Typography
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // Spacing
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  // Border radius
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusFull = 9999;

  // Shadows
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x10000000), offset: Offset(0, 2), blurRadius: 8),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 16),
  ];

  /// Build light theme
  static flutter.ThemeData light() {
    return flutter.ThemeData(
      brightness: flutter.Brightness.light,
      primaryColor: lightPrimary,
      scaffoldBackgroundColor: lightBackground,
      cardTheme: flutter.CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: flutter.RoundedRectangleBorder(
          borderRadius: flutter.BorderRadius.circular(radiusLg),
          side: flutter.BorderSide(color: lightBorder, width: 1),
        ),
      ),
      appBarTheme: flutter.AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        titleTextStyle: titleMedium.copyWith(color: lightText),
        iconTheme: flutter.IconThemeData(color: lightText),
        centerTitle: true,
      ),
      elevatedButtonTheme: flutter.ElevatedButtonThemeData(
        style: flutter.ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: flutter.Colors.white,
          padding: const flutter.EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingSm,
          ),
          shape: flutter.RoundedRectangleBorder(
            borderRadius: flutter.BorderRadius.circular(radiusMd),
          ),
          textStyle: label,
        ),
      ),
      outlinedButtonTheme: flutter.OutlinedButtonThemeData(
        style: flutter.OutlinedButton.styleFrom(
          foregroundColor: lightPrimary,
          side: flutter.BorderSide(color: lightPrimary),
          padding: const flutter.EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingSm,
          ),
          shape: flutter.RoundedRectangleBorder(
            borderRadius: flutter.BorderRadius.circular(radiusMd),
          ),
          textStyle: label,
        ),
      ),
      chipTheme: flutter.ChipThemeData(
        backgroundColor: lightBorder,
        labelStyle: bodySmall,
        padding: const flutter.EdgeInsets.symmetric(horizontal: spacingSm, vertical: 2),
        shape: flutter.RoundedRectangleBorder(
          borderRadius: flutter.BorderRadius.circular(radiusFull),
        ),
      ),
      iconTheme: flutter.IconThemeData(color: lightText, size: 20),
      dividerTheme: flutter.DividerThemeData(color: lightBorder, thickness: 1),
      useMaterial3: true,
    );
  }

  /// Build dark theme
  static flutter.ThemeData dark() {
    return flutter.ThemeData(
      brightness: flutter.Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBackground,
      cardTheme: flutter.CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: flutter.RoundedRectangleBorder(
          borderRadius: flutter.BorderRadius.circular(radiusLg),
          side: flutter.BorderSide(color: darkBorder, width: 1),
        ),
      ),
      appBarTheme: flutter.AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        titleTextStyle: titleMedium.copyWith(color: darkText),
        iconTheme: flutter.IconThemeData(color: darkText),
        centerTitle: true,
      ),
      elevatedButtonTheme: flutter.ElevatedButtonThemeData(
        style: flutter.ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: flutter.Colors.white,
          padding: const flutter.EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingSm,
          ),
          shape: flutter.RoundedRectangleBorder(
            borderRadius: flutter.BorderRadius.circular(radiusMd),
          ),
          textStyle: label,
        ),
      ),
      outlinedButtonTheme: flutter.OutlinedButtonThemeData(
        style: flutter.OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: flutter.BorderSide(color: darkPrimary),
          padding: const flutter.EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingSm,
          ),
          shape: flutter.RoundedRectangleBorder(
            borderRadius: flutter.BorderRadius.circular(radiusMd),
          ),
          textStyle: label,
        ),
      ),
      chipTheme: flutter.ChipThemeData(
        backgroundColor: darkBorder,
        labelStyle: bodySmall,
        padding: const flutter.EdgeInsets.symmetric(horizontal: spacingSm, vertical: 2),
        shape: flutter.RoundedRectangleBorder(
          borderRadius: flutter.BorderRadius.circular(radiusFull),
        ),
      ),
      iconTheme: flutter.IconThemeData(color: darkText, size: 20),
      dividerTheme: flutter.DividerThemeData(color: darkBorder, thickness: 1),
      useMaterial3: true,
    );
  }
}
