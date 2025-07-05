# Umut Ticaret - Flutter E-Ticaret Uygulaması

Bu proje, Flutter ve Dart kullanılarak geliştirilmiş, modern, performans odaklı ve zengin özelliklere sahip bir mobil e-ticaret uygulamasıdır. Kullanıcıların ürünleri keşfetmesini, favorilerine eklemesini ve kolayca sepetlerine ekleyip satın alma işlemlerini tamamlamasını sağlar.

## 🌟 Proje Felsefesi

Bu projenin temel amacı, temiz kod mimarisi, performans optimizasyonu ve ölçeklenebilir bir yapı sunarak Flutter ile e-ticaret uygulaması geliştirmek isteyenler için bir referans noktası oluşturmaktır. Kodun okunabilirliği ve bakımının kolay olması önceliklendirilmiştir.

## ✨ Temel Özellikler

-   **Modern ve Sezgisel Arayüz:** Kullanıcı deneyimini ön planda tutan, akıcı ve estetik bir tasarım.
-   **Gelişmiş Ürün Listeleme:**
    -   Kategorilere göre ürünler.
    -   Öne çıkanlar, yeni gelenler gibi özel etiketli ürün grupları.
    -   Fiyat, marka ve popülerliğe göre sıralama ve filtreleme seçenekleri.
-   **Akıllı Arama:** Anlık sonuçlar gösteren, ürün adı ve markaya göre arama yapabilen bir arama çubuğu.
-   **Favoriler Yönetimi:** Kullanıcıların beğendikleri ürünleri favori listelerine ekleyip çıkarması ve bu listeyi görüntülemesi.
-   **Dinamik Sepet:** Ürün ekleme, çıkarma ve adet güncelleme gibi temel sepet işlemleri.
-   **Duyarlı (Responsive) Tasarım:** `MediaQuery` ve esnek widget'lar (`Expanded`, `Flexible`) kullanılarak farklı ekran boyutlarına ve yönlendirmelere tam uyum.
-   **Performans Optimizasyonları:**
    -   `ListView.builder` ve `GridView.builder` ile verimli liste oluşturma.
    -   `CachedNetworkImage` ile resimlerin önbelleğe alınması.
    -   Gereksiz widget yeniden oluşturmalarını önlemek için `const` kullanımı.
    -   `Provider` ile state yönetiminin optimize edilmesi.

## 📂 Proje Yapısı

Proje, özelliklere göre modüler bir yapıda organize edilmiştir. Bu, yeni özellikler eklemeyi ve mevcut kodu yönetmeyi kolaylaştırır.

```
lib/
├── constants/      # Uygulama genelindeki sabitler (renkler, metin stilleri vb.)
├── data/           # Geçici veriler, modeller için başlangıç verileri
├── models/         # Uygulamanın veri modelleri (Product, Category vb.)
├── providers/      # State management için Provider sınıfları
├── screens/        # Uygulamanın ekranları (Ana Sayfa, Ürün Detay, Sepet vb.)
│   ├── home/
│   ├── products/
│   └── ...
├── widgets/        # Yeniden kullanılabilir widget'lar (ProductCard, SearchBar vb.)
│   ├── common/
│   └── home/
└── main.dart       # Uygulamanın başlangıç noktası
```

## 🛠️ Kullanılan Teknolojiler ve Paketler

-   **Flutter & Dart:** Ana geliştirme platformu ve dili.
-   **Provider:** State management için tercih edilen, basit ve güçlü bir çözüm.
-   **CachedNetworkImage:** Ağdan indirilen resimleri verimli bir şekilde yönetmek ve önbelleğe almak için.
-   **Flutter Services:** Cihazın özellikleri ve servisleriyle (örneğin, haptic feedback) etkileşim için.

## 🚀 Kurulum ve Başlatma

Projeyi yerel makinenizde çalıştırmak için aşağıdaki adımları izleyin:

1.  **Gereksinimler:**
    -   [Flutter SDK](https://flutter.dev/docs/get-started/install) (versiyon 3.x.x veya üstü)
    -   Bir kod editörü (VS Code, Android Studio vb.)
    -   Bir emülatör veya fiziksel cihaz.

2.  **Projeyi Klonlayın:**
    ```sh
    git clone https://github.com/kullanici-adi/umut_ticaret.git
    cd umut_ticaret
    ```

3.  **Bağımlılıkları Yükleyin:**
    Proje dizinindeyken aşağıdaki komutu çalıştırarak gerekli paketleri indirin:
    ```sh
    flutter pub get
    ```

4.  **Uygulamayı Çalıştırın:**
    Bir emülatör veya fiziksel bir cihaz bağladıktan sonra uygulamayı başlatın:
    ```sh
    flutter run
    ```

## 🤝 Katkıda Bulunma

Katkılarınız projeyi daha iyi hale getirecektir! Katkıda bulunmak isterseniz, lütfen aşağıdaki adımları izleyin:

1.  Bu repoyu "Fork" edin.
2.  Yeni bir özellik dalı oluşturun (`git checkout -b ozellik/yeni-ozellik`).
3.  Değişikliklerinizi yapın ve "Commit" edin (`git commit -m 'Yeni özellik eklendi'`).
4.  Dalınızı itin (`git push origin ozellik/yeni-ozellik`).
5.  Bir "Pull Request" (PR) açın.

## 📜 Lisans

Bu proje MIT Lisansı altında lisanslanmıştır. Daha fazla bilgi için `LICENSE` dosyasına bakın.

## 📧 İletişim

Umut Can - [umut.can@ornek.com](mailto:umut.can@ornek.com)

Proje Linki: [https://github.com/kullanici-adi/umut_ticaret](https://github.com/kullanici-adi/umut_ticaret)
