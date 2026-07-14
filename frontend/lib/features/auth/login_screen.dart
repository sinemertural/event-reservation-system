import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';

// Riverpod state'lerini dinleyebilmek için ConsumerStatefulWidget kullanıyoruz
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey =
      GlobalKey<FormState>(); // form widget'ının kontrolünü sağlar.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    // Login -> Events kısmına geçişte login ekranı artık olmadığı için dispose ile belleği temilziyoruz. (Memory Leak önlendi.)
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // email -> şifre -> giriş yap butonu basıldığında
    // Formdaki zorunlu alanlar doldurulmuş mu kontrol et
    if (_formKey.currentState!.validate()) {
      // Validator (doğrulama)
      // Controller'daki login fonksiyonunu tetikle
      final success = await ref
          .read(authControllerProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text.trim());

      if (success && mounted) {
        // mounted : bu ekran hala açık mı?
        context.go('/events');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // dikkat watch kullanıyoruz sebebi; loading oldu UI yeniden çizilir, error oldu UI yeniden çizilir.
    final authState = ref.watch(authControllerProvider);

    // Herhangi bir hata fırlatılırsa (Örn: Şifre yanlış) ekranda Snackbar olarak göster
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      // watch : UI yeniden çiz.  listen: Bir olay olursa bana haber ver.(ör: Snackbar)
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.event_seat, size: 80, color: Colors.blue),
                  const SizedBox(height: 24),
                  const Text(
                    'Etkinlik Rezervasyon',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),

                  // EMAIL ALANI
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'E-posta gerekli';
                      }
                      // Regex ile standart e-posta formatı kontrolü
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return 'Lütfen geçerli bir e-posta adresi girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ŞİFRE ALANI
                  TextFormField(
                    controller: _passwordController,
                    // obscureText artık dinamik: _isPasswordVisible true ise gizleme (!true = false)
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      // suffixIcon: Kutucuğun sağına ikon ekler
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          // İkona tıklandığında durumu tersine çevir ve ekranı yeniden çiz
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Şifre gerekli';
                      }
                      if (value.length < 6) {
                        return 'Şifre en az 6 karakter olmalıdır';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // GİRİŞ BUTONU
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleLogin,
                      child: authState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Giriş Yap',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),

                  // KAYIT OL YÖNLENDİRMESİ
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('Hesabın yok mu? Kayıt Ol'),
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
