class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'admin' or 'employee'
  final String? department;
  final String? phone;
  final String? profileImageUrl;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.department,
    this.phone,
    this.profileImageUrl,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'employee',
      department: map['department'],
      phone: map['phone'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'department': department,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? name,
    String? department,
    String? phone,
    String? profileImageUrl,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      role: role,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
    );
  }
}
