import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF10B981); // Emerald 500
  static const Color primaryDark = Color(0xFF059669); // Emerald 600
  static const Color primaryLight = Color(0xFF34D399); // Emerald 400
  static const Color accent = Color(0xFF34D399); // Light Green
  static const Color error = Color(0xFFFF453A); // Apple Red

  // Dark Theme Colors
  static const Color background = Color(0xFF0A0A0A); // Soft Black
  static const Color surface = Color(0xFF1C1C1E); // Apple dark gray
  static const Color surfaceElevated = Color(0xFF2C2C2E); // Apple card gray
  static const Color border = Color(0xFF3A3A3C); // Subtle separator
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF98989D); // Apple gray

  // Light Theme Colors
  static const Color lightBackground = Color(
    0xFFF2F2F7,
  ); // Apple Light Gray background
  static const Color lightSurface = Color(0xFFFFFFFF); // White surface
  static const Color lightSurfaceElevated = Color(0xFFE5E5EA); // Elevated white
  static const Color lightBorder = Color(0xFFC7C7CC); // Light border
  static const Color lightTextPrimary = Color(0xFF000000); // Black text
  static const Color lightTextSecondary = Color(0xFF8E8E93); // Medium gray

  static BoxShadow get eliteShadow => BoxShadow(
    color: Colors.black.withValues(
      alpha: 0.1,
    ), // Fixed to be theme independent or slightly lighter for light mode context
    blurRadius: 20,
    spreadRadius: -5,
    offset: const Offset(0, 10),
  );

  static BoxShadow get emeraldGlow => BoxShadow(
    color: const Color(0xFF10B981).withValues(alpha: 0.15),
    blurRadius: 20,
    spreadRadius: 2,
    offset: const Offset(0, 4),
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppTheme {
  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      bgColor: AppColors.background,
      surfaceClr: AppColors.surface,
      surfaceElev: AppColors.surfaceElevated,
      borderClr: AppColors.border,
      textPri: AppColors.textPrimary,
      textSec: AppColors.textSecondary,
    );
  }

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      bgColor: AppColors.lightBackground,
      surfaceClr: AppColors.lightSurface,
      surfaceElev: AppColors.lightSurfaceElevated,
      borderClr: AppColors.lightBorder,
      textPri: AppColors.lightTextPrimary,
      textSec: AppColors.lightTextSecondary,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bgColor,
    required Color surfaceClr,
    required Color surfaceElev,
    required Color borderClr,
    required Color textPri,
    required Color textSec,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryLight,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: surfaceClr,
        onSurface: textPri,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      textTheme:
          GoogleFonts.interTextTheme(
            ThemeData(brightness: brightness).textTheme,
          ).copyWith(
            displayLarge: GoogleFonts.inter(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: textPri,
            ),
            headlineMedium: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: textPri,
            ),
            headlineSmall: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textPri,
            ),
            titleLarge: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textPri,
            ),
            titleMedium: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPri,
            ),
            titleSmall: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textPri,
            ),
            bodyLarge: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: textPri,
            ),
            bodyMedium: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: textPri,
            ),
            labelLarge: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textPri,
            ),
            labelSmall: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              color: textSec,
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPri),
        titleTextStyle: TextStyle(
          color: textPri,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors
              .white, // Elevated Buttons will always use gradient context so white foreground
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElev,
        labelStyle: TextStyle(color: textSec),
        floatingLabelStyle: TextStyle(
          color: brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
        hintStyle: TextStyle(color: textSec),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderClr, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderClr, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        prefixIconColor: textSec,
      ),
      cardTheme: CardThemeData(
        color: surfaceClr,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static BoxDecoration get primaryGradient => BoxDecoration(
    gradient: const LinearGradient(
      colors: [AppColors.primary, AppColors.primaryDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [AppColors.emeraldGlow],
  );

  static BoxDecoration glassDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: isDark ? 0.8 : 0.9),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
      ),
      boxShadow: [AppColors.eliteShadow],
    );
  }
}
