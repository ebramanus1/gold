import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

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
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryGold,
              AppTheme.lightGold,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(UIConstants.paddingLarge),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.paddingXLarge),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // شعار التطبيق
                      _buildLogo(),
                      
                      const SizedBox(height: UIConstants.paddingLarge),
                      
                      // عنوان تسجيل الدخول
                      Text(
                        'تسجيل الدخول',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                      
                      const SizedBox(height: UIConstants.paddingSmall),
                      
                      Text(
                        'أدخل بيانات الدخول للوصول إلى النظام',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.grey600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: UIConstants.paddingLarge),
                      
                      // نموذج تسجيل الدخول
                      _buildLoginForm(),
                      
                      const SizedBox(height: UIConstants.paddingLarge),
                      
                      // أزرار المصادقة البديلة
                      _buildAlternativeAuth(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGold, AppTheme.accentGold],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.diamond,
        size: 50,
        color: AppTheme.white,
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // حقل اسم المستخدم
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'اسم المستخدم',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال اسم المستخدم';
              }
              return null;
            },
          ),
          
          const SizedBox(height: UIConstants.paddingMedium),
          
          // حقل كلمة المرور
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور';
              }
              if (value.length < AppConstants.passwordMinLength) {
                return 'كلمة المرور قصيرة جداً';
              }
              return null;
            },
          ),
          
          const SizedBox(height: UIConstants.paddingMedium),
          
          // خيارات إضافية
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
              const Text('تذكرني'),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // نسيت كلمة المرور
                },
                child: const Text('نسيت كلمة المرور؟'),
              ),
            ],
          ),
          
          const SizedBox(height: UIConstants.paddingLarge),
          
          // زر تسجيل الدخول
          SizedBox(
            width: double.infinity,
            height: UIConstants.buttonHeightLarge,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const CircularProgressIndicator(color: AppTheme.white)
                  : const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: UIConstants.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeAuth() {
    return Column(
      children: [
        const Divider(),
        
        const SizedBox(height: UIConstants.paddingMedium),
        
        Text(
          'أو سجل الدخول باستخدام',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.grey600,
          ),
        ),
        
        const SizedBox(height: UIConstants.paddingMedium),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // المصادقة البيومترية
            _buildAuthButton(
              icon: Icons.fingerprint,
              label: 'بصمة الإصبع',
              onPressed: _handleBiometricAuth,
            ),
            
            // Face ID
            _buildAuthButton(
              icon: Icons.face,
              label: 'Face ID',
              onPressed: _handleFaceIdAuth,
            ),
            
            // رمز QR
            _buildAuthButton(
              icon: Icons.qr_code,
              label: 'رمز QR',
              onPressed: _handleQrAuth,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.grey100,
            border: Border.all(color: AppTheme.grey300),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: AppTheme.primaryGold,
              size: UIConstants.iconSizeLarge,
            ),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: UIConstants.paddingSmall),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

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
      if (_usernameController.text == 'admin' && _passwordController.text == 'password') {
        // نجح تسجيل الدخول
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
      const SnackBar(content: Text('المصادقة البيومترية غير متاحة حالياً')),
    );
  }

  void _handleFaceIdAuth() {
    // تنفيذ Face ID
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Face ID غير متاح حالياً')),
    );
  }

  void _handleQrAuth() {
    // تنفيذ مصادقة QR
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('مصادقة QR غير متاحة حالياً')),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}

