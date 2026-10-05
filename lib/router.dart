import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/cubit/session_cubit.dart';
import 'features/auth/presentation/cubit/session_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/habits/domain/entities/habit_import.dart';
import 'pages/completed_habits_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/habit_detail_page.dart';
import 'pages/home_page.dart';
import 'pages/import_conflicts_page.dart';
import 'pages/legal_info_page.dart';
import 'pages/settings_page.dart';
import 'pages/splash_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Routes for the app. Navigation follows [session]: loading shows the
/// splash, signed out shows login, guest/authenticated users get the habits.
/// [refresh] (usually a [SessionRouterRefresh]) re-runs the redirect.
GoRouter buildRouter(SessionCubit session, Listenable refresh) => GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: refresh,
  redirect: (context, state) {
    final loc = state.matchedLocation;
    switch (session.state.status) {
      case SessionStatus.loading:
        return loc == '/' ? null : '/';
      case SessionStatus.signedOut:
        return loc == '/login' ? null : '/login';
      case SessionStatus.guest:
      case SessionStatus.authenticated:
        return loc == '/' || loc == '/login' ? '/habits' : null;
    }
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/habits',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              HabitDetailPage(habitId: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/completed-habits',
      builder: (context, state) => const CompletedHabitsPage(),
    ),
    GoRoute(
      path: '/import-conflicts',
      builder: (context, state) =>
          ImportConflictsPage(plan: state.extra! as ImportPlan),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
      routes: [
        GoRoute(
          path: 'about',
          builder: (context, state) =>
              const LegalInfoPage(kind: LegalInfoKind.about),
        ),
        GoRoute(
          path: 'privacy',
          builder: (context, state) =>
              const LegalInfoPage(kind: LegalInfoKind.privacy),
        ),
        GoRoute(
          path: 'terms',
          builder: (context, state) =>
              const LegalInfoPage(kind: LegalInfoKind.terms),
        ),
      ],
    ),
  ],
);

/// Adapts a cubit stream to the [Listenable] go_router refreshes on.
class SessionRouterRefresh extends ChangeNotifier {
  SessionRouterRefresh(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
