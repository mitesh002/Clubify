import 'package:json_annotation/json_annotation.dart';

part 'registration_model.g.dart';

@JsonSerializable()
class RegistrationModel {
  final String id;
  final String eventId;
  final String studentId;
  final String status; // 'registered', 'approved', 'rejected', 'attended', 'cancelled'
  final DateTime registeredAt;
  final DateTime? approvedAt;
  final DateTime? attendedAt;
  final String? notes;
  final int pointsEarned;
  final Map<String, dynamic>? metadata;

  const RegistrationModel({
    required this.id,
    required this.eventId,
    required this.studentId,
    this.status = 'registered',
    required this.registeredAt,
    this.approvedAt,
    this.attendedAt,
    this.notes,
    this.pointsEarned = 0,
    this.metadata,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) => _$RegistrationModelFromJson(json);
  Map<String, dynamic> toJson() => _$RegistrationModelToJson(this);

  RegistrationModel copyWith({
    String? id,
    String? eventId,
    String? studentId,
    String? status,
    DateTime? registeredAt,
    DateTime? approvedAt,
    DateTime? attendedAt,
    String? notes,
    int? pointsEarned,
    Map<String, dynamic>? metadata,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
      approvedAt: approvedAt ?? this.approvedAt,
      attendedAt: attendedAt ?? this.attendedAt,
      notes: notes ?? this.notes,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegistrationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RegistrationModel(id: $id, eventId: $eventId, status: $status)';
  }

  // Helper methods
  bool get isRegistered => status == 'registered';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isAttended => status == 'attended';
  bool get isCancelled => status == 'cancelled';
  
  bool get canBeApproved => status == 'registered';
  bool get canBeRejected => status == 'registered' || status == 'approved';
  bool get canMarkAttended => status == 'approved';
  bool get canBeCancelled => status == 'registered' || status == 'approved';
  
  String get statusDisplayText {
    switch (status) {
      case 'registered':
        return 'Registered';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'attended':
        return 'Attended';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
  
  Duration? get timeSinceRegistration {
    return DateTime.now().difference(registeredAt);
  }
  
  Duration? get timeSinceApproval {
    return approvedAt != null ? DateTime.now().difference(approvedAt!) : null;
  }
  
  Duration? get timeSinceAttendance {
    return attendedAt != null ? DateTime.now().difference(attendedAt!) : null;
  }
}
