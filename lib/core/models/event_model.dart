import 'package:json_annotation/json_annotation.dart';

part 'event_model.g.dart';

@JsonSerializable()
class EventModel {
  final String id;
  final String clubId;
  final String title;
  final String description;
  final DateTime dateTime;
  final String venue;
  final int maxParticipants;
  final int currentParticipants;
  final String status; // 'upcoming', 'ongoing', 'completed', 'cancelled'
  final String? bannerUrl;
  final List<String> tags;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const EventModel({
    required this.id,
    required this.clubId,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.venue,
    required this.maxParticipants,
    this.currentParticipants = 0,
    this.status = 'upcoming',
    this.bannerUrl,
    this.tags = const [],
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.metadata,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);
  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  EventModel copyWith({
    String? id,
    String? clubId,
    String? title,
    String? description,
    DateTime? dateTime,
    String? venue,
    int? maxParticipants,
    int? currentParticipants,
    String? status,
    String? bannerUrl,
    List<String>? tags,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return EventModel(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      venue: venue ?? this.venue,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      status: status ?? this.status,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      tags: tags ?? this.tags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'EventModel(id: $id, title: $title, status: $status)';
  }

  // Helper methods
  bool get isUpcoming => status == 'upcoming' && dateTime.isAfter(DateTime.now());
  bool get isOngoing => status == 'ongoing';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isPast => dateTime.isBefore(DateTime.now());
  
  bool get hasAvailableSpots => currentParticipants < maxParticipants;
  int get availableSpots => maxParticipants - currentParticipants;
  double get occupancyRate => maxParticipants > 0 ? currentParticipants / maxParticipants : 0.0;
  
  String get tagsText => tags.join(', ');
  
  Duration get timeUntilEvent => dateTime.difference(DateTime.now());
  bool get isWithin24Hours => timeUntilEvent.inHours <= 24 && timeUntilEvent.inHours >= 0;
  bool get isWithinWeek => timeUntilEvent.inDays <= 7 && timeUntilEvent.inDays >= 0;
  
  String get statusDisplayText {
    switch (status) {
      case 'upcoming':
        return 'Upcoming';
      case 'ongoing':
        return 'Ongoing';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
