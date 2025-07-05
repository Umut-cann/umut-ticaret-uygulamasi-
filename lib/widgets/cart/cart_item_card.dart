import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/cart_item.dart';
import '../../utils/helpers.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;
  final VoidCallback onTap; // Ürün detayına gitmek için

  const CartItemCard({
    required this.cartItem,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
      ), // Dikey boşluk artırıldı
      elevation: 2, // Hafifçe artırılmış gölge
      shadowColor: Colors.black.withOpacity(0.08), // Daha yumuşak gölge rengi
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Daha yuvarlak köşeler
        // side: BorderSide(color: AppColors.lightGrey.withOpacity(0.3), width: 1.0) // İsteğe bağlı ince kenarlık
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // Eşleşen köşe yuvarlaklığı
        child: Padding(
          padding: const EdgeInsets.all(12.0), // İç boşluk ayarlandı
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Dikeyde ortala
            children: [
              // Ürün Resmi
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  12.0,
                ), // Daha yuvarlak resim köşeleri
                child: CachedNetworkImage(
                  imageUrl: cartItem.product.imageUrl,
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 200),
                  fadeOutDuration: const Duration(milliseconds: 200),
                  memCacheWidth: 150, // 2x for high resolution displays
                  memCacheHeight: 150,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                    width: 75,
                    height: 75,
                    color: AppColors.lightGrey.withOpacity(0.5),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 75,
                    height: 75,
                    color: AppColors.lightGrey.withOpacity(0.5),
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.darkGrey.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16), // Boşluk artırıldı
              // Ürün Bilgileri ve Adet Kontrolü
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween, // Dikeyde boşlukları dağıt
                  children: [
                    Text(
                      cartItem.product.name,
                      style: AppTextStyles.bodyL.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ), // Satır yüksekliği eklendi
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4), // Boşluk ayarlandı
                    // Fiyat
                    Text(
                      Helpers.formatCurrency(cartItem.product.price),
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ), // Fiyat daha belirgin
                    ),
                    const SizedBox(height: 8),
                    // Adet Kontrolü ve Silme Butonu
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween, // Öğeleri uçlara dağıt
                      children: [
                        // Adet Kontrolü
                        Row(
                          children: [
                            _buildQuantityButton(
                              icon: Icons.remove,
                              onPressed: onRemove,
                              enabled: cartItem.quantity > 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                              ), // Yatay boşluk artırıldı
                              child: Text(
                                '${cartItem.quantity}',
                                style: AppTextStyles.h6.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _buildQuantityButton(
                              icon: Icons.add,
                              onPressed: onAdd,
                            ),
                          ],
                        ),
                        // Silme Butonu (Daha küçük ve tıklama alanı artırılmış)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                            size: 24,
                          ), // İkon güncellendi
                          tooltip: 'Ürünü Kaldır',
                          padding: const EdgeInsets.all(
                            4,
                          ), // Tıklama alanını artır
                          constraints: const BoxConstraints(),
                          splashRadius: 20, // Tıklama efekti yarıçapı
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Adet artırma/azaltma butonu için yardımcı widget (Daha modern stil)
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    return Material(
      color:
          enabled
              ? AppColors.lightGrey.withOpacity(0.3)
              : AppColors.lightGrey.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6), // İç boşluk
          child: Icon(
            icon,
            size: 18, // İkon boyutu
            color:
                enabled
                    ? AppColors.primary
                    : AppColors.darkGrey.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
