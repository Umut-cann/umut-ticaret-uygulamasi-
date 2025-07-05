/*import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';

/// Performance-optimized product card with no animations
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final double? width;
  final bool showAddToCartButton;
  final String heroTagPrefix;
  final Function(BuildContext, Product)? onAddToCart;

  const ProductCard({
    required this.product,
    required this.onTap,
    this.width,
    this.showAddToCartButton = false,
    this.heroTagPrefix = '',
    this.onAddToCart,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive font sizes based on screen width
    const double baseProductNameFontSize = 13.0;
    const double basePriceFontSize = 14.0;
    const double standardScreenWidth = 360.0;

    double responsiveProductNameFontSize =
        baseProductNameFontSize * (screenWidth / standardScreenWidth);
    responsiveProductNameFontSize = responsiveProductNameFontSize.clamp(10.0, 15.0);

    double responsivePriceFontSize =
        basePriceFontSize * (screenWidth / standardScreenWidth);
    responsivePriceFontSize = responsivePriceFontSize.clamp(12.0, 16.0);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8),
        elevation: 1.0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  // Product image without animations
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        // No fade animations
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        // Performance optimizations
                        memCacheWidth: 300,
                        memCacheHeight: 300,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Static placeholder
                        placeholder: (context, url) => Container(
                          color: AppColors.lightGrey.withOpacity(0.5),
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                        ),
                        // Static error widget
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.lightGrey.withOpacity(0.5),
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.darkGrey,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Discount badge - only shown if product has a discount
                  if (product.oldPrice != null)
                    Positioned(
                      top: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '%${(((product.oldPrice! - product.price) / product.oldPrice!) * 100).toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                    
                  // Favorite button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Consumer<FavoritesProvider>(
                      builder: (context, favoritesProvider, child) {
                        final isFavorite = favoritesProvider.isFavorite(product);
                        return GestureDetector(
                          onTap: () => favoritesProvider.toggleFavorite(product),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                              color: isFavorite
                                  ? AppColors.error
                                  : AppColors.darkGrey.withOpacity(0.7),
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Add to cart button - only shown if product is in stock
                  if (product.stockStatus != 'out_of_stock' && showAddToCartButton)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          if (onAddToCart != null) {
                            onAddToCart!(context, product);
                          } else {
                            cartProvider.addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} sepete eklendi'),
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'Tamam',
                                  onPressed: () {},
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                            ),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 6),
              
              // Special tag if available
              if (product.specialTag != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.specialTag!,
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveProductNameFontSize - 3,
                      ),
                    ),
                  ),
                ),
              
              // Product name
              Flexible(
                flex: 2,
                child: Text(
                  product.name.isNotEmpty ? product.name : "Ürün Adı",
                  style: TextStyle(
                    fontSize: responsiveProductNameFontSize,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Brand
              if (product.brand != null)
                Text(
                  product.brand!,
                  style: TextStyle(
                    fontSize: responsiveProductNameFontSize - 2,
                    color: AppColors.darkGrey.withOpacity(0.8),
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
              const SizedBox(height: 4),
              
              // Rating
              Row(
                children: [
                  // Static star icons instead of animated rating bar
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < product.rating.floor() 
                            ? Icons.star_rounded 
                            : (index < product.rating 
                                ? Icons.star_half_rounded 
                                : Icons.star_border_rounded),
                        color: Colors.amber[600],
                        size: 14,
                      );
                    }),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${product.reviewCount})',
                    style: TextStyle(
                      fontSize: responsiveProductNameFontSize - 3,
                      color: AppColors.darkGrey.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 6),
              
              // Price and cart
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Old price if on sale
                        if (product.oldPrice != null)
                          Text(
                            '${product.oldPrice!.toStringAsFixed(2)} TL',
                            style: TextStyle(
                              fontSize: responsiveProductNameFontSize - 1,
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.darkGrey.withOpacity(0.7),
                            ),
                          ),
                        // Current price
                        Text(
                          '${product.price.toStringAsFixed(2)} TL',
                          style: TextStyle(
                            fontSize: responsivePriceFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/