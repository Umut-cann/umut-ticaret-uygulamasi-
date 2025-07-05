import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umut_ticaret/models/product.dart';
import 'package:umut_ticaret/providers/ui_state_provider.dart';
import 'package:umut_ticaret/screens/products/product_detail_screen.dart';

import '../../constants/app_colors.dart';

/// Performance-optimized banner carousel that uses AnimatedBuilder and FadeTransition
/// instead of heavy animations to improve performance
class PromoBannerCarousel extends StatefulWidget {
  final List<Product> products;
  const PromoBannerCarousel({super.key, required this.products});

  List<Product> get _limitedProducts => products.take(5).toList();

  String _getSpecialTag(int index) {
    final tags = [
      'Haftanın En Çok Satanı',
      'Yeni Ürün',
      'Son Fırsat',
      'Sınırlı Stok',
      'Trend Ürün',
    ];
    return tags[index % tags.length];
  }

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  final CarouselController _controller = CarouselController();

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'Haftanın En Çok Satanı':
        return Color(0xFF9C27B0); // Mor
      case 'Yeni Ürün':
        return Color(0xFF4CAF50); // Yeşil
      case 'Son Fırsat':
        return Color(0xFFF44336); // Kırmızı
      case 'Sınırlı Stok':
        return Color(0xFFFF9800); // Turuncu
      case 'Trend Ürün':
        return Color(0xFF2196F3); // Mavi
      default:
        return AppColors.primary;
    }
  }

  IconData _getTagIcon(String tag) {
    switch (tag) {
      case 'Haftanın En Çok Satanı':
        return Icons.local_fire_department_outlined;
      case 'Yeni Ürün':
        return Icons.new_releases_outlined;
      case 'Son Fırsat':
        return Icons.timer_outlined;
      case 'Sınırlı Stok':
        return Icons.inventory_2_outlined;
      case 'Trend Ürün':
        return Icons.trending_up_outlined;
      default:
        return Icons.star_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bannerHeight = screenWidth * (screenWidth > 600 ? 0.33 : 0.42);

    return Column(
      children: [
        CarouselSlider(
          items: List.generate(
            widget._limitedProducts.length,
            (index) => _OptimizedBannerItem(
              product: widget._limitedProducts[index],
              specialTag: widget._getSpecialTag(index),
              tagColor: _getTagColor(widget._getSpecialTag(index)),
              tagIcon: _getTagIcon(widget._getSpecialTag(index)),
              bannerHeight: bannerHeight,
              screenWidth: screenWidth,
              index: index,
            ),
          ),
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            enlargeFactor: 0.22,
            aspectRatio: 21 / 9,
            viewportFraction: 0.8,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeOutQuint,
            pauseAutoPlayOnTouch: true,
            onPageChanged: (index, reason) {
              Provider.of<UIStateProvider>(context, listen: false)
                  .setBannerIndex(index);
            },
          ),
        ),
        const SizedBox(height: 12),
        _OptimizedIndicator(productCount: widget._limitedProducts.length),
      ],
    );
  }
}

/// Optimized indicator dots using AnimatedBuilder for better performance
class _OptimizedIndicator extends StatelessWidget {
  final int productCount;
  
  const _OptimizedIndicator({required this.productCount});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<UIStateProvider>(
      builder: (context, uiProvider, _) {
        return AnimatedBuilder(
          animation: uiProvider,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                productCount,
                (index) {
                  bool isActive = uiProvider.currentBannerIndex == index;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.fastOutSlowIn,
                      width: isActive ? 32.0 : 10.0,
                      height: 10.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(isActive ? 6.0 : 5.0),
                        gradient: isActive
                            ? LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.accent,
                                ],
                              )
                            : null,
                        color: isActive ? null : Colors.grey.withOpacity(0.25),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// Optimized banner item that uses AnimatedBuilder and FadeTransition
class _OptimizedBannerItem extends StatefulWidget {
  final Product product;
  final String specialTag;
  final Color tagColor;
  final IconData tagIcon;
  final double bannerHeight;
  final double screenWidth;
  final int index;

  const _OptimizedBannerItem({
    required this.product,
    required this.specialTag,
    required this.tagColor,
    required this.tagIcon,
    required this.bannerHeight,
    required this.screenWidth,
    required this.index,
  });

  @override
  State<_OptimizedBannerItem> createState() => _OptimizedBannerItemState();
}

class _OptimizedBannerItemState extends State<_OptimizedBannerItem> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isImageLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    // Pre-load image
    precacheImage(
      CachedNetworkImageProvider(
        widget.product.images.first,
        cacheKey: 'banner_${widget.product.id}',
      ),
      context,
    ).then((_) {
      if (mounted) {
        setState(() {
          _isImageLoaded = true;
        });
        _fadeController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<UIStateProvider>(
      builder: (context, uiProvider, _) {
        // Use AnimatedBuilder for rotation effect
        return AnimatedBuilder(
          animation: uiProvider,
          builder: (context, child) {
            final double rotationY = uiProvider.currentBannerIndex == widget.index
                ? 0.0
                : widget.index > uiProvider.currentBannerIndex
                    ? 0.05
                    : -0.05;
                    
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0008)
                ..rotateY(rotationY),
              alignment: Alignment.center,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    product: widget.product,
                    heroTagPrefix: 'banner_${widget.product.id}',
                  ),
                ),
              );
            },
            child: Container(
              width: widget.screenWidth,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: Stack(
                  children: [
                    // Image with FadeTransition for smooth appearance
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Stack(
                        children: [
                          // Main image
                          CachedNetworkImage(
                            imageUrl: widget.product.images.first,
                            height: widget.bannerHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            fadeInDuration: Duration.zero, // No animation for performance
                            fadeOutDuration: Duration.zero,
                            memCacheWidth: (widget.screenWidth * 2).toInt(),
                            memCacheHeight: (widget.bannerHeight * 2).toInt(),
                            placeholder: (context, url) => Container(
                              color: AppColors.lightGrey.withOpacity(0.5),
                              height: widget.bannerHeight,
                              width: double.infinity,
                              child: Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: AppColors.primary.withOpacity(0.3),
                                  size: 40,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.lightGrey.withOpacity(0.3),
                              height: widget.bannerHeight,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.signal_wifi_off_outlined,
                                    color: AppColors.mediumGrey,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Bağlantı Hatası",
                                    style: TextStyle(
                                      color: AppColors.mediumGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Gradient overlay - static, not animated
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.center,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                                  stops: const [0.6, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bottom info panel
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.product.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${widget.product.price.toStringAsFixed(2)} ₺',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Şimdi Al',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Tag badge
                    Positioned(
                      top: 16,
                      left: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.tagColor.withOpacity(0.8),
                                  widget.tagColor.withOpacity(0.6),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.tagColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.tagIcon,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.specialTag,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Discount badge
                    if (widget.product.discountPercentage != null)
                      Positioned(
                        top: 80, // Positioned below the tag badge
                        left: 16,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '%${widget.product.discountPercentage!.toStringAsFixed(0)} İndirim',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    
                    // Stock info badge
                    if (widget.product.stock < 10)
                      Positioned(
                        top: widget.product.discountPercentage != null ? 125 : 80,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Son ${widget.product.stock} Ürün',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
