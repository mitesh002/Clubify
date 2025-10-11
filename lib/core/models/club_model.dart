import 'package:json_annotation/json_annotation.dart';

part 'club_model.g.dart';

@JsonSerializable()
class ClubModel {
  final String id;
  final String name;
  final String description;
  final String leaderId;
  final String status; // 'pending', 'approved', 'rejected'
  final String? logoUrl;
  final List<String> categories;
  final int memberCount;
  final int eventCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const ClubModel({
    required this.id,
    required this.name,
    required this.description,
    required this.leaderId,
    this.status = 'pending',
    this.logoUrl,
    this.categories = const [],
    this.memberCount = 0,
    this.eventCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.metadata,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) => _$ClubModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClubModelToJson(this);

  ClubModel copyWith({
    String? id,
    String? name,
    String? description,
    String? leaderId,
    String? status,
    String? logoUrl,
    List<String>? categories,
    int? memberCount,
    int? eventCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return ClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      leaderId: leaderId ?? this.leaderId,
      status: status ?? this.status,
      logoUrl: logoUrl ?? this.logoUrl,
      categories: categories ?? this.categories,
      memberCount: memberCount ?? this.memberCount,
      eventCount: eventCount ?? this.eventCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClubModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ClubModel(id: $id, name: $name, status: $status)';
  }

  // Helper methods
  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  
  String get displayName => name;
  
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'C';
  }
  
  String get categoriesText => categories.join(', ');
}
