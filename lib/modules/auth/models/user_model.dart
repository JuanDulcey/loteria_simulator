class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  // Create from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }
}
