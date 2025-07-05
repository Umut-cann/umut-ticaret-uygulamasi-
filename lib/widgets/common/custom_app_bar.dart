import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading; // Özel leading ikonu için
  final bool centerTitle; // Başlığı ortalamak için

  const CustomAppBar({
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.leading,
    this.centerTitle = true, // Varsayılan olarak ortalı
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false; // Geri gidilebilir mi?

    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && showBackButton && canPop) {
      effectiveLeading = IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.appBarForeground,
        ),
        tooltip: 'Geri',
        onPressed: () => Navigator.maybePop(context),
      );
    }

    return AppBar(
      leading: effectiveLeading,
      automaticallyImplyLeading: false, // Manuel kontrol ediyoruz
      title: Text(
        title,
        style: AppTextStyles.h6,
        overflow: TextOverflow.ellipsis, // Taşarsa ... ile göster
        maxLines: 1, // Genellikle AppBar başlıkları tek satırdır
      ),
      centerTitle: centerTitle,
      actions: actions,
      backgroundColor: AppColors.appBarBackground,
      foregroundColor: AppColors.appBarForeground,
      elevation: 0, // Gölge yok
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
