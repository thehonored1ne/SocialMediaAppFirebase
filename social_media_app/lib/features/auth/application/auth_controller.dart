import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/features/auth/data/repositories/firebase_auth_repository.dart';
import '../domain/repositories/auth_repository.dart';

part 'auth_controller.g.dart';

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

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }

  Future<String> reauthenticate(String password) async {
    return await ref.read(authRepositoryProvider).reauthenticateUser(password);
  }

  Future<void> deleteAccount() async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    state = const AsyncLoading();
    try {
      final res = await ref.read(authRepositoryProvider).deleteAccount(user.uid);
      if (res == "success") {
        state = const AsyncData(null);
      } else {
        state = AsyncError(res, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<String> login(String email, String password) async {
    state = const AsyncLoading();
    final res = await ref.read(authRepositoryProvider).loginUser(
          email: email,
          password: password,
        );
    state = const AsyncData(null);
    return res;
  }

  Future<String> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AsyncLoading();
    final res = await ref.read(authRepositoryProvider).signUpUser(
          email: email,
          password: password,
          username: username,
        );
    state = const AsyncData(null);
    return res;
  }
}
