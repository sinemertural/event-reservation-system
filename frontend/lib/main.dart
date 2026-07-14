import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  ); // Riverpod'u başlatmak için ProviderScope ile sarmalıyoruz. bu sayede projenin her yerinde ref.watch(),ref.read() kullanabileceğiz.
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Yazdığımız GoRouter konfigürasyonunu okuyoruz
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Etkinlik Rezervasyon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // GoRouter'ı Material App'e bağlıyoruz
      routerConfig: router,
    );
  }
}
