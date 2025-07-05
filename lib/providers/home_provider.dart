import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/category.dart';
import '../models/product.dart';

class HomeProvider extends ChangeNotifier {
  // Cache for recently used timestamps to determine least recently used items
  final Map<String, DateTime> _cacheAccessTimestamps = {};
  
  // Last cleanup timestamp to avoid frequent cleanups
  DateTime _lastCleanupTime = DateTime.now();
  // Search state
  final TextEditingController searchController = TextEditingController();
  bool _isSearching = false;
  List<Product> _searchResults = [];
  
  // Filter state
  Category? _selectedCategoryFilter;
  RangeValues? _selectedPriceRangeFilter;
  
  // Cache for expensive computations
  final Map<String?, String> _stockStatusTextCache = {};
  final Map<String?, Color> _stockStatusColorCache = {};
  
  // Cache product cards to prevent rebuilds
  final Map<String, Widget> _productCardCache = {};
  
  // Maximum cache size before cleanup
  static const int _maxCacheSize = 50;
  
  // Minimum time between cache cleanups (5 minutes)
  static const Duration _cleanupInterval = Duration(minutes: 5);
  
  // Getters
  bool get isSearching => _isSearching;
  List<Product> get searchResults => _searchResults;
  Category? get selectedCategoryFilter => _selectedCategoryFilter;
  RangeValues? get selectedPriceRangeFilter => _selectedPriceRangeFilter;
  Map<String, Widget> get productCardCache => _productCardCache;
  
  // Products by category
  List<Product> get specialTagProducts => DummyData.products
      .where((p) => p.specialTag != null && p.specialTag!.isNotEmpty)
      .toList();
      
  List<Category> get categories => DummyData.categories;
  
  List<Product> get featuredProducts => DummyData.getFeaturedProducts();
  
  List<Product> get newArrivals => DummyData.products.reversed.take(10).toList();
  
  // Constructor
  HomeProvider() {
    searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    bool isStateChanged = false;
    
    if (query.isEmpty) {
      if (_isSearching) {
        _isSearching = false;
        isStateChanged = true;
      }
      if (_searchResults.isNotEmpty) {
        _searchResults = [];
        isStateChanged = true;
      }
    } else {
      // Apply filters
      var filteredResults = DummyData.products.where((product) {
        // Search matches
        final nameMatch = product.name.toLowerCase().contains(query);
        final descMatch = product.description.toLowerCase().contains(query);
        
        // Find the category name for this product
        final category = DummyData.categories.firstWhere(
          (cat) => cat.id == product.categoryId,
          orElse: () => Category(id: '', name: '', icon: Icons.category),
        );
        final categoryMatch = category.name.toLowerCase().contains(query);
        
        final textMatch = nameMatch || descMatch || categoryMatch;
        
        // Category filter
        final categoryFilterMatch = _selectedCategoryFilter == null || 
                                product.categoryId == _selectedCategoryFilter!.id;
        
        // Price filter
        final priceFilterMatch = _selectedPriceRangeFilter == null || 
                              (product.price >= _selectedPriceRangeFilter!.start && 
                               product.price <= _selectedPriceRangeFilter!.end);
        
        return textMatch && categoryFilterMatch && priceFilterMatch;
      }).toList();

      if (!_isSearching) {
        _isSearching = true;
        isStateChanged = true;
      }
      
      // Only update and notify if results have changed
      if (_searchResults.length != filteredResults.length ||
          !_areListsEqual(_searchResults, filteredResults)) {
        _searchResults = filteredResults;
        isStateChanged = true;
      }
    }
    
    // Only notify if state actually changed
    if (isStateChanged) {
      notifyListeners();
    }
  }
  
  // Helper method to compare lists
  bool _areListsEqual(List<Product> list1, List<Product> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id) return false;
    }
    return true;
  }
  
  void clearFilters() {
    bool stateChanged = false;
    
    if (_selectedCategoryFilter != null) {
      _selectedCategoryFilter = null;
      stateChanged = true;
    }
    
    if (_selectedPriceRangeFilter != null) {
      _selectedPriceRangeFilter = null;
      stateChanged = true;
    }
    
    // Only notify once and then update search results
    if (stateChanged) {
      notifyListeners();
      // We'll update search results in a separate microtask to avoid
      // triggering multiple updates in the same frame
      Future.microtask(_onSearchChanged);
    }
  }
  
  void setSelectedCategoryFilter(Category? category) {
    // Only update and notify if there's an actual change
    if ((_selectedCategoryFilter == null && category != null) ||
        (_selectedCategoryFilter != null && category == null) ||
        (_selectedCategoryFilter != null && category != null && 
         _selectedCategoryFilter!.id != category.id)) {
      _selectedCategoryFilter = category;
      notifyListeners();
      
      // Update search results in a separate microtask
      Future.microtask(_onSearchChanged);
    }
  }
  
  void setSelectedPriceRangeFilter(RangeValues? range) {
    // Only update and notify if there's an actual change
    if ((_selectedPriceRangeFilter == null && range != null) ||
        (_selectedPriceRangeFilter != null && range == null) ||
        (_selectedPriceRangeFilter != null && range != null && 
         (_selectedPriceRangeFilter!.start != range.start || 
          _selectedPriceRangeFilter!.end != range.end))) {
      _selectedPriceRangeFilter = range;
      notifyListeners();
      
      // Update search results in a separate microtask
      Future.microtask(_onSearchChanged);
    }
  }
  
  void clearProductCardCache() {
    // This method is now only for external forced cleanup
    _productCardCache.clear();
    _cacheAccessTimestamps.clear();
  }
  
  /// Performs smart cache cleanup if needed, keeping most recently used items
  void _performCacheCleanupIfNeeded() {
    final now = DateTime.now();
    
    // Only clean up if cache is large enough and enough time has passed since last cleanup
    if (_productCardCache.length > _maxCacheSize && 
        now.difference(_lastCleanupTime) > _cleanupInterval) {
      
      // Sort keys by access time (oldest first)
      final sortedKeys = _cacheAccessTimestamps.keys.toList()
        ..sort((a, b) => _cacheAccessTimestamps[a]!.compareTo(_cacheAccessTimestamps[b]!));
      
      // Keep only the most recently used half of the cache
      final keysToRemove = sortedKeys.sublist(0, sortedKeys.length ~/ 2);
      
      // Remove old items
      for (final key in keysToRemove) {
        _productCardCache.remove(key);
        _cacheAccessTimestamps.remove(key);
      }
      
      _lastCleanupTime = now;
    }
  }
  
  // Stock status methods
  String getStockStatusText(String? status) {
    // Simple cleanup if cache gets too large
    if (_stockStatusTextCache.length > 20) {
      _stockStatusTextCache.clear();
    }
    
    return _stockStatusTextCache.putIfAbsent(status, () {
      switch (status) {
        case 'in_stock':
          return 'Stokta Mevcut';
        case 'low_stock':
          return 'Az Kaldı!';
        case 'out_of_stock':
          return 'Tükendi';
        default:
          return '';
      }
    });
  }

  Color getStockStatusColor(String? status) {
    return _stockStatusColorCache.putIfAbsent(status, () {
      switch (status) {
        case 'in_stock':
          return Colors.green.shade600;
        case 'low_stock':
          return Colors.orange.shade700;
        case 'out_of_stock':
          return Colors.red.shade600;
        default:
          return Colors.grey.shade700;
      }
    });
  }
  
  // Add a product card to the cache
  Widget cacheProductCard(String key, Widget card) {
    // Update access timestamp
    _cacheAccessTimestamps[key] = DateTime.now();
    
    // Return cached card or create new one
    return _productCardCache.putIfAbsent(key, () {
      // Check if cache needs cleaning before adding new item
      _performCacheCleanupIfNeeded();
      return card;
    });
  }
}
