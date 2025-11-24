import '../models/user.dart';

class AuthService {
  // Separate user lists for each role
  static final Map<String, List<User>> _usersByRole = {
    'driver': [],
    'passenger': [],
    'owner': [],
    'admin': [],
  };

  static bool signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) {
    // Check if user already exists for this specific role
    bool userExists = _usersByRole[role]!.any((user) => user.email == email);
    if (userExists) {
      return false;
    }

    // Create new user for this role
    _usersByRole[role]!.add(User(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
    ));
    return true;
  }

  static User? signIn({
    required String email,
    required String password,
    required String role,
  }) {
    try {
      return _usersByRole[role]!.firstWhere(
            (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  static bool isUserRegisteredForRole({
    required String email,
    required String role,
  }) {
    return _usersByRole[role]!.any((user) => user.email == email);
  }
}