import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'event_model.dart';
import 'event_repository.dart';

class EventListController extends AutoDisposeAsyncNotifier<List<EventModel>> {
  int _currentPage = 1;
  bool _hasMore = true; // Daha fazla sayfa var mı?
  bool _isLoadingMore = false; // Şu an alt sayfayı çekiyor muyuz?

  @override
  FutureOr<List<EventModel>> build() async {
    _currentPage = 1;
    _hasMore = true;
    return _fetchEvents(page: _currentPage);
  }

  // Ortak veri çekme fonksiyonu
  Future<List<EventModel>> _fetchEvents({
    required int page,
    String? date,
  }) async {
    final repository = ref.read(eventRepositoryProvider);
    // Limiti 4 olarak ayarladık
    final newEvents = await repository.getEvents(
      page: page,
      limit: 4,
      date: date,
    );

    // Eğer gelen veri 4'den azsa, demek ki son sayfaya ulaştık
    if (newEvents.length < 4) {
      _hasMore = false;
    }
    return newEvents;
  }

  // Pull-to-refresh veya Tarih Filtresi
  Future<void> refreshEvents({String? date}) async {
    state = const AsyncLoading();
    _currentPage = 1; // Yenilemede sayfayı başa sar
    _hasMore = true;

    state = await AsyncValue.guard(() async {
      return _fetchEvents(page: _currentPage, date: date);
    });
  }

  // YENİ: Listenin sonuna gelince çalışacak Sonsuz Kaydırma (Load More) metodu
  Future<void> loadMore({String? date}) async {
    // Zaten yüklüyorsa veya daha fazla veri yoksa işlemi kes
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    _currentPage++; // Sonraki sayfaya geç

    try {
      final newEvents = await _fetchEvents(page: _currentPage, date: date);

      // Mevcut listeyi koruyup, yeni gelenleri listenin sonuna ekliyoruz
      if (state.hasValue) {
        state = AsyncData([...state.value!, ...newEvents]);
      }
    } catch (e) {
      _currentPage--; // Hata alırsak sayfa numarasını geri al
    } finally {
      _isLoadingMore = false;
    }
  }
}

// UI katmanından bu controller'ı dinlemek için Provider'ımızı tanımlıyoruz
final eventListControllerProvider =
    AsyncNotifierProvider.autoDispose<EventListController, List<EventModel>>(
      () {
        return EventListController();
      },
    );

final eventDetailProvider = FutureProvider.family
    .autoDispose<EventModel, String>((ref, id) async {
      final repository = ref.read(eventRepositoryProvider);
      return await repository.getEventById(id);
    });
