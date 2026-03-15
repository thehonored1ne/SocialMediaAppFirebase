import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  
  Future<String> loginUser({
    required String email,
    required String password,
  });

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
  });

  Future<void> signOut();
  
  Future<String> reauthenticateUser(String password);

  Future<bool> isUsernameAvailable(String username);

  Future<String> deleteAccount(String uid);
}
