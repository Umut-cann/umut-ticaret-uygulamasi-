import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:umut_ticaret/models/product.dart';
import 'package:umut_ticaret/providers/ui_state_provider.dart';
import 'package:umut_ticaret/screens/products/product_detail_screen.dart';

import '../../constants/app_colors.dart';

/// Performance-optimized banner carousel with no animations
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
  final CarouselController _carouselController = CarouselController();

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'Haftanın En Çok Satanı':
        return const Color(0xFF9C27B0); // Mor
      case 'Yeni Ürün':
        return const Color(0xFF4CAF50); // Yeşil
      case 'Son Fırsat':
        return const Color(0xFFF44336); // Kırmızı
      case 'Sınırlı Stok':
        return const Color(0xFFFF9800); // Turuncu
      case 'Trend Ürün':
        return const Color(0xFF2196F3); // Mavi
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
            (index) => _buildBannerItem(
              widget._limitedProducts[index],
              widget._getSpecialTag(index),
              _getTagColor(widget._getSpecialTag(index)),
              _getTagIcon(widget._getSpecialTag(index)),
              bannerHeight,
              screenWidth,
            ),
          ),
          options: CarouselOptions(
            height: bannerHeight,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            autoPlayInterval: const Duration(seconds: 5),
            pauseAutoPlayOnTouch: true,
            onPageChanged: (index, reason) {
              Provider.of<UIStateProvider>(context, listen: false)
                  .setBannerIndex(index);
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildIndicator(widget._limitedProducts.length),
      ],
    );
  }

  /// Build indicator dots without animations
  Widget _buildIndicator(int count) {
    return Consumer<UIStateProvider>(
      builder: (context, uiProvider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            count,
            (index) {
              bool isActive = uiProvider.currentBannerIndex == index;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Container(
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
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Build banner item without animations
  Widget _buildBannerItem(
    Product product,
    String specialTag,
    Color tagColor,
    IconData tagIcon,
    double bannerHeight,
    double screenWidth,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
              // No hero tag for better performance
            ),
          ),
        );
      },
      child: Container(
        width: screenWidth,
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
              // Optimized image with no animations
              _buildOptimizedImage(product.images.first, bannerHeight),
              
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
                            product.name,
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
                                '${product.price.toStringAsFixed(2)} ₺',
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
                            tagColor.withOpacity(0.8),
                            tagColor.withOpacity(0.6),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: tagColor.withOpacity(0.3),
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
                            tagIcon,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            specialTag,
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
              if (product.discountPercentage != null)
                Positioned(
                  top: 80,
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
                      '%${product.discountPercentage!.toStringAsFixed(0)} İndirim',
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
              if (product.stock < 10)
                Positioned(
                  top: product.discountPercentage != null ? 125 : 80,
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
                      'Son ${product.stock} Ürün',
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
    );
  }

  /// Build optimized image without animations
  Widget _buildOptimizedImage(String imageUrl, double height) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          // Disable animations for performance
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          // Performance optimizations
          memCacheWidth: (MediaQuery.of(context).size.width * 2).toInt(),
          memCacheHeight: (height * 2).toInt(),
          // Static placeholders instead of animated ones
          placeholder: (context, url) => Container(
            color: AppColors.lightGrey.withOpacity(0.5),
            height: height,
            width: double.infinity,
            child: Center(
              child: Icon(
                Icons.image_outlined,
                color: AppColors.mediumGrey,
                size: 40,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.lightGrey.withOpacity(0.3),
            height: height,
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
        
        // Gradient overlay
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
    );
  }
}
