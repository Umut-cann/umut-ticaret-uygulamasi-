import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:provider/provider.dart';
import 'package:umut_ticaret/providers/favorites_provider.dart';
import 'package:umut_ticaret/providers/ui_state_provider.dart';

import 'flutter_impeller_fix.dart';

import 'constants/app_theme.dart';
import 'providers/cart_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/main_screen.dart';




// canlı alışverişi kaldır 
// kaçırılmıycak  fırstatlar 

void main() async {
  // Initialize the binding before setting any properties
  WidgetsFlutterBinding.ensureInitialized();
  
  // Apply our custom fixes for Impeller rendering issues
  await FlutterImpellerFix.initialize();
  
  // Disable hardware acceleration on Android emulator to avoid crashes
  if (kDebugMode && Platform.isAndroid) {
    debugPrint('🔧 Applying Android-specific rendering settings');
    // Increase Skia cache size for better performance
    await SystemChannels.skia.invokeMethod<void>('Skia.setResourceCacheMaxBytes', 512 * 1024 * 1024);
  }
  
  // Configure aggressive image cache cleanup
  PaintingBinding.instance.imageCache.maximumSize = 100;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB
  
  // Ensure image cache is clean
  ImageCache().clear();
  ImageCache().clearLiveImages();
  
  // Set additional rendering options if needed
  // Add Flutter-specific rendering flags here as needed
  
  await initializeDateFormatting(
    'tr_TR',
    null,
  ); // Türkçe tarih formatlamayı başlat
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
        ChangeNotifierProvider(create: (context) => UIStateProvider()),
      ],
      child: MaterialApp(
//          showPerformanceOverlay: true,

        title: 'Umut Ticaret',
        theme: AppTheme.lightTheme,
        // darkTheme: AppTheme.darkTheme,
        // themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        // Başlangıç ekranı - normalde splash veya auth kontrol olur
        home: const MainScreen(), // Veya test için LoginScreen()
      ),
    );
  }
}
