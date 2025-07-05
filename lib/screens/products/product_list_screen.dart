import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../data/dummy_data.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/products/product_card.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final Category? category;
  final String? title;
  final List<Product>?
  predefinedProductList; // Opsiyonel olarak dışarıdan ürün listesi almak için

  const ProductListScreen({
    this.category,
    this.title,
    this.predefinedProductList,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _isGridView = true; // Başlangıçta grid görünümü
  String _sortOption = 'popular'; // Varsayılan sıralama

  // Filtreleme için saklanacak değerler (ana state'e taşınmalı veya bir state management çözümü kullanılmalı)
  RangeValues _appliedPriceRange = RangeValues(0, 1000);
  double _appliedMinRating = 0;
  // List<String> _appliedBrands = []; // Eğer marka filtresi eklenecekse

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    List<Product> allProducts;
    if (widget.predefinedProductList != null) {
      allProducts = List.from(
        widget.predefinedProductList!,
      ); // Dışarıdan gelen listeyi kullan
    } else if (widget.category != null) {
      allProducts = DummyData.getProductsByCategory(widget.category!.id);
    } else {
      // Kategori veya önceden tanımlanmış liste yoksa, başlığa göre veya tüm ürünleri yükle
      // Şimdilik tüm ürünleri yüklüyoruz, daha sonra başlığa göre özelleştirilebilir.
      allProducts = DummyData.products;
    }

    // Filtreleri uygula
    List<Product> filteredProducts =
        allProducts.where((product) {
          final priceInRange =
              product.price >= _appliedPriceRange.start &&
              product.price <= _appliedPriceRange.end;
          final ratingOk = product.rating >= _appliedMinRating;
          // Marka filtresi eklenecekse:
          // final brandOk = _appliedBrands.isEmpty || _appliedBrands.contains(product.brand);
          return priceInRange && ratingOk /* && brandOk */;
        }).toList();

    setState(() {
      _products = filteredProducts;
      _sortProducts(); // Filtrelenmiş ürünleri sırala
    });
  }

  void _sortProducts() {
    // _products listesi zaten filtrelenmiş olduğu için doğrudan setState içinde sıralama yapılabilir.
    // Ancak _loadProducts içinde zaten setState çağrıldığı için,
    // _sortProducts'u _loadProducts'tan sonra çağırmak ve sıralamayı _products üzerinde yapmak yeterli.
    // Bu fonksiyonun kendi setState'i olması, _products listesi zaten güncel olduğunda gereksiz rebuild yapabilir.
    // Yine de mevcut yapıyı koruyarak setState ekliyorum, ama optimize edilebilir.
    setState(() {
      switch (_sortOption) {
        case 'price_asc':
          _products.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          _products.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'rating':
          _products.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'newest':
          _products.sort(
            (a, b) => int.parse(
              b.id.substring(1),
            ).compareTo(int.parse(a.id.substring(1))),
          ); // ID'ye göre (p1, p2...)
          break;
        case 'popular': // Popülerlik (Örnek: Yorum sayısı * puan)
        default:
          _products.sort(
            (a, b) =>
                (b.reviewCount * b.rating).compareTo(a.reviewCount * a.rating),
          );
          break;
      }
    });
  }

  // Filtreleme Bottom Sheet (Tasarım)
  void _showFilterSheet(BuildContext context) {
    // Sheet açıldığında mevcut uygulanan filtreleri göstermesi için
    // state'den değerleri alıyoruz.
    RangeValues _currentPriceRange = _appliedPriceRange;
    double _currentMinRating = _appliedMinRating;
    // List<String> _currentSelectedBrands = List.from(_appliedBrands); // Marka filtresi için

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Tam ekran olabilir
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          // Sheet içindeki state için
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height:
                  MediaQuery.of(context).size.height * 0.75, // Yükseklik ayarı
              padding: const EdgeInsets.all(20.0),
              color: Colors.white, // Arka plan rengini beyaz olarak ayarla
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık ve Kapatma
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filtrele', style: AppTextStyles.h5),
                      IconButton(
                        icon: Icon(Icons.close, color: AppColors.darkGrey),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  Expanded(
                    // Kaydırılabilir içerik
                    child: ListView(
                      children: [
                        // Fiyat Aralığı
                        Text('Fiyat Aralığı', style: AppTextStyles.h6),
                        RangeSlider(
                          values: _currentPriceRange,
                          min: 0,
                          max: 2000, // Max fiyat (dummy data'ya göre ayarla)
                          divisions: 40, // Aralık sayısı
                          labels: RangeLabels(
                            '${_currentPriceRange.start.toStringAsFixed(0)}₺',
                            '${_currentPriceRange.end.toStringAsFixed(0)}₺',
                          ),
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.lightGrey,
                          onChanged: (values) {
                            setModalState(() => _currentPriceRange = values);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Puanlama Filtresi
                        Text('Minimum Puan', style: AppTextStyles.h6),
                        RatingBar.builder(
                          // Değiştirilebilir rating bar
                          initialRating: _currentMinRating,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder:
                              (context, _) =>
                                  Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            setModalState(() => _currentMinRating = rating);
                          },
                          itemSize: 30,
                        ),
                        const SizedBox(height: 24),

                        // Diğer filtreler (Renk, Beden vb.) eklenebilir
                      ],
                    ),
                  ),

                  // Uygula ve Temizle Butonları
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Sheet içindeki filtreleri temizle
                            setModalState(() {
                              _currentPriceRange = RangeValues(
                                0,
                                1000,
                              ); // Varsayılan
                              _currentMinRating = 0;
                              // _currentSelectedBrands = [];
                            });
                            // Ana state'deki filtreleri de temizle ve ürünleri yeniden yükle
                            setState(() {
                              _appliedPriceRange = RangeValues(0, 1000);
                              _appliedMinRating = 0;
                              // _appliedBrands = [];
                              _loadProducts(); // Filtreler temizlendiği için ürün listesini güncelle
                            });
                            Navigator.pop(ctx); // Sheet'i kapat
                          },
                          child: Text('Temizle'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(color: AppColors.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Filtreleri Uygula
                            setState(() {
                              _appliedPriceRange = _currentPriceRange;
                              _appliedMinRating = _currentMinRating;
                              // _appliedBrands = List.from(_currentSelectedBrands);
                              _loadProducts(); // Yeni filtrelere göre ürünleri yükle
                            });
                            Navigator.pop(ctx);
                          },
                          child: Text(
                            'Filtrele (${_calculateActiveFilters(_currentPriceRange, _currentMinRating, [])})', // _currentSelectedBrands
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Aktif filtre sayısını hesapla (yardımcı fonksiyon)
  int _calculateActiveFilters(
    RangeValues priceRange,
    double minRating,
    List<String> brands, // Eğer marka filtresi eklenirse kullanılacak
  ) {
    int count = 0;
    // Varsayılan değerlerden farklıysa filtre aktif sayılır
    if (priceRange.start > 0 || priceRange.end < 2000) {
      // max değeri RangeSlider'daki max ile aynı olmalı
      // Veya daha genel bir varsayılan aralık kontrolü:
      // if (priceRange.start != 0 || priceRange.end != 1000) // Eğer başlangıç varsayılanı (0,1000) ise
      count++;
    }
    if (minRating > 0) count++;
    if (brands.isNotEmpty) count++;
    // Diğer filtreler...
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle = widget.title ?? widget.category?.name ?? 'Ürünler';
    return Scaffold(
      appBar: CustomAppBar(
        title: screenTitle, // Dinamik başlık
        showBackButton:
            true, // Keep showBackButton, or adjust as per new logic. Assuming it should be kept or handled by CustomAppBar's default.
        // showSearchButton: false, // This was in the intended replace, but CustomAppBar might not have it or it's handled differently.
        // The original had showBackButton: true. The replace block for CustomAppBar needs to be consistent.
        // For now, let's assume the primary change is the title and the actions array remains structurally similar.
        // If showSearchButton is a new prop for CustomAppBar, it should be added. If it replaces showBackButton, that's a different change.
        // The provided replace block had `showSearchButton: false`, let's use that if it's the intended change for CustomAppBar's props.
        // However, the original CustomAppBar call had `showBackButton: true`. The prompt's replace block for this section has `showSearchButton: false`.
        // Let's stick to the provided replace block's intention for CustomAppBar arguments, assuming CustomAppBar is also updated.
        // The key is that the *search* block was wrong. The *replace* block dictates the new state.
        // The original search block had `showSearchButton: false` which was a mistake. The original *content* had `showBackButton: true`.
        // The *replace* block for this section has `showSearchButton: false`. This implies CustomAppBar is expected to handle `showSearchButton`.
        // The original `actions` are preserved in the replace block by just opening the array `actions: [`.
        actions: [],
      ),
      body: Column(
        children: [
          // Sıralama ve Filtreleme Çubuğu
          Padding(
            // Bu Padding widget'ı Sıralama ve Filtreleme Çubuğu için
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: AppColors.lightGrey.withOpacity(0.5),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sıralama Dropdown
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortOption,
                      icon: Icon(
                        Icons.sort_rounded,
                        size: 22,
                        color: AppColors.textSecondary,
                      ),
                      elevation: 0,
                      style: AppTextStyles.bodyM.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      items: const [
                        DropdownMenuItem(
                          value: 'popular',
                          child: Text('Popülerlik'),
                        ),
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text('En Yeniler'),
                        ),
                        DropdownMenuItem(
                          value: 'price_asc',
                          child: Text('Fiyat (Artan)'),
                        ),
                        DropdownMenuItem(
                          value: 'price_desc',
                          child: Text('Fiyat (Azalan)'),
                        ),
                        DropdownMenuItem(
                          value: 'rating',
                          child: Text('Yüksek Puan'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sortOption = value;
                            _sortProducts(); // Sıralamayı uygula
                          });
                        }
                      },
                    ),
                  ),

                  // Filtreleme Butonu
                  ElevatedButton.icon(
                    onPressed: () => _showFilterSheet(context),
                    icon: Icon(Icons.filter_alt_outlined, size: 18),
                    label: Text(
                      'Filtrele (${_calculateActiveFilters(_appliedPriceRange, _appliedMinRating, [])})', //_appliedBrands
                      style: AppTextStyles.bodyS.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ), // <<<< DÜZELTİLDİ: Padding widget'ı burada kapanıyor.

          const SizedBox(
            height: 8,
          ), // Sıralama çubuğu ile liste arasına (Artık Column'un doğrudan bir çocuğu)
          // Ürün Listesi (Grid veya Liste)
          Expanded(
            // (Artık Column'un doğrudan bir çocuğu)
            child:
                _products.isEmpty
                    ? Center(
                      child: Text(
                        'Bu kategoride filtrelerinize uygun ürün bulunamadı.',
                        style: AppTextStyles.bodyL,
                        textAlign: TextAlign.center,
                      ),
                    )
                    : _isGridView
                    ? GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _products.length,
                      itemBuilder:
                          (ctx, index) => ProductCard(
                            product: _products[index],
                            showAddToCartButton: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailScreen(
                                        product: _products[index],
                                      ),
                                ),
                              );
                            },
                          ),
                    )
                    : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      itemCount: _products.length,
                      itemBuilder:
                          (ctx, index) => ProductCard(
                            product: _products[index],
                            showAddToCartButton: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailScreen(
                                        product: _products[index],
                                      ),
                                ),
                              );
                            },
                          ),
                    ),
          ),
        ],
      ),
    );
  }
}
