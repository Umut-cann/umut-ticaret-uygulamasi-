


import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Yönlendirme için
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/common/social_login_button.dart';
import '../main_screen.dart';
import 'signup_screen.dart';
import '../../providers/navigation_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _rememberMe = false;

  void _showOtpSheet(BuildContext context) {
     String _phoneNumber = '';
     String _otpCode = '';
     bool _otpSent = false;
     bool _isLoading = false; // Yüklenme durumu

     showModalBottomSheet(
        context: context, isScrollControlled: true,
         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        builder: (ctx) {
          return StatefulBuilder(
             builder: (BuildContext context, StateSetter setModalState){
               return Padding(
                 padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
                 child: Column(
                    mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 15), decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(10)))),
                      Text('Telefon Numarası ile Giriş', style: AppTextStyles.h5),
                      const SizedBox(height: 16),
                      if (!_otpSent)
                        TextFormField(
                           decoration: const InputDecoration(labelText: 'Telefon Numarası (5xxxxxxxxx)', prefixIcon: Icon(Icons.phone_android_outlined)),
                            keyboardType: TextInputType.phone,
                            autofocus: true, // Otomatik focus
                           validator: (v) => (v == null || v.length < 10) ? 'Geçerli numara girin' : null,
                           onSaved: (v) => _phoneNumber = v!,
                           onChanged: (v) => _phoneNumber = v,
                         )
                      else // OTP Gönderildiyse
                        Column( crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              Text('$_phoneNumber numarasına gönderilen 6 haneli kodu girin.', style: AppTextStyles.bodyM),
                              const SizedBox(height: 12),
                             TextFormField(
                                decoration: const InputDecoration(labelText: 'Doğrulama Kodu (OTP)', prefixIcon: Icon(Icons.password_outlined)),
                                keyboardType: TextInputType.number, maxLength: 6, autofocus: true,
                                validator: (v) => (v == null || v.length < 6) ? '6 haneli kodu girin' : null,
                                onSaved: (v) => _otpCode = v!,
                                onChanged: (v) => _otpCode = v,
                              ),
                           ],
                        ),
                      const SizedBox(height: 24),
                       ElevatedButton(
                          onPressed: _isLoading ? null : () async { // Async işlem
                             setModalState(() => _isLoading = true);
                             await Future.delayed(Duration(seconds: 1)); // Simülasyon

                             if (!_otpSent) {
                                if (_phoneNumber.length >= 10) {
                                   print('OTP gönderiliyor: $_phoneNumber');
                                   setModalState(() { _otpSent = true; });
                                } else {
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lütfen geçerli bir telefon numarası girin.'), backgroundColor: AppColors.error));
                                }
                             } else {
                                if (_otpCode.length == 6) {
                                   print('OTP Doğrulandı: $_otpCode');
                                   Navigator.pop(ctx);
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
                                } else {
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lütfen 6 haneli kodu girin.'), backgroundColor: AppColors.error));
                                }
                             }
                              setModalState(() => _isLoading = false);
                          },
                           style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(_otpSent ? 'Doğrula ve Giriş Yap' : 'Doğrulama Kodu Gönder'),
                       ),
                       if (_otpSent)
                          TextButton(
                            onPressed: _isLoading ? null : () { setModalState(() { _otpSent = false; }); },
                             child: Text('Numarayı Değiştir veya Tekrar Gönder', style: AppTextStyles.bodyS.copyWith(color: AppColors.accent)),
                          ),
                   ],
                 ),
               );
             }
          );
        },
     );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.storefront, size: screenSize.width * 0.2, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text('Tekrar Hoş Geldiniz!', style: AppTextStyles.h3, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Hesabınıza giriş yapın.', style: AppTextStyles.bodyL.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'E-posta Adresi', prefixIcon: Icon(Icons.email_outlined)),
                    keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || !v.contains('@')) ? 'Geçerli e-posta girin' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Şifre', prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.darkGrey),
                        onPressed: () => setState(() => _obscureText = !_obscureText)),
                    ),
                    obscureText: _obscureText, textInputAction: TextInputAction.done,
                    validator: (v) => (v == null || v.length < 6) ? 'Şifre en az 6 karakter olmalı' : null,
                     onFieldSubmitted: (_) { // Klavye gönder tuşuna basınca
                        if (_formKey.currentState!.validate()) {
                           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
                        }
                     },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 24, height: 24, child: Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v!), activeColor: AppColors.primary, visualDensity: VisualDensity.compact, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
                           const SizedBox(width: 4),
                          GestureDetector(onTap: () => setState(() => _rememberMe = !_rememberMe), child: Text('Beni Hatırla', style: AppTextStyles.bodyS)),
                        ],
                      ),
                      TextButton(onPressed: () { /* Şifremi Unuttum */ }, style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text('Şifremi Unuttum?', style: AppTextStyles.bodyS.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        print('Giriş yapılıyor...');
                         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
                      }
                    },
                     style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Giriş Yap'),
                  ),
                  const SizedBox(height: 20),
                  Row( // VEYA Ayırıcı
                    children: [
                      const Expanded(child: Divider(thickness: 0.8)),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Text('VEYA', style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary))),
                      const Expanded(child: Divider(thickness: 0.8)),
                    ],
                  ),
                  const SizedBox(height: 20),
                   OutlinedButton.icon( // Telefonla Giriş
                      onPressed: () => _showOtpSheet(context), icon: const Icon(Icons.phone_android_outlined), label: const Text('Telefon Numarası ile Giriş Yap'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                   ),
                  const SizedBox(height: 16),
                  Row( // Sosyal Medya
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialLoginButton(icon: Icons.g_mobiledata_outlined, label: 'Google', iconColor: Colors.red, onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen())); }),
                      const SizedBox(width: 16),
                       SocialLoginButton(icon: Icons.apple, label: 'Apple', iconColor: Colors.black, onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen())); }),
                       const SizedBox(width: 16),
                       SocialLoginButton(icon: Icons.facebook, label: 'Facebook', iconColor: Colors.blueAccent, onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen())); }),
                    ],
                  ),
                  const SizedBox(height: 24),
                    TextButton( // Misafir Girişi
                       onPressed: () {
                          // Gerçek uygulamada misafir state'i ayarlanır
                          Provider.of<NavigationProvider>(context, listen: false).setIndex(0);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
                       },
                       child: Text('Misafir Olarak Devam Et', style: AppTextStyles.bodyM.copyWith(color: AppColors.darkGrey, decoration: TextDecoration.underline)),
                    ),
                   const SizedBox(height: 16),
                  Row( // Kayıt Ol
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Hesabınız yok mu?', style: AppTextStyles.bodyM),
                      TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                        child: Text('Kayıt Ol', style: AppTextStyles.bodyM.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
                    ],
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
