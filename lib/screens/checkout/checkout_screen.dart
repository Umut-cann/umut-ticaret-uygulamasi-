import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Dialog sonrası provider temizliği için

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/cart_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../utils/helpers.dart'; // Formatlama için
import '../../widgets/common/custom_app_bar.dart';
import '../payment/payment_screen.dart'; // UNCOMMENTED: PaymentScreen navigation re-added

class CheckoutScreen extends StatefulWidget {
  final double totalAmount; // Sepetten gelen ürün toplamı (kargo hariç)

  const CheckoutScreen({required this.totalAmount, Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedAddressIndex = 0;
  // String _selectedPaymentMethod = 'credit_card'; // REMOVED (Payment logic completely removed)
  String _selectedShippingOption = 'standard';
  bool _preliminaryFormAccepted = false; // Ön Bilgilendirme Formu onayı
  bool _distanceSalesContractAccepted =
      false; // Mesafeli Satış Sözleşmesi onayı

  final List<Map<String, String>> _addresses = [
    {
      'title': 'Ev Adresim',
      'address': '123 Örnek Sok, No: 4, D: 5, Çankaya/Ankara, 06500',
    },
    {
      'title': 'İş Adresim',
      'address': '456 Plaza Cad, Kat: 5, Ofis: 502, Beşiktaş/İstanbul, 34340',
    },
    {
      'title': 'Yazlık',
      'address': '789 Sahil Yolu, Palmiye Sitesi, No: 12, Bodrum/Muğla, 48400',
    },
  ];

  final List<Map<String, dynamic>> _shippingOptions = [
    {
      'id': 'standard',
      'name': 'Standart Kargo',
      'price': 29.99,
      'eta': '3-5 iş günü',
      'available': true,
    },
    {
      'id': 'express',
      'name': 'Hızlı Kargo',
      'price': 49.99,
      'eta': '1-2 iş günü',
      'available': true,
    },
    {
      'id': 'sameday',
      'name': 'Aynı Gün Teslimat',
      'price': 79.99,
      'eta': 'Bugün (18:00\'e kadar)',
      'available': true,
    }, // Bölgeye göre değişir
    {
      'id': 'click_collect',
      'name': 'Mağazadan Al',
      'price': 0.0,
      'eta': 'Hemen Hazır',
      'available': false,
    }, // Gelecek özellik
  ];

  // REMOVED: _showPaymentMethodSheet, _buildPaymentOptionTile and _buildCreditCardFormPlaceholder (Payment logic completely removed)

  void _showAddressFormSheet(
    BuildContext context, {
    Map<String, String>? addressToEdit,
  }) {
    final _formKey = GlobalKey<FormState>();
    String _title = addressToEdit?['title'] ?? '';
    String _addressLine = addressToEdit?['address'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Important for keyboard visibility and larger content
      backgroundColor: Colors.white, // Changed to white for a cleaner look
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      // useRootNavigator: true, // Can help with animations over other modals/routes if needed
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  addressToEdit == null ? 'Yeni Adres Ekle' : 'Adresi Düzenle',
                  style: AppTextStyles.h5,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(
                    labelText: 'Adres Başlığı (Ev, İş vb.)',
                    prefixIcon: Icon(Icons.bookmark_border_outlined),
                  ),
                  validator: (v) => v!.isEmpty ? 'Başlık boş olamaz' : null,
                  onSaved: (v) => _title = v!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _addressLine,
                  decoration: const InputDecoration(
                    labelText: 'Tam Adres',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  maxLines: 3,
                  minLines: 1,
                  validator: (v) => v!.isEmpty ? 'Adres boş olamaz' : null,
                  onSaved: (v) => _addressLine = v!,
                ),
                // Şehir, İlçe, Posta Kodu alanları eklenebilir...
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      print('Adres: $_title - $_addressLine');
                      Navigator.pop(ctx);
                      // Gerçek uygulamada provider veya state ile liste güncellenir
                      setState(() {
                        if (addressToEdit == null) {
                          _addresses.add({
                            'title': _title,
                            'address': _addressLine,
                          });
                          _selectedAddressIndex =
                              _addresses.length - 1; // Yeni ekleneni seç
                        } else {
                          // Mevcut index'i bul ve güncelle
                          int index = _addresses.indexWhere(
                            (a) => a['title'] == addressToEdit['title'],
                          );
                          if (index != -1) {
                            _addresses[index] = {
                              'title': _title,
                              'address': _addressLine,
                            };
                          }
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: Text(
                    addressToEdit == null ? 'Adresi Kaydet' : 'Güncelle',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Metin içerikleri (Normalde bunlar ayrı dosyalardan veya API'den gelir)
  final String _preliminaryFormText = """
Ön Bilgilendirme Formu

Madde 1: Taraflar
Satıcı: [Satıcı Firma Adı]
Adres: [Satıcı Adresi]
Telefon: [Satıcı Telefon]
E-posta: [Satıcı E-posta]

Alıcı: [Alıcı Adı Soyadı]
Adres: [Alıcı Teslimat Adresi]
Telefon: [Alıcı Telefon]
E-posta: [Alıcı E-posta]

Madde 2: Konu
İşbu Ön Bilgilendirme Formu'nun konusu, Alıcı'nın Satıcı'ya ait [Web Sitesi Adresi] internet sitesinden elektronik ortamda siparişini yaptığı aşağıda nitelikleri ve satış fiyatı belirtilen ürünün/ürünlerin satışı ve teslimi ile ilgili olarak 6502 sayılı Tüketicinin Korunması Hakkında Kanun ve Mesafeli Sözleşmeler Yönetmeliği hükümleri gereğince tarafların hak ve yükümlülüklerinin belirlenmesidir.

Madde 3: Sözleşme Konusu Ürün/Ürünler Bilgileri
[Buraya sipariş edilen ürünlerin listesi, adetleri, KDV dahil fiyatları, kargo ücreti gibi bilgiler eklenecektir.]

Madde 4: Cayma Hakkı
Alıcı, sözleşme konusu ürünün kendisine veya gösterdiği adresteki kişi/kuruluşa tesliminden itibaren 14 (ondört) gün içinde hiçbir gerekçe göstermeksizin ve cezai şart ödemeksizin sözleşmeden cayma hakkına sahiptir. Cayma hakkının kullanıldığına dair bildirimin bu süre içinde Satıcı'ya yazılı olarak veya kalıcı veri saklayıcısı ile bildirilmesi yeterlidir.

[Diğer maddeler eklenecektir...]

İşbu ön bilgilendirme formunu okuduğumu, anladığımı ve kabul ettiğimi beyan ederim.
  """;

  final String _distanceSalesContractText = """
Mesafeli Satış Sözleşmesi

Madde 1: Taraflar
[Ön Bilgilendirme Formu'ndaki Taraflar bilgisi ile aynı]

Madde 2: Konu
[Ön Bilgilendirme Formu'ndaki Konu bilgisi ile aynı]

Madde 3: Sözleşme Konusu Ürün/Hizmetin Özellikleri ve Satış Bedeli
[Buraya sipariş edilen ürünlerin detaylı bilgileri, vergiler dahil toplam satış fiyatı, ödeme şekli, teslimat bilgileri, teslimat masrafları gibi bilgiler eklenecektir.]

Madde 4: Cayma Hakkı
Alıcı, hiçbir hukuki ve cezai sorumluluk üstlenmeksizin ve hiçbir gerekçe göstermeksizin malı teslim aldığı veya sözleşmenin imzalandığı tarihten itibaren ondört gün içerisinde malı veya hizmeti reddederek sözleşmeden cayma hakkının var olduğunu ve cayma bildiriminin Satıcı'ya ulaşması tarihinden itibaren Satıcı'nın malı geri almayı taahhüt ederiz.
Cayma hakkının kullanılması için bu süre içinde Satıcı'ya yazılı bildirimde bulunulması şarttır. Bu hakkın kullanılması halinde, ürünün Satıcı'ya iade edilmesi zorunludur.

[Diğer maddeler eklenecektir...]

İşbu mesafeli satış sözleşmesini okuduğumu, anladığımı ve kabul ettiğimi beyan ederim.
  """;

  // Sözleşme Onayları Bölümü
  Widget _buildAgreementSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAgreementTile(
            title: 'Ön Bilgilendirme Formu',
            accepted: _preliminaryFormAccepted,
            onChanged: (value) {
              if (value == true) {
                // Kullanıcı checkbox'ı işaretlediğinde doğrudan true yapmıyoruz,
                // önce bottom sheet'i gösteriyoruz.
                _showAgreementBottomSheet(
                  context,
                  'Ön Bilgilendirme Formu',
                  _preliminaryFormText,
                  () => setState(() => _preliminaryFormAccepted = true),
                  () => setState(
                    () => _preliminaryFormAccepted = false,
                  ), // Bottom sheet kapatılırsa veya onaylanmazsa false kalır
                );
              } else {
                setState(() => _preliminaryFormAccepted = false);
              }
            },
          ),
          _buildAgreementTile(
            title: 'Mesafeli Satış Sözleşmesi',
            accepted: _distanceSalesContractAccepted,
            onChanged: (value) {
              if (value == true) {
                _showAgreementBottomSheet(
                  context,
                  'Mesafeli Satış Sözleşmesi',
                  _distanceSalesContractText,
                  () => setState(() => _distanceSalesContractAccepted = true),
                  () => setState(() => _distanceSalesContractAccepted = false),
                );
              } else {
                setState(() => _distanceSalesContractAccepted = false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementTile({
    required String title,
    required bool accepted,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: InkWell(
        onTap: () {
          _showAgreementBottomSheet(
            context,
            title,
            title == 'Ön Bilgilendirme Formu'
                ? _preliminaryFormText
                : _distanceSalesContractText,
            () => setState(() {
              if (title == 'Ön Bilgilendirme Formu') {
                _preliminaryFormAccepted = true;
              } else {
                _distanceSalesContractAccepted = true;
              }
            }),
            () => setState(() {
              // Onaylanmazsa checkbox'ı false yap
              if (title == 'Ön Bilgilendirme Formu' &&
                  _preliminaryFormAccepted) {
                // _preliminaryFormAccepted = false; // Bu satır onChanged'i tetikler, sonsuz döngüye girebilir.
              } else if (title == 'Mesafeli Satış Sözleşmesi' &&
                  _distanceSalesContractAccepted) {
                // _distanceSalesContractAccepted = false;
              }
            }),
          );
        },
        child: Text(
          title,
          style: AppTextStyles.bodyL.copyWith(
            decoration: TextDecoration.underline,
            color: AppColors.primary,
          ),
        ),
      ),
      value: accepted,
      onChanged: onChanged, // Checkbox'a basıldığında onChanged tetiklenir
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.primary,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showAgreementBottomSheet(
    BuildContext context,
    String title,
    String content,
    VoidCallback onAccepted,
    VoidCallback onCancelled, // Kullanıcı onaylamadan kapatırsa
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: AppTextStyles.h5),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          onCancelled(); // İptal edildiğini bildir
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Text(content, style: AppTextStyles.bodyM),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      onAccepted();
                      Navigator.of(ctx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppColors.primary,
                      foregroundColor:
                          Colors.white, // Flutter 2.5 ve sonrası için
                    ),
                    child: const Text('Okudum, Onaylıyorum'),
                  ),
                  SizedBox(
                    height: MediaQuery.of(ctx).padding.bottom + 10,
                  ), // Güvenli alan için
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // Bottom sheet herhangi bir şekilde kapandığında (swipe, back button vs.)
      // Eğer onAccepted çağrılmadıysa, onCancelled'ı çağır.
      // Bu, state'in doğru yönetilmesine yardımcı olur.
      // Ancak bu mantık zaten IconButton ve ElevatedButton içinde var.
      // Belki burada ek bir kontrole gerek yoktur, test edilmeli.
    });
  }

  @override
  Widget build(BuildContext context) {
    double selectedShippingPrice =
        _shippingOptions.firstWhere(
          (opt) => opt['id'] == _selectedShippingOption,
        )['price'];
    // Payment related logic (isCOD, paymentFee) completely removed.
    // 300 TL üzeri alışverişte standart kargo bedava
    if (_selectedShippingOption == 'standard' && widget.totalAmount >= 300) {
      selectedShippingPrice = 0.0;
    }
    double finalTotal = widget.totalAmount + selectedShippingPrice;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Ödeme', showBackButton: true),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Teslimat Adresi
          _buildSectionTitle('Teslimat Adresi'),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _addresses.length,
            itemBuilder: (ctx, index) {
              final address = _addresses[index];
              final bool isSelected = _selectedAddressIndex == index;
              return InkWell(
                onTap: () => setState(() => _selectedAddressIndex = index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primary.withOpacity(0.05)
                            : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : AppColors.lightGrey,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: _selectedAddressIndex,
                        onChanged:
                            (v) => setState(() => _selectedAddressIndex = v!),
                        activeColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address['title']!,
                              style: AppTextStyles.h6.copyWith(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              address['address']!,
                              style: AppTextStyles.bodyS.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: AppColors.darkGrey,
                        ),
                        tooltip: 'Düzenle',
                        onPressed:
                            () => _showAddressFormSheet(
                              context,
                              addressToEdit: _addresses[index],
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
          TextButton.icon(
            onPressed: () => _showAddressFormSheet(context),
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.accent,
              size: 20,
            ),
            label: const Text(
              'Yeni Adres Ekle',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Kargo Seçeneği
          _buildSectionTitle(
            'Kargo Seçeneği',
            padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: AppColors.lightGrey, width: 1.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedShippingOption,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.darkGrey,
                ),
                elevation: 2,
                style: AppTextStyles.bodyL.copyWith(
                  color: AppColors.textPrimary,
                ),
                dropdownColor: AppColors.surface,
                items:
                    _shippingOptions.map((opt) {
                      bool isAvailable = opt['available'] ?? true;
                      double displayPrice = opt['price'];
                      if (opt['id'] == 'standard' &&
                          widget.totalAmount >= 300) {
                        displayPrice = 0.0;
                      }
                      return DropdownMenuItem<String>(
                        value: opt['id'],
                        enabled: isAvailable,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ), // Item padding
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${opt['name']} (${opt['eta']})',
                                  style: AppTextStyles.bodyL.copyWith(
                                    color:
                                        isAvailable
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                displayPrice == 0.0
                                    ? 'Ücretsiz'
                                    : Helpers.formatCurrency(displayPrice),
                                style: AppTextStyles.bodyL.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isAvailable
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null &&
                      _shippingOptions.firstWhere(
                        (opt) => opt['id'] == value,
                      )['available']) {
                    setState(() => _selectedShippingOption = value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // REMOVED: 3. Ödeme Yöntemi Section (Payment logic completely removed)
          const SizedBox(height: 24),

          // 4. Sipariş Özeti
          _buildSectionTitle(
            'Sipariş Özeti',
            padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.surface, // Daha temiz bir arka plan
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.lightGrey.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Ürün Toplamı:',
                  Helpers.formatCurrency(widget.totalAmount),
                ),
                const SizedBox(height: 10),
                _buildSummaryRow(
                  'Kargo Ücreti:',
                  selectedShippingPrice == 0.0
                      ? 'Ücretsiz'
                      : Helpers.formatCurrency(selectedShippingPrice),
                  isFree: selectedShippingPrice == 0.0,
                ),
                // REMOVED: Kapıda Ödeme Hizmet Bedeli row (Payment logic completely removed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: AppColors.lightGrey, thickness: 1),
                ),
                _buildSummaryRow(
                  'Genel Toplam:',
                  Helpers.formatCurrency(finalTotal),
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildAgreementSection(context),
        ],
      ),
      bottomNavigationBar: _buildBottomCompleteOrderBar(context, finalTotal),
    );
  }

  Widget _buildSectionTitle(String title, {EdgeInsetsGeometry? padding}) =>
      Padding(
        padding: padding ?? const EdgeInsets.only(top: 16.0, bottom: 8.0),
        child: Text(
          title,
          style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w600),
        ),
      );

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isFree = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              isTotal
                  ? AppTextStyles.h6
                  : AppTextStyles.bodyM.copyWith(
                    color: AppColors.textSecondary,
                  ),
        ),
        Text(
          value,
          style:
              isTotal
                  ? AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold)
                  : AppTextStyles.bodyL.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isFree ? AppColors.success : AppColors.textPrimary,
                  ),
        ),
      ],
    );
  }

  // REMOVED: _getPaymentMethodName and _getPaymentMethodIcon
  // String _getPaymentMethodName(String key) { ... }
  // IconData _getPaymentMethodIcon(String key) { ... }

  // REMOVED: _buildCreditCardFormPlaceholder
  // Widget _buildCreditCardFormPlaceholder() { ... }

  Widget _buildBottomCompleteOrderBar(BuildContext context, double finalTotal) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 12.0,
        bottom: MediaQuery.of(context).padding.bottom + 12.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, -3), // changes position of shadow
          ),
        ],
        // border: Border(top: BorderSide(color: AppColors.lightGrey.withOpacity(0.5), width: 1.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toplam Tutar:',
                style: AppTextStyles.bodyL.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                Helpers.formatCurrency(finalTotal),
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed:
                !(_preliminaryFormAccepted && _distanceSalesContractAccepted)
                    ? null
                    : () async {
                      // MODIFIED: Made async
                      // Navigate to PaymentScreen and await its result.
                      // PaymentScreen should pop with `true` for success, `false` or `null` otherwise.
                      // Ensure PaymentScreen is created and accepts 'totalAmount'.
                      // You might need to pass other details like address, shipping, cart items
                      // depending on PaymentScreen's requirements.
                      final Map<String, String> currentSelectedAddress =
                          _addresses[_selectedAddressIndex];
                      final Map<String, dynamic> currentSelectedShipping =
                          _shippingOptions.firstWhere(
                            (opt) => opt['id'] == _selectedShippingOption,
                          );

                      final paymentSuccessful = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PaymentScreen(
                                totalAmount: finalTotal,
                                // Example: pass other data if PaymentScreen needs it
                                // addressDetails: currentSelectedAddress,
                                // shippingDetails: currentSelectedShipping,
                              ),
                        ),
                      );

                      // If payment was successful and widget is still mounted
                      if (paymentSuccessful == true && mounted) {
                        final cartProvider = Provider.of<CartProvider>(
                          context,
                          listen: false,
                        );
                        // Eğer bir kupon uygulandıysa, onu kullanıldı olarak işaretle
                        if (cartProvider.appliedCoupon != null) {
                          cartProvider.markCouponAsUsed(
                            cartProvider.appliedCoupon!.id,
                          );
                        }
                        // Show success dialog
                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // User must interact with dialog
                          builder:
                              (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                titlePadding: const EdgeInsets.fromLTRB(
                                  24,
                                  24,
                                  24,
                                  10,
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(
                                  24,
                                  0,
                                  24,
                                  20,
                                ),
                                actionsPadding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                title: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: AppColors.success,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Sipariş Başarılı!',
                                      style: AppTextStyles.h5,
                                    ),
                                  ],
                                ),
                                content: Text(
                                  'Siparişiniz başarıyla alındı.\nSipariş No: ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                                  style: AppTextStyles.bodyM.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop(); // Dialogu kapat
                                      // Sepeti temizleme işlemi zaten yukarıda kupon işaretlendikten sonra yapılabilir
                                      // veya burada da kalabilir, ancak kupon işaretleme önce olmalı.
                                      Provider.of<CartProvider>(
                                        context,
                                        listen: false,
                                      ).clearCart();
                                      Provider.of<NavigationProvider>(
                                        context,
                                        listen: false,
                                      ).setIndex(0);
                                      Navigator.of(context).popUntil(
                                        (route) => route.isFirst,
                                      ); // Pop CheckoutScreen and go to home
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: Text(
                                      'ANASAYFAYA DÖN',
                                      style: AppTextStyles.button.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      } else if (paymentSuccessful == false && mounted) {
                        // Optional: Handle payment failure explicitly if PaymentScreen pops with `false`
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Ödeme başarısız oldu veya iptal edildi.",
                            ),
                          ),
                        );
                      }
                      // If paymentSuccessful is null (e.g., user backed out of PaymentScreen),
                      // no specific action is taken here, user remains on CheckoutScreen.
                    },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor:
                  (_preliminaryFormAccepted && _distanceSalesContractAccepted)
                      ? AppColors.primary
                      : AppColors.mediumGrey,
              foregroundColor:
                  (_preliminaryFormAccepted && _distanceSalesContractAccepted)
                      ? AppColors.textOnPrimary
                      : AppColors.lightGrey,
              textStyle: AppTextStyles.button.copyWith(
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation:
                  (_preliminaryFormAccepted && _distanceSalesContractAccepted)
                      ? 2
                      : 0,
            ),
            child: const Text('SİPARİŞİ TAMAMLA'),
          ),
        ],
      ),
    );
  }
}
