import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_models;

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if user exists with given email and role
  Future<bool> userExists(String email, String role) async {
    try {
      print('🔍 Checking if user exists: $email with role $role');
      
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: role)
          .get();
      
      bool exists = querySnapshot.docs.isNotEmpty;
      print(exists ? '✅ User exists!' : '❌ No existing user found');
      return exists;
    } catch (e) {
      print('❌ Error checking user existence: $e');
      return false;
    }
  }

  // Sign up new user
  Future<firebase_auth.User?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    try {
      print('🚀 Starting sign up process for: $email as $role');
      
      // Check if user already exists
      bool exists = await userExists(email, role);
      if (exists) {
        print('⚠️ User already exists with this role');
        throw Exception('User with this email and role already exists');
      }

      // Create Firebase Auth user
      print('👤 Creating Firebase Auth user...');
      firebase_auth.UserCredential userCredential = 
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase Auth user created: ${userCredential.user!.uid}');

      // Send email verification
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        print('📧 Sending verification email...');
        await userCredential.user!.sendEmailVerification();
        print('✅ Verification email sent to $email');
      }

      // Save user data to Firestore
      print('💾 Saving user data to Firestore...');
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'role': role,
        'emailVerified': false,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ User data saved to Firestore successfully!');

      // Verify the data was saved
      var doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (doc.exists) {
        print('📊 VERIFICATION: Data exists in Firestore!');
        print('📊 User data: ${doc.data()}');
      }

      return userCredential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('❌ Unexpected error during sign up: $e');
      rethrow;
    }
  }

  // Sign in existing user
  Future<app_models.User?> signIn(String email, String password) async {
    try {
      print('🔐 Attempting sign in for: $email');
      
      firebase_auth.UserCredential userCredential = 
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Sign in successful!');
      
      // Sync email verification status from Firebase Auth to Firestore
      await syncEmailVerificationStatus();

      // Get user data from Firestore
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('📊 User data retrieved: ${data['role']}');
        print('📧 Email verified: ${userCredential.user!.emailVerified}');
        
        return app_models.User(
          id: userCredential.user!.uid,
          firstName: data['firstName'],
          lastName: data['lastName'],
          email: data['email'],
          phone: data['phone'],
          role: data['role'],
        );
      }

      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('❌ Unexpected error during sign in: $e');
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent to $email');
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ Password reset error: ${e.code}');
      throw Exception(_getAuthErrorMessage(e.code));
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    print('👋 User signed out');
  }

  // Get current user
  firebase_auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      firebase_auth.User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        print('📧 Resending verification email to ${user.email}...');
        await user.sendEmailVerification();
        print('✅ Verification email resent!');
      } else if (user?.emailVerified == true) {
        print('⚠️ Email already verified!');
        throw Exception('Email is already verified');
      } else {
        print('❌ No user logged in');
        throw Exception('No user logged in');
      }
    } catch (e) {
      print('❌ Error resending verification email: $e');
      rethrow;
    }
  }

  // Check if email is verified (refresh the user first)
  Future<bool> isEmailVerified() async {
    try {
      firebase_auth.User? user = _auth.currentUser;
      if (user != null) {
        await user.reload(); // Refresh user data
        user = _auth.currentUser; // Get updated user
        
        // If verified in Firebase Auth, update Firestore too
        if (user?.emailVerified == true) {
          await _firestore.collection('users').doc(user!.uid).update({
            'emailVerified': true,
          });
          print('✅ Firestore updated with email verification status');
        }
        
        return user?.emailVerified ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Error checking email verification: $e');
      return false;
    }
  }
  
  // Sync email verification status from Firebase Auth to Firestore
  Future<void> syncEmailVerificationStatus() async {
    try {
      firebase_auth.User? user = _auth.currentUser;
      if (user != null) {
        await user.reload(); // Refresh user data
        user = _auth.currentUser; // Get updated user
        
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'emailVerified': user.emailVerified,
            'lastLogin': FieldValue.serverTimestamp(),
          });
          print('✅ Email verification status synced: ${user.emailVerified}');
        }
      }
    } catch (e) {
      print('❌ Error syncing verification status: $e');
    }
  }

  // Helper method for user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      default:
        return 'Authentication error: $code';
    }
  }
}