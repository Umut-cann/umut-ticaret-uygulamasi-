
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../main_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController(); // Şifre karşılaştırması için
  bool _obscureText = true;
  bool _obscureConfirmText = true;
  bool _agreeToTerms = false;
  bool _isLoading = false; // Yüklenme durumu

  @override
  void dispose() {
     _passwordController.dispose(); // Controller'ı temizle
     super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final screenSize = MediaQuery.of(context).size;

    return Scaffold(
       appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary), onPressed: () => Navigator.pop(context))),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Text('Hesap Oluştur', style: AppTextStyles.h3, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Hızlıca kayıt olun ve alışverişe başlayın.', style: AppTextStyles.bodyL.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                   TextFormField(
                    decoration: const InputDecoration(labelText: 'Ad Soyad', prefixIcon: Icon(Icons.person_outline)),
                    keyboardType: TextInputType.name, textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.isEmpty) ? 'Ad Soyad boş olamaz' : null,
                  ),
                   const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'E-posta Adresi', prefixIcon: Icon(Icons.email_outlined)),
                    keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || !v.contains('@')) ? 'Geçerli e-posta girin' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController, // Controller'ı bağla
                    decoration: InputDecoration(labelText: 'Şifre', prefixIcon: const Icon(Icons.lock_outline),
                       suffixIcon: IconButton(icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.darkGrey), onPressed: () => setState(() => _obscureText = !_obscureText))),
                    obscureText: _obscureText, textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.length < 6) ? 'Şifre en az 6 karakter olmalı' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Şifre Tekrar', prefixIcon: const Icon(Icons.lock_outline),
                       suffixIcon: IconButton(icon: Icon(_obscureConfirmText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.darkGrey), onPressed: () => setState(() => _obscureConfirmText = !_obscureConfirmText))),
                    obscureText: _obscureConfirmText, textInputAction: TextInputAction.done,
                     validator: (v) {
                       if (v == null || v.isEmpty) return 'Şifreyi tekrar girin';
                       if (v != _passwordController.text) return 'Şifreler uyuşmuyor';
                       return null;
                     },
                      onFieldSubmitted: (_) => _submitForm(), // Klavye bitti tuşuna basınca
                  ),
                   const SizedBox(height: 16),
                   CheckboxListTile(
                      value: _agreeToTerms,
                      onChanged: (v) => setState(() => _agreeToTerms = v!),
                      title: GestureDetector(
                         onTap: (){ /* Kullanım Koşulları */ },
                         child: RichText(text: TextSpan(style: AppTextStyles.bodyS.copyWith(color: AppColors.textPrimary),
                           children: [
                              TextSpan(text: 'Kullanım Koşulları\'nı'), TextSpan(text: ' ve ', style: TextStyle(color: AppColors.textSecondary)),
                              TextSpan(text: 'Gizlilik Politikası\'nı', style: TextStyle(color: AppColors.accent, decoration: TextDecoration.underline)),
                              TextSpan(text: ' okudum, onaylıyorum.'),
                           ])),
                      ),
                      controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero, activeColor: AppColors.primary,
                        // Hata durumu (form denendiğinde ve işaretli değilse)
                       side: BorderSide(color: !_agreeToTerms && (_formKey.currentState?.validate() == false || _isLoading) ? AppColors.error : AppColors.darkGrey, width: 1.5),
                    ),
                    // Hata mesajı (opsiyonel, CheckboxListTile'ın altına)
                   if (!_agreeToTerms && _isLoading) // Sadece submit denendiğinde göster
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 4),
                        child: Text('Devam etmek için onaylamanız gerekir.', style: AppTextStyles.bodyS.copyWith(color: AppColors.error)),
                      ),
                   const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm, // Yükleniyorsa pasif
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isLoading
                       ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                       : const Text('Kayıt Ol'),
                  ),
                  const SizedBox(height: 20),
                  Row( // Giriş Yap
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Zaten hesabınız var mı?', style: AppTextStyles.bodyM),
                      TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                        child: Text('Giriş Yap', style: AppTextStyles.bodyM.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
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

  // Form gönderme fonksiyonu
  void _submitForm() async {
     setState(() => _isLoading = true); // Yükleniyor durumunu başlat
     await Future.delayed(Duration(milliseconds: 100)); // Hata mesajının görünmesi için kısa bekleme

     if (_formKey.currentState!.validate() && _agreeToTerms) {
        _formKey.currentState!.save();
        print('Kayıt olunuyor...');
        // Simülasyon
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainScreen()), (Route<dynamic> route) => false);
     } else if (!_agreeToTerms) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lütfen Kullanım Koşulları\'nı onaylayın.'), backgroundColor: AppColors.error));
     }
     // Validate başarısız olursa veya terms kabul edilmezse isLoading'i false yap
     if(mounted) { // Widget hala ağaçtaysa state'i güncelle
        setState(() => _isLoading = false);
     }
  }
}
