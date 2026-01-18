class User {
  final int? id;
  final String name;
  final String? phone;
  final String? email;
  final String? role;
  final int? restaurantId;
  final bool? isActive;

  User({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.role,
    this.restaurantId,
    this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      restaurantId: json['restaurant_id'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'restaurant_id': restaurantId,
      'is_active': isActive,
    };
  }
}