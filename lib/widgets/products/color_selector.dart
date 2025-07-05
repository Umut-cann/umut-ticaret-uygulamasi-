
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/helpers.dart'; // colorFromHex için

class ColorSelector extends StatelessWidget {
  final List<String> colors; // Hex renk kodları listesi
  final String? selectedColor;
  final Function(String) onColorSelected;

  const ColorSelector({
    required this.colors,
    this.selectedColor,
    required this.onColorSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40, // Yükseklik
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final colorHex = colors[index];
          final color = Helpers.colorFromHex(colorHex);
          final bool isSelected = selectedColor == colorHex;

          // Beyaz renk için farklı kenarlık
          final bool isWhite = color.red > 240 && color.green > 240 && color.blue > 240;

          return GestureDetector(
            onTap: () => onColorSelected(colorHex),
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  // Seçili ise veya beyaz ise kenarlık göster
                  color: isSelected
                      ? AppColors.primary
                      : isWhite
                          ? AppColors.lightGrey // Beyaz için gri kenarlık
                          : Colors.transparent, // Diğerleri için kenarlık yok
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                     color: AppColors.primary.withOpacity(0.3),
                     blurRadius: 4,
                     spreadRadius: 1,
                  )
                ] : [], // Seçili olana gölge efekti
              ),
              // Seçili ise içinde tik işareti (renk koyu ise beyaz, açık ise siyah)
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white, // Parlaklığa göre ikon rengi
                      size: 18,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
