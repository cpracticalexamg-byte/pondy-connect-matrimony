class UserModel {
  final String userId;
  final String mobile;
  final String email;
  final String passwordHash;
  final String salt;
  final String profileFor;
  final String createdAt;
  final String lastLogin;
  final String status; // active, hidden, deleted
  final String planId;
  final String planExpiry;
  final bool isVerified;
  final bool isDemo;
  final String locality;
  final String city;

  const UserModel({
    required this.userId,
    required this.mobile,
    this.email = '',
    this.passwordHash = '',
    this.salt = '',
    this.profileFor = 'Myself',
    required this.createdAt,
    required this.lastLogin,
    this.status = 'active',
    this.planId = 'free',
    this.planExpiry = '',
    this.isVerified = false,
    this.isDemo = false,
    this.locality = 'Mudaliarpet',
    this.city = 'Puducherry',
  });

  factory UserModel.fromMap(Map<String, String> map) {
    return UserModel(
      userId: map['user_id'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      passwordHash: map['password_hash'] ?? '',
      salt: map['salt'] ?? '',
      profileFor: map['profile_for'] ?? 'Myself',
      createdAt: map['created_at'] ?? '',
      lastLogin: map['last_login'] ?? '',
      status: map['status'] ?? 'active',
      planId: map['plan_id'] ?? 'free',
      planExpiry: map['plan_expiry'] ?? '',
      isVerified: (map['is_verified'] ?? 'false').toLowerCase() == 'true',
      isDemo: (map['is_demo'] ?? 'false').toLowerCase() == 'true',
      locality: map['locality']?.isNotEmpty == true ? map['locality']! : 'Mudaliarpet',
      city: map['city']?.isNotEmpty == true ? map['city']! : 'Puducherry',
    );
  }

  Map<String, String> toMap() {
    return {
      'user_id': userId,
      'mobile': mobile,
      'email': email,
      'password_hash': passwordHash,
      'salt': salt,
      'profile_for': profileFor,
      'created_at': createdAt,
      'last_login': lastLogin,
      'status': status,
      'plan_id': planId,
      'plan_expiry': planExpiry,
      'is_verified': isVerified.toString(),
      'is_demo': isDemo.toString(),
      'locality': locality,
      'city': city,
    };
  }

  UserModel copyWith({
    String? mobile,
    String? email,
    String? passwordHash,
    String? salt,
    String? profileFor,
    String? lastLogin,
    String? status,
    String? planId,
    String? planExpiry,
    bool? isVerified,
    bool? isDemo,
    String? locality,
    String? city,
  }) {
    return UserModel(
      userId: userId,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      profileFor: profileFor ?? this.profileFor,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      status: status ?? this.status,
      planId: planId ?? this.planId,
      planExpiry: planExpiry ?? this.planExpiry,
      isVerified: isVerified ?? this.isVerified,
      isDemo: isDemo ?? this.isDemo,
      locality: locality ?? this.locality,
      city: city ?? this.city,
    );
  }
}
