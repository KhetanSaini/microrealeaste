import 'package:flutter/material.dart';

// Light color scheme
const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF1976D2),
  onPrimary: Colors.white,
  secondary: Color(0xFF26A69A),
  onSecondary: Colors.white,
  error: Color(0xFFD32F2F),
  onError: Colors.white,
  background: Color(0xFFF5F5F5),
  onBackground: Color(0xFF212121),
  surface: Colors.white,
  onSurface: Color(0xFF212121),
  outline: Color(0xFFBDBDBD),
  tertiary: Color(0xFFFFB300),
  onTertiary: Colors.black,
  secondaryContainer: Color(0xFFE0F2F1),
  onSecondaryContainer: Color(0xFF004D40),
  surfaceVariant: Color(0xFFF0F0F0),
  onSurfaceVariant: Color(0xFF757575),
);

// Dark color scheme
const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF90CAF9),
  onPrimary: Color(0xFF0D47A1),
  secondary: Color(0xFF80CBC4),
  onSecondary: Color(0xFF004D40),
  error: Color(0xFFEF9A9A),
  onError: Color(0xFFB71C1C),
  background: Color(0xFF121212),
  onBackground: Colors.white,
  surface: Color(0xFF1E1E1E),
  onSurface: Colors.white,
  outline: Color(0xFF616161),
  tertiary: Color(0xFFFFE082),
  onTertiary: Color(0xFF212121),
  secondaryContainer: Color(0xFF37474F),
  onSecondaryContainer: Color(0xFFE0F2F1),
  surfaceVariant: Color(0xFF2C2C2C),
  onSurfaceVariant: Color(0xFFBDBDBD),
);

// Common text theme
final TextTheme textTheme = TextTheme(
  headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
  bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
  bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
  labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
);

final ThemeData lightTheme = ThemeData(
  colorScheme: lightColorScheme,
  textTheme: textTheme,
  useMaterial3: true,
  scaffoldBackgroundColor: lightColorScheme.background,
  appBarTheme: AppBarTheme(
    backgroundColor: lightColorScheme.surface,
    elevation: 0,
    iconTheme: IconThemeData(color: lightColorScheme.onSurface),
    titleTextStyle: textTheme.headlineSmall?.copyWith(color: lightColorScheme.onSurface),
  ),
  cardTheme: CardThemeData(
    color: lightColorScheme.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: lightColorScheme.outline.withOpacity(0.1), width: 1),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: textTheme.labelLarge,
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: lightColorScheme.surfaceVariant,
    selectedColor: lightColorScheme.primary,
    secondarySelectedColor: lightColorScheme.secondary,
    labelStyle: textTheme.labelMedium!,
    secondaryLabelStyle: textTheme.labelMedium!,
    brightness: Brightness.light,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
);

final ThemeData darkTheme = ThemeData(
  colorScheme: darkColorScheme,
  textTheme: textTheme,
  useMaterial3: true,
  scaffoldBackgroundColor: darkColorScheme.background,
  appBarTheme: AppBarTheme(
    backgroundColor: darkColorScheme.surface,
    elevation: 0,
    iconTheme: IconThemeData(color: darkColorScheme.onSurface),
    titleTextStyle: textTheme.headlineSmall?.copyWith(color: darkColorScheme.onSurface),
  ),
  cardTheme: CardThemeData(
    color: darkColorScheme.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: darkColorScheme.outline.withOpacity(0.1), width: 1),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: darkColorScheme.primary,
      foregroundColor: darkColorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: textTheme.labelLarge,
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: darkColorScheme.surfaceVariant,
    selectedColor: darkColorScheme.primary,
    secondarySelectedColor: darkColorScheme.secondary,
    labelStyle: textTheme.labelMedium!,
    secondaryLabelStyle: textTheme.labelMedium!,
    brightness: Brightness.dark,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
); 