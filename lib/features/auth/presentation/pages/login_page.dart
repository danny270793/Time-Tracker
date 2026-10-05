import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../cubit/session_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
      await context.read<SessionCubit>().signIn(email.text, password.text);
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visibleError =
        error ?? context.select((SessionCubit c) => c.state.error);
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
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: Image.asset(
                        'assets/habit_tracker_icon.png',
                        width: 88,
                        height: 88,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.signIn,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    key: const ValueKey('login-email'),
                    controller: email,
                    autofillHints: const [AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: l10n.email),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const ValueKey('login-password'),
                    controller: password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => busy ? null : _signIn(),
                    decoration: InputDecoration(labelText: l10n.password),
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
                    child: Text(l10n.signIn),
                  ),
                  TextButton(
                    key: const ValueKey('continue-without-account'),
                    onPressed: busy
                        ? null
                        : context.read<SessionCubit>().continueAsGuest,
                    child: Text(l10n.continueWithoutAccount),
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
