import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Singleton pattern: _instance isimli tek bir nesne oluşturup uygulama boyunca SecureStorage sadece bir kere oluşturulacak. (Bellek dostu)
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage(); //_storage sayesinde _storage.write(),_storage.read(),_storage.delete() gibi metodlara erişebileceğiz.

  // Anahtar kelimemiz
  final String _tokenKey = 'jwt_token';

  // Token'ı Kasaya Kilitle (Login sonrası kullanılacak)
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // 2. Token'ı Kasadan Oku (API isteklerinde kullanılacak)
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // 3. Token'ı Kasadan Sil (Logout işleminde kullanılacak)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
