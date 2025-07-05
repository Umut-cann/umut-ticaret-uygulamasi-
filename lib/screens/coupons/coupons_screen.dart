import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:umut_ticaret/constants/app_colors.dart';
import 'package:umut_ticaret/constants/app_text_styles.dart';
// Kendi dosya yollarınızı kullanın:



// --- Coupon Model (Değişiklik yok) ---
class Coupon {
  final String id;
  String title;
  String description;
  final String code;
  final DateTime expiryDate;
  bool isUsed;

  Coupon({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.expiryDate,
    this.isUsed = false,
  });
}

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  late List<Coupon> _coupons;
  final DateFormat _formatter = DateFormat('dd.MM.yy'); // Daha kısa tarih formatı

  // AppColors.accentLight null ise varsayılan değer
  // Bu renk artık daha az kullanılacak, belki gri bir ton olabilir.
  final Color _subtleAccentColor = AppColors.accentLight ?? AppColors.mediumGrey.withOpacity(0.2);


  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  String _getDiscountValue(String title) {
    if (title.contains("TL")) {
      return title.split(" TL")[0];
    } else if (title.contains("%")) {
      return title.split("%")[0];
    } else if (title.toUpperCase() == "ÜCRETSİZ KARGO") {
      return "ÜCRETSİZ";
    }
    return title.split(" ")[0];
  }

  String _getDiscountUnit(String title) {
    if (title.contains("TL")) {
      return "TL";
    } else if (title.contains("%")) {
      return "%";
    } else if (title.toUpperCase() == "ÜCRETSİZ KARGO") {
      return "KARGO";
    }
    return "";
  }

  void _loadCoupons() {
    _coupons = [
      Coupon(
        id: '1',
        title: '25 TL',
        description: 'Tüm kitaplarda 100 TL ve üzeri alışverişlerde.',
        code: 'KITAP25',
        expiryDate: DateTime.now().add(const Duration(days: 30)),
      ),
      Coupon(
        id: '4',
        title: '15%',
        description: 'Yeni sezon giyim ürünlerinde geçerli.',
        code: 'MODA15',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
      ),
      Coupon(
        id: '2',
        title: '50 TL',
        description: 'Elektronik aksesuarlarda 300 TL ve üzeri için.',
        code: 'TEKNO50',
        expiryDate: DateTime.now().add(const Duration(days: 15)),
        isUsed: true,
      ),
      Coupon(
        id: '3',
        title: 'ÜCRETSİZ KARGO',
        description: '150 TL ve üzeri tüm siparişlerinizde.',
        code: 'KARGOFREE',
        expiryDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
       Coupon(
        id: '5',
        title: '10%',
        description: 'Hafta sonuna özel tüm yiyecek ve içeceklerde indirim.',
        code: 'LEZZET10',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
      ),
    ];
    _coupons.sort((a, b) {
      bool aCanUse = !a.isUsed && a.expiryDate.isAfter(DateTime.now());
      bool bCanUse = !b.isUsed && b.expiryDate.isAfter(DateTime.now());
      if (aCanUse && !bCanUse) return -1;
      if (!aCanUse && bCanUse) return 1;
      if (a.expiryDate.isAfter(b.expiryDate)) return -1;
      if (b.expiryDate.isAfter(a.expiryDate)) return 1;
      return 0;
    });
  }

  void _handleCouponTap(BuildContext context, Coupon coupon) {
    final bool canUse = !coupon.isUsed && !coupon.expiryDate.isBefore(DateTime.now());
    if (canUse) {
      Clipboard.setData(ClipboardData(text: coupon.code)).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 2,
            content: Text('${coupon.code} kodu panoya kopyalandı!', style: AppTextStyles.bodyM.copyWith(color: AppColors.textOnPrimary)),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: AppColors.primary, // Siyah arka plan, beyaz metin
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        );
      });
    } else {
      String message = coupon.isUsed ? "Bu kupon zaten kullanıldı." : "Bu kuponun süresi doldu.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 2,
          content: Text(message, style: AppTextStyles.bodyM.copyWith(color: AppColors.textOnPrimary)), // textOnPrimary beyazsa
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppColors.darkGrey, // Koyu gri bir hata/uyarı
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kuponlarım', style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface, // Beyaz veya çok açık gri
        elevation: 0, // Tamamen düz
        centerTitle: true, // Ortalanmış başlık
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      backgroundColor: AppColors.background, // Genellikle beyaz
      body: _coupons.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              itemCount: _coupons.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0), // Kartlar arası boşluk
                  child: _buildCompactModernCouponCard(context, _coupons[index]),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined, // Zarif bir kupon ikonu
              size: 70,
              color: AppColors.mediumGrey,
            ),
            const SizedBox(height: 20),
            Text(
              'Henüz Size Özel Bir Kupon Yok',
              style: AppTextStyles.h6.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Yeni fırsatlar için bizi takip etmeye devam edin.',
              style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactModernCouponCard(BuildContext context, Coupon coupon) {
    final bool isExpired = coupon.expiryDate.isBefore(DateTime.now());
    final bool canUse = !coupon.isUsed && !isExpired;

    // Renkler (Siyah-Beyaz Ağırlıklı)
    Color cardBackgroundColor;
    Color primaryTextColor;
    Color secondaryTextColor;
    Color stubBackgroundColor;
    Color dashedLineColor;
    IconData statusIcon = Icons.arrow_forward_ios_rounded;
    Color statusIconColor = AppColors.textPrimary;


    if (canUse) {
      cardBackgroundColor = AppColors.primary; // SİYAH Kupon
      primaryTextColor = AppColors.textOnPrimary; // BEYAZ metin
      secondaryTextColor = AppColors.textOnPrimary.withOpacity(0.8);
      stubBackgroundColor = AppColors.surface; // BEYAZ stub
      dashedLineColor = AppColors.lightGrey.withOpacity(0.7);
      statusIconColor = AppColors.textPrimary; // Beyaz stub üzerinde SİYAH ok
    } else {
      cardBackgroundColor = AppColors.surface; // BEYAZ Kupon (pasif)
      primaryTextColor = AppColors.textSecondary; // GRİ metin
      secondaryTextColor = AppColors.textSecondary.withOpacity(0.7);
      stubBackgroundColor = AppColors.lightGrey.withOpacity(0.5); // Çok AÇIK GRİ stub
      dashedLineColor = AppColors.mediumGrey.withOpacity(0.5);
      statusIcon = coupon.isUsed ? Icons.check_circle_outline_rounded : Icons.hourglass_bottom_rounded;
      statusIconColor = AppColors.mediumGrey;
    }

    final double mainContentRatio = 0.72; // Ana içerik alanı (sol)
    final double stubRatio = 1.0 - mainContentRatio; // Sağdaki koparma parçası

    bool isSpecialTitle = coupon.title.toUpperCase() == "ÜCRETSİZ KARGO";
    double titleFontSize = isSpecialTitle ? 20 : 32; // Boyutlar küçültüldü
    double unitFontSize = isSpecialTitle ? 14 : AppTextStyles.h6.fontSize!;

    return GestureDetector(
      onTap: () => _handleCouponTap(context, coupon),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGrey.withOpacity(0.08), // Çok hafif gölge
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipPath(
          clipper: _CompactCouponClipper(
            rightStubRatio: stubRatio,
            cornerRadius: 10.0, // Daha küçük köşe
            holeRadius: 6.0,   // Daha küçük delik
          ),
          child: Container(
            // Yükseklik artık IntrinsicHeight ve içerikle belirlenecek
            color: cardBackgroundColor, // Ana bölümün arka planı
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Sol Bölüm (İndirim Bilgisi)
                  Expanded(
                    flex: (mainContentRatio * 100).round(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14), // Padding ayarlandı
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _getDiscountValue(coupon.title),
                                style: AppTextStyles.h2.copyWith( // h2 veya h3
                                  color: primaryTextColor,
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (_getDiscountUnit(coupon.title).isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: isSpecialTitle ? 4 : 3.0,
                                    bottom: isSpecialTitle ? 1 : 5
                                  ),
                                  child: Text(
                                    _getDiscountUnit(coupon.title),
                                    style: AppTextStyles.subtitle1.copyWith( // subtitle1
                                      color: primaryTextColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: unitFontSize,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4), // Azaltıldı
                          Text(
                            coupon.description,
                            style: AppTextStyles.bodyS.copyWith( // bodyS daha küçük
                              color: secondaryTextColor,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             mainAxisSize: MainAxisSize.min,
                             children: [
                                Text(
                                  'KOD: ${coupon.code.toUpperCase()}',
                                  style: AppTextStyles.caption.copyWith( // caption
                                    color: secondaryTextColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Son: ${_formatter.format(coupon.expiryDate)}',
                                  style: AppTextStyles.bodyXS.copyWith( // bodyXS
                                    color: secondaryTextColor.withOpacity(0.8),
                                  ),
                                ),
                             ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sağ Bölüm (Dikey Kesikli Çizgi ve Stub Alanı)
                  Expanded(
                    flex: (stubRatio * 100).round(),
                    child: Container(
                      color: stubBackgroundColor, // Stub bölümünün arka planı
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          CustomPaint(
                            size: const Size(1.5, double.infinity), // Çizgi kalınlığı
                            painter: _DashedLinePainter(
                              color: dashedLineColor,
                              strokeWidth: 1.5,
                              dashHeight: 4,
                              dashSpace: 2.5,
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Icon(
                              statusIcon,
                              color: statusIconColor.withOpacity(canUse ? 0.8 : 0.6),
                              size: 18, // Daha küçük ikon
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Kompakt Kupon Şekli için Custom Clipper
class _CompactCouponClipper extends CustomClipper<Path> {
  final double rightStubRatio;
  final double cornerRadius;
  final double holeRadius;

  _CompactCouponClipper({
    required this.rightStubRatio,
    required this.cornerRadius,
    required this.holeRadius,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final double stubWidth = size.width * rightStubRatio;
    final double mainWidth = size.width - stubWidth;

    // Sol üst köşe
    path.moveTo(0, cornerRadius);
    path.arcToPoint(Offset(cornerRadius, 0), radius: Radius.circular(cornerRadius), clockwise: false);

    // Üst kenar (ana bölüm)
    path.lineTo(mainWidth - holeRadius, 0);

    // Üstteki yarım daire kesik (içe doğru)
    path.arcToPoint(
      Offset(mainWidth + holeRadius, 0),
      radius: Radius.circular(holeRadius),
      clockwise: true,
    );

    // Üst kenar (stub bölümü)
    path.lineTo(size.width - cornerRadius, 0);

    // Sağ üst köşe
    path.arcToPoint(Offset(size.width, cornerRadius), radius: Radius.circular(cornerRadius), clockwise: false);

    // Sağ kenar
    path.lineTo(size.width, size.height - cornerRadius);

    // Sağ alt köşe
    path.arcToPoint(Offset(size.width - cornerRadius, size.height), radius: Radius.circular(cornerRadius), clockwise: false);

    // Alt kenar (stub bölümü)
    path.lineTo(mainWidth + holeRadius, size.height);

    // Alttaki yarım daire kesik (içe doğru)
    path.arcToPoint(
      Offset(mainWidth - holeRadius, size.height),
      radius: Radius.circular(holeRadius),
      clockwise: true,
    );

    // Alt kenar (ana bölüm)
    path.lineTo(cornerRadius, size.height);

    // Sol alt köşe
    path.arcToPoint(Offset(0, size.height - cornerRadius), radius: Radius.circular(cornerRadius), clockwise: false);

    // Sol kenar
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Dikey Kesikli Çizgi için CustomPainter
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashHeight;
  final double dashSpace;

  _DashedLinePainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashHeight = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startY = 0;
    final double centerX = 0; // Soldan başlar

    while (startY < size.height) {
      canvas.drawLine(
        Offset(centerX, startY),
        Offset(centerX, math.min(startY + dashHeight, size.height)),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}