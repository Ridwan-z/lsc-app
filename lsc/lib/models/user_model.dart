class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? institution;
  final String? major;
  final String subscriptionType;
  final int storageUsed;
  final int storageLimit;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.institution,
    this.major,
    required this.subscriptionType,
    required this.storageUsed,
    required this.storageLimit,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      institution: json['institution'],
      major: json['major'],
      subscriptionType: json['subscription_type'] ?? 'free',
      storageUsed: json['storage_used'] ?? 0,
      storageLimit: json['storage_limit'] ?? 1073741824,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'institution': institution,
      'major': major,
      'subscription_type': subscriptionType,
      'storage_used': storageUsed,
      'storage_limit': storageLimit,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Calculate storage percentage
  double get storagePercentage {
    if (storageLimit == 0) return 0;
    return (storageUsed / storageLimit) * 100;
  }

  // Check if premium
  bool get isPremium =>
      subscriptionType == 'premium' || subscriptionType == 'pro';
}
