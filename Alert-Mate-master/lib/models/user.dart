class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final List<String>? roles;
  final String profilePicture;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    this.roles,
    this.profilePicture = '',
  });

  String get fullName => '$firstName $lastName';

  bool hasRole(String checkRole) => roles?.contains(checkRole) ?? false;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'roles': roles ?? [role],
      'profilePicture': profilePicture,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? map['activeRole'] ?? 'passenger',
      roles: List<String>.from(map['roles'] ?? [map['role'] ?? 'passenger']),
      profilePicture: map['profilePicture'] ?? '',
    );
  }
}