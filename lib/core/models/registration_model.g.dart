// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegistrationModel _$RegistrationModelFromJson(Map<String, dynamic> json) =>
    RegistrationModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      studentId: json['studentId'] as String,
      status: json['status'] as String? ?? 'registered',
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      attendedAt: json['attendedAt'] == null
          ? null
          : DateTime.parse(json['attendedAt'] as String),
      notes: json['notes'] as String?,
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RegistrationModelToJson(RegistrationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'studentId': instance.studentId,
      'status': instance.status,
      'registeredAt': instance.registeredAt.toIso8601String(),
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'attendedAt': instance.attendedAt?.toIso8601String(),
      'notes': instance.notes,
      'pointsEarned': instance.pointsEarned,
      'metadata': instance.metadata,
    };
