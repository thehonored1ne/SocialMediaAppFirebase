import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:social_media_app/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:social_media_app/features/auth/domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return FirebaseAuthRepository();
}

@riverpod
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<String> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).loginUser(
          email: email,
          password: password,
        );
    state = const AsyncData(null);
    return result;
  }

  Future<String> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signUpUser(
          email: email,
          password: password,
          username: username,
        );
    state = const AsyncData(null);
    return result;
  }

  Future<bool> isUsernameAvailable(String username) async {
    return await ref.read(authRepositoryProvider).isUsernameAvailable(username);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}
