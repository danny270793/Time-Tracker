import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

enum SessionStatus { loading, signedOut, guest, authenticated }

class SessionState extends Equatable {
  const SessionState({
    this.status = SessionStatus.loading,
    this.user,
    this.error,
  });

  final SessionStatus status;
  final AppUser? user;
  final String? error;

  bool get isAuthenticated => status == SessionStatus.authenticated;

  @override
  List<Object?> get props => [status, user, error];
}
