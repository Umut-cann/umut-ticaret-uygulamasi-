import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import 'package:umut_ticaret/constants/app_colors.dart';
import 'package:umut_ticaret/screens/home/home_screen.dart';
import 'package:umut_ticaret/screens/main_screen.dart'; // Assuming you have AppColors defined

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  // bool useBackgroundImage = false; // Removed as PNGs are being removed
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    border = OutlineInputBorder(
      // This 'border' variable is defined but not used. Can be removed if not needed elsewhere.
      borderSide: BorderSide(
        color: AppColors.primary.withOpacity(0.7),
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(8.0),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kart Bilgileri',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              CreditCardWidget(
                enableFloatingCard:
                    false, // true might look more modern if desired
                // glassmorphismConfig: Glassmorphism(
                //   blurX: 1.0,
                //   blurY: 1.0,
                //   gradient: LinearGradient(
                //     colors: [
                //       AppColors.primary.withOpacity(0.8), // Using AppColors
                //       AppColors.primary.withOpacity(0.6), // Using AppColors
                //     ],
                //     begin: Alignment.topLeft,
                //     end: Alignment.bottomRight,
                //   ),
                // ),
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                bankName: '', // Keep it clean
                frontCardBorder: Border.all(color: Colors.transparent),
                backCardBorder: Border.all(color: Colors.transparent),
                showBackView: isCvvFocused,
                obscureCardNumber: true,
                obscureCardCvv: true,
                isHolderNameVisible: true,
                cardBgColor: AppColors.primary.withOpacity(0.9),
                backgroundImage: null, // Removed PNG background image reference
                isSwipeGestureEnabled: true,
                onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                // Removed customCardTypeIcons that used PNGs.
                // The library will use its default icons or show nothing if defaults aren't available for specific types.
                // If you still want custom icons but not PNGs, you could use Icon widgets here.
                // For example:
                // customCardTypeIcons: <CustomCardTypeIcon>[
                //   CustomCardTypeIcon(
                //     cardType: CardType.mastercard,
                //     cardImage: const Icon(Icons.credit_card, size: 48, color: Colors.white), // Example using an Icon
                //   ),
                //    CustomCardTypeIcon(
                //     cardType: CardType.visa,
                //     cardImage: const Icon(Icons.payment, size: 48, color: Colors.white), // Example using an Icon
                //   ),
                // ],
                // For now, we remove them entirely as requested.
                // If the library has built-in SVG or font icons for Visa/Mastercard, they might show up.
                // Otherwise, it might show a generic icon or text.
                customCardTypeIcons: const [], // No custom PNG icons
                labelCardHolder: 'KART SAHİBİ',
                labelExpiredDate: 'SKT',
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      CreditCardForm(
                        formKey: formKey,
                        obscureCvv: true,
                        obscureNumber: true,
                        cardNumber: cardNumber,
                        cvvCode: cvvCode,
                        isHolderNameVisible: true,
                        isCardNumberVisible: true,
                        isExpiryDateVisible: true,
                        cardHolderName: cardHolderName,
                        expiryDate: expiryDate,
                        inputConfiguration: InputConfiguration(
                          cardNumberDecoration: _modernInputDecoration(
                            labelText: 'Kart Numarası',
                            hintText: '•••• •••• •••• ••••',
                            prefixIcon: Icons.credit_card,
                          ),
                          expiryDateDecoration: _modernInputDecoration(
                            labelText: 'Son Kullanma Tarihi',
                            hintText: 'AA/YY',
                            prefixIcon: Icons.calendar_today,
                          ),
                          cvvCodeDecoration: _modernInputDecoration(
                            labelText: 'CVV',
                            hintText: '•••',
                            prefixIcon: Icons.lock_outline,
                          ),
                          cardHolderDecoration: _modernInputDecoration(
                            labelText: 'Kart Sahibi Adı Soyadı',
                            prefixIcon: Icons.person_outline,
                          ),
                          cardNumberTextStyle: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          cardHolderTextStyle: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          expiryDateTextStyle: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          cvvCodeTextStyle: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        onCreditCardModelChange: onCreditCardModelChange,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textOnPrimary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            minimumSize: const Size(double.infinity, 52),
                            elevation: 2,
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              print('Form is valid. Processing payment...');
                              _handlePaymentSuccess();
                            } else {
                              print('Form is invalid.');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Lütfen kart bilgilerinizi kontrol edin.',
                                  ),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'ÖDEMEYİ TAMAMLA',
                            style: TextStyle(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // For scrollability
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    if (creditCardModel != null) {
      setState(() {
        cardNumber = creditCardModel.cardNumber;
        expiryDate = creditCardModel.expiryDate;
        cardHolderName = creditCardModel.cardHolderName;
        cvvCode = creditCardModel.cvvCode;
        isCvvFocused = creditCardModel.isCvvFocused;
      });
    }
  }

  InputDecoration _modernInputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      labelStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon:
          prefixIcon != null
              ? Icon(prefixIcon, color: AppColors.primary, size: 20)
              : null,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: AppColors.lightGrey.withOpacity(0.8),
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: AppColors.lightGrey.withOpacity(0.8),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  void _handlePaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(width: 20),
                    Text(
                      "Ödeme işleniyor...",
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close loading dialog
      _showSuccessDialogAndReturn();
    });
  }

  void _showSuccessDialogAndReturn() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
            contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ödeme Başarılı!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            content: Text(
              'Kart bilgileriniz başarıyla doğrulandı ve ödemeniz alındı.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const MainScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  'TAMAM',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
