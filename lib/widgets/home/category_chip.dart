import 'package:flutter/material.dart';

import '../../constants/app_colors.dart'; // Renklerinizin yolu doğru olmalı
import '../../constants/app_text_styles.dart'; // Metin stillerinizin yolu doğru olmalı
import '../../models/category.dart'; // Modelinizin yolu doğru olmalı

class CategoryChip extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final bool isSelected;

  const CategoryChip({
    required this.category,
    required this.onTap,
    this.isSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Modern tasarımlar genellikle temanın renklerini daha çok referans alır.
    // Eğer AppColors'da çok spesifik tanımlar yoksa, Theme.of(context) kullanmak daha esnek olabilir.
    // Örnek:
    // final theme = Theme.of(context);
    // final unselectedBg = theme.colorScheme.surface; // veya theme.scaffoldBackgroundColor
    // final unselectedFg = theme.colorScheme.onSurface.withOpacity(0.7);
    // final selectedBg = theme.colorScheme.primary;
    // final selectedFg = theme.colorScheme.onPrimary;

    // Şimdilik AppColors varsayımıyla devam edelim:
    final Color unselectedBackgroundColor =
        AppColors.surface; // Veya Colors.grey[100] gibi çok açık bir renk
    final Color unselectedForegroundColor =
        AppColors.textSecondary; // Veya AppColors.textPrimary.withOpacity(0.65)
    final Color unselectedBorderColor = AppColors.primary.withOpacity(
      0.15,
    ); // Çok çok soluk

    final Color selectedBackgroundColor = AppColors.primary;
    final Color selectedForegroundColor = AppColors.textOnPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        onPressed: onTap,
        pressElevation:
            0, // Basıldığında ekstra gölge olmasın, daha düz bir his
        // Modern tasarımlarda gereksiz olabilir
        avatar: Icon(
          category.icon,
          size: 18, // İkon boyutu
          color:
              isSelected ? selectedForegroundColor : unselectedForegroundColor,
        ),
        label: Text(
          category.name,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        labelPadding: const EdgeInsets.only(
          left: 6.0,
          right: 8.0,
        ), // Avatar ile metin arası ve metin sonrası boşluk
        labelStyle: AppTextStyles.bodyS.copyWith(
          // Temel metin stiliniz
          fontSize: 13, // Biraz daha küçük ve zarif olabilir
          fontWeight:
              isSelected
                  ? FontWeight.w600
                  : FontWeight.normal, // Seçiliyken daha belirgin
          color:
              isSelected ? selectedForegroundColor : unselectedForegroundColor,
          letterSpacing: 0.15, // Hafif harf aralığı okunabilirliği artırır
        ),
        backgroundColor:
            isSelected ? selectedBackgroundColor : unselectedBackgroundColor,
        elevation:
            isSelected ? 2.0 : 0.0, // Seçiliyken hafif bir gölge, değilken düz
        shadowColor:
            isSelected
                ? AppColors.primary.withOpacity(0.25)
                : Colors.transparent,
        shape: StadiumBorder(
          side:
              isSelected
                  ? BorderSide
                      .none // Seçiliyken kenarlık yok
                  : BorderSide(
                    color:
                        unselectedBorderColor, // Seçili değilken çok ince ve soluk bir kenarlık
                    width: 1.0,
                  ),
        ),

        // Alternatif: Seçili değilken kenarlıksız, sadece arka plan farkı
        // shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 8.0,
        ), // Chip'in genel iç boşluğu
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        tooltip: category.name,
      ),
    );
  }
}

// --- Kullanım Örneği için Dummy Sınıflar (Gerçek projenizde bunlar zaten var olacaktır) ---
// class Category {
//   final String id;
//   final String name;
//   final IconData icon;
//
//   Category({required this.id, required this.name, required this.icon});
// }

// AppColors'da aşağıdaki gibi renkler olduğunu varsayıyorum.
// Kendi projenizdeki AppColors'a göre uyarlayın.
// class AppColors {
//   static const Color primary = Color(0xFF0A84FF); // Canlı bir mavi (örnek)
//   static const Color textOnPrimary = Colors.white;
//
//   static const Color textPrimary = Color(0xFF1D1D1F); // Koyu metin
//   static const Color textSecondary = Color(0xFF6E6E73); // Daha soluk metin
//
//   static const Color surface = Color(0xFFF5F5F7); // Çok açık gri, neredeyse beyaz bir yüzey
//   static const Color background = Colors.white;
//
//   // Diğer renkler...
//   static const Color lightGrey = Colors.grey;
//   static const Color darkGrey = Colors.black54;
// }
//
// class AppTextStyles {
//   static TextStyle bodyS = TextStyle(fontSize: 14, fontFamily: 'YourAppFont'); // Temel metin stiliniz
// }
