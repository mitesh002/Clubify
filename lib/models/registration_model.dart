class RegistrationModel {
  final String id;
  final String eventId;
  final String studentId;
  final String status; // 'registered', 'approved', 'rejected', 'attended'
  final DateTime registeredAt;
  final DateTime? approvedAt;
  final String? notes;

  RegistrationModel({
    required this.id,
    required this.eventId,
    required this.studentId,
    this.status = 'registered',
    required this.registeredAt,
    this.approvedAt,
    this.notes,
  });

  factory RegistrationModel.fromMap(Map<String, dynamic> map, String id) {
    return RegistrationModel(
      id: id,
      eventId: map['event_id'] ?? '',
      studentId: map['student_id'] ?? '',
      status: map['status'] ?? 'registered',
      registeredAt: DateTime.fromMillisecondsSinceEpoch(map['registered_at'] ?? 0),
      approvedAt: map['approved_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['approved_at'])
          : null,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'student_id': studentId,
      'status': status,
      'registered_at': registeredAt.millisecondsSinceEpoch,
      'approved_at': approvedAt?.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  RegistrationModel copyWith({
    String? id,
    String? eventId,
    String? studentId,
    String? status,
    DateTime? registeredAt,
    DateTime? approvedAt,
    String? notes,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
      approvedAt: approvedAt ?? this.approvedAt,
      notes: notes ?? this.notes,
    );
  }
}
