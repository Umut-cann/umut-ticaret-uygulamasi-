import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  // Modern bir font ailesi seçelim, örneğin Poppins
  static final String _fontFamily = GoogleFonts.poppins().fontFamily!;

  static final TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.25,
  );
  static final TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final TextStyle h6Secondary = h6.copyWith(
    color: AppColors.textSecondary,
    fontWeight:
        FontWeight.normal, // Genellikle ikincil başlıklar daha az vurgulu olur
  );

  static final TextStyle h6Accent = h6.copyWith(color: AppColors.accent);
  static final TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle h4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle h5 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle h6 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle subtitle1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
  );
  static final TextStyle subtitle2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  static final TextStyle bodyL = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  ); // bodyLarge yerine bodyL kullanıldı
  static final TextStyle bodyLarge =
      bodyL; // Geriye dönük uyumluluk veya alternatif isimlendirme için

  static final TextStyle bodyLBold = bodyL.copyWith(
    fontWeight: FontWeight.bold,
  );
  static final TextStyle bodyM = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  ); // bodyMedium yerine bodyM kullanıldı
  static final TextStyle bodyMedium =
      bodyM; // Geriye dönük uyumluluk veya alternatif isimlendirme için
  static final TextStyle bodyS = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static final TextStyle bodySAccent = bodyS.copyWith(
    color: AppColors.accent.withOpacity(0.8),
  );

  static final TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.5,
  );

  static final TextStyle textButtonPrimary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14, // Ya da buton ile aynı font boyutu
    fontWeight: FontWeight.w600, // Ya da buton ile aynı kalınlık
    color: AppColors.primary,
  );

  static final TextStyle textButtonSecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static final TextStyle chipLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static final TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );

  static final TextStyle bodyXS = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.2,
  );

  // bodyXS stilinin gri renkli versiyonu
  static final TextStyle bodyXSGrey = bodyXS.copyWith(
    color: AppColors.darkGrey,
  );
  static final TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );

  // Özel Gri Stiller
  static TextStyle bodyLGrey = bodyL.copyWith(color: Colors.grey[600]);
  static TextStyle bodyMGrey = bodyM.copyWith(color: Colors.grey[500]);
}
