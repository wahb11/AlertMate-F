import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_models;

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if user exists with given email (checks all roles)
  Future<bool> userExists(String email) async {
    try {
      print('🔍 Checking if user exists: $email');
      
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      bool exists = querySnapshot.docs.isNotEmpty;
      print(exists ? '✅ User exists!' : '❌ No existing user found');
      return exists;
    } catch (e) {
      print('❌ Error checking user existence: $e');
      return false;
    }
  }

  // Sign up new user with multiple roles
  Future<firebase_auth.User?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required List<String> roles,
  }) async {
    try {
      print('🚀 Starting sign up process for: $email with roles: $roles');
      
      // First, check if user already exists in Firestore
      bool exists = await userExists(email);
      
      if (exists) {
        // User exists: ADD NEW ROLE instead of creating new auth user
        print('👤 User exists with this email. Adding new role: $roles');
        
        final querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        
        if (querySnapshot.docs.isNotEmpty) {
          String uid = querySnapshot.docs.first.id;
          Map<String, dynamic> data = querySnapshot.docs.first.data();
          
          List<String> existingRoles = List<String>.from(data['roles'] ?? []);
          
          // Add new roles if not already present
          for (String role in roles) {
            if (!existingRoles.contains(role)) {
              existingRoles.add(role);
              print('➕ Added role: $role');
            }
          }
          
          // Update user with new roles
          await _firestore.collection('users').doc(uid).update({
            'roles': existingRoles,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
          print('✅ Roles updated for existing user: $existingRoles');
          
          // Verify the update
          var doc = await _firestore.collection('users').doc(uid).get();
          if (doc.exists) {
            print('📊 VERIFICATION: Updated roles in Firestore!');
            print('📊 User data: ${doc.data()}');
          }
          
          return _auth.currentUser;
        }
      }

      // Create new Firebase Auth user
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

      // Set first role as active role
      String activeRole = roles.isNotEmpty ? roles.first : 'passenger';

      // Save user data to Firestore with roles array
      print('💾 Saving user data to Firestore...');
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'roles': roles,
        'activeRole': activeRole,
        'emailVerified': false,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'profilePicture': '',
      });

      print('✅ User data saved to Firestore successfully!');
      print('👥 Roles: $roles | Active Role: $activeRole');

      // Verify the data was saved
      var doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (doc.exists) {
        print('📊 VERIFICATION: Data exists in Firestore!');
        print('📊 User data: ${doc.data()}');
      }

      return userCredential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      if (e.code == 'email-already-in-use') {
        // Try to add role with password verification
        try {
          print('⚠️ Email already in Firebase Auth. Attempting to add role...');
          firebase_auth.UserCredential signInCredential = 
              await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          String uid = signInCredential.user!.uid;
          
          // Get existing roles
          DocumentSnapshot doc = 
              await _firestore.collection('users').doc(uid).get();
          
          if (doc.exists) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            List<String> existingRoles = 
                List<String>.from(data['roles'] ?? []);
            
            // Add new roles
            for (String role in roles) {
              if (!existingRoles.contains(role)) {
                existingRoles.add(role);
                print('➕ Added role: $role');
              }
            }
            
            // Update Firestore
            await _firestore.collection('users').doc(uid).update({
              'roles': existingRoles,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            
            print('✅ Roles added successfully to existing user');
            return signInCredential.user;
          }
        } catch (signInError) {
          print('❌ Sign in failed. Wrong password or user not found.');
          throw Exception('Incorrect password for existing email');
        }
      }
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
        
        // Handle both old (single role) and new (multiple roles) format
        List<String>? roles;
        String activeRole;
        
        if (data.containsKey('roles') && data['roles'] is List) {
          // New format with roles array
          roles = List<String>.from(data['roles'] ?? ['passenger']);
          activeRole = data['activeRole'] ?? roles!.first;
        } else if (data.containsKey('role') && data['role'] is String) {
          // Old format with single role - migrate automatically
          String oldRole = data['role'] ?? 'passenger';
          roles = [oldRole];
          activeRole = oldRole;
          
          // Update to new format in background
          _migrateUserToNewFormat(userCredential.user!.uid, oldRole);
        } else {
          // Fallback
          roles = ['passenger'];
          activeRole = 'passenger';
        }
        
        print('📊 User roles: $roles | Active role: $activeRole');
        print('📧 Email verified: ${userCredential.user!.emailVerified}');
        
        return app_models.User(
          id: userCredential.user!.uid,
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          role: activeRole,
          roles: roles,
          profilePicture: data['profilePicture'] ?? '',
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

  // Update active role for a user
  Future<void> updateActiveRole(String uid, String newActiveRole) async {
    try {
      print('🔄 Updating active role to: $newActiveRole');
      
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> roles = List<String>.from(data['roles'] ?? []);
        
        if (roles.contains(newActiveRole)) {
          await _firestore.collection('users').doc(uid).update({
            'activeRole': newActiveRole,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('✅ Active role updated to: $newActiveRole');
        } else {
          print('❌ User does not have the $newActiveRole role');
          throw Exception('User does not have the $newActiveRole role');
        }
      }
    } catch (e) {
      print('❌ Failed to update active role: $e');
      throw Exception('Failed to update active role: $e');
    }
  }

  // Add a new role to user
  Future<void> addRoleToUser(String uid, String role) async {
    try {
      print('➕ Adding role: $role to user: $uid');
      
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> roles = List<String>.from(data['roles'] ?? []);
        
        if (!roles.contains(role)) {
          roles.add(role);
          await _firestore.collection('users').doc(uid).update({
            'roles': roles,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('✅ Role added successfully: $role');
        } else {
          print('⚠️ User already has this role');
        }
      }
    } catch (e) {
      print('❌ Failed to add role: $e');
      throw Exception('Failed to add role: $e');
    }
  }

  // Remove a role from user
  Future<void> removeRoleFromUser(String uid, String role) async {
    try {
      print('➖ Removing role: $role from user: $uid');
      
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> roles = List<String>.from(data['roles'] ?? []);
        String activeRole = data['activeRole'] ?? '';
        
        if (roles.contains(role)) {
          roles.remove(role);
          
          if (roles.isEmpty) {
            print('❌ Cannot remove last role');
            throw Exception('Cannot remove last role');
          }
          
          if (activeRole == role) {
            await _firestore.collection('users').doc(uid).update({
              'roles': roles,
              'activeRole': roles.first,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            print('✅ Role removed and switched active role to: ${roles.first}');
          } else {
            await _firestore.collection('users').doc(uid).update({
              'roles': roles,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            print('✅ Role removed successfully');
          }
        } else {
          print('⚠️ User does not have this role');
        }
      }
    } catch (e) {
      print('❌ Failed to remove role: $e');
      throw Exception('Failed to remove role: $e');
    }
  }

  // Get user's roles
  Future<List<String>> getUserRoles(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['roles'] ?? ['passenger']);
      }
      
      return ['passenger'];
    } catch (e) {
      print('❌ Error getting user roles: $e');
      return ['passenger'];
    }
  }

  // Get user's active role
  Future<String> getUserActiveRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['activeRole'] ?? 'passenger';
      }
      
      return 'passenger';
    } catch (e) {
      print('❌ Error getting active role: $e');
      return 'passenger';
    }
  }

  // Migrate a single user from old format to new format
  Future<void> _migrateUserToNewFormat(String uid, String oldRole) async {
    try {
      print('🔄 Migrating user $uid to new format...');
      await _firestore.collection('users').doc(uid).update({
        'roles': [oldRole],
        'activeRole': oldRole,
        'role': FieldValue.delete(),
      });
      print('✅ User migrated successfully');
    } catch (e) {
      print('⚠️ Migration failed (non-critical): $e');
    }
  }

  // Migrate all existing users (run once)
  Future<void> migrateAllExistingUsers() async {
    try {
      print('🚀 Starting migration of all existing users...');
      
      QuerySnapshot users = await _firestore.collection('users').get();
      int migratedCount = 0;
      int skippedCount = 0;

      for (var doc in users.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        if (data.containsKey('role') && data['role'] is String && !data.containsKey('roles')) {
          String oldRole = data['role'];
          
          await _firestore.collection('users').doc(doc.id).update({
            'roles': [oldRole],
            'activeRole': oldRole,
            'role': FieldValue.delete(),
          });
          
          migratedCount++;
          print('✅ Migrated user: ${doc.id} with role: $oldRole');
        } else {
          skippedCount++;
        }
      }
      
      print('🎉 Migration complete!');
      print('📊 Total users: ${users.docs.length}');
      print('✅ Migrated: $migratedCount');
      print('⏭️ Skipped: $skippedCount');
    } catch (e) {
      print('❌ Migration failed: $e');
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

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      firebase_auth.User? user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        user = _auth.currentUser;
        
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
        await user.reload();
        user = _auth.currentUser;
        
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
        return 'An account with this email exists. Use correct password to add new role.';
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