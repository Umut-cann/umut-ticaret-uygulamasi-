import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Helper class to fix Impeller renderer issues
class FlutterImpellerFix {
  // Keep track of whether we've been initialized
  static bool _initialized = false;
  
  // Store current platform
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  
  /// Initialize this class as early as possible in your app
  static Future<void> initialize() async {
    // Only initialize once
    if (_initialized) return;
    _initialized = true;
    
    if (kIsWeb) return; // Skip all fixes on web
    
    // Apply platform-specific fixes
    await _applyImageCacheFixes();
    await _applyPlatformSpecificFixes();
    await _optimizeMemoryUsage();
    
    // Debugging information
    debugPrint('🔧 FlutterImpellerFix: Applied rendering optimizations');
  }
  
  /// Apply fixes to image caching system
  static Future<void> _applyImageCacheFixes() async {
    // Aggressively clear image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    // Set smaller image cache size to avoid memory issues
    // Lower values mean less memory usage but more network requests
    PaintingBinding.instance.imageCache.maximumSize = 50;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB
  }
  
  /// Apply platform-specific rendering fixes
  static Future<void> _applyPlatformSpecificFixes() async {
    if (isAndroid) {
      // Increase Skia resource cache size on Android
      await SystemChannels.skia.invokeMethod<void>('Skia.setResourceCacheMaxBytes', 256 * 1024 * 1024);
      
      // Configure render settings for better performance
      if (kDebugMode) {
        // Debug mode typically has worse performance, so we apply more aggressive optimizations
        await _setAndroidRenderMode("forceSoftware");
      }
    }
    
    if (isIOS) {
      // iOS-specific optimizations if needed
    }
  }
  
  /// Optimize memory usage
  static Future<void> _optimizeMemoryUsage() async {
    // Request low memory mode from the system
    if (isAndroid || isIOS) {
      WidgetsBinding.instance.addObserver(_MemoryManagementObserver());
    }
  }
  
  /// Set Android rendering mode
  static Future<void> _setAndroidRenderMode(String mode) async {
    try {
      const platform = MethodChannel('com.example.meet_app/renderer');
      await platform.invokeMethod('setRenderMode', {'mode': mode});
    } catch (e) {
      // Method channel not implemented, ignore
    }
  }
}

/// Observer to handle memory pressure situations
class _MemoryManagementObserver extends WidgetsBindingObserver {
  @override
  void didHaveMemoryPressure() {
    // Clear all caches when memory is low
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    if (kDebugMode) {
      debugPrint('🔧 FlutterImpellerFix: Cleared caches due to memory pressure');
    }
  }
}
