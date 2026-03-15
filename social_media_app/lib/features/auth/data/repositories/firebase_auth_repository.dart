import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/core/constants/app_constants.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final trimUsername = username.trim().toLowerCase();
    if (trimUsername.isEmpty) return false;

    final snapshot = await _db
        .collection(AppConstants.usersCollection)
        .where('username_lowercase', isEqualTo: trimUsername)
        .get();

    return snapshot.docs.isEmpty;
  }

  @override
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final cleanEmail = email.trim();
      final cleanPassword = password.trim();

      if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
        return "Please enter all fields";
      }

      await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );
      return "success";
    } on FirebaseAuthException catch (e) {
      return _mapAuthException(e);
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  @override
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final cleanEmail = email.trim();
      final cleanPassword = password.trim();
      final cleanUsername = username.trim();

      if (cleanEmail.isEmpty || cleanPassword.isEmpty || cleanUsername.isEmpty) {
        return "Please fill all fields";
      }

      final isAvailable = await isUsernameAvailable(cleanUsername);
      if (!isAvailable) {
        return "Username is already taken";
      }

      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );

      await _db.collection(AppConstants.usersCollection).doc(cred.user!.uid).set({
        'username': cleanUsername,
        'username_lowercase': cleanUsername.toLowerCase(),
        'uid': cred.user!.uid,
        'email': cleanEmail,
        'bio': 'New developer on DevNotes',
        'followers': 0,
        'following': 0,
        'profileImage': '',
        'saved_posts': [],
      });

      return "success";
    } on FirebaseAuthException catch (e) {
      return _mapAuthException(e);
    } catch (e) {
      return "Registration failed. Please try again.";
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<String> reauthenticateUser(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password.trim(),
        );
        await user.reauthenticateWithCredential(credential);
        return "success";
      }
      return "User not found";
    } on FirebaseAuthException catch (e) {
      return _mapAuthException(e);
    } catch (e) {
      return "Authentication failed";
    }
  }

  @override
  Future<String> deleteAccount(String uid) async {
    try {
      await _db.collection(AppConstants.usersCollection).doc(uid).delete();
      await _auth.currentUser?.delete();
      return "success";
    } on FirebaseAuthException catch (e) {
      return _mapAuthException(e);
    } catch (e) {
      return e.toString();
    }
  }

  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return "Incorrect email or password.";
      case 'email-already-in-use':
        return "This email is already registered.";
      case 'invalid-email':
        return "Please enter a valid email address.";
      case 'weak-password':
        return "Password is too weak. Use at least 6 characters.";
      case 'user-disabled':
        return "This account has been disabled.";
      case 'too-many-requests':
        return "Too many attempts. Please try again later.";
      case 'network-request-failed':
        return "No internet connection.";
      default:
        return e.message ?? "Authentication failed. Please try again.";
    }
  }
}
