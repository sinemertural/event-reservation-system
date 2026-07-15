import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';
import 'event_model.dart';

abstract class IEventRepository {
  Future<List<EventModel>> getEvents({
    int page = 1,
    int limit = 4,
    String? date,
  });

  Future<EventModel> getEventById(String id);
}

class EventRepository implements IEventRepository {
  final Dio _dio;

  EventRepository(this._dio);

  @override
  Future<List<EventModel>> getEvents({
    int page = 1,
    int limit = 4,
    String? date,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};

      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date;
      }

      final response = await _dio.get('/events', queryParameters: queryParams);

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => EventModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ??
          'Etkinlikler yüklenirken bir hata oluştu.';
      throw Exception(errorMessage);
    }
  }

  @override
  Future<EventModel> getEventById(String id) async {
    try {
      final response = await _dio.get('/events/$id');

      return EventModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Etkinlik detayı bulunamadı.';
      throw Exception(errorMessage);
    }
  }
}

// 3. PROVIDER (DEPENDENCY INJECTION)
final eventRepositoryProvider = Provider<IEventRepository>((ref) {
  final networkClient = ref.watch(networkClientProvider);
  return EventRepository(networkClient.dio);
});
