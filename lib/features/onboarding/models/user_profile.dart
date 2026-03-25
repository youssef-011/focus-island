class UserProfile {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String country;
  final String bio;
  final String avatarId;
  final bool isOnboardingCompleted;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.country,
    this.bio = '',
    this.avatarId = 'seed',
    this.isOnboardingCompleted = false,
  });

  bool get hasPaymentDetails =>
      name.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      country.trim().isNotEmpty;

  bool get isGuest => userId.startsWith('guest') || email.trim().isEmpty;

  UserProfile copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? country,
    String? bio,
    String? avatarId,
    bool? isOnboardingCompleted,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      bio: bio ?? this.bio,
      avatarId: avatarId ?? this.avatarId,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'bio': bio,
      'avatarId': avatarId,
      'isOnboardingCompleted': isOnboardingCompleted,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      country: json['country'] ?? 'EG',
      bio: json['bio'] ?? '',
      avatarId: json['avatarId'] ?? 'seed',
      isOnboardingCompleted: json['isOnboardingCompleted'] ?? false,
    );
  }
}
