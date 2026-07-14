import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reservation_model.dart';
import 'reservation_repository.dart';
import '../events/event_controller.dart';

class ReservationListController
    extends AutoDisposeAsyncNotifier<List<ReservationModel>> {
  @override
  FutureOr<List<ReservationModel>> build() async {
    return _fetchMyReservations();
  }

  Future<List<ReservationModel>> _fetchMyReservations() async {
    final repository = ref.read(reservationRepositoryProvider);
    return await repository.getMyReservations();
  }

  // Rezervasyon İptal İşlemi
  Future<bool> cancel(String reservationId) async {
    try {
      final repository = ref.read(reservationRepositoryProvider);
      await repository.cancelReservation(reservationId);

      // İptal başarılı olursa listeyi yenile
      state = const AsyncLoading();
      state = await AsyncValue.guard(() => _fetchMyReservations());

      // Ana sayfadaki etkinlikler listesini de yenile (Kontenjanın geri arttığını UI'da görmek için)
      ref.invalidate(eventListControllerProvider);

      return true;
    } catch (e) {
      // Hata durumunu fırlat ki UI'da SnackBar ile gösterebilelim
      throw Exception(e.toString());
    }
  }
}

final reservationListControllerProvider =
    AsyncNotifierProvider.autoDispose<
      ReservationListController,
      List<ReservationModel>
    >(() {
      return ReservationListController();
    });
