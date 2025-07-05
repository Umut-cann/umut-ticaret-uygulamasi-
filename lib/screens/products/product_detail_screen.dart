import 'dart:math';
import 'dart:ui'; // Gerekirse ImageFilter için (blur vb.)

// import 'package:badges/badges.dart' as badges; // Artık kullanılmıyor
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:umut_ticaret/providers/favorites_provider.dart';

// Örnek importlar - kendi projenize göre güncelleyin
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../data/dummy_data.dart'; // Varsa
import '../../models/product.dart';
import '../../providers/cart_provider.dart'; // CartProvider hala SnackBar için gerekli olabilir
import '../../providers/navigation_provider.dart';
import '../../utils/helpers.dart'; // Varsa
import '../../widgets/common/full_screen_image_viewer.dart'; // Varsa
import '../../widgets/products/color_selector.dart'; // Varsa
import '../../widgets/products/product_card.dart'; // Varsa
import '../../widgets/products/size_selector.dart'; // Varsa

// _buildCircularIcon helper fonksiyonu kaldırıldı

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String heroTagPrefix;

  const ProductDetailScreen({
    required this.product,
    this.heroTagPrefix = '',
    super.key,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  String? _selectedColor;
  String? _selectedSize;
  int _quantity = 1;

  final CarouselController _imageCarouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    if (widget.product.availableColors?.isNotEmpty ?? false) {
      _selectedColor = widget.product.availableColors!.first;
    }
    if (widget.product.availableSizes?.isNotEmpty ?? false) {
      _selectedSize = widget.product.availableSizes!.first;
    }
  }

  void _showGroupBuySheet(BuildContext context) {
    // ... (BottomSheet kodu aynı kalır)
     showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text('Arkadaşlarınla Birlikte Al!', style: AppTextStyles.h5),
              const SizedBox(height: 8),
              Text(
                'Bu ürünü arkadaşlarınla birlikte alarak %15\'e varan indirim kazanabilirsiniz. Davet etmek istediğin arkadaşlarını seç veya bağlantıyı paylaş.',
                style: AppTextStyles.bodyM,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Arkadaş ara veya e-posta gir',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(8),
                     borderSide: BorderSide(color: AppColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 100,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGrey),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.lightGrey.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    '[Seçilen Arkadaş Listesi Burada Gösterilecek]',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bağlantı kopyalandı (Simülasyon)')),
                        );
                      },
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Bağlantıyı Paylaş', overflow: TextOverflow.ellipsis),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: BorderSide(color: AppColors.accent),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Davet gönderildi (Simülasyon)')),
                        );
                      },
                      icon: const Icon(Icons.group_add_outlined, size: 18),
                      label: const Text('Davet Et', overflow: TextOverflow.ellipsis),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
  }

  Widget _buildArTryOnButton() {
     // ... (AR Buton kodu aynı kalır)
     if (widget.product.categoryId == 'c1' ||
        widget.product.categoryId == 'c2' ||
        widget.product.categoryId == 'c10')
    {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
        child: OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('AR Deneme özelliği şu an geliştirilmektedir.'),
                backgroundColor: AppColors.accent,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.camera_outlined, size: 20),
          label: const Text('AR ile Dene'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.accent),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // *** HERO HATASI ÇÖZÜMÜ: Benzer ürünleri alırken mevcut ürünü filtrele ***
    final allSimilarRaw = DummyData.getSimilarProducts(
      widget.product.id,
      widget.product.categoryId,
    );
    final similarProducts = allSimilarRaw
        .where((p) => p.id != widget.product.id) // Mevcut ürünü çıkar
        .toList();
    // *** Çözüm Sonu ***

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaPadding = MediaQuery.of(context).padding;
    final double imageGalleryHeight = screenWidth;
    const double badgeTopOffset = 55.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // --- Kaydırılabilir İçerik Bölümü ---
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Ürün Resim Galerisi
                SizedBox(
                  height: imageGalleryHeight,
                  child: Hero(
                    // Ana resmin tag'i (prefix + product_image_ + id)
                    tag: '${widget.heroTagPrefix}product_image_${widget.product.id}',
                    child: CarouselSlider(
                      items: widget.product.images.map((imgUrl) {
                        return Builder(
                          builder: (BuildContext context) {
                            final imageIndex = widget.product.images.indexOf(imgUrl);
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenImageViewer(
                                      imageUrls: widget.product.images,
                                      initialIndex: imageIndex,
                                    ),
                                    fullscreenDialog: true,
                                  ),
                                );
                              },
                              child: CachedNetworkImage(
                                imageUrl: imgUrl,
                                fit: BoxFit.cover,
                                width: screenWidth,
                                fadeInDuration: const Duration(milliseconds: 300),
                                fadeOutDuration: const Duration(milliseconds: 300),
                                // Use proper cache dimensions based on device screen
                                memCacheWidth: (screenWidth * 2).toInt(), // 2x for high resolution displays
                                memCacheHeight: ((screenWidth * 1.2) * 2).toInt(), // Approximate height based on width
                                // Use imageBuilder instead of direct rendering
                                imageBuilder: (context, imageProvider) => Container(
                                  width: screenWidth,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => Container(
                                  color: AppColors.lightGrey.withOpacity(0.5),
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.lightGrey.withOpacity(0.3),
                                  child: const Center(
                                    child: Icon(Icons.broken_image_outlined, color: AppColors.darkGrey, size: 40),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                   //   carouselController: _imageCarouselController,
                      options: CarouselOptions(
                        height: imageGalleryHeight,
                        viewportFraction: 1.0,
                        initialPage: 0,
                        enableInfiniteScroll: widget.product.images.length > 1,
                        autoPlay: false,
                        onPageChanged: (index, reason) => setState(() => _currentImageIndex = index),
                      ),
                    ),
                  ),
                ),

                // Resim Gösterge Noktaları (Container İçinde)
                if (widget.product.images.length > 1)
                  Container(
                    color: AppColors.lightGrey.withOpacity(0.15),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: widget.product.images.asMap().entries.map((entry) {
                        return GestureDetector(
                     //     onTap: () => _imageCarouselController.animateToPage(entry.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _currentImageIndex == entry.key ? 24.0 : 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(_currentImageIndex == entry.key ? 4 : 10),
                              color: AppColors.primary.withOpacity(
                                _currentImageIndex == entry.key ? 0.9 : 0.4,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // 2. Ürün Detayları ve Seçenekler
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       // ... (İçerik - Fiyat, Puan, Renk, Beden, Adet, Açıklama vb. aynı kalır)
                        const SizedBox(height: 16),
                      Text(widget.product.name, style: AppTextStyles.h4),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.product.oldPrice != null)
                                Text(
                                  Helpers.formatCurrency(widget.product.oldPrice!),
                                  style: AppTextStyles.bodyL.copyWith(
                                    color: AppColors.textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                Helpers.formatCurrency(widget.product.price),
                                style: AppTextStyles.h3.copyWith(
                                  color: widget.product.oldPrice != null ? AppColors.error : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Yorumlar bölümüne git (Simülasyon)')),
                               );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                              child: Row(
                                children: [
                                  RatingBarIndicator(
                                    rating: widget.product.rating,
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star_rate_rounded, color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 20.0,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '(${widget.product.reviewCount})',
                                    style: AppTextStyles.bodyM.copyWith(color: AppColors.darkGrey),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios, size: 12, color: AppColors.darkGrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (widget.product.availableColors != null && widget.product.availableColors!.isNotEmpty) ...[
                        Text('Renk:', style: AppTextStyles.h6),
                        const SizedBox(height: 8),
                        ColorSelector(
                          colors: widget.product.availableColors!,
                          selectedColor: _selectedColor,
                          onColorSelected: (c) => setState(() => _selectedColor = c),
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (widget.product.availableSizes != null && widget.product.availableSizes!.isNotEmpty) ...[
                        Text('Beden:', style: AppTextStyles.h6),
                        const SizedBox(height: 8),
                        SizeSelector(
                          sizes: widget.product.availableSizes!,
                          selectedSize: _selectedSize,
                          onSizeSelected: (s) => setState(() => _selectedSize = s),
                        ),
                        const SizedBox(height: 20),
                      ],

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Adet:', style: AppTextStyles.h6),
                          Row(
                            children: [
                              _buildQuantityButton(
                                icon: Icons.remove,
                                enabled: _quantity > 1,
                                onPressed: () => setState(() { if (_quantity > 1) _quantity--; }),
                              ),
                              SizedBox(
                                width: 40,
                                child: Center(
                                  child: Text('$_quantity', style: AppTextStyles.h5),
                                ),
                              ),
                              _buildQuantityButton(
                                icon: Icons.add,
                                onPressed: () => setState(() => _quantity++),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildExpandableSection(
                        title: 'Ürün Açıklaması',
                        content: widget.product.description,
                        initiallyExpanded: true,
                      ),
                      const Divider(height: 1, thickness: 0.5),
                      _buildExpandableSection(
                        title: 'Yorumlar (${widget.product.reviewCount})',
                        contentWidget: _buildReviewsPlaceholder(),
                      ),
                 
                      
                      
                      
                      const SizedBox(height: 10),

                      _buildArTryOnButton(),

        
                      const SizedBox(height: 12),

                      if (widget.product.hasSubscriptionOption) ...[
                        OutlinedButton.icon(
                          onPressed: () {
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('Abonelik ekranı açılıyor (Simülasyon)')),
                             );
                          },
                          icon: const Icon(Icons.autorenew_outlined, size: 20),
                          label: const Text('Abonelikle Daha Ucuza Al'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.success,
                            side: BorderSide(color: AppColors.success),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      Text('Bunları da Beğenebilirsiniz', style: AppTextStyles.h5),
                      const SizedBox(height: 12),
                       // Filtrelenmiş liste burada kullanılır
                      _buildHorizontalProductList(similarProducts),
                      SizedBox(height: safeAreaPadding.bottom > 0 ? 10 : 20),
                    ],
                  ),
                ),
              ],
            ),
          ), // End SingleChildScrollView

          // --- Konumlandırılmış Üst Katman Elemanları ---

          // Geri Butonu (Sol Üst - Yeni Yapı)
          Positioned(
            top: safeAreaPadding.top + 8.0,
            left: 12.0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Tooltip(
                message: 'Geri',
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 3),), ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon( Icons.arrow_back_ios_new, color: AppColors.darkGrey, size: 20, ),
                ),
              ),
            ),
          ),

          // Aksiyon İkonları (Sağ Üst - Yeni Yapı)
          Positioned(
            top: safeAreaPadding.top + 8.0,
            right: 12.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Paylaş İkonu (Yeni Yapı)
                GestureDetector(
                  onTap: () { /* Paylaşma işlemi */ },
                  child: Tooltip(
                     message: 'Paylaş',
                     child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle,
                        boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 3), ), ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon( Icons.share_outlined, color: AppColors.darkGrey, size: 20, ),
                     ),
                  ),
                ),
                const SizedBox(width: 8),
                // Favori İkonu (Yeni Yapı & Consumer)
                Consumer<FavoritesProvider>(
                  builder: (context, favoritesProvider, child) {
                    final isFavorite = favoritesProvider.isFavorite(widget.product);
                    return GestureDetector(
                      onTap: () { favoritesProvider.toggleFavorite(widget.product); /* SnackBar? */ },
                      child: Tooltip(
                          message: isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                          child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle,
                            boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 3), ), ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? AppColors.error : AppColors.darkGrey,
                            size: 20,
                          ),
                         ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // NFT Rozeti
    
          // İndirim Rozeti
          if (widget.product.discountPercentage != null)
            Positioned(
              top: safeAreaPadding.top + 8.0 + badgeTopOffset,
              left: 12.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error, borderRadius: BorderRadius.circular(6),
                  boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: Offset(0,1)) ]
                ),
                child: Text(
                  '%${widget.product.discountPercentage!.toStringAsFixed(0)} İndirim',
                  style: AppTextStyles.caption.copyWith( color: Colors.white, fontWeight: FontWeight.bold, ),
                ),
              ),
            ),

        ], // End Main Stack Children
      ),
      bottomNavigationBar: _buildBottomAddToCartBar(context, cartProvider),
    );
  }

  // --- Helper Widgets ---

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    // ... (Aynı kalır)
     return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? AppColors.darkGrey : AppColors.lightGrey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? Colors.transparent : AppColors.lightGrey.withOpacity(0.3),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primary : AppColors.darkGrey.withOpacity(0.5),
        ),
      ),
    );
  }

 /* Widget _buildNftBadge() {
    // ... (Aynı kalır)
     return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.purpleAccent, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_outlined, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              'NFT',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
*/
  Widget _buildHorizontalProductList(List<Product> products) {
     // ... (Aynı kalır - Filtrelenmiş liste kullanılır)
       if (products.isEmpty) return const SizedBox.shrink();
    const double cardHeight = 270;
    const double cardWidth = 160;

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: products.length,
        itemBuilder: (ctx, index) => Padding(
          padding: EdgeInsets.only(right: index == products.length - 1 ? 0 : 12.0),
          child: ProductCard( // ProductCard'ın kendi Hero tag'i olmalı (örn: product_image_id)
            product: products[index],
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    product: products[index],
                    // Detay sayfasına giderken farklı prefix verilir
                    heroTagPrefix: 'similar_detail_', // 'similar_' yerine daha belirgin
                  ),
                ),
              );
            },
            width: cardWidth,
            showAddToCartButton: false,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAddToCartBar(BuildContext context, CartProvider cartProvider) {
     // ... (Aynı kalır)
      final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 10.0,
        bottom: safeAreaBottom + 10.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(top: BorderSide(color: AppColors.lightGrey.withOpacity(0.5), width: 1.0)),
      ),
      child: ElevatedButton(
        onPressed: () {
          bool requiresColor = widget.product.availableColors?.isNotEmpty ?? false;
          bool requiresSize = widget.product.availableSizes?.isNotEmpty ?? false;
          String? missingSelection;

          if (requiresColor && _selectedColor == null) {
            missingSelection = 'renk';
          } else if (requiresSize && _selectedSize == null) {
            missingSelection = 'beden';
          }

          if (missingSelection != null) {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                content: Text('Lütfen bir $missingSelection seçin!'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }

          try {
              for (int i = 0; i < _quantity; i++) {
                cartProvider.addItem( widget.product, /* Pass variations if needed */ );
              }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${_quantity} adet ${widget.product.name} sepete eklendi!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  bottom: (safeAreaBottom + 60 + 20),
                  left: 15,
                  right: 15,
                ),
                action: SnackBarAction(
                  label: 'Sepete Git',
                  textColor: Colors.white,
                  onPressed: () {
                    Provider.of<NavigationProvider>(context, listen: false).setIndex(2);
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ),
            );
           } catch (error) {
               ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sepete eklenirken bir hata oluştu: $error'),
                    backgroundColor: AppColors.error,
                 ),
               );
           }
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: const Text('Sepete Ekle'),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    String? content,
    Widget? contentWidget,
    bool initiallyExpanded = false,
  }) {
     // ... (Aynı kalır)
      return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(title, style: AppTextStyles.h6),
        childrenPadding: const EdgeInsets.only(bottom: 16.0, top: 0, left: 8.0, right: 8.0),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.darkGrey,
        initiallyExpanded: initiallyExpanded,
        children: <Widget>[
          Align(
             alignment: Alignment.centerLeft,
             child: contentWidget ??
               (content != null
                   ? Text(content, style: AppTextStyles.bodyM.copyWith(height: 1.5))
                   : const SizedBox.shrink()),
          )
        ],
      ),
    );
  }

  Widget _buildReviewsPlaceholder() {
    // ... (Aynı kalır)
     int reviewCount = widget.product.reviewCount;
    int reviewCountToShow = min(reviewCount, 3);

    if (reviewCount == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
        child: Text('Henüz yorum yapılmamış. İlk yorumu sen yap!',
           style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(reviewCountToShow, (index) {
           double rating = max(1.0, min(5.0, 4.8 - (index * 0.6) - Random().nextDouble() * 0.5));
           String comment = index == 0
                      ? 'Harika bir ürün, kalitesi beklentimin üzerinde. Kesinlikle tavsiye ederim.'
                      : index == 1
                      ? 'Fiyat/performans olarak çok başarılı. Kargo da oldukça hızlıydı, teşekkürler!'
                      : 'Rengi fotoğraftakinden bir tık daha soluk geldi ama yine de çok beğendim. Kullanışlı.';
           DateTime date = DateTime.now().subtract(Duration(days: index * 7 + Random().nextInt(15) + 3));

           return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kullanıcı ${Random().nextInt(9000) + 1000}',
                        style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                      ),
                      RatingBarIndicator(
                        rating: rating,
                        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 16.0,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment, style: AppTextStyles.bodyS.copyWith(height: 1.4)),
                  const SizedBox(height: 6),
                  Text(Helpers.formatDate(date), style: AppTextStyles.caption),
                ],
              ),
            );
         }),
        if (reviewCount > reviewCountToShow)
          Center(
            child: TextButton(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tüm yorumlar ekranı (Simülasyon)')),
                 );
              },
              child: Text(
                'Tüm ${widget.product.reviewCount} Yorumu Gör',
                style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSustainabilityInfo() {
     // ... (Aynı kalır)
       return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.product.sustainabilityScore != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.eco_outlined, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Çevre Dostu Skor: ',
                  style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                ),
                Chip(
                  label: Text(
                    '${(widget.product.sustainabilityScore! * 100).toStringAsFixed(0)}/100 ${widget.product.sustainabilityScore! > 0.7 ? '(Yüksek)' : widget.product.sustainabilityScore! > 0.4 ? '(Orta)' : '(Düşük)'}',
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColors.success.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide.none,
                ),
              ],
            ),
          ),
        if (widget.product.carbonFootprint != null)
          Row(
             crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.public_outlined, color: AppColors.darkGrey, size: 20),
              const SizedBox(width: 8),
              Text(
                'Karbon Ayak İzi: ',
                style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(widget.product.carbonFootprint!, style: AppTextStyles.bodyM),
            ],
          ),
      ],
    );
  }
}