
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../data/dummy_data.dart';
import 'product.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled, returned }

class Order {
  final String id;
  final DateTime orderDate;
  final List<Product> items; // Basit tutuldu, normalde adet/fiyat bilgisi de olurdu
  final double totalAmount;
  final String shippingAddress;
  final String paymentMethod;
  OrderStatus status;
  final String? trackingNumber;
  final DateTime? estimatedDeliveryDate;

  Order({
    required this.id,
    required this.orderDate,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.paymentMethod,
    this.status = OrderStatus.pending,
    this.trackingNumber,
    this.estimatedDeliveryDate,
  });

   String get statusText {
     switch (status) {
       case OrderStatus.pending: return 'Onay Bekliyor';
       case OrderStatus.processing: return 'Hazırlanıyor';
       case OrderStatus.shipped: return 'Kargoya Verildi';
       case OrderStatus.delivered: return 'Teslim Edildi';
       case OrderStatus.cancelled: return 'İptal Edildi';
       case OrderStatus.returned: return 'İade Edildi';
       default: return 'Bilinmiyor';
     }
   }

   Color get statusColor {
     switch (status) {
       case OrderStatus.pending: return Colors.orangeAccent;
       case OrderStatus.processing: return Colors.blueAccent;
       case OrderStatus.shipped: return AppColors.accent;
       case OrderStatus.delivered: return AppColors.success;
       case OrderStatus.cancelled: return AppColors.error;
       case OrderStatus.returned: return Colors.deepOrange;
       default: return AppColors.darkGrey;
     }
   }

   static List<Order> createDummyOrders(int count) {
      final List<Order> orders = [];
      final random = Random();
      final products = DummyData.products;

      for (int i = 0; i < count; i++) {
          final orderItemCount = random.nextInt(4) + 1;
          final orderItems = List.generate(orderItemCount, (_) => products[random.nextInt(products.length)]);
          final total = orderItems.fold(0.0, (sum, item) => sum + item.price);
          final statusValues = OrderStatus.values;
          final status = statusValues[random.nextInt(statusValues.length)];
          final orderDate = DateTime.now().subtract(Duration(days: random.nextInt(60), hours: random.nextInt(24))); // Son 2 ay
          DateTime? deliveryDate;
          if (status == OrderStatus.delivered || status == OrderStatus.returned) {
            deliveryDate = orderDate.add(Duration(days: random.nextInt(5) + 2));
          } else if (status != OrderStatus.cancelled) {
             deliveryDate = DateTime.now().add(Duration(days: random.nextInt(5) + 1));
          }

         orders.add(Order(
            id: 'ORD-${DateTime.now().year}${10000 + i}',
            orderDate: orderDate,
            items: orderItems,
            totalAmount: total * (1 + random.nextDouble() * 0.15), // Kargo vb. ekle
            shippingAddress: 'Örnek Mah. ${random.nextInt(100)} Sk. No:${random.nextInt(20)} D:${random.nextInt(10)}, İlçe/İl',
            paymentMethod: random.nextBool() ? 'Kredi Kartı' : 'Kapıda Ödeme',
            status: status,
            trackingNumber: (status == OrderStatus.shipped || status == OrderStatus.delivered || status == OrderStatus.returned) ? 'ABC${random.nextInt(999999)}TR' : null,
            estimatedDeliveryDate: deliveryDate,
         ));
      }
       orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      return orders;
   }
}
