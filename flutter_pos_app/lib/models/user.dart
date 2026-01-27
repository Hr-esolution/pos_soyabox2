import 'dart:convert';

class User {
  final String? id;
  final String name;
  final String phone;
  final String role;
  final String pin;
  final bool isActive;
  final DateTime updatedAt;

  User({
    this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.pin,
    required this.isActive,
    required this.updatedAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isServer => role == 'server';

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? role,
    String? pin,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      pin: pin ?? this.pin,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'pin': pin,
      'is_active': isActive,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      pin: map['pin'] ?? '',
      isActive: map['is_active'] ?? true,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(id: $id, name: $name, phone: $phone, role: $role, pin: $pin, isActive: $isActive, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.phone == phone &&
        other.role == role &&
        other.pin == pin &&
        other.isActive == isActive &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      phone,
      role,
      pin,
      isActive,
      updatedAt,
    );
  }
}