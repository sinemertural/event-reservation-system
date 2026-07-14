import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reservation_controller.dart';
import 'reservation_model.dart';

class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsState = ref.watch(reservationListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rezervasyonlarım'), centerTitle: true),
      body: reservationsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Bir hata oluştu:\n$error', textAlign: TextAlign.center),
        ),
        data: (reservations) {
          if (reservations.isEmpty) {
            return const Center(
              child: Text(
                'Henüz bir rezervasyonunuz bulunmuyor.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // 1. GRUPLAMA İŞLEMİ (Aynı etkinliğe ait rezervasyonları birleştir)
          final groupedReservations = <String, List<ReservationModel>>{};
          for (var res in reservations) {
            // Eğer bu eventId map'te yoksa boş liste oluştur, sonra içine ekle
            groupedReservations.putIfAbsent(res.eventId, () => []).add(res);
          }

          // Map'teki listeleri (grupları) UI'da göstermek için düz bir listeye çeviriyoruz
          final groups = groupedReservations.values.toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final group = groups[index];

              // Gruptaki ilk rezervasyondan etkinlik bilgilerini alıyoruz
              final firstRes = group.first;
              final eventTitle = firstRes.event?.title ?? 'Bilinmeyen Etkinlik';
              final eventDate = firstRes.event?.date;
              final formattedDate = eventDate != null
                  ? "${eventDate.day.toString().padLeft(2, '0')}/${eventDate.month.toString().padLeft(2, '0')}/${eventDate.year}"
                  : 'Tarih Belirtilmedi';

              // 2. TOPLAM KİŞİ SAYISINI HESAPLAMA (Gruptaki tüm guestCount'ları topluyoruz)
              final totalGuests = group.fold<int>(
                0,
                (sum, res) => sum + res.guestCount,
              );

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ETKİNLİK BİLGİLERİ
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                // Güncellenen toplam kişi sayısını yazdırıyoruz
                                Text(
                                  '$totalGuests Kişi (Toplam)',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // İPTAL BUTONU
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('İptal Onayı'),
                              content: const Text(
                                'Bu etkinliğe ait 1 adet rezervasyonu iptal etmek istediğinize emin misiniz?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Hayır'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Evet, İptal Et',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              final messenger = ScaffoldMessenger.of(context);
                              final reservationToCancel = group.last;
                              await ref
                                  .read(
                                    reservationListControllerProvider.notifier,
                                  )
                                  .cancel(reservationToCancel.id);

                              // Navigator.pop(context) kısımlarını da kaldırdık.

                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '1 adet rezervasyon iptal edildi.',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
