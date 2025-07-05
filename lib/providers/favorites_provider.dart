import 'package:flutter/material.dart';

import '../models/product.dart'; // Product modelini import et

class FavoritesProvider with ChangeNotifier {
  final List<Product> _favoriteItems = [];

  List<Product> get favoriteItems => _favoriteItems;

  bool isFavorite(Product product) {
    return _favoriteItems.any((item) => item.id == product.id);
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      _favoriteItems.removeWhere((item) => item.id == product.id);
    } else {
      _favoriteItems.add(product);
    }
    notifyListeners();
  }
  
  void clearAll() {
    _favoriteItems.clear();
    notifyListeners();
  }
}
