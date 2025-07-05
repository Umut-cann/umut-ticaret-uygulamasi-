import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/navigation/modern_bottom_nav.dart';
import 'cart/cart_screen.dart';
import 'favorites/favorites_screen.dart'; // Favoriler ekranını import et
import 'home/home_screen.dart';
import 'misc/order_tracking_screen.dart'; // Siparişlerim sayfası
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Gösterilecek sayfaların listesi
  final List<Widget> _pages = [
    const HomeScreen(),
    const OrderTrackingScreen(),
    const CartScreen(),
    const FavoritesScreen(),
  ];

  // final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey(); // Kaldırıldı

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      extendBody: true, // Body'nin Nav Bar'ın arkasına uzanmasını sağlar (şeffaflık için)
      body: IndexedStack(index: navProvider.selectedIndex, children: _pages),
      bottomNavigationBar: ModernBottomNavBar(
        currentIndex: navProvider.selectedIndex,
        onTap: (index) {
          // Add haptic feedback for a more premium experience
          HapticFeedback.lightImpact();
          navProvider.setIndex(index);
        },
        items: [
          // Home
          ModernBottomNavItem(
            outlinedIcon: Icons.explore_outlined,
            filledIcon: Icons.explore,
            label: "Keşfet",
          ),
          // Orders
          ModernBottomNavItem(
            outlinedIcon: Icons.list_alt_outlined,
            filledIcon: Icons.list_alt,
            label: "Siparişler",
          ),
          // Favorites
    
          // Cart with badge
          ModernBottomNavItem(
            outlinedIcon: Icons.shopping_cart_outlined,
            filledIcon: Icons.shopping_cart,
            label: "Sepetim",
            badgeCount: cartProvider.itemCount > 0 ? cartProvider.itemCount : null,
          ),
          // Favorites
        
          // Profile
          ModernBottomNavItem(
            outlinedIcon: Icons.favorite_border_rounded,
            filledIcon: Icons.favorite_rounded,
            label: "Favoriler",
          ),
        ],
      ),
    );
  }

}
