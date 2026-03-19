class UserEntity {
  final String uid;
  final String? name;
  final String email;

  UserEntity({
    required this.uid,
    required this.name,
    required this.email,
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? name,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,     // If new uid is null, use the old one
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }

  // Converts UserEntity to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name ?? '',
      'email': email,
    };
  }

  // Creates UserEntity from JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      uid: json['uid'] ?? '',
      name: json['name'],
      email: json['email'] ?? '',
    );
  }

  // Creates UserEntity from Map
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
    );
  }
}

