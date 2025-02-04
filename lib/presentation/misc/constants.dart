import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF395C03); // Hijau Gelap - Warna Utama
  static const Color secondary = Color(0xFF9ABA01); // Hijau Muda - Aksen
  static const Color background = Color(0xFFF8F8DE); // Krem Muda - Background

  // Neutral Colors
  static const Color neutral100 = Color(0xFFFFFFFF); // Pure White
  static const Color neutral200 = Color(0xFFF4F4F4); // Light Gray
  static const Color neutral300 = Color(0xFFE0E0E0); // Lighter Gray
  static const Color neutral400 = Color(0xFFBDBDBD); // Medium Gray
  static const Color neutral500 = Color(0xFF9E9E9E); // Gray
  static const Color neutral600 = Color(0xFF757575); // Dark Gray
  static const Color neutral700 = Color(0xFF616161); // Darker Gray
  static const Color neutral800 = Color(0xFF424242); // Very Dark Gray
  static const Color neutral900 = Color(0xFF212121); // Almost Black

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFA726); // Orange
  static const Color error = Color(0xFFEF5350); // Red
  static const Color info = Color(0xFF42A5F5); // Blue

  // Additional Theme Colors
  static const Color accent1 = Color(0xFF6B8E23); // Olive Green
  static const Color accent2 = Color(0xFFB5C689); // Sage
  static const Color accent3 = Color(0xFFD4E157); // Lime
}

class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.neutral900,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.neutral900,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral900,
    letterSpacing: -0.2,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.neutral800,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.neutral800,
    letterSpacing: 0.1,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.neutral700,
    letterSpacing: 0.2,
  );

  // Button Text
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Caption & Label
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.neutral600,
    letterSpacing: 0.2,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.neutral700,
    letterSpacing: 0.1,
  );
}

class AppFonts {
  static final TextStyle notoKufi =
      GoogleFonts.notoKufiArabic(); // Untuk judul dengan nuansa islami
  static final TextStyle plusJakarta =
      GoogleFonts.plusJakartaSans(); // Untuk body text

  static final TextStyle lato = GoogleFonts.lato(); // Untuk body text
  static final TextStyle amiri =
      GoogleFonts.amiri(); // Untuk judul dengan nuansa islami

  static final TextStyle poppins =
      GoogleFonts.poppins(); // Untuk body text yang modern
  static final TextStyle scheherazade =
      GoogleFonts.scheherazadeNew(); // Untuk judul dengan nuansa islami
}

class AppSizes {
  // Padding & Margin
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
}

// Theme Data
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.neutral100,
        error: AppColors.error,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        displaySmall: AppTextStyles.h3,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.buttonLarge,
        labelMedium: AppTextStyles.buttonMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.neutral100,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
        ),
      ),
    );
  }
}

class RoleConstants {
  static const String superAdmin = 'superAdmin';
  static const String admin = 'admin';
  static const String santri = 'santri';

  static const List<String> allRoles = [superAdmin, admin, santri];

  static const Map<String, String> roleDisplayNames = {
    superAdmin: 'Super Admin',
    admin: 'Admin',
    santri: 'Santri',
  };

  // Role-based permissions/capabilities
  static const Map<String, List<String>> roleCapabilities = {
    superAdmin: [
      'manage_users',
      'manage_roles',
      'manage_presensi',
      'view_presensi',
      'manage_programs'
    ],
    admin: ['manage_presensi', 'view_presensi', 'manage_programs'],
    santri: ['view_presensi'],
  };
}
