import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      appBarTheme:  AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        iconTheme: IconThemeData(color: AppColors.appBarForeground),
        titleTextStyle: AppTextStyles.h6,
        centerTitle: true, // Başlıkları ortala
      ),
      // Google Fonts'u tema genelinde uygulamak için
      textTheme: GoogleFonts.poppinsTextTheme(
        // Seçilen fontu burada uygula
        ThemeData.light().textTheme
            .copyWith(
              // Mevcut tema text stillerini temel al
              displayLarge: AppTextStyles.h1,
              displayMedium: AppTextStyles.h2,
              displaySmall: AppTextStyles.h3,
              headlineMedium: AppTextStyles.h4,
              headlineSmall: AppTextStyles.h5,
              titleLarge: AppTextStyles.h6,
              bodyLarge: AppTextStyles.bodyL,
              bodyMedium: AppTextStyles.bodyM,
              bodySmall: AppTextStyles.bodyS,
              labelLarge: AppTextStyles.button,
            )
            .apply(
              bodyColor: AppColors.textPrimary, // Ana metin rengini koru
              displayColor: AppColors.textPrimary, // Başlık renklerini koru
            ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2,
          minimumSize: const Size(64, 48), // Minimum buton boyutu
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.primary,
          ), // Outlined için renk farklı
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          minimumSize: const Size(64, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
          minimumSize: const Size(64, 40),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGrey,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        labelStyle: AppTextStyles.bodyM.copyWith(color: AppColors.textPrimary),
        prefixIconColor: AppColors.darkGrey, // İkon renkleri
        suffixIconColor: AppColors.darkGrey,
      ),
      cardTheme: CardTheme(
        elevation: 1,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          // İnce kenarlık ekleyelim
          // side: BorderSide(color: AppColors.lightGrey.withOpacity(0.5), width: 0.8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGrey,
        thickness: 1.0,
        space: 1, // Dikey boşluğu azalt
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        elevation: 5,
        modalBackgroundColor: Colors.black54, // Arka plan karartması
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightGrey,
        disabledColor: Colors.grey.shade300,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        labelStyle: AppTextStyles.bodyS.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle: AppTextStyles.bodyS.copyWith(
          color: AppColors.textOnPrimary,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide.none,
        ),
        //  selectedColorOpacity: 1.0, // Tam renk olsun
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
        checkColor: MaterialStateProperty.all(AppColors.textOnPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: AppColors.darkGrey, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary.withOpacity(0.5);
          }
          return null;
        }),
      ),
      // Curved Navigation Bar renkleri widget içinden ayarlanıyor.
    );
  }
}
