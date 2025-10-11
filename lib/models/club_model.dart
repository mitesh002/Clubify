class ClubModel {
  final String id;
  final String name;
  final String description;
  final String leaderId;
  final String status; // 'pending', 'approved', 'rejected'
  final String? imageUrl;
  final DateTime createdAt;

  ClubModel({
    required this.id,
    required this.name,
    required this.description,
    required this.leaderId,
    this.status = 'pending',
    this.imageUrl,
    required this.createdAt,
  });

  factory ClubModel.fromMap(Map<String, dynamic> map, String id) {
    return ClubModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      leaderId: map['leaderId'] ?? map['leader_id'] ?? '',
      status: map['status'] ?? 'pending',
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
      'name': name,
      'description': description,
      'leaderId': leaderId,
      'status': status,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

  ClubModel copyWith({
    String? id,
    String? name,
    String? description,
    String? leaderId,
    String? status,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return ClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      leaderId: leaderId ?? this.leaderId,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
