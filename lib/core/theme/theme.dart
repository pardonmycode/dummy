import 'package:material_ui/material_ui.dart' as flutter;
import 'package:material_ui/material_ui.dart';

/// Design tokens for the Widgetly app.
class AppTheme {
  AppTheme._();

  // Primary color
  static const Color primary = Color(0xFF4361EE);
  static const Color secondary = Color(0xFF7209B7);
  static const Color accent = Color(0xFFF72585);

  // Success/Warning/Error/Info (used across light and dark)
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

  /// Light ColorScheme
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF4361EE),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE8EDFF),
    onPrimaryContainer: Color(0xFF1A34A8),
    secondary: Color(0xFF7209B7),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFF3E0FF),
    onSecondaryContainer: Color(0xFF4C0080),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A1A),
    surfaceVariant: Color(0xFFF8F9FA),
    onSurfaceVariant: Color(0xFF6C757D),
    background: Color(0xFFF8F9FA),
    onBackground: Color(0xFF1A1A1A),
    error: Color(0xFFE74C3C),
    onError: Colors.white,
    outline: Color(0xFFE9ECEF),
    outlineVariant: Color(0xFFE9ECEF),
  );

  /// Dark ColorScheme
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF7B93F4),
    onPrimary: Colors.black,
    primaryContainer: Color(0xFF2A3A8A),
    onPrimaryContainer: Color(0xFFB8C4FF),
    secondary: Color(0xFF9D4EDD),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF4C0080),
    onSecondaryContainer: Color(0xFFD8A8FF),
    surface: Color(0xFF1E1E1E),
    onSurface: Color(0xFFF0F0F0),
    surfaceVariant: Color(0xFF121212),
    onSurfaceVariant: Color(0xFFA0A0A0),
    background: Color(0xFF121212),
    onBackground: Color(0xFFF0F0F0),
    error: Color(0xFFFF3B30),
    onError: Colors.white,
    outline: Color(0xFF3A3A3A),
    outlineVariant: Color(0xFF3A3A3A),
  );

  /// Build light theme using ColorScheme
  static flutter.ThemeData light() {
    return flutter.ThemeData(
      colorScheme: lightScheme,
      brightness: flutter.Brightness.light,
      scaffoldBackgroundColor: lightScheme.surfaceVariant,
      cardTheme: flutter.CardThemeData(
        color: lightScheme.surface,
        elevation: 0,
        shape: flutter.RoundedRectangleBorder(
          borderRadius: flutter.BorderRadius.circular(radiusLg),
          side: flutter.BorderSide(color: lightScheme.outline, width: 1),
        ),
      ),
      appBarTheme: flutter.AppBarTheme(
        backgroundColor: lightScheme.surface,
        elevation: 0,
        titleTextStyle: titleMedium.copyWith(color: lightScheme.onSurface),
        iconTheme: flutter.IconThemeData(color: lightScheme.onSurface),
        centerTitle: true,
      ),
      elevatedButtonTheme: flutter.ElevatedButtonThemeData(
        style: flutter.ElevatedButton.styleFrom(
          backgroundColor: lightScheme.primary,
          foregroundColor: lightScheme.onPrimary,
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
          foregroundColor: lightScheme.primary,
          side: flutter.BorderSide(color: lightScheme.primary),
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
        backgroundColor: lightScheme.outline,
        labelStyle: bodySmall,
        padding: const flutter.EdgeInsets.symmetric(horizontal: spacingSm, vertical: 2),
        shape: flutter.RoundedRectangleBorder(
          borderRadius: flutter.BorderRadius.circular(radiusFull),
        ),
      ),
      iconTheme: flutter.IconThemeData(color: lightScheme.onSurface, size: 20),
      dividerTheme: flutter.DividerThemeData(color: lightScheme.outline, thickness: 1),
      useMaterial3: true,
    );
  }

  /// Build dark theme using ColorScheme
  static flutter.ThemeData dark() {
    return flutter.ThemeData(
      colorScheme: darkScheme,
      brightness: flutter.Brightness.dark,
      scaffoldBackgroundColor: darkScheme.surfaceVariant,
      cardTheme: flutter.CardThemeData(
        color: darkScheme.surface,
        elevation: 0,
        shape: flutter.RoundedRectangleBorder(
          borderRadius: flutter.BorderRadius.circular(radiusLg),
          side: flutter.BorderSide(color: darkScheme.outline, width: 1),
        ),
      ),
      appBarTheme: flutter.AppBarTheme(
        backgroundColor: darkScheme.surface,
        elevation: 0,
        titleTextStyle: titleMedium.copyWith(color: darkScheme.onSurface),
        iconTheme: flutter.IconThemeData(color: darkScheme.onSurface),
        centerTitle: true,
      ),
      elevatedButtonTheme: flutter.ElevatedButtonThemeData(
        style: flutter.ElevatedButton.styleFrom(
          backgroundColor: darkScheme.primary,
          foregroundColor: darkScheme.onPrimary,
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
          foregroundColor: darkScheme.primary,
          side: flutter.BorderSide(color: darkScheme.primary),
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
        backgroundColor: darkScheme.outline,
        labelStyle: bodySmall,
        padding: const flutter.EdgeInsets.symmetric(horizontal: spacingSm, vertical: 2),
        shape: flutter.RoundedRectangleBorder(
          borderRadius: flutter.BorderRadius.circular(radiusFull),
        ),
      ),
      iconTheme: flutter.IconThemeData(color: darkScheme.onSurface, size: 20),
      dividerTheme: flutter.DividerThemeData(color: darkScheme.outline, thickness: 1),
      useMaterial3: true,
    );
  }
}
