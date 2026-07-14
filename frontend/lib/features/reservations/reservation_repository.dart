import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/auth_providers.dart';
import 'reservation_model.dart';

abstract class IReservationRepository {
  Future<bool> createReservation(String eventId, int guestCount);
  Future<List<ReservationModel>> getMyReservations();
  Future<bool> cancelReservation(String reservationId);
}

class ReservationRepository implements IReservationRepository {
  final Dio _dio;

  ReservationRepository(this._dio);

  @override
  Future<bool> createReservation(String eventId, int guestCount) async {
    try {
      await _dio.post(
        '/reservations',
        data: {'event_id': eventId, 'guest_count': guestCount},
      );
      return true;
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Rezervasyon işlemi başarısız oldu.';
      throw Exception(errorMessage);
    }
  }

  @override
  Future<List<ReservationModel>> getMyReservations() async {
    try {
      final response = await _dio.get('/reservations/me');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => ReservationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Rezervasyonlarınız yüklenemedi.';
      throw Exception(errorMessage);
    }
  }

  @override
  Future<bool> cancelReservation(String reservationId) async {
    try {
      await _dio.delete('/reservations/$reservationId');
      return true;
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'İptal işlemi başarısız oldu.';
      throw Exception(errorMessage);
    }
  }
}

// UI katmanından bu repository'e erişebilmek için Provider'ımızı tanımlıyoruz
final reservationRepositoryProvider = Provider<IReservationRepository>((ref) {
  final networkClient = ref.watch(networkClientProvider);
  return ReservationRepository(networkClient.dio);
});
