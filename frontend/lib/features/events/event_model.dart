class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final int totalQuota;
  final int availableQuota;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.totalQuota,
    required this.availableQuota,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'İsimsiz Etkinlik',
      description: json['description'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      totalQuota: json['total_quota'] ?? json['totalQuota'] ?? 0,
      availableQuota: json['available_quota'] ?? json['availableQuota'] ?? 0,
    );
  }
}
