import 'package:frontend/features/auth/register_screen.dart';
import 'package:frontend/features/auth/splash_screen.dart';
import 'package:frontend/features/events/event_detail_screen.dart';
import 'package:frontend/features/events/events_screen.dart';
import 'package:frontend/features/reservations/reservatios_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/login_screen.dart';

// Router'ımızı da Riverpod ile sarmalıyoruz.
// İleride "Kullanıcı giriş yapmamışsa otomatik login sayfasına at" (Redirect)
// gibi güvenlik önlemlerini buraya çok kolay ekleyebiliriz.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/', // Uygulama açıldığında ilk splash screen
    routes: [
      // 0. SPLASH SCREEN
      GoRoute(path: ('/'), builder: (context, state) => const SplashScreen()),

      // 1. GİRİŞ YAP EKRANI
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // 2. KAYIT OL EKRANI
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // 3. ETKİNLİKLER (ANA SAYFA)
      GoRoute(
        path: '/events',
        builder: (context, state) => const EventsScreen(),
      ),

      // 4. ETKİNLİK DETAYI EKRANI
      GoRoute(
        path: '/events/:id',
        builder: (context, state) {
          // URL'deki ':id' parametresini yakalıyoruz
          final eventId = state.pathParameters['id']!;
          return EventDetailScreen(eventId: eventId);
        },
      ),

      GoRoute(
        path: '/my-reservations',
        builder: (context, state) => const ReservationsScreen(),
      ),
    ],
  );
});
