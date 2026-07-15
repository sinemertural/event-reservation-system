import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'event_controller.dart';

// YENİ: Seçili tarihi hafızada tutacak basit bir provider
final selectedDateProvider = StateProvider.autoDispose<String?>((ref) => null);

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsState = ref.watch(eventListControllerProvider);
    final activeFilter = ref.watch(selectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlikler'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Tarihe Göre Filtrele',
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
              );

              if (selectedDate != null) {
                final formattedDate =
                    "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

                ref.read(selectedDateProvider.notifier).state = formattedDate;

                ref
                    .read(eventListControllerProvider.notifier)
                    .refreshEvents(date: formattedDate);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.confirmation_num_outlined),
            onPressed: () {
              context.push('/my-reservations');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: eventsState.when(
        data: (events) {
          return RefreshIndicator(
            onRefresh: () async {
              final currentFilter = ref.read(selectedDateProvider);

              if (currentFilter != null) {
                final shouldClear = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Filtreyi Kaldır'),
                      content: const Text(
                        'Tarih filtresini kaldırıp tüm etkinlikleri görmek istediğinize emin misiniz?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Hayır, Filtreyi Koru'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Evet, Tümünü Göster'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldClear == true) {
                  ref.read(selectedDateProvider.notifier).state = null;
                  await ref
                      .read(eventListControllerProvider.notifier)
                      .refreshEvents();
                } else {
                  await ref
                      .read(eventListControllerProvider.notifier)
                      .refreshEvents(date: currentFilter);
                }
              } else {
                await ref
                    .read(eventListControllerProvider.notifier)
                    .refreshEvents();
              }
            },
            child: events.isEmpty
                ? CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'Seçtiğiniz tarihte etkinlik bulunmuyor.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200) {
                        final currentFilter = ref.read(selectedDateProvider);
                        ref
                            .read(eventListControllerProvider.notifier)
                            .loadMore(date: currentFilter);
                      }
                      return false;
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        // YENİ MANTIK: Spinner çizildiği an alt sayfayı otomatik çek
                        if (index == events.length) {
                          if (events.length >= 4 && events.length % 4 == 0) {
                            // OTOMATİK TETİKLEME (Ekrana çizildiği an loadMore çalışır)
                            final currentFilter = ref.read(
                              selectedDateProvider,
                            );
                            Future.microtask(() {
                              ref
                                  .read(eventListControllerProvider.notifier)
                                  .loadMore(date: currentFilter);
                            });

                            return const SizedBox(
                              height: 60,
                              child: Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }

                        final event = events[index];
                        final isFull = event.availableQuota <= 0;
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
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
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
                                          color: isFull
                                              ? Colors.red
                                              : Colors.green,
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
                  ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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
