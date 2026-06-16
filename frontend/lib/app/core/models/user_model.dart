class UserModel {
  final String id;
  final String name;
  final String email;
  final String provider;
  String gender;
  String? tanggalLahir;
  String theme;
  final String? photoUrl;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.provider,
    required this.gender,
    this.tanggalLahir,
    required this.theme,
    required this.photoUrl,
    required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      provider: json['provider'] ?? 'local',
      gender: json['gender'] ?? 'unknown',
      tanggalLahir: json['date_of_birth'],
      theme: json['theme'] ?? 'light',
      photoUrl: json['photo_url'],
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'provider': provider,
      'gender': gender,
      'date_of_birth': tanggalLahir,
      'theme': theme,
      'photo_url': photoUrl,
      'is_verified': isVerified,
    };
  }
}