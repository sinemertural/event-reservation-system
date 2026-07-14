import 'package:flutter/material.dart';
import 'package:frontend/features/auth/register_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/login_screen.dart';

// Router'ımızı da Riverpod ile sarmalıyoruz.
// İleride "Kullanıcı giriş yapmamışsa otomatik login sayfasına at" (Redirect)
// gibi güvenlik önlemlerini buraya çok kolay ekleyebiliriz.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login', // Uygulama açıldığında ilk burası çalışacak
    routes: [
      // 1. GİRİŞ YAP EKRANI
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // 2. ETKİNLİKLER (ANA SAYFA) - Şimdilik yer tutucu (Placeholder) koyuyoruz
      GoRoute(
        path: '/events',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Etkinlikler Sayfası Çok Yakında!')),
        ),
      ),

      // 3. KAYIT OL EKRANI - Şimdilik yer tutucu
      // 3. KAYIT OL EKRANI
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
});
