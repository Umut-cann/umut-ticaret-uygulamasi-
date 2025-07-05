import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/order.dart';
import '../../screens/products/product_detail_screen.dart'; // Tekrar satın al için
import '../../utils/helpers.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({required this.order, super.key});

  @override
  Widget build(BuildContext context) {
    // Siparişteki ilk birkaç ürünün resmini gösterelim
    final imageCount = order.items.length > 3 ? 3 : order.items.length;
    final displayItems = order.items.take(imageCount).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0), // Sadece alt boşluk
      padding: const EdgeInsets.all(16.0), // İç boşluk arttırıldı
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2), // Hafif gölge
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sipariş Başlığı (ID, Tarih, Durum)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sipariş No: ${order.id}',
                style: AppTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Durum Rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: order.statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  order.statusText,
                  style: AppTextStyles.caption.copyWith(
                    color: order.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Text(
            Helpers.formatDate(order.orderDate), // Sipariş tarihi
            style: AppTextStyles.bodyS,
          ),
          const SizedBox(height: 12), // Boşluk azaltıldı
          // Ürün Görselleri (Yatayda)
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  displayItems.length +
                  (order.items.length > imageCount
                      ? 1
                      : 0), // Fazla ürün varsa +1 sayaç
              itemBuilder: (ctx, index) {
                if (index < displayItems.length) {
                  // Ürün resmi
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: displayItems[index].imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 200),
                        fadeOutDuration: const Duration(milliseconds: 200),
                        memCacheWidth: 120, // 2x for high resolution displays
                        memCacheHeight: 120,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 60,
                          color: AppColors.lightGrey,
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
                          width: 60,
                          height: 60,
                          color: AppColors.lightGrey,
                          child: const Icon(Icons.error_outline, size: 20),
                        ),
                      ),
                    ),
                  );
                } else {
                  // Kalan ürün sayısı göstergesi
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '+${order.items.length - imageCount}',
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 10), // Boşluk azaltıldı
          // Toplam Tutar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Toplam Tutar:', style: AppTextStyles.bodyM),
              Text(
                Helpers.formatCurrency(order.totalAmount),
                style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16), // Boşluk arttırıldı
          // Butonlar (Sipariş Detayı / Tekrar Satın Al / Takip Et)
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Butonları sağa yasla
            children: [
              // Kargo Takip Butonu (varsa)
              if (order.trackingNumber != null &&
                  order.status == OrderStatus.shipped)
                OutlinedButton.icon(
                  onPressed: () {
                    /* Kargo Takip Sayfası/Linki (UI Only) */
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Kargo Takip No: ${order.trackingNumber}',
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: Icon(Icons.local_shipping_outlined, size: 18),
                  label: Text('Takip Et'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    textStyle: AppTextStyles.bodyS.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    foregroundColor: AppColors.accent,
                    side: BorderSide(color: AppColors.accent),
                  ),
                ),
              if (order.trackingNumber != null &&
                  order.status == OrderStatus.shipped)
                const SizedBox(width: 8), // Butonlar arası boşluk
              // Sipariş Detayları Butonu
              TextButton(
                onPressed: () {
                  // Sipariş Detay sayfasına gidilebilir (UI Only)
                  _showOrderDetailDialog(context, order);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  foregroundColor: AppColors.primary, // Renk değiştirildi
                  textStyle: AppTextStyles.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Detaylar'),
              ),
              const SizedBox(width: 8),

              // Tekrar Satın Al Butonu (Teslim edildi veya iade edildi ise)
              if (order.status == OrderStatus.delivered ||
                  order.status == OrderStatus.returned)
                ElevatedButton(
                  onPressed: () {
                    // İlk ürünü sepete ekle veya ürün detayına git (örnek)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ProductDetailScreen(product: order.items.first),
                      ),
                    );
                    // Veya tüm ürünleri tek tek sepete ekle
                    // order.items.forEach((p) => Provider.of<CartProvider>(context, listen: false).addItem(p));
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ürünler sepete eklendi!')));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ), // Padding güncellendi
                    textStyle: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.primary, // Ana renk kullanıldı
                    foregroundColor: Colors.white,
                    elevation: 0.5, // Hafif yükseklik
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ), // Köşeler yuvarlatıldı
                  ),
                  child: const Text('Tekrar Al'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Sipariş Detayı için basit bir dialog (örnek)
  void _showOrderDetailDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Sipariş Detayları (${order.id})'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Tarih: ${Helpers.formatDate(order.orderDate)}'),
                  Text('Durum: ${order.statusText}'),
                  Text('Ödeme Yöntemi: ${order.paymentMethod}'),
                  Text('Teslimat Adresi: ${order.shippingAddress}'),
                  if (order.estimatedDeliveryDate != null)
                    Text(
                      'Tahmini Teslimat: ${Helpers.formatDate(order.estimatedDeliveryDate!)}',
                    ),
                  if (order.trackingNumber != null)
                    Text('Kargo Takip No: ${order.trackingNumber}'),
                  const Divider(height: 15),
                  Text(
                    'Ürünler:',
                    style: AppTextStyles.bodyL.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...order.items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '- ${item.name} (${Helpers.formatCurrency(item.price)})',
                          ),
                        ),
                      )
                      .toList(),
                  const Divider(height: 15),
                  Text(
                    'Toplam Tutar: ${Helpers.formatCurrency(order.totalAmount)}',
                    style: AppTextStyles.h6,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Kapat'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }
}
