import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../data/dummy_data.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../providers/home_provider.dart';
import '../../widgets/home/category_chip.dart';
import '../../widgets/home/promo_banner.dart';
import '../../widgets/products/product_card.dart';
import '../../widgets/search/searchbar.dart';
import '../products/product_detail_screen.dart';
import '../products/product_list_screen.dart';

/// HomeScreen with Provider pattern implementation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  // Keep alive to prevent rebuilds when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: const _HomeScreenContent(),
    );
  }
}

/// Content widget that uses provider pattern
class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        // Note: Cache clearing is now handled by the provider internally
        // We no longer call clearProductCardCache() during build
        
        final specialTagProducts = provider.specialTagProducts;
        final categories = provider.categories;
        final featuredProducts = provider.featuredProducts;
        final newArrivals = provider.newArrivals;
        
        return Scaffold(
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  // Simulate data refresh
                  await Future.delayed(const Duration(seconds: 1));
                  // In a real app, API calls would be made here
                },
                color: AppColors.primary,
                child: ListView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.only(
                    top: provider.isSearching ? 0 : 100,
                    // Add extra bottom padding to prevent overlap with navigation bar
                    bottom: 80,
                  ),
                  children: [
                    const SizedBox(height: 16.0),
                    
                    // Show search results if searching
                    if (provider.isSearching)
                      _buildSearchResults(context, provider)
                    else ...[                      
                      // 1. Promo Banners
                      const SizedBox(height: 16.0),
                      PromoBannerCarousel(products: specialTagProducts),
                      const SizedBox(height: 24),

                      // 2. Category List
                      _buildSectionHeader(
                        'Kategoriler',
                        onViewAll: () {
                          /* Categories Page Navigation */
                        },
                      ),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          itemCount: categories.length,
                          cacheExtent: 1000,
                          itemBuilder: (ctx, index) => CategoryChip(
                            category: categories[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductListScreen(
                                    category: categories[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Featured Products / AI Recommendations
                      _buildSectionHeader(
                        'Sizin İçin Seçtiklerimiz',
                        onViewAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductListScreen(
                                title: 'Sizin İçin Seçtiklerimiz',
                                predefinedProductList: featuredProducts,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildHorizontalProductList(context, provider, featuredProducts),
                      const SizedBox(height: 24),

                      // 4. Campaign Card
                      _buildCampaignCard(context),
                      const SizedBox(height: 24),

                      // 5. New Arrivals
                      _buildSectionHeader(
                        'Yeni Gelenler',
                        onViewAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductListScreen(
                                title: 'Yeni Gelenler',
                                predefinedProductList: newArrivals,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildHorizontalProductList(context, provider, newArrivals),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
              
              // Modern search bar
              ModernSearchBar(
                controller: provider.searchController,
                hintText: "Ürün, marka veya kategori ara...",
                padding: const EdgeInsets.only(
                  top: 40.0,
                  right: 16.0,
                  left: 16.0,
                  bottom: 12.0,
                ),
                onChanged: (value) {
                  // Provider already listens to the controller changes
                },
                onSubmitted: (value) {
                  // Handle search submission if needed
                },
                onFilterPressed: () {
                  HapticFeedback.mediumImpact();
                  _showFilterOptionsSheet(context, provider);
                },
                hasActiveFilters: provider.selectedCategoryFilter != null || 
                                  provider.selectedPriceRangeFilter != null,
                onClearFiltersPressed: () => provider.clearFilters(),
                backgroundColor: Theme.of(context).cardColor.withOpacity(0.95),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Filter options sheet
  void _showFilterOptionsSheet(BuildContext context, HomeProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.0).copyWith(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Closing bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filtrele', style: AppTextStyles.h5),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            provider.clearFilters();
                          });
                        },
                        child: Text(
                          'Temizle',
                          style: AppTextStyles.textButtonPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Kategori', style: AppTextStyles.bodyLBold),
                  Wrap(
                    spacing: 8.0,
                    children: provider.categories.map((category) {
                      final isSelected = 
                          provider.selectedCategoryFilter?.id == category.id;
                      return ChoiceChip(
                        label: Text(
                          category.name,
                          style: AppTextStyles.chipLabel,
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            provider.setSelectedCategoryFilter(
                                selected ? category : null);
                          });
                        },
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('Fiyat Aralığı', style: AppTextStyles.bodyLBold),
                  RangeSlider(
                    values: provider.selectedPriceRangeFilter ??
                            const RangeValues(0, 1000),
                    min: 0,
                    max: 5000,
                    divisions: 50,
                    labels: provider.selectedPriceRangeFilter != null
                        ? RangeLabels(
                            '${provider.selectedPriceRangeFilter!.start.toStringAsFixed(0)} TL',
                            '${provider.selectedPriceRangeFilter!.end.toStringAsFixed(0)} TL',
                          )
                        : null,
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        provider.setSelectedPriceRangeFilter(values);
                      });
                    },
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.lightGrey,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Close filter sheet
                      // Provider will handle search update
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                    ),
                    child: const Text('Filtreleri Uygula'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // Section header widget
  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h5),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Tümünü Gör',
                style: AppTextStyles.textButtonPrimary,
              ),
            ),
        ],
      ),
    );
  }

  // Search results widget
  Widget _buildSearchResults(BuildContext context, HomeProvider provider) {
    if (provider.searchResults.isEmpty && provider.searchController.text.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0).copyWith(top: 80),
          child: Text(
            '"${provider.searchController.text}" için sonuç bulunamadı.',
            style: AppTextStyles.bodyL.copyWith(color: AppColors.darkGrey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12.0).copyWith(top: 70),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: provider.searchResults.length,
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        final product = provider.searchResults[index];
        final cacheKey = 'search_${product.id}';
        return provider.cacheProductCard(
          cacheKey,
          ProductCard(
            product: product,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
            heroTagPrefix: 'search_',
            showAddToCartButton: true,
          ),
        );
      },
    );
  }

  // Horizontal product list widget
  Widget _buildHorizontalProductList(BuildContext context, HomeProvider provider, List<Product> products) {
    if (products.isEmpty) return const SizedBox.shrink();
    
    return SizedBox(
      height: 290,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: products.length,
        cacheExtent: 1000,
        itemBuilder: (ctx, index) {
          final product = products[index];
          final cacheKey = 'horizontal_${product.id}';
          return provider.cacheProductCard(
            cacheKey,
            ProductCard(
              product: product,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
              width: 170,
              showAddToCartButton: true,
            ),
          );
        },
      ),
    );
  }

  // Campaign card widget
  Widget _buildCampaignCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () {
          // Navigate to campaign detail page
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withOpacity(0.1),
                AppColors.accent.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.campaign_outlined, color: AppColors.accent, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kaçırılmayacak Fırsatlar!',
                      style: AppTextStyles.h6.copyWith(color: AppColors.accent),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sezon indirimleri ve özel teklifler sizi bekliyor.',
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.accent.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
