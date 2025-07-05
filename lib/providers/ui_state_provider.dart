import 'package:flutter/material.dart';

/// Provider for managing UI state across the app
/// This helps to avoid excessive setState calls which can impact performance
class UIStateProvider with ChangeNotifier {
  // Carousel state
  int _currentBannerIndex = 0;
  
  // Getters
  int get currentBannerIndex => _currentBannerIndex;

  // Setters with notifications
  void setBannerIndex(int index) {
    if (_currentBannerIndex != index) {
      _currentBannerIndex = index;
      notifyListeners();
    }
  }
  
  // Helper methods for carousel interactions
  void nextBanner() {
    // Implementation to be added if needed
    notifyListeners();
  }
  
  void previousBanner() {
    // Implementation to be added if needed
    notifyListeners();
  }
}
