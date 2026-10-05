import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection.dart';
import 'core/locale/app_locale_controller.dart';
import 'core/logger/app_logger.dart';
import 'core/security/app_biometric_unlock_controller.dart';
import 'core/theme/app_theme_controller.dart';
import 'features/auth/presentation/cubit/session_cubit.dart';
import 'features/auth/presentation/cubit/session_state.dart';
import 'features/habits/domain/repositories/habits_repository.dart';
import 'features/habits/presentation/cubit/habits_cubit.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'widgets/biometric_lock_gate.dart';

// Dart's HttpClient (used under the hood by package:http and thus by
// Supabase) has its own bundled trust store, independent of the Android/iOS
// OS trust store - installing a corporate proxy's root CA (e.g. Zscaler) at
// the OS level does nothing for it. Debug-only: trust it here too, so local
// dev works behind a TLS-intercepting proxy. Never runs in release builds.
Future<void> _trustDevProxyCertificateIfNeeded() async {
  if (!kDebugMode) return;
  try {
    final bytes = await rootBundle.load('assets/certs/zscaler_root_ca.pem');
    SecurityContext.defaultContext.setTrustedCertificatesBytes(
      bytes.buffer.asUint8List(),
    );
    AppLogger.info('trusted dev proxy certificate');
  } catch (e) {
    AppLogger.info('no dev proxy certificate to trust: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _trustDevProxyCertificateIfNeeded();
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Missing SUPABASE_URL or SUPABASE_ANON_KEY. '
      'Run with --dart-define-from-file=.env.json.',
    );
  }
  AppLogger.info('initializing Supabase');
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
  AppLogger.info('Supabase initialized');

  setupDi();
  AppLogger.info('DI setup complete');
  await loadAppControllers();

  runApp(const App());
  unawaited(getIt<SessionCubit>().initialize());
}

/// Restores persisted language, theme and biometric preferences.
Future<void> loadAppControllers() async {
  await getIt<AppLocaleController>().load();
  await getIt<AppThemeController>().load();
  await getIt<AppBiometricUnlockController>().load();
}

class App extends StatefulWidget {
  const App({super.key});

  static Locale? _resolveDeviceLocale(
    Locale? deviceLocale,
    Iterable<Locale> supported,
  ) {
    if (deviceLocale == null) return supported.first;
    for (final loc in supported) {
      if (loc.languageCode == deviceLocale.languageCode) return loc;
    }
    return supported.first;
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final SessionCubit _session = getIt<SessionCubit>();
  late final SessionRouterRefresh _routerRefresh = SessionRouterRefresh(
    _session.stream,
  );
  late final GoRouter _router = buildRouter(_session, _routerRefresh);
  late final HabitsCubit _habits = getIt<HabitsCubit>(
    param1: _session.repository,
  )..load();

  /// Identity of the repository [_habits] is attached to (`null` = guest).
  String? _attachedUserId;

  @override
  void initState() {
    super.initState();
    _attachedUserId = _session.state.user?.id;
  }

  @override
  void dispose() {
    _router.dispose();
    _routerRefresh.dispose();
    _habits.close();
    super.dispose();
  }

  void _onSessionChanged(BuildContext context, SessionState state) {
    final userId = state.user?.id;
    if (userId == _attachedUserId) return;
    _attachedUserId = userId;
    final HabitsRepository repository = _session.repository;
    unawaited(_habits.attach(repository));
  }

  @override
  Widget build(BuildContext context) {
    final appLocale = getIt<AppLocaleController>();
    final appTheme = getIt<AppThemeController>();
    final bio = getIt<AppBiometricUnlockController>();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _session),
        BlocProvider.value(value: _habits),
      ],
      child: BlocListener<SessionCubit, SessionState>(
        listener: _onSessionChanged,
        child: ListenableBuilder(
          listenable: Listenable.merge([appLocale, appTheme]),
          builder: (context, _) => MaterialApp.router(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: appLocale.materialAppLocale,
            localeResolutionCallback: App._resolveDeviceLocale,
            themeMode: appTheme.themeMode,
            theme: _theme(Brightness.light),
            darkTheme: _theme(Brightness.dark),
            routerConfig: _router,
            builder: (context, child) => ListenableBuilder(
              listenable: bio,
              builder: (context, _) => BlocBuilder<SessionCubit, SessionState>(
                builder: (context, session) => BiometricLockGate(
                  enabled: session.isAuthenticated && bio.enabled,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B52ED),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      typography: Typography.material2021(platform: defaultTargetPlatform),
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF8F8FA)
          : null,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
