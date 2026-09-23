import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_preferences.dart';
import 'features/auth/auth_pages.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/session_controller.dart';
import 'features/habits/data/habits_migrator.dart';
import 'features/habits/data/local_habits_repository.dart';
import 'features/habits/data/supabase_habits_repository.dart';
import 'features/habits/presentation/app_pages.dart';
import 'features/habits/presentation/habits_cubit.dart';

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
  } catch (_) {
    // No dev proxy certificate bundled; nothing to trust.
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
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);

  final preferences = AppPreferences();
  await preferences.load();
  final local = LocalHabitsRepository();
  SupabaseHabitsRepository cloud(String userId) =>
      SupabaseHabitsRepository(Supabase.instance.client, userId);
  final session = SessionController(
    auth: SupabaseAuthService(Supabase.instance.client),
    migrator: HabitsMigrator(local: local, cloudForUser: cloud),
    localRepository: local,
    cloudRepository: cloud,
  );
  runApp(HabitFlowApp(preferences: preferences, sessionController: session));
  unawaited(session.initialize());
}

class HabitFlowApp extends StatelessWidget {
  const HabitFlowApp({
    super.key,
    required this.preferences,
    this.sessionController,
  });

  final AppPreferences preferences;
  final SessionController? sessionController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: preferences,
      builder: (context, _) => MaterialApp(
        title: "Danny's Habits Tracker",
        debugShowCheckedModeBanner: false,
        locale: preferences.locale,
        supportedLocales: const [Locale('en'), Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: preferences.themeMode,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        home: sessionController == null
            ? BlocProvider(
                create: (_) => HabitsCubit(LocalHabitsRepository())..load(),
                child: HomePage(preferences: preferences),
              )
            : SessionGate(
                controller: sessionController!,
                preferences: preferences,
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
    );
  }
}
