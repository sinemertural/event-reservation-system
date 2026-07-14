import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'event_controller.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controller'ı dinleyerek anlık durumu (state) alıyoruz
    final eventsState = ref.watch(eventListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlikler'),
        centerTitle: true,
        actions: [
          // İleride takvim filtresi eklemek için yer tutucu ikon
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tarih filtresi yakında eklenecek!'),
                ),
              );
            },
          ),
        ],
      ),
      // .when() ile 3 durumu ayrı ayrı  çiziyoruz (loading, data , error )
      body: eventsState.when(
        // 1. DURUM: Veri başarıyla geldiğinde
        data: (events) {
          if (events.isEmpty) {
            return const Center(
              child: Text(
                'Şu an aktif etkinlik bulunmuyor.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // BONUS: Pull-to-refresh (Aşağı kaydırarak yenileme)
          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(eventListControllerProvider.notifier)
                  .refreshEvents();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = events[index];

                // İş kuralı: Kontenjan dolu mu kontrolü
                final isFull = event.availableQuota <= 0;

                // Tarihi gün/ay/yıl olarak biçimlendirme
                final formattedDate =
                    "${event.date.day.toString().padLeft(2, '0')}/${event.date.month.toString().padLeft(2, '0')}/${event.date.year}";

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Tıklanınca detay sayfasına yönlendir (ID'yi URL parametresi olarak gönderiyoruz)
                      context.push('/events/${event.id}');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formattedDate,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.group,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isFull
                                    ? 'Kontenjan Dolu'
                                    : 'Kalan Kontenjan: ${event.availableQuota}',
                                style: TextStyle(
                                  color: isFull ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        // 2. DURUM: Veri yüklenirken (Spinner)
        loading: () => const Center(child: CircularProgressIndicator()),

        // 3. DURUM: Hata oluştuğunda
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  error.toString().replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(eventListControllerProvider.notifier)
                        .refreshEvents();
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
