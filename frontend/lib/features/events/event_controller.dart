import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'event_model.dart';
import 'event_repository.dart';

// Ekran kapandığında belleği temizlemek için AutoDispose kullanıyoruz. ve asenkron çalışan bir state kullanacağını belli ediyor. (AsyncNotifier)
class EventListController extends AutoDisposeAsyncNotifier<List<EventModel>> {
  @override
  FutureOr<List<EventModel>> build() async {
    // Uygulama açılır açılmaz 1. sayfa verilerini çekiyoruz
    return _fetchInitialEvents();
  }

  Future<List<EventModel>> _fetchInitialEvents() async {
    final repository = ref.read(eventRepositoryProvider);
    // Şimdilik ilk 10 kaydı getiriyoruz. (Sonsuz kaydırma için burayı daha sonra genişletebiliriz)
    return await repository.getEvents(page: 1, limit: 10);
  }

  // Pull-to-refresh (Yukarıdan çekip yenileme) veya Tarih Filtresi uygulandığında çalışacak metod
  Future<void> refreshEvents({String? date}) async {
    // Arayüze "Yükleniyor" durumunu bildir
    state = const AsyncLoading();

    // AsyncValue.guard = try-catch bloğu
    // Başarılı olursa AsyncData, hata alırsak otomatik olarak AsyncError döner.
    state = await AsyncValue.guard(() async {
      final repository = ref.read(eventRepositoryProvider);
      return await repository.getEvents(page: 1, limit: 10, date: date);
    });
  }
}

// UI katmanından bu controller'ı dinlemek için Provider'ımızı tanımlıyoruz
final eventListControllerProvider =
    AsyncNotifierProvider.autoDispose<EventListController, List<EventModel>>(
      () {
        return EventListController();
      },
    );

// FutureProvider.family özelliği dışarıdan bir parametre alıp tek seferlik veri çekmek için kullanılır.
// ID'ye göre tekil etkinlik detayını getiren provider
final eventDetailProvider = FutureProvider.family
    .autoDispose<EventModel, String>((ref, id) async {
      final repository = ref.read(eventRepositoryProvider);
      return await repository.getEventById(id);
    });
