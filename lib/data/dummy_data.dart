import 'dart:math'; // Rastgele değerler ve ID üretimi için eklendi.

import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/product.dart';

class DummyData {
  static final _random = Random(); // Tek bir Random örneği

  static final List<Category> categories = [
    Category(id: 'c1', name: 'Giyim', icon: Icons.checkroom_outlined),
    Category(
      id: 'c2',
      name: 'Elektronik',
      icon: Icons.laptop_chromebook_outlined,
    ),
    Category(id: 'c3', name: 'Ev & Yaşam', icon: Icons.chair_outlined),
    Category(id: 'c4', name: 'Kozmetik', icon: Icons.spa_outlined),
    Category(
      id: 'c5',
      name: 'Süpermarket',
      icon: Icons.local_grocery_store_outlined,
    ),
    Category(id: 'c6', name: 'Anne & Bebek', icon: Icons.child_care_outlined),
    Category(
      id: 'c7',
      name: 'Spor & Outdoor',
      icon: Icons.sports_soccer_outlined,
    ),
    Category(id: 'c8', name: 'Kitap & Hobi', icon: Icons.auto_stories_outlined),
    Category(
      id: 'c9',
      name: 'Oto Aksesuar',
      icon: Icons.directions_car_filled_outlined,
    ),
    Category(id: 'c10', name: 'Moda Aksesuar', icon: Icons.watch_outlined),
  ];

  // Kategoriye özel temel ürün isimleri
  static final Map<String, List<String>> _categorySpecificProductNames = {
    'c1': [
      "Erkek Tişört",
      "Kadın Bluz",
      "Kot Pantolon",
      "Etek",
      "Ceket",
      "Trençkot",
      "Sweatshirt",
      "Takım Elbise",
      "Şort",
      "Gömlek",
      "Mont",
      "Elbise",
      "Hırka",
      "Tayt",
      "Spor Eşofman Takımı",
    ],
    'c2': [
      "Dizüstü Bilgisayar",
      "Bluetooth Kulaklık",
      "Akıllı Telefon",
      "Powerbank",
      "Akıllı Saat",
      "Oyuncu Mouse",
      "Klavye",
      "Monitör",
      "Televizyon",
      "Akıllı Lamba",
      "Şarj Cihazı",
      "USB Bellek",
      "Kamera",
      "Drone",
      "Tablet",
    ],
    'c3': [
      "Çamaşır Sepeti",
      "Halı",
      "Yastık",
      "Abajur",
      "Kitaplık",
      "Sandalye",
      "Sehpa",
      "Nevresim Takımı",
      "Battaniye",
      "Perde",
      "Duvar Saati",
      "Mum",
      "Masa Lambası",
      "Ayakkabılık",
      "Raf Ünitesi",
    ],
    'c4': [
      "Ruj",
      "Fondöten",
      "Göz Kalemi",
      "Maskara",
      "Allık",
      "Nemlendirici",
      "Yüz Temizleme Jeli",
      "Parfüm",
      "Cilt Serumu",
      "BB Krem",
      "Aseton",
      "Oje",
      "Güneş Kremi",
      "Kaş Kalemi",
      "Makyaj Temizleyici",
    ],
    'c5': [
      "Makarna",
      "Zeytinyağı",
      "Pirinç",
      "Mercimek",
      "Tuz",
      "Şeker",
      "Süt",
      "Yoğurt",
      "Kahve",
      "Çay",
      "Çikolata",
      "Cips",
      "Dondurma",
      "Konserve Mısır",
      "Bulaşık Deterjanı",
    ],
    'c6': [
      "Bebek Bezi",
      "Emzik",
      "Biberon",
      "Mama Sandalyesi",
      "Bebek Arabası",
      "Göğüs Pompası",
      "Bebek Battaniyesi",
      "Islak Mendil",
      "Bebek Şampuanı",
      "Mama Önlüğü",
      "Oyuncak Ayı",
      "Bebek Tulumu",
      "Emzirme Yastığı",
      "Bebek Telsizi",
      "Bebek Termometresi",
    ],
    'c7': [
      "Yoga Matı",
      "Dambıl",
      "Koşu Ayakkabısı",
      "Spor Çantası",
      "Termos",
      "Kamp Sandalyesi",
      "Uyku Tulumu",
      "Matara",
      "Sporcu Taytı",
      "Bisiklet",
      "Fitness Eldiveni",
      "Koşu Bandı",
      "Dalış Gözlüğü",
      "Kamp Çadırı",
      "Sporcu Atleti",
    ],
    'c8': [
      "Roman",
      "Boyama Kitabı",
      "Satranç Takımı",
      "Yapboz",
      "Günlük",
      "Hikaye Kitabı",
      "Kalem Seti",
      "Hobi Bıçağı",
      "Defter",
      "Mandala Kitabı",
      "Akıl Oyunları",
      "Su Bazlı Boya",
      "Örgü Seti",
      "Çizim Defteri",
      "Sudoku Kitabı",
    ],
    'c9': [
      "Oto Koltuk Kılıfı",
      "Araç İçi Kamera",
      "Telefon Tutucu",
      "Oto Süpürge",
      "Oto Parfüm",
      "Güneşlik",
      "Bagaj Organizer",
      "Oto Cam Filmi",
      "LED Far",
      "Lastik Parlatıcı",
      "İlk Yardım Seti",
      "Oto Şarj Cihazı",
      "Jant Kapağı",
      "Cam Suyu",
      "Park Sensörü",
    ],
    'c10': [
      "Güneş Gözlüğü",
      "Şapka",
      "Saat",
      "Bileklik",
      "Kolye",
      "Küpe",
      "Kravat",
      "Cüzdan",
      "Kemer",
      "Çanta",
      "Fular",
      "Yüzük",
      "Broş",
      "Saç Bandı",
      "Anahtarlık",
    ],
  };

  // Örnek ürün isimleri ve sıfatları (fallback için veya genel kullanım için kalabilir)
  static final List<String> _sampleBaseProductNames = [
    "Tişört",
    "Kulaklık",
    // "Kahve Sehpası", // c3 için daha uygun
    "Yüz Serumu",
    "Makarna",
    "Bebek Bezi",
    "Koşu Ayakkabısı",
    "Roman",
    "Telefon Tutucu",
    "Kol Saati",
    "Kazak",
    // "Duvar Rafı", // c3 için daha uygun
    "Makyaj Seti",
    "Zeytinyağı",
    "Zıbın Seti",
    "Yoga Matı",
    "Polisiye Kitap",
    // "Lastik Parlatıcı", // c9 için daha uygun
    "Kolye",
    "Kot Pantolon",
    "Akıllı Saat",
    // "Kitaplık", // c3 için daha uygun
    "Güneş Kremi",
    "Yulaf Ezmesi",
    "Bebek Arabası",
    "Dambıl Seti",
    "Tarihi Kitap",
    // "Oto Cam Suyu", // c9 için daha uygun
    "Spor Bileklik",
    "Blender",
    "Tava Seti",
    // "Nevresim Takımı", // c3 için daha uygun
    "Şampuan",
    "Oyuncak Araba",
    "Spor Çantası",
    "Sırt Çantası",
    "Gözlük",
    "Cüzdan",
    "Parfüm",
    "Tablet",
    "Laptop Çantası",
    "Mouse",
    "Klavye",
    "Monitör",
    "Yazıcı",
    // "Halı", // c3 için daha uygun
    // "Perde", // c3 için daha uygun
    // "Aydınlatma", // c3 için daha uygun
    // "Saklama Kabı", // c3 veya c5 için daha uygun
    // "Çay Makinesi", // c2 veya c3 için daha uygun
  ];

  static final List<String> _sampleAdjectives = [
    "Şık",
    "Modern",
    "Kaliteli",
    "Dayanıklı",
    "Organik",
    "Doğal",
    "Profesyonel",
    "Ekonomik",
    "Yeni Sezon",
    "İndirimli",
    "Popüler",
    "Ergonomik",
    "Konforlu",
    "Renkli",
    "Desenli",
    "Minimalist",
    "Gelişmiş",
    "Hızlı",
    "Güçlü",
    "Zarif",
  ];

  static final List<String> _sampleBrandNames = [
    "Elit Marka",
    "TrendModa",
    "TeknoHarika",
    "EvGüzeli",
    "SüperMarketim",
    "BebekNeşesi",
    "SporAktif",
    "HobiDünyam",
    "OtoPlus",
    "AksesuarStil",
  ];
  static final List<String> _sampleSellerNames = [
    "Güvenilir Satıcı",
    "Hızlı Tedarikçi",
    "Yetkili Bayi",
    "OnlineMağaza",
    "ButikEv",
    "Resmi Distribütör",
    "Yerel İşletme",
  ];

  static final List<Product> products = List.generate(150, (index) {
    final category = categories[index % categories.length];
    final adjective =
        _sampleAdjectives[_random.nextInt(
          _sampleAdjectives.length,
        )]; // Rastgele sıfat seçimi
    final baseNamesForCategory =
        _categorySpecificProductNames[category.id] ??
        _sampleBaseProductNames; // Kategoriye özel isim listesi, yoksa genel liste
    final baseName =
        baseNamesForCategory[_random.nextInt(
          baseNamesForCategory.length,
        )]; // Kategoriye uygun temel isim seçimi
    final productName = "$adjective $baseName"; // Ürün ismini oluştur
    final String currentImageUrl =
        'https://picsum.photos/seed/product${index + _random.nextInt(1000)}/600/400'; // Rastgele resim URL'si

    // Product.random yerine doğrudan Product constructor'ını kullanalım.
    // Product sınıfının bu alanları kabul eden bir constructor'ı olduğu varsayılıyor.
    return Product(
      id: 'prod_${index + 1}_${_random.nextInt(100000)}', // Daha benzersiz ID
      name: productName, // Anlamlı ürün adı
      categoryId: category.id,
      description:
          "Bu ${category.name} kategorisinden harika bir ${productName.toLowerCase()}. Günlük kullanım için ideal ve yüksek kaliteli malzemelerden üretilmiştir. ${_random.nextBool() ? 'Çeşitli renk seçenekleri mevcuttur.' : 'Sınırlı sayıda stoklarla!'}",
      price: double.parse(
        (_random.nextDouble() * 450 + 50).toStringAsFixed(
          2,
        ), // 50-500 arası fiyat
      ),
      imageUrl: currentImageUrl, // Ana liste resmi
      images: List.generate(
        _random.nextInt(4) + 2, // 2-5 arası rastgele resim sayısı
        (i) =>
            'https://picsum.photos/seed/product${index + i + _random.nextInt(1000)}/600/400',
      ), // Detay sayfası galerisi için resimler
      rating: double.parse(
        (3.0 + _random.nextDouble() * 2.0).toStringAsFixed(
          1,
        ), // 3.0-5.0 arası puan
      ),
      reviewCount: _random.nextInt(300) + 15, // 15-314 arası yorum sayısı
      isFeatured: (_random.nextDouble() < 0.15), // %15 ihtimalle öne çıkan ürün
      brand:
          "${_sampleBrandNames[_random.nextInt(_sampleBrandNames.length)]} Serisi ${_random.nextInt(50) + 1}", // Daha çeşitli marka
      stock: _random.nextInt(100) + 10, // 10-109 arası stok
      // Eğer Product modelinde renkler, bedenler gibi ek alanlar varsa, onlar da burada eklenebilir.
      // Örneğin: colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.black, Colors.white].sublist(0, _random.nextInt(3)+1),
      // sizes: ['S', 'M', 'L', 'XL'].sublist(0, _random.nextInt(3)+1),
      specialTag:
          _random.nextDouble() < 0.1
              ? "Sınırlı Stok"
              : null, // %10 ihtimalle özel etiket
    );
  });

  static List<Product> getProductsByCategory(String categoryId) {
    return products
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  static List<Product> getFeaturedProducts() {
    // Hem isFeatured olanları hem de yüksek puanlılardan bazılarını alalım
    var featured = products.where((product) => product.isFeatured).toList();
    var highRated =
        products.where((p) => p.rating >= 4.5 && !p.isFeatured).toList();
    highRated.shuffle(_random); // Rastgele sırala
    featured.addAll(highRated.take(6)); // Yüksek puanlılardan 6 tane ekle
    featured.shuffle(_random); // Son listeyi karıştır
    return featured.take(10).toList(); // En fazla 10 tane göster
  }

  static List<Product> getSimilarProducts(
    String currentProductId,
    String categoryId,
  ) {
    return products
        .where((p) => p.categoryId == categoryId && p.id != currentProductId)
        .take(6)
        .toList();
  }

  // Arama fonksiyonu (basit isim araması)
  static List<Product> searchProducts(String query) {
    if (query.isEmpty) return [];
    query = query.toLowerCase();
    return products
        .where(
          (p) =>
              p.name.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query),
        )
        .toList();
  }
}
