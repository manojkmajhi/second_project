class UserProfileModel {
  final String name;
  final String email;
  final String? imagePath;

  UserProfileModel({
    required this.name,
    required this.email,
    this.imagePath,
  });

  UserProfileModel copyWith({
    String? name,
    String? email,
    String? imagePath,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}