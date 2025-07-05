import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/cart_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/cart/cart_item_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../checkout/checkout_screen.dart';
import '../products/product_detail_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    // Örnek kargo hesaplaması
    double subtotal = cart.subtotalAmount; // subtotalAmount olarak değiştirildi
    double shippingThreshold = 300; // Kargo bedava sınırı
    double shippingCost =
        (subtotal == 0 || subtotal >= shippingThreshold)
            ? 0.0
            : 29.99; // 300 TL üzeri veya sepet boşsa kargo bedava
    double total =
        cart.totalAmount + shippingCost; // cart.totalAmount (indirimli) + kargo

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sepetim', // Sayı olmadan daha temiz
        showBackButton: false,
        actions: [
          if (cart.itemCount > 0)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded, // Daha modern bir silme ikonu
                color: AppColors.error,
              ), // Daha modern ve uygun ikon
              tooltip: 'Sepeti Temizle',
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Sepeti Temizle'),
                        content: const Text(
                          'Sepetinizdeki tüm ürünleri silmek istediğinizden emin misiniz?',
                        ),
                        actions: [
                          TextButton(
                            child: const Text('İptal'),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          TextButton(
                            child: Text(
                              'Temizle',
                              style: TextStyle(color: AppColors.error),
                            ),
                            onPressed: () {
                              cart.clearCart();
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ),
                );
              },
            ),
        ],
      ),
      body:
          cart.itemCount == 0
              ? _buildEmptyCart(context)
              : Column(
                children: [
                  // Kargo Bedava Barı (varsa)
                  if (subtotal > 0 && subtotal < shippingThreshold)
                    _buildFreeShippingIndicator(
                      context,
                      subtotal,
                      shippingThreshold,
                    ),

                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount: cartItems.length,
                      itemBuilder: (ctx, index) {
                        final item = cartItems[index];
                        return CartItemCard(
                          cartItem: item,
                          onAdd: () => cart.addItem(item.product),
                          onRemove:
                              () => cart.removeSingleItem(item.product.id),
                          onDelete: () => cart.removeItem(item.product.id),
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailScreen(
                                        product: item.product,
                                      ),
                                ),
                              ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      // Alt Özet ve Ödeme Butonu (Sepet boş değilse göster)
      bottomNavigationBar:
          cart.itemCount > 0
              ? _buildCartSummary(context, cart, subtotal, shippingCost, total)
              : null,
    );
  }

  // Kargo Bedava İndikatörü
  Widget _buildFreeShippingIndicator(
    BuildContext context,
    double currentAmount,
    double threshold,
  ) {
    double remaining = threshold - currentAmount;
    double progress = currentAmount / threshold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      color: AppColors.success.withOpacity(0.1), // Yeşilimsi arkaplan
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: AppColors.success,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${Helpers.formatCurrency(remaining)} daha ekleyin, kargo bedava olsun!',
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.success.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
            minHeight: 5, // Çubuk kalınlığı
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  // Sepet Boş Widget'ı
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppColors.primary.withOpacity(0.7),
          ), // Daha ilgili ve modern ikon
          const SizedBox(height: 20),
          Text(
            'Sepetiniz Henüz Boş',
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            'Hemen alışverişe başlayıp \nharika ürünleri keşfedin!',
            style: AppTextStyles.bodyL.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed:
                () => Provider.of<NavigationProvider>(
                  context,
                  listen: false,
                ).setIndex(0),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Alışverişe Başla'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              textStyle: AppTextStyles.button,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ), // Daha yuvarlak köşeler
            ),
          ),
        ],
      ),
    );
  }

  // Sepet Özeti ve Ödeme Butonu Widget'ı
  Widget _buildCartSummary(
    BuildContext context,
    CartProvider cart,
    double subtotal,
    double shippingCost,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 16.0,
      ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        color: AppColors.surface, // Veya Theme.of(context).cardColor
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ), // Üst köşeleri yuvarlat
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
        // border: Border(top: BorderSide(color: AppColors.lightGrey.withOpacity(0.5), width: 1.0)) // Kenarlık yerine gölge daha modern
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kupon Seçim Alanı
          _buildCouponSection(context, cart),
          const SizedBox(height: 16),
          const SizedBox(height: 20), // Boşluk artırıldı
          _buildSummaryRow(
            'Ara Toplam:',
            Helpers.formatCurrency(cart.subtotalAmount),
          ),
          if (cart.appliedCoupon != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: _buildSummaryRow(
                'İndirim (${cart.appliedCoupon!.code}):',
                '-${Helpers.formatCurrency(cart.discountAmount)}',
                isDiscount: true,
              ),
            ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Kargo:',
            shippingCost == 0.0
                ? 'Ücretsiz'
                : Helpers.formatCurrency(shippingCost),
            isFree: shippingCost == 0.0,
          ),
          const Divider(
            height: 28,
            thickness: 0.5,
            color: AppColors.lightGrey,
          ), // Daha ince ve belirgin divider
          _buildSummaryRow(
            'Genel Toplam:',
            Helpers.formatCurrency(total),
            isTotal: true,
          ),
          const SizedBox(height: 20), // Boşluk artırıldı
          ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(totalAmount: total),
                  ),
                ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(
                double.infinity,
                52,
              ), // Yükseklik artırıldı
              textStyle: AppTextStyles.button.copyWith(
                fontSize: 16,
              ), // Daha büyük font
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ), // Daha yuvarlak köşeler
              elevation: 3, // Daha belirgin gölge
            ),
            child: const Text('Ödemeye Geç'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isFree = false,
    bool isDiscount = false, // İndirim satırı için yeni parametre
  }) {
    final TextStyle labelStyle =
        isTotal
            ? AppTextStyles.bodyL.copyWith(fontWeight: FontWeight.w600)
            : AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary);
    final TextStyle valueStyle =
        isTotal
            ? AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold)
            : AppTextStyles.bodyL.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  isFree
                      ? AppColors.success
                      : isDiscount
                      ? AppColors
                          .error // İndirim için kırmızı renk
                      : AppColors.textPrimary,
            );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }

  // Kupon Seçim Widget'ı
  Widget _buildCouponSection(BuildContext context, CartProvider cart) {
    // availableCoupons getter'ı zaten filtrelenmiş ve sıralanmış kuponları döndürür.
    final availableCoupons = cart.availableCoupons;
    final appliedCoupon = cart.appliedCoupon;

    if (availableCoupons.isEmpty) {
      return const SizedBox.shrink(); // Kupon yoksa bir şey gösterme
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kuponlar',
          style: AppTextStyles.bodyL.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120, // Kupon kartlarının yüksekliğine göre ayarlanabilir
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableCoupons.length,
            itemBuilder: (context, index) {
              final coupon = availableCoupons[index];
              final bool isSelected = appliedCoupon?.id == coupon.id;
              final bool isValid = coupon.isValid(cart.subtotalAmount);

              return GestureDetector(
                onTap: () {
                  if (isValid) {
                    if (isSelected) {
                      cart.removeCoupon();
                    } else {
                      cart.applyCoupon(coupon);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Bu kuponu kullanmak için minimum harcama tutarına ulaşılmadı veya kupon geçerli değil.',
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: Container(
                  width: 180, // Kupon kartı genişliği
                  margin: const EdgeInsets.only(right: 12.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surface,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color:
                          isSelected
                              ? AppColors.primary
                              : isValid
                              ? AppColors.lightGrey
                              : Colors.red,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : [],
                  ),
                  child: Opacity(
                    opacity: isValid ? 1.0 : 0.5, // Geçersizse soluklaştır
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          coupon.code,
                          style: AppTextStyles.bodyL.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coupon
                              .title, // Artık 'description' yerine 'title' kullanılıyor gibi görünüyor modelde, ama CouponScreen'de description var. Provider'daki mock data'ya göre description daha uygun.
                          // Eğer Coupon modelinde 'title' alanı kuponun ana metniyse ve 'description' detaysa, ona göre güncellenmeli.
                          // Şimdilik provider'daki mock dataya ve Coupon modelindeki description alanına güvenerek devam ediyorum.
                          semanticsLabel: coupon.description,
                          style: AppTextStyles.bodyS.copyWith(
                            color:
                                isSelected
                                    ? AppColors.primary.withOpacity(0.8)
                                    : AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (coupon.minimumSpend != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Min. ${Helpers.formatCurrency(coupon.minimumSpend!)}',
                              style: AppTextStyles.caption.copyWith(
                                color:
                                    isSelected
                                        ? AppColors.primary.withOpacity(0.7)
                                        : AppColors.textSecondary.withOpacity(
                                          0.8,
                                        ),
                              ),
                            ),
                          ),

                        // isValid zaten CartProvider içinde kontrol ediliyor ve availableCoupons listesine sadece geçerli olanlar ekleniyor.
                        // Bu nedenle buradaki ek kontrol kaldırılabilir veya farklı bir mesaj gösterilebilir.
                        // if (!isValid && cart.subtotalAmount < (coupon.minimumSpend ?? 0)) // Bu kontrol artık gereksiz
                        //   Padding(
                        //     padding: const EdgeInsets.only(top: 4.0),
                        //     child: Text(
                        //       'Kullanılamaz',
                        //       style: AppTextStyles.caption.copyWith(
                        //         color: AppColors.error,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (appliedCoupon != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Uygulanan Kupon: ${appliedCoupon.code}',
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () => cart.removeCoupon(),
                  child: Text(
                    'Kaldır',
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
