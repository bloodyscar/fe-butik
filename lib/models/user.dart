class User {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String? role;
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  // Method to convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
