import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/reservations/reservation_repository.dart';
import 'event_controller.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Etkinlik Detayı')),
      body: detailState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Bir hata oluştu:\n$error', textAlign: TextAlign.center),
        ),
        data: (event) {
          final isFull = event.availableQuota <= 0;
          final formattedDate =
              "${event.date.day.toString().padLeft(2, '0')}/${event.date.month.toString().padLeft(2, '0')}/${event.date.year}";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // BAŞLIK
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // TARİH VE KONTENJAN BİLGİ KARTLARI
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.people_outline,
                        title: 'Toplam',
                        value: '${event.totalQuota} Kişi',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16), // Araya ferah bir boşluk
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.group,
                        title: 'Kalan',
                        value: isFull ? 'Dolu' : '${event.availableQuota} Kişi',
                        color: isFull ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // İki satır arası boşluk
                // 2. SATIR: TARİH KARTI (Alt satırda, tam genişlikte)
                SizedBox(
                  width: double.infinity, // Kartın ekranı kaplamasını sağlar
                  child: _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Tarih',
                    value: formattedDate,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 32),

                // AÇIKLAMA
                const Text(
                  'Etkinlik Hakkında',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 40),

                // REZERVASYON BUTONU
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isFull
                        ? null
                        : () async {
                            // Yükleniyor dialogu göster (İşlem bitene kadar ekranı kilitler)
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            try {
                              final repo = ref.read(
                                reservationRepositoryProvider,
                              );
                              // Şimdilik varsayılan olarak 1 kişilik rezervasyon atıyoruz
                              await repo.createReservation(eventId, 1);

                              // İşlem bitince yükleniyor dialogunu kapat
                              if (context.mounted) Navigator.pop(context);

                              // Başarılı mesajı
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Rezervasyon başarıyla oluşturuldu!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }

                              // Etkinlik listesini ve bu detayı yenile ki yeni kontenjan ekrana yansısın
                              ref.invalidate(eventListControllerProvider);
                              ref.invalidate(eventDetailProvider(eventId));
                            } catch (e) {
                              // Hata varsa dialogu kapat ve hatayı göster
                              if (context.mounted) Navigator.pop(context);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().replaceAll(
                                        'Exception: ',
                                        '',
                                      ),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isFull ? 'Kontenjan Dolu' : 'Rezervasyon Yap',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Arayüzü temiz tutmak için oluşturduğumuz yardımcı widget
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
