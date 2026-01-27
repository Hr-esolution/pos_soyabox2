import 'dart:convert';

class AuthResponse {
  final bool success;
  final String? message;
  final User? user;
  final String? token;

  AuthResponse({
    required this.success,
    this.message,
    this.user,
    this.token,
  });

  AuthResponse copyWith({
    bool? success,
    String? message,
    User? user,
    String? token,
  }) {
    return AuthResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      user: user ?? this.user,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'user': user?.toMap(),
      'token': token,
    };
  }

  factory AuthResponse.fromMap(Map<String, dynamic> map) {
    return AuthResponse(
      success: map['success'] ?? false,
      message: map['message'],
      user: map['user'] != null ? User.fromMap(Map<String, dynamic>.from(map['user'])) : null,
      token: map['token'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthResponse.fromJson(String source) => AuthResponse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AuthResponse(success: $success, message: $message, user: $user, token: $token)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AuthResponse &&
        other.success == success &&
        other.message == message &&
        other.user == user &&
        other.token == token;
  }

  @override
  int get hashCode {
    return Object.hash(
      success,
      message,
      user,
      token,
    );
  }
}