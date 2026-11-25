import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _lightPrimary = Color(0xFF5B5F97);
  static const _lightBackground = Color(0xFFF4F2FA);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightBorder = Color(0xFFE2DDF0);
  static const _lightText = Color(0xFF25233A);
  static const _lightAccent = Color(0xFFE88C9B);

  static const _darkPrimary = Color(0xFFAAAEEB);
  static const _darkBackground = Color(0xFF171725);
  static const _darkSurface = Color(0xFF222233);
  static const _darkBorder = Color(0xFF44445E);
  static const _darkText = Color(0xFFF3F0FF);
  static const _darkAccent = Color(0xFFF3A0AE);

  static final ThemeData lightTheme = _buildTheme(
    brightness: Brightness.light,
    primary: _lightPrimary,
    background: _lightBackground,
    surface: _lightSurface,
    border: _lightBorder,
    text: _lightText,
    accent: _lightAccent,
    onPrimary: Colors.white,
  );

  static final ThemeData darkTheme = _buildTheme(
    brightness: Brightness.dark,
    primary: _darkPrimary,
    background: _darkBackground,
    surface: _darkSurface,
    border: _darkBorder,
    text: _darkText,
    accent: _darkAccent,
    onPrimary: _darkBackground,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color background,
    required Color surface,
    required Color border,
    required Color text,
    required Color accent,
    required Color onPrimary,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: accent,
      onSecondary: _lightText,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      surface: surface,
      onSurface: text,
      outline: border,
      surfaceTint: primary,
    );
    final baseTextTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
    final fontTheme = baseTextTheme.apply(
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      bodyColor: text,
      displayColor: text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: fontTheme.copyWith(
        labelSmall: GoogleFonts.robotoMono(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: accent.withValues(alpha: 0.18),
        checkmarkColor: primary,
        labelStyle: TextStyle(color: text),
        side: BorderSide(color: border),
        shape: const StadiumBorder(),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.transparent,
        indicatorColor: accent.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? primary : text,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? primary : text,
            size: 22,
          ),
        ),
      ),
    );
  }
}
