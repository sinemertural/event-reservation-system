import '../events/event_model.dart';

class ReservationModel {
  final String id;
  final String eventId;
  final int guestCount;
  final DateTime createdAt;

  final EventModel? event;

  ReservationModel({
    required this.id,
    required this.eventId,
    required this.guestCount,
    required this.createdAt,
    this.event,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id']?.toString() ?? '',
      eventId: json['event_id'] ?? json['eventId'] ?? '',
      guestCount: json['guest_count'] ?? json['guestCount'] ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),

      event: json['event'] != null ? EventModel.fromJson(json['event']) : null,
    );
  }
}
