import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_client.dart';
import '../../../core/storage/secure_storage.dart';
import 'auth_repository.dart';

//Provider görevi "depo". Uygulama içerisinde kullanılacak olan nesneleri verir.

final networkClientProvider = Provider<NetworkClient>(
  (ref) => NetworkClient(),
); // uygulamada biri NetworkClient isterse ona oluşturup ver.
final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

// AuthRepository'yi inşa edip sisteme sunan provider (Dependency Injection)
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final networkClient = ref.watch(networkClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);

  return AuthRepository(networkClient.dio, secureStorage);
});
