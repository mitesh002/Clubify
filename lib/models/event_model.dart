class EventModel {
  final String id;
  final String clubId;
  final String title;
  final String description;
  final DateTime dateTime;
  final String venue;
  final int maxParticipants;
  final String status; // 'upcoming', 'ongoing', 'completed', 'cancelled'
  final String? imageUrl;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.clubId,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.venue,
    required this.maxParticipants,
    this.status = 'upcoming',
    this.imageUrl,
    required this.createdAt,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      clubId: map['clubId'] ?? map['club_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dateTime: map['dateTime'] is DateTime
          ? map['dateTime']
          : (map['date_time'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['date_time'])
              : DateTime.now()),
      venue: map['venue'] ?? '',
      maxParticipants: map['maxParticipants'] ?? map['max_participants'] ?? 0,
      status: map['status'] ?? 'upcoming',
      imageUrl: map['imageUrl'] ?? map['image_url'],
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : (map['created_at'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clubId': clubId,
      'title': title,
      'description': description,
      'dateTime': dateTime,
      'venue': venue,
      'maxParticipants': maxParticipants,
      'status': status,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

  EventModel copyWith({
    String? id,
    String? clubId,
    String? title,
    String? description,
    DateTime? dateTime,
    String? venue,
    int? maxParticipants,
    String? status,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      venue: venue ?? this.venue,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
