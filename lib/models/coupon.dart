enum CouponType {
  percentage,
  fixedAmount,
  freeShipping,
} // freeShipping eklendi

class Coupon {
  final String id;
  final String code;
  CouponType type;
  double value; // Yüzdesel indirim için yüzde oranı, sabit tutar için miktar
  String title; // Kupon başlığı (örn: "25 TL İndirim", "%10 İndirim")
  String description;
  DateTime expiryDate;
  double? minimumSpend; // Opsiyonel minimum harcama tutarı
  bool isUsed;

  Coupon({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.title,
    required this.description,
    required this.expiryDate,
    this.minimumSpend,
    this.isUsed = false,
  });

  // İndirim miktarını hesaplayan bir metot
  double calculateDiscount(double totalAmount) {
    if (!isValid(totalAmount)) return 0.0;

    if (type == CouponType.percentage) {
      return (totalAmount * value) / 100;
    } else if (type == CouponType.fixedAmount) {
      // Sabit tutarlı indirim, sepet tutarını geçemez
      return value > totalAmount ? totalAmount : value;
    } else if (type == CouponType.freeShipping) {
      // Kargo ücreti indirimi burada hesaplanmaz, kargo hesaplamasında dikkate alınır.
      // Bu metot sadece ürün indirimi için.
      return 0.0;
    }
    return 0.0;
  }

  // Kuponun geçerli olup olmadığını kontrol eden bir metot
  bool isValid(double currentTotal) {
    if (isUsed) {
      return false; // Zaten kullanılmış
    }
    if (expiryDate.isBefore(DateTime.now())) {
      return false; // Süresi dolmuş
    }
    if (minimumSpend != null && currentTotal < minimumSpend!) {
      return false; // Minimum harcama tutarına ulaşılmamış
    }
    return true;
  }
}
