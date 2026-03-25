class UserProfile {
  final String name;
  final String email;
  final bool isOnboardingCompleted;

  UserProfile({
    required this.name,
    required this.email,
    this.isOnboardingCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'isOnboardingCompleted': isOnboardingCompleted,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isOnboardingCompleted: json['isOnboardingCompleted'] ?? false,
    );
  }
}
