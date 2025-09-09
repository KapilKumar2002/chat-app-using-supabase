class UserModel {
  final String id;
  final String username;
  final String email;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.profileImage,
  });

  // Factory method to create UserModel from Supabase JSON
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profile_image'],
    );
  }

  // Convert UserModel to Map (useful for sending data)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile_image': profileImage,
    };
  }
}
