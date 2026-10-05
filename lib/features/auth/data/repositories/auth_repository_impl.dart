import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  AppUser? _map(User? user) =>
      user == null ? null : AppUser(id: user.id, email: user.email);

  @override
  AppUser? get currentUser => _map(_client.auth.currentUser);

  @override
  Stream<AppUser?> get userChanges =>
      _client.auth.onAuthStateChange.map((event) => _map(event.session?.user));

  @override
  Future<AppUser> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign in did not return a user');
    }
    return _map(user)!;
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<void> updateEmail(String email) =>
      _client.auth.updateUser(UserAttributes(email: email.trim()));

  @override
  Future<void> updatePassword(String password) =>
      _client.auth.updateUser(UserAttributes(password: password));
}
