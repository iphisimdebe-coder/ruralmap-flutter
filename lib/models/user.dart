class AppUser {
  final String name;
  final String email;
  final String phone;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const AppUser({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.lastLogin,
  });

  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return AppUser(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      role: map['role'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'] as String)
          : null,
    );
  }
}
