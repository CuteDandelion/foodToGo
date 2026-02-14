import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color primary = Color(0xFF10B981);
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryAccent = Color(0xFF6EE7B7);
  
  // Login Page Specific Colors (from brand guidelines)
  static const Color loginBackground = Color(0xFF29f094);  // Bright green
  static const Color loginCardBorder = Color(0xFF242a24);  // Dark grey
  static const Color loginTextPrimary = Color(0xFF242a24);  // Dark grey
  static const Color loginTextSecondary = Color(0xFF666666);  // Medium grey
  static const Color loginTextMuted = Color(0xFF999999);  // Light grey
  static const Color loginDivider = Color(0xFFE0E0E0);  // Very light grey
  static const Color loginCheckboxUnchecked = Color(0xFFCCCCCC);  // Light grey

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color social = Color(0xFFEC4899);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkBorder = Color(0xFF334155);

  /// Light theme data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primaryLight,
        surface: lightSurface,
        surfaceContainerHighest: lightBackground,
        error: error,
        onPrimary: Colors.white,
        onSecondary: lightTextPrimary,
        onSurface: lightTextPrimary,
        onSurfaceVariant: lightTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: lightBackground,
      textTheme: _buildTextTheme(lightTextPrimary, lightTextSecondary),
      cardTheme: _buildCardTheme(lightSurface, lightBorder),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(lightBorder),
      textButtonTheme: _buildTextButtonTheme(),
      inputDecorationTheme: _buildInputTheme(lightBorder, lightSurface),
      appBarTheme: _buildAppBarTheme(lightSurface, lightTextPrimary),
      dividerTheme: _buildDividerTheme(lightBorder),
      bottomSheetTheme: _buildBottomSheetTheme(lightSurface),
      dialogTheme: _buildDialogTheme(lightSurface),
      snackBarTheme: _buildSnackBarTheme(),
    );
  }

  /// Dark theme data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryLight,
        surface: darkSurface,
        surfaceContainerHighest: darkBackground,
        error: error,
        onPrimary: Colors.white,
        onSecondary: darkTextPrimary,
        onSurface: darkTextPrimary,
        onSurfaceVariant: darkTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: _buildTextTheme(darkTextPrimary, darkTextSecondary),
      cardTheme: _buildCardTheme(darkSurface, darkBorder),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(darkBorder),
      textButtonTheme: _buildTextButtonTheme(),
      inputDecorationTheme: _buildInputTheme(darkBorder, darkSurface),
      appBarTheme: _buildAppBarTheme(darkSurface, darkTextPrimary),
      dividerTheme: _buildDividerTheme(darkBorder),
      bottomSheetTheme: _buildBottomSheetTheme(darkSurface),
      dialogTheme: _buildDialogTheme(darkSurface),
      snackBarTheme: _buildSnackBarTheme(),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 36.sp,
        fontWeight: FontWeight.w800,
        color: primary,
        height: 1.1,
      ),
      headlineLarge: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: secondary,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: secondary,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: secondary,
        letterSpacing: 0.5,
        height: 1,
      ),
    );
  }

  static CardTheme _buildCardTheme(Color surface, Color border) {
    return CardTheme(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: border, width: 1),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
        minimumSize: Size(double.infinity, 56.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        textStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(Color border) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: border, width: 2),
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
        minimumSize: Size(double.infinity, 56.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        textStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        textStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme(Color border, Color surface) {
    return InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: border, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: border, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: TextStyle(
        fontSize: 14.sp,
        color: lightTextSecondary,
      ),
      hintStyle: TextStyle(
        fontSize: 14.sp,
        color: lightTextSecondary.withAlpha(128),
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme(Color surface, Color text) {
    return AppBarTheme(
      backgroundColor: surface,
      foregroundColor: text,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  static DividerThemeData _buildDividerTheme(Color border) {
    return DividerThemeData(
      color: border,
      thickness: 1,
      space: 1,
    );
  }

  static BottomSheetThemeData _buildBottomSheetTheme(Color surface) {
    return BottomSheetThemeData(
      backgroundColor: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
    );
  }

  static DialogTheme _buildDialogTheme(Color surface) {
    return DialogTheme(
      backgroundColor: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme() {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      contentTextStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Background gradients for dashboard
  static LinearGradient get lightBackgroundGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE8F5E9), // Light green
          Color(0xFFFFFFFF), // White
        ],
        stops: [0.0, 0.6],
      );

  static LinearGradient get darkBackgroundGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1B5E20), // Dark green
          Color(0xFF0D3318), // Darker green
        ],
        stops: [0.0, 1.0],
      );
}
