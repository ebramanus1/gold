import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../main/main_screen.dart';

// Assuming languageProvider is defined elsewhere, for example:
// final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
//   return LanguageNotifier();
// });
//
// class LanguageNotifier extends StateNotifier<Locale> {
//   LanguageNotifier() : super(const Locale('ar')); // Default language
//
//   void changeLanguage(String langCode) {
//     state = Locale(langCode);
//   }
// }


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_me') ?? false;
    if (remember) {
      setState(() {
        _rememberMe = true;
        _usernameController.text = prefs.getString('saved_username') ?? '';
        _passwordController.text = prefs.getString('saved_password') ?? '';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  /// A new, more stylish language switcher widget using PopupMenuButton.
  Widget _buildLanguageSwitcher() {
    return PopupMenuButton<String>(
      onSelected: (String newLang) {
        // Change the language using the Riverpod provider.
        ref.read(languageProvider.notifier).changeLanguage(newLang);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'ar',
          child: Text('العربية'),
        ),
        const PopupMenuItem<String>(
          value: 'en',
          child: Text('English'),
        ),
      ],
      // This is the button's appearance.
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        // --- FIX: Using Theme.of(context).primaryColor which is a standard theme color ---
        // Also removed 'const' because Theme.of(context) is not a compile-time constant.
        child: Icon(
          Icons.language,
          color: Theme.of(context).primaryColor, 
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // We no longer need the locale from the provider here for the dropdown
    // final locale = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(localizations.translate('login_title') ?? 'تسجيل الدخول', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        // --- CHANGE: The language switcher is removed from actions ---
        actions: const [], 
      ),
      // --- CHANGE: The body is now a Stack to overlay the language button ---
      body: Stack(
        children: [
          // This is the original content of your screen
          Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(UIConstants.paddingXXLarge),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.paddingLarge),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: localizations.translate('auth.username') ?? 'اسم المستخدم',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              prefixIcon: const Icon(Icons.person),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) => value == null || value.isEmpty ? (localizations.translate('required_field') ?? 'مطلوب') : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: localizations.translate('auth.password') ?? 'كلمة المرور',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) => value == null || value.isEmpty ? (localizations.translate('required_field') ?? 'مطلوب') : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                              ),
                              Text(localizations.translate('auth.rememberMe') ?? 'تذكرني'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() => _isLoading = true);
                                        await Future.delayed(const Duration(seconds: 1));
                                        setState(() => _isLoading = false);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(localizations.translate('login_success') ?? 'تم تسجيل الدخول بنجاح!')),
                                        );
                                        await Future.delayed(const Duration(milliseconds: 500));
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => const MainScreen()),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(localizations.translate('auth.login') ?? 'تسجيل الدخول', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // --- CHANGE: This is the new language button, positioned absolutely ---
          Positioned(
            top: 16.0,
            right: 16.0,
            child: _buildLanguageSwitcher(),
          ),
        ],
      ),
    );
  }

  // The rest of your methods remain unchanged.
  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // محاكاة عملية تسجيل الدخول
      await Future.delayed(const Duration(seconds: 2));
      
      // في التطبيق الحقيقي، ستتم المصادقة هنا
      if (_usernameController.text == 'zxc' && _passwordController.text == 'zxc') {
        // نجح تسجيل الدخول
        if (_rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('remember_me', true);
          await prefs.setString('saved_username', _usernameController.text);
          await prefs.setString('saved_password', _passwordController.text);
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('remember_me');
          await prefs.remove('saved_username');
          await prefs.remove('saved_password');
        }
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/main');
        }
      } else {
        // فشل تسجيل الدخول
        _showErrorDialog('بيانات الدخول غير صحيحة');
      }
    } catch (e) {
      _showErrorDialog('حدث خطأ أثناء تسجيل الدخول');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleBiometricAuth() {
    // تنفيذ المصادقة البيومترية
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Builder(
          builder: (context) {
            final localizations = AppLocalizations.of(context)!;
            return Text(localizations.translate('biometric_not_available') ?? 'المصادقة البيومترية غير متاحة حالياً');
          },
        ),
      ),
    );
  }

  void _handleFaceIdAuth() {
    // تنفيذ Face ID
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Builder(
          builder: (context) {
            final localizations = AppLocalizations.of(context)!;
            return Text(localizations.translate('faceid_not_available') ?? 'Face ID غير متاح حالياً');
          },
        ),
      ),
    );
  }

  void _handleQrAuth() {
    // تنفيذ مصادقة QR
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Builder(
          builder: (context) {
            final localizations = AppLocalizations.of(context)!;
            return Text(localizations.translate('qr_not_available') ?? 'مصادقة QR غير متاحة حالياً');
          },
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Builder(
          builder: (context) {
            final localizations = AppLocalizations.of(context)!;
            return Text(localizations.translate('error') ?? 'خطأ');
          },
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Builder(
              builder: (context) {
                final localizations = AppLocalizations.of(context)!;
                return Text(localizations.translate('ok') ?? 'موافق');
              },
            ),
          ),
        ],
      ),
    );
  }
}
