class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerified,
    this.pendingEmail,
  });

  final int id;
  final String name;
  final String email;
  final bool isVerified;
  final String? pendingEmail;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      pendingEmail: json['pendingEmail'] as String?,
    );
  }

  AuthUser copyWith({
    String? name,
    String? email,
    bool? isVerified,
    String? pendingEmail,
    bool clearPendingEmail = false,
  }) {
    return AuthUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
      pendingEmail: clearPendingEmail
          ? null
          : pendingEmail ?? this.pendingEmail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isVerified': isVerified,
      'pendingEmail': pendingEmail,
    };
  }
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final AuthUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String? ?? '',
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  AuthSession copyWith({String? token, AuthUser? user}) {
    return AuthSession(token: token ?? this.token, user: user ?? this.user);
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user.toJson()};
  }
}
