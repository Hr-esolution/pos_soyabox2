class User {
  final String? localId;
  final int? serverId;
  final String name;
  final String phone;
  final String role;
  final String pin;
  final bool isActive;
  final DateTime updatedAt;
  final String syncStatus;

  User({
    this.localId,
    this.serverId,
    required this.name,
    required this.phone,
    required this.role,
    required this.pin,
    required this.isActive,
    required this.updatedAt,
    required this.syncStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      localId: json['local_id'],
      serverId: json['server_id'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
      pin: json['pin'],
      isActive: json['is_active'] ?? true,
      updatedAt: DateTime.parse(json['updated_at']),
      syncStatus: json['sync_status'] ?? 'synced',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'local_id': localId,
      'server_id': serverId,
      'name': name,
      'phone': phone,
      'role': role,
      'pin': pin,
      'is_active': isActive,
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  User copyWith({
    String? localId,
    int? serverId,
    String? name,
    String? phone,
    String? role,
    String? pin,
    bool? isActive,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return User(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      pin: pin ?? this.pin,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isServer => role.toLowerCase() == 'server';
}