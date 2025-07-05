import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:umut_ticaret/screens/coupons/coupons_screen.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/cart_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/navigation/modern_bottom_nav.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';
// Bottom Navigation items
import '../home/home_screen.dart';
import '../misc/order_tracking_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Gerçek uygulamada bu değer AuthProvider'dan gelir
  bool _isLoggedIn = true; // Başlangıçta giriş yapılmış varsayalım

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    bool isLogout = false,
    String? trailingText,
  }) {
    final bool isKuponlarim = title == 'Kuponlarım';
    final Color effectiveIconColor =
        isLogout ? AppColors.error : (iconColor ?? AppColors.primary);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 8, // Yatay padding eklendi
        vertical: 12, // Dikey padding artırıldı
      ),
      leading: Container(
        padding: const EdgeInsets.all(14), // Padding biraz daha artırıldı
        decoration: BoxDecoration(
          color: effectiveIconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16), // Daha da yuvarlak köşeler
        ),
        child: Icon(
          icon,
          color: effectiveIconColor,
          size: 26, // İkon boyutu biraz daha büyütüldü
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyL.copyWith(fontWeight: FontWeight.w600),
      ), // Bolder title
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            isKuponlarim
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trailingText,
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                : Text(
                  trailingText,
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
          if (trailingText != null) const SizedBox(width: 8),
          if (!isLogout)
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
        ],
      ),
      onTap: onTap,
      textColor: isLogout ? AppColors.error : AppColors.textPrimary,
      iconColor: effectiveIconColor,
      splashColor: effectiveIconColor.withOpacity(0.1),
      hoverColor: effectiveIconColor.withOpacity(0.05),
    );
  }

  Widget _buildCommunitySection(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.forum_outlined, color: AppColors.accent),
                const SizedBox(width: 8),
                Text('Topluluk & Forum', style: AppTextStyles.h6),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Diğer kullanıcılarla sohbet edin, deneyimlerinizi paylaşın ve ürünler hakkında tartışın.',
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              // Butonu sağa yasla
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {
                  /* Forum Sayfası */
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: BorderSide(color: AppColors.accent),
                ),
                child: const Text('Foruma Göz At'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context);
    
    return Scaffold(
      extendBody: true, // Body'nin Nav Bar'ın arkasına uzanmasını sağlar
      appBar: const CustomAppBar(
        title: 'Hesabım',
        showBackButton: false,
        centerTitle: true,
      ), // Başlık ortalandı
      body: ListView(
        physics: const BouncingScrollPhysics(),
        // Add bottom padding to avoid content being hidden behind navigation bar
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0 + MediaQuery.of(context).padding.bottom + 80),
        children: [
          if (_isLoggedIn)
            Row(
              // Kullanıcı Bilgisi
              children: [
                CircleAvatar(
                  radius: 40, // Yarıçap artırıldı
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person_outline, // Daha modern bir ikon
                    size: 45, // İkon boyutu artırıldı
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  // İsim uzunsa taşmasın
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Umut Can Kurban',
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ), // İsim daha belirgin
                      Text(
                        'ayse.yilmaz@email.com',
                        style: AppTextStyles.bodyM.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.darkGrey,
                  ),
                  tooltip: 'Profili Düzenle',
                  onPressed: () {
                    /* Profil Düzenleme */
                  },
                ),
              ],
            )
          else // Giriş Yapılmamışsa
            Column(
              // Giriş/Kayıt Butonu
              children: [
                Text(
                  'Size özel fırsatlar ve kolay sipariş takibi için giriş yapın!',
                  style: AppTextStyles.bodyL,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // LoginScreen'e git (Mevcut sayfayı değiştirerek)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text('Giriş Yap veya Kayıt Ol'),
                ),
              ],
            ),

          const SizedBox(height: 30), // Boşluk artırıldı
          if (_isLoggedIn) ...[
            // VIP Gold Kartı kaldırıldı.
            const SizedBox(
              height: 10,
            ), // Kart kaldırıldıktan sonraki boşluk ayarlandı
          ],

          // Menü
          _buildProfileMenuItem(
            icon: Icons.list_alt_outlined,
            title: 'Siparişlerim',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderTrackingScreen(),
                  ),
                ),
          ),
          _buildProfileMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Adreslerim',
            onTap: () {
              /* Adreslerim Sayfası */
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.payment_outlined,
            title: 'Ödeme Yöntemlerim',
            onTap: () {
              /* Ödeme Yöntemleri Sayfası */
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.favorite_border_outlined,
            title: 'Favorilerim',
            iconColor: Colors.pinkAccent,
            onTap: () {
              /* Favoriler Sayfası */
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.discount_outlined,
            title: 'Kuponlarım',
            iconColor: AppColors.success,
            trailingText: '3 Yeni', // Örnek sağdaki yazı
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CouponsScreen()),
              );
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.people_outline,
            title: 'Arkadaşını Getir',
            iconColor: AppColors.accent,
            onTap: () {
              /* Arkadaşını Getir Sayfası/Popup */
            },
          ),

          const Divider(
            height: 30, // Yükseklik artırıldı
            thickness: 0.5, // Kalınlık azaltıldı
            indent: 20, // Girinti artırıldı
            endIndent: 20, // Girinti artırıldı
            color: AppColors.lightGrey, // Renk belirtildi
          ), // Ayraç
          // Forum/Topluluk
          _buildCommunitySection(context),
          const SizedBox(height: 16),

          // Ayarlar ve Yardım
          _buildProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Ayarlar',
            onTap: () {
              /* Ayarlar */
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.help_outline_outlined,
            title: 'Yardım & Destek',
            onTap: () {
              /* Yardım */
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.info_outline,
            title: 'Uygulama Hakkında',
            onTap: () {
              /* Hakkında */
            },
          ),

          const Divider(height: 24, thickness: 1, indent: 16, endIndent: 16),

          // Çıkış Yap
          if (_isLoggedIn)
            _buildProfileMenuItem(
              icon: Icons.logout,
              title: 'Çıkış Yap',
              isLogout: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Çıkış Yap'),
                        content: const Text(
                          'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
                        ),
                        actions: [
                          TextButton(
                            child: const Text('İptal'),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          TextButton(
                            child: Text(
                              'Çıkış Yap',
                              style: TextStyle(color: AppColors.error),
                            ),
                            onPressed: () {
                              Navigator.of(ctx).pop(); // Dialogu kapat
                              setState(
                                () => _isLoggedIn = false,
                              ); // State'i güncelle (UI Only)
                              // Gerçekte AuthProvider.logout() çağrılır ve yönlendirme yapılır
                              // Provider.of<NavigationProvider>(context, listen: false).setIndex(0);
                            },
                          ),
                        ],
                      ),
                );
              },
            ),
          const SizedBox(height: 30), // En alta boşluk artırıldı
        ],
      ),
      // Add bottom navigation bar
      bottomNavigationBar: ModernBottomNavBar(
        currentIndex: 3, // Profile index
        onTap: (index) {
          // Add haptic feedback
          HapticFeedback.lightImpact();
          
          // Set navigation index
          navProvider.setIndex(index);
          
          // Navigate to appropriate screen based on index
          switch (index) {
            case 0: // Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 1: // Orders
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const OrderTrackingScreen()),
              );
              break;
            case 2: // Cart
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
              break;
            case 3: // Profile (current screen)
              // Already on profile screen, no navigation needed
              break;
          }
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
          // Cart with badge
          ModernBottomNavItem(
            outlinedIcon: Icons.shopping_cart_outlined,
            filledIcon: Icons.shopping_cart,
            label: "Sepetim",
            badgeCount: cartProvider.itemCount > 0 ? cartProvider.itemCount : null,
          ),
          // Profile (selected)
          ModernBottomNavItem(
            outlinedIcon: Icons.person_outline,
            filledIcon: Icons.person,
            label: "Hesabım",
          ),
        ],
      ),
    );
  }
}
