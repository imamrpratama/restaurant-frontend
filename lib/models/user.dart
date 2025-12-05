class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? googleId;
  final bool twoFactorEnabled;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.googleId,
    this.twoFactorEnabled = false,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      googleId: json['google_id'],
      // FIX: Convert int (0/1) to bool
      twoFactorEnabled: json['google2fa_enabled'] == 1 ||
          json['google2fa_enabled'] == true ||
          json['two_factor_enabled'] == 1 ||
          json['two_factor_enabled'] == true,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'google_id': googleId,
      'two_factor_enabled': twoFactorEnabled ? 1 : 0,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Getter for backward compatibility
  bool get google2faEnabled => twoFactorEnabled;
}
