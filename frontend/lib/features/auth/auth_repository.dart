import 'package:dio/dio.dart';
import '../../../core/storage/secure_storage.dart';

abstract class IAuthRepository {
  Future<void> login(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<void> logout();
}

// Sadece API ile konuşmaktan ve token kaydetmekten sorumludur.
class AuthRepository implements IAuthRepository {
  final Dio _dio;
  final SecureStorage _secureStorage;

  AuthRepository(this._dio, this._secureStorage);

  @override
  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post(
        // tam URL yazmıyoruz. Network Client' ta baseUrl var zaten.
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // Backend'den gelen token'ı güvenli kasaya kaydet
      final String token = response.data['data']['token'];
      await _secureStorage.saveToken(token);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ??
          'Giriş yapılamadı. Lütfen tekrar deneyin.';
      throw Exception(errorMessage);
    }
  }

  @override
  Future<void> register(String name, String email, String password) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      // Kayıt başarılıysa UI tarafında login sayfasına yönlendirme yapacağız
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Kayıt işlemi başarısız oldu.';
      throw Exception(errorMessage);
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.deleteToken();
  }
}
