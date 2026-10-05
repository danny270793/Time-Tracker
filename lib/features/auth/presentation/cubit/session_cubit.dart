import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../habits/data/repositories/habits_migrator.dart';
import '../../../habits/domain/repositories/habits_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'session_state.dart';

/// Tracks whether the user is signed in, browsing as a guest, or signed out,
/// and exposes the [HabitsRepository] that matches the current session.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required this.auth,
    required this.migrator,
    required this.localRepository,
    required this.cloudRepository,
  }) : super(const SessionState());

  static const guestKey = 'continue_without_account';

  final AuthRepository auth;
  final HabitsMigrator migrator;
  final HabitsRepository localRepository;
  final HabitsRepository Function(String userId) cloudRepository;

  StreamSubscription<AppUser?>? _subscription;
  bool _enteringCloud = false;

  HabitsRepository get repository {
    final current = state.user;
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
    if (isClosed) return;
    emit(
      SessionState(
        status: prefs.getBool(guestKey) == true
            ? SessionStatus.guest
            : SessionStatus.signedOut,
      ),
    );
  }

  Future<void> signIn(String email, String password) async {
    emit(SessionState(status: SessionStatus.loading, user: state.user));
    try {
      await (await SharedPreferences.getInstance()).setBool(guestKey, false);
      await _enterCloud(await auth.signIn(email, password));
    } catch (exception) {
      emit(
        SessionState(
          status: SessionStatus.signedOut,
          error: exception.toString(),
        ),
      );
      rethrow;
    }
  }

  Future<void> continueAsGuest() async {
    await (await SharedPreferences.getInstance()).setBool(guestKey, true);
    emit(const SessionState(status: SessionStatus.guest));
  }

  Future<void> signOut() async {
    await (await SharedPreferences.getInstance()).setBool(guestKey, false);
    await auth.signOut();
    emit(const SessionState(status: SessionStatus.signedOut));
  }

  Future<void> _handleAuthChange(AppUser? next) async {
    if (next == null) {
      if (state.status == SessionStatus.authenticated) {
        emit(const SessionState(status: SessionStatus.signedOut));
      }
      return;
    }
    await _enterCloud(next);
  }

  Future<void> _enterCloud(AppUser next) async {
    if (_enteringCloud ||
        (state.status == SessionStatus.authenticated &&
            state.user?.id == next.id)) {
      return;
    }
    _enteringCloud = true;
    emit(SessionState(status: SessionStatus.loading, user: state.user));
    try {
      await migrator.migrateOnce(next.id);
      if (!isClosed) {
        emit(SessionState(status: SessionStatus.authenticated, user: next));
      }
    } catch (exception) {
      if (!isClosed) {
        emit(
          SessionState(
            status: SessionStatus.signedOut,
            error: exception.toString(),
          ),
        );
      }
    } finally {
      _enteringCloud = false;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
