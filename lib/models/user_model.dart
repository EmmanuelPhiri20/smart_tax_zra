class UserModel {
  final String id;
  final String email;
  final String phone;
  final String name;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    this.avatarUrl,
  });

  factory UserModel.fromFirebaseUser(dynamic user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      name: user.displayName ?? 'User',
      avatarUrl: user.photoURL,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'avatarUrl': avatarUrl,
    };
  }
}
