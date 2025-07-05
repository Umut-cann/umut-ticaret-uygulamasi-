import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/coupon.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  Coupon? _appliedCoupon;
  List<Coupon> _allCoupons =
      []; // Tüm kuponların tutulacağı liste (CouponsScreen'den alınacak)
  List<Coupon> _availableCoupons =
      []; // Sepette gösterilecek, filtrelenmiş kuponlar

  Coupon? get appliedCoupon => _appliedCoupon;
  // Sadece geçerli ve kullanılmamış kuponları döndür
  List<Coupon> get availableCoupons {
    _filterAvailableCoupons(); // Her erişimde filtrele
    return _availableCoupons;
  }

  CartProvider() {
    _loadAllCoupons(); // Provider oluşturulduğunda tüm kuponları yükle
  }

  // CouponsScreen'deki _loadCoupons mantığı buraya taşınacak
  void _loadAllCoupons() {
    // Bu kısım normalde bir servis veya veritabanından gelir.
    // Şimdilik CouponsScreen'deki mock datayı kullanalım.
    _allCoupons = [
      Coupon(
        id: 'c1',
        title: '25 TL İndirim',
        description:
            'Tüm kitaplarda 100 TL ve üzeri alışverişlerde geçerlidir.',
        code: 'KITAP25',
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        type: CouponType.fixedAmount,
        value: 25,
        minimumSpend: 100,
        isUsed: false,
      ),
      Coupon(
        id: 'c2',
        title: '%15 İndirim',
        description:
            'Yeni sezon giyim ürünlerinde geçerli özel indirim fırsatı.',
        code: 'MODA15',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        type: CouponType.percentage,
        value: 15,
        isUsed: false,
      ),
      Coupon(
        id: 'c3',
        title: '50 TL İndirim',
        description:
            'Elektronik aksesuarlarda 300 TL ve üzeri alışverişlerinizde kullanabilirsiniz.',
        code: 'TEKNO50',
        expiryDate: DateTime.now().add(const Duration(days: 15)),
        type: CouponType.fixedAmount,
        value: 50,
        minimumSpend: 300,
        isUsed: true, // Bu kupon kullanılmış olarak işaretlendi
      ),
      Coupon(
        id: 'c4',
        title: 'Ücretsiz Kargo',
        description: '150 TL ve üzeri tüm siparişlerinizde kargo bedava!',
        code: 'KARGOFREE',
        expiryDate: DateTime.now().subtract(
          const Duration(days: 2),
        ), // Bu kuponun süresi dolmuş
        type: CouponType.freeShipping,
        value:
            0, // Kargo için değer 0 olabilir, hesaplama kargo adımında yapılır
        minimumSpend: 150,
        isUsed: false,
      ),
      Coupon(
        id: 'c5',
        title: '%10 Hafta Sonu İndirimi',
        description:
            'Hafta sonuna özel tüm yiyecek ve içeceklerde geçerli %10 indirim.',
        code: 'LEZZET10',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
        type: CouponType.percentage,
        value: 10,
        isUsed: false,
      ),
    ];
    _filterAvailableCoupons();
    notifyListeners();
  }

  void _filterAvailableCoupons() {
    _availableCoupons =
        _allCoupons.where((coupon) {
          // isValid metodu zaten isUsed ve expiryDate kontrolü yapıyor.
          // Ek olarak, freeShipping kuponları sepette gösterilmeyecekse burada filtrelenebilir.
          // Şimdilik tüm geçerli kuponları alalım.
          return coupon.isValid(
            subtotalAmount,
          ); // isValid zaten isUsed ve expiryDate kontrolü yapıyor
        }).toList();

    // İsteğe bağlı: Kullanılabilir kuponları sırala (örn: en yeni, en çok indirim yapan vb.)
    _availableCoupons.sort((a, b) {
      if (a.expiryDate.isAfter(b.expiryDate)) return -1;
      if (b.expiryDate.isAfter(a.expiryDate)) return 1;
      return 0;
    });
  }

  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalQuantity {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get subtotalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  double get discountAmount {
    if (_appliedCoupon != null && _appliedCoupon!.isValid(subtotalAmount)) {
      return _appliedCoupon!.calculateDiscount(subtotalAmount);
    }
    return 0.0;
  }

  double get totalAmount {
    return subtotalAmount - discountAmount;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product, quantity: 1),
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedCoupon = null; // Sepet temizlendiğinde kuponu da kaldır
    _filterAvailableCoupons(); // Sepet temizlendiğinde kuponların geçerliliğini tekrar kontrol et
    notifyListeners();
  }

  // Bu metot, bir kupon kullanıldığında (örneğin sipariş tamamlandığında) çağrılmalı
  void markCouponAsUsed(String couponId) {
    final couponIndex = _allCoupons.indexWhere((c) => c.id == couponId);
    if (couponIndex != -1) {
      _allCoupons[couponIndex].isUsed = true;
      if (_appliedCoupon?.id == couponId) {
        _appliedCoupon = null; // Uygulanan kupon kullanıldıysa kaldır
      }
      _filterAvailableCoupons();
      notifyListeners();
    }
  }

  void applyCoupon(Coupon coupon) {
    // _filterAvailableCoupons çağrısı availableCoupons getter'ında yapıldığı için burada tekrar gerek yok.
    // Sadece seçilen kuponun gerçekten _availableCoupons içinde olup olmadığını kontrol edebiliriz (ekstra güvenlik)
    if (_availableCoupons.any(
      (c) => c.id == coupon.id && c.isValid(subtotalAmount),
    )) {
      _appliedCoupon = coupon;
      notifyListeners();
    } else {
      print(
        'Kupon geçerli değil, minimum harcama tutarına ulaşılamadı veya zaten kullanılmış.',
      );
      // Kullanıcıya geri bildirim verilebilir.
    }
  }

  @override
  void notifyListeners() {
    _filterAvailableCoupons(); // Herhangi bir değişiklikte kuponları yeniden filtrele
    super.notifyListeners();
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }
}
