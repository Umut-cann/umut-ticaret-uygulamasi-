
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class SizeSelector extends StatelessWidget {
  final List<String> sizes;
  final String? selectedSize;
  final Function(String) onSizeSelected;

  const SizeSelector({
    required this.sizes,
    this.selectedSize,
    required this.onSizeSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40, // Yükseklik
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sizes.length,
        itemBuilder: (context, index) {
          final size = sizes[index];
          final bool isSelected = selectedSize == size;

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ChoiceChip(
              label: Text(size),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onSizeSelected(size);
                }
              },
               labelStyle: AppTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
               ),
              selectedColor: AppColors.primary, // Tema'dan alıyor ama override edilebilir
              backgroundColor: AppColors.surface, // Tema'dan alıyor
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Daha köşeli
                side: BorderSide(
                   color: isSelected ? AppColors.primary : AppColors.lightGrey,
                   width: 1.5,
                )
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16), // İç boşluk
               visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}
