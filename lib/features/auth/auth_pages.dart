import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/app_preferences.dart';
import '../habits/presentation/app_pages.dart';
import '../habits/presentation/habits_cubit.dart';
import 'session_controller.dart';

class SessionGate extends StatelessWidget {
  const SessionGate({
    super.key,
    required this.controller,
    required this.preferences,
  });

  final SessionController controller;
  final AppPreferences preferences;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      switch (controller.status) {
        case SessionStatus.loading:
          return const SplashPage();
        case SessionStatus.signedOut:
          return LoginPage(controller: controller);
        case SessionStatus.guest:
        case SessionStatus.authenticated:
          return BlocProvider(
            key: ValueKey(
              '${controller.status.name}-${controller.user?.id ?? 'guest'}',
            ),
            create: (_) => HabitsCubit(controller.repository)..load(),
            child: BiometricLockGate(
              enabled:
                  controller.status == SessionStatus.authenticated &&
                  preferences.biometricLock,
              child: HomePage(
                preferences: preferences,
                sessionController: controller,
              ),
            ),
          );
      }
    },
  );
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_graph_rounded, size: 64),
          SizedBox(height: 20),
          CircularProgressIndicator(),
        ],
      ),
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.controller});

  final SessionController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.controller.signIn(email.text, password.text);
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final es = AppStrings.of(context).es;
    final visibleError = error ?? widget.controller.error;
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.auto_graph_rounded, size: 64),
                  const SizedBox(height: 20),
                  Text(
                    es ? 'Inicia sesión' : 'Sign in',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    key: const ValueKey('login-email'),
                    controller: email,
                    autofillHints: const [AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: es ? 'Correo' : 'Email',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const ValueKey('login-password'),
                    controller: password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => busy ? null : _signIn(),
                    decoration: InputDecoration(
                      labelText: es ? 'Contraseña' : 'Password',
                    ),
                  ),
                  if (visibleError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      visibleError,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const ValueKey('sign-in'),
                    onPressed: busy ? null : _signIn,
                    child: Text(es ? 'Iniciar sesión' : 'Sign in'),
                  ),
                  TextButton(
                    key: const ValueKey('continue-without-account'),
                    onPressed: busy ? null : widget.controller.continueAsGuest,
                    child: Text(
                      es ? 'Continuar sin cuenta' : 'Continue without account',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BiometricLockGate extends StatefulWidget {
  const BiometricLockGate({
    super.key,
    required this.enabled,
    required this.child,
  });

  final bool enabled;
  final Widget child;

  @override
  State<BiometricLockGate> createState() => _BiometricLockGateState();
}

class _BiometricLockGateState extends State<BiometricLockGate>
    with WidgetsBindingObserver {
  final LocalAuthentication auth = LocalAuthentication();
  bool locked = false;
  bool authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.enabled && state == AppLifecycleState.paused) {
      setState(() => locked = true);
    } else if (widget.enabled && state == AppLifecycleState.resumed && locked) {
      _unlock();
    }
  }

  Future<void> _unlock() async {
    if (authenticating) return;
    setState(() => authenticating = true);
    try {
      final success = await auth.authenticate(
        localizedReason: 'Unlock Habit tracker',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      if (mounted && success) setState(() => locked = false);
    } finally {
      if (mounted) setState(() => authenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || !locked) return widget.child;
    return Scaffold(
      body: Center(
        child: FilledButton.icon(
          onPressed: authenticating ? null : _unlock,
          icon: const Icon(Icons.fingerprint),
          label: const Text('Unlock'),
        ),
      ),
    );
  }
}
