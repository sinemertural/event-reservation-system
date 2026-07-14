import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';
import 'auth_repository.dart';

// AsyncValue<void> kullanıyoruz çünkü bu işlemler bize bir veri dönmeyecek,
// sadece Yükleniyor (Loading), Hata (Error) veya Başarılı (Data) durumlarını bileceğiz.
class AuthController extends StateNotifier<AsyncValue<void>> {
  // sürekli değişen bir duurm olduğu için (loading, başarılı, hata) -> StateNotifier
  final IAuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  Future<bool> login(String email, String password) async {
    state =
        const AsyncValue.loading(); // UI'a "Yükleniyor (Spinner) göster" emri ver
    try {
      await _authRepository.login(email, password);
      state = const AsyncValue.data(null); // İşlem bitti, spinner'ı durdur
      return true; // İşlem başarılı
    } catch (e, st) {
      state = AsyncValue.error(
        e,
        st,
      ); // UI'a "Hata mesajı göster" emri ver. st : Stack Trace (Hata nerede oluştu?)
      return false; // İşlem başarısız
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.register(name, email, password);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    // Çıkış yapıldıktan sonra uygulamayı başlangıç state'ine alıyoruz
    state = const AsyncValue.data(null);
  }
}

// Controller'ımızı arayüzde (UI) dinleyebilmek için Provider'a sarıyoruz
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return AuthController(authRepository);
    });
