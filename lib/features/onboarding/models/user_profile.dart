class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String country;
  final bool isOnboardingCompleted;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.country,
    this.isOnboardingCompleted = false,
  });

  bool get hasPaymentDetails =>
      name.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      country.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'isOnboardingCompleted': isOnboardingCompleted,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      country: json['country'] ?? 'EG',
      isOnboardingCompleted: json['isOnboardingCompleted'] ?? false,
    );
  }
}
