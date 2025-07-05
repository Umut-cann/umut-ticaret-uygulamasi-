import 'dart:math';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl; // Ana liste resmi
  final String categoryId;
  final double rating;
  final int reviewCount;
  final List<String> images; // Detay sayfası galerisi için
  final List<String>? availableColors; // Renk seçenekleri (hex kodları)
  final List<String>? availableSizes; // Beden seçenekleri
  final bool isFeatured; // Ana sayfada öne çıksın mı?
  final bool hasSubscriptionOption; // Abonelik seçeneği var mı?
  final double? sustainabilityScore; // 0.0 - 1.0 arası sürdürülebilirlik skoru
  final String? carbonFootprint; // Karbon ayak izi bilgisi (metin)
  final bool isNftAssociated; // NFT ile ilişkili mi?
  final double? oldPrice; // İndirimli fiyat gösterimi için eski fiyat
  final String? stockStatus; // e.g., "in_stock", "low_stock", "out_of_stock"
  final String? specialTag; // e.g., "Haftanın Ürünü", "Ayın Popüler Ürünü"
  final String? brand; // Marka bilgisi eklendi
  final int stock; // Stok miktarı eklendi

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.stock, // stock parametresi zorunlu hale getirildi
    this.availableColors,
    this.availableSizes,
    this.isFeatured = false,
    this.hasSubscriptionOption = false,
    this.sustainabilityScore,
    this.carbonFootprint,
    this.isNftAssociated = false,
    this.oldPrice,
    this.stockStatus,
    this.specialTag,
    this.brand,
  });

  // İndirim oranı (varsa)
  double? get discountPercentage {
    if (oldPrice != null && oldPrice! > price) {
      return ((oldPrice! - price) / oldPrice!) * 100;
    }
    return null;
  }

  factory Product.random(String id, String categoryId) {
    final Random random = Random();
    final bool hasColors = random.nextBool();
    final bool hasSizes = random.nextBool();
    final List<String> productNames = [
      'Harika Tişört',
      'Modern Pantolon',
      'Şık Ayakkabı',
      'Teknolojik Saat',
      'Organik Kahve',
      'Bebek Bezi XL',
      'Gamer Klavyesi',
      'Yoga Matı',
      'Dekoratif Vazo',
      'Akıllı Telefon',
      'Bluetooth Kulaklık',
      'Dizüstü Bilgisayar',
      'Koşu Ayakkabısı',
      'Güneş Gözlüğü',
    ];
    final List<String> colors = [
      '#000000',
      '#FFFFFF',
      '#FF0000',
      '#0000FF',
      '#00FF00',
      '#FFFF00',
      '#CCCCCC',
      '#800080',
      '#FFA500',
    ]; // Mor, Turuncu eklendi
    final List<String> sizes = [
      'XS',
      'S',
      'M',
      'L',
      'XL',
      'XXL',
      '36',
      '38',
      '40',
      '42',
      '44',
    ]; // Ayakkabı/giyim bedenleri

    final double currentPrice =
        (random.nextDouble() * 450 + 50).toDouble(); // 50-500 arası fiyat
    final bool hasDiscount = random.nextDouble() < 0.3; // %30 indirim ihtimali
    final double? oldPriceValue =
        hasDiscount
            ? currentPrice * (1 + (random.nextDouble() * 0.4 + 0.1))
            : null; // %10-%50 arası indirim

    final List<String> stockStatuses = [
      'in_stock',
      'low_stock',
      'out_of_stock',
    ];
    final List<String?> specialTags = [
      null,
      'Haftanın Ürünü',
      'Ayın Popüler Ürünü',
      'Sınırlı Stok!',
      'Yeni Geldi',
    ];
    final List<String> brandNames = [
      'Marka A',
      'Marka B',
      'Marka C',
      'SüperMarka',
      'EcoMarka',
    ];

    return Product(
      id: id,
      name: '${productNames[random.nextInt(productNames.length)]} $id',
      description:
          'Bu ${productNames[random.nextInt(productNames.length)]} için harika bir açıklama metni. Üstün kalite malzemelerden üretilmiş olup, modern tasarımıyla dikkat çekmektedir. Günlük kullanım veya özel günler için idealdir. ${random.nextInt(50) + 50}% geri dönüştürülmüş materyal içerir.',
      price: currentPrice,
      oldPrice: oldPriceValue,
      categoryId: categoryId,
      rating:
          (random.nextDouble() * 3.5 + 1.5).toDouble(), // 1.5 - 5.0 arası puan
      reviewCount: random.nextInt(800) + 20, // 20 - 820 arası yorum
      imageUrl: 'https://picsum.photos/seed/${id}main/400/400',
      images: List.generate(
        random.nextInt(4) + 2,
        (index) => 'https://picsum.photos/seed/$id$index/600/800',
      ), // 2-5 arası detay resmi
      stock: random.nextInt(100) + 1, // Rastgele stok miktarı (1-100)
      availableColors:
          hasColors
              ? List.generate(
                random.nextInt(4) + 2,
                (_) => colors[random.nextInt(colors.length)],
              ).toSet().toList()
              : null, // Tekrarlanan renk olmasın
      availableSizes:
          hasSizes
              ? List.generate(
                random.nextInt(5) + 1,
                (_) => sizes[random.nextInt(sizes.length)],
              ).toSet().toList()
              : null, // Tekrarlanan beden olmasın
      isFeatured: random.nextDouble() < 0.3,
      hasSubscriptionOption: random.nextDouble() < 0.15,
      sustainabilityScore:
          random.nextDouble() < 0.4 ? random.nextDouble() : null,
      carbonFootprint:
          random.nextDouble() < 0.3
              ? '${(random.nextDouble() * 5 + 1).toStringAsFixed(1)} kg CO2e'
              : null,
      isNftAssociated: random.nextDouble() < 0.05,
      stockStatus: stockStatuses[random.nextInt(stockStatuses.length)],
      specialTag: specialTags[random.nextInt(specialTags.length)],
      brand: brandNames[random.nextInt(brandNames.length)], // Rastgele marka
    );
  }
}
