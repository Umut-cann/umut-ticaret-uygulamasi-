
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // SVG kullanacaksanız
import '../../constants/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  // final String? iconPath; // SVG için
  final IconData? icon; // IconData için
  final String label; // Düğme altındaki yazı (opsiyonel)
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? backgroundColor;

  const SocialLoginButton({
    super.key,
    // this.iconPath,
    this.icon,
    required this.label,
    required this.onPressed,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24), // Yuvarlak tıklama efekti
          child: Container(
            width: 52, // Sabit boyut
            height: 52,
            padding: const EdgeInsets.all(12), // İkon için iç boşluk
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lightGrey, width: 1.5),
               boxShadow: [
                  BoxShadow(
                     color: Colors.black.withOpacity(0.05),
                     blurRadius: 4,
                     offset: Offset(0, 2)
                  )
               ]
            ),
            child: icon != null
                ? Icon(icon, color: iconColor ?? AppColors.primary, size: 24)
                : const SizedBox(), // Varsa SVGWidget buraya gelir
                // : SvgPicture.asset(
                //     iconPath!,
                //     colorFilter: iconColor != null ? ColorFilter.mode(iconColor!, BlendMode.srcIn) : null,
                //     width: 24,
                //     height: 24,
                //   ),
          ),
        ),
        // const SizedBox(height: 6),
        // Text(label, style: AppTextStyles.caption), // Etiketleri kaldırdık, daha temiz duruyor
      ],
    );
  }
}
