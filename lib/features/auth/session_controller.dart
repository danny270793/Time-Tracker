import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../habits/data/habits_migrator.dart';
import '../habits/domain/habits_repository.dart';
import 'auth_service.dart';

enum SessionStatus { loading, signedOut, guest, authenticated }

class SessionController extends ChangeNotifier {
  SessionController({
    required this.auth,
    required this.migrator,
    required this.localRepository,
    required this.cloudRepository,
  });

  static const guestKey = 'continue_without_account';

  final AuthService auth;
  final HabitsMigrator migrator;
  final HabitsRepository localRepository;
  final HabitsRepository Function(String userId) cloudRepository;

  SessionStatus status = SessionStatus.loading;
  AppUser? user;
  String? error;
  StreamSubscription<AppUser?>? _subscription;
  bool _enteringCloud = false;

  HabitsRepository get repository {
    final current = user;
    return current == null ? localRepository : cloudRepository(current.id);
  }

  Future<void> initialize() async {
    _subscription = auth.userChanges.listen(_handleAuthChange);
    final current = auth.currentUser;
    if (current != null) {
      await _enterCloud(current);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    status = prefs.getBool(guestKey) == true
        ? SessionStatus.guest
        : SessionStatus.signedOut;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    error = null;
    status = SessionStatus.loading;
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setBool(guestKey, false);
      await _enterCloud(await auth.signIn(email, password));
    } catch (exception) {
      error = exception.toString();
      status = SessionStatus.signedOut;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> continueAsGuest() async {
    await (await SharedPreferences.getInstance()).setBool(guestKey, true);
    user = null;
    status = SessionStatus.guest;
    notifyListeners();
  }

  Future<void> signOut() async {
    await (await SharedPreferences.getInstance()).setBool(guestKey, false);
    await auth.signOut();
    user = null;
    status = SessionStatus.signedOut;
    notifyListeners();
  }

  Future<void> _handleAuthChange(AppUser? next) async {
    if (next == null) {
      if (status == SessionStatus.authenticated) {
        user = null;
        status = SessionStatus.signedOut;
        notifyListeners();
      }
      return;
    }
    await _enterCloud(next);
  }

  Future<void> _enterCloud(AppUser next) async {
    if (_enteringCloud ||
        (status == SessionStatus.authenticated && user?.id == next.id)) {
      return;
    }
    _enteringCloud = true;
    status = SessionStatus.loading;
    notifyListeners();
    try {
      await migrator.migrateOnce(next.id);
      user = next;
      error = null;
      status = SessionStatus.authenticated;
    } catch (exception) {
      user = null;
      error = exception.toString();
      status = SessionStatus.signedOut;
    } finally {
      _enteringCloud = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
