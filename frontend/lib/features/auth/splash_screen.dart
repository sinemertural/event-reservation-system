import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/auth_providers.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Ekran çizildikten hemen sonra token kontrolünü başlatıyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    // 1. SecureStorage'dan token'ı oku (Metot adın readToken veya getToken olabilir, ona göre düzeltirsin)
    final secureStorage = ref.read(secureStorageProvider);
    final token = await secureStorage.getToken();

    if (mounted) {
      if (token != null && token.isNotEmpty) {
        context.go('/events'); // token varsa içeri al
      } else {
        context.go('/login'); // token yoksa login sayfasına git
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
