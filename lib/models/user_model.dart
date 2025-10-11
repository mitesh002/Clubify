class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'student' or 'club_leader'
  final String course;
  final int points;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.course,
    this.points = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      course: map['course'] ?? '',
      points: map['points'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'course': course,
      'points': points,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? course,
    int? points,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      course: course ?? this.course,
      points: points ?? this.points,
    );
  }
}
