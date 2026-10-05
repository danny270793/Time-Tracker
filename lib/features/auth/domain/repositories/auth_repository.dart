import '../entities/app_user.dart';

abstract class AuthRepository {
  AppUser? get currentUser;
  Stream<AppUser?> get userChanges;

  Future<AppUser> signIn(String email, String password);
  Future<void> signOut();
  Future<void> updateEmail(String email);
  Future<void> updatePassword(String password);
}
