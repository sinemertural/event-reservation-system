import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class NetworkClient {
  late final Dio _dio;
  final SecureStorage _secureStorage = SecureStorage();

  NetworkClient() {
    _dio = Dio(
      BaseOptions(
        // DİKKAT: Android emülatör testleri için localhost yerine 10.0.2.2 kullanılır.
        // Eğer iOS simülatör kullanıyorsan burayı 'http://127.0.0.1:3000/api' yapabilirsin.
        // Gerçek cihaz kullanacaksan bilgisayarının yerel IP adresini (örn: 192.168.1.x) yazmalısın.
        // 'http://10.0.2.2:3000/api' olan kısmı aşağıdaki gibi değiştiriyoruz:
        baseUrl: 'http://127.0.0.1:3000/api',
        connectTimeout: const Duration(
          seconds: 10,
        ), // Sunucuya bağlanmak için maksimum süre
        receiveTimeout: const Duration(
          seconds: 10,
        ), // Sunucudan yanıt almak için maksimum süre
        headers: {
          'Content-Type': 'application/json',
        }, // Tüm isteklerde JSON formatında veri gönderileceğini belirtir
      ),
    );

    _initializeInterceptors(); //Interceptor'lar, istek ve yanıtları yakalamak ve işlemek için kullanılır. Flutter -> Interceptor -> Backend
  }

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // onRequest : İSTEK GİTMEDEN HEMEN ÖNCE BURASI ÇALIŞIR
          // Kasadan token'ı al
          final token = await _secureStorage.getToken();

          // Eğer token varsa, Authorization başlığına 'Bearer <token>' formatında ekle
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // İsteğin yoluna devam etmesine izin ver
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // GLOBAL HATA YAKALAMA
          // İleride burada 401 Unauthorized gelirse kullanıcıyı otomatik logoute atma işlemleri eklenebilir.
          return handler.next(e);
        },
      ),
    );
  }

  // Dışarıdan bu ayarlanmış dio objesine erişebilmek için bir getter
  Dio get dio => _dio;
}
