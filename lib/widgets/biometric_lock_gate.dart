import 'package:flutter/material.dart';

import '../core/di/injection.dart';
import '../core/security/app_biometric_unlock_controller.dart';
import '../l10n/app_localizations.dart';

/// Covers the app with a biometric unlock screen after it returns from the
/// background, while [enabled] is true (signed in + biometric unlock on).
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
  bool locked = false;
  bool authenticating = false;

  /// Set once the prompt has been shown for the current lock, so a dismissed
  /// prompt lands on the retry button instead of asking again on resume.
  bool promptShown = false;
  bool failed = false;

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
    if (!widget.enabled) return;
    // The system biometric prompt backgrounds the app itself, so ignore the
    // lifecycle while it is up - otherwise a cancelled prompt immediately
    // triggers a new one and the user can never reach the retry button.
    if (authenticating) return;
    if (state == AppLifecycleState.paused) {
      setState(() => locked = true);
    } else if (state == AppLifecycleState.resumed && locked && !promptShown) {
      _unlock();
    }
  }

  Future<void> _unlock() async {
    if (authenticating) return;
    final l10n = AppLocalizations.of(context)!;
    final auth = getIt<AppBiometricUnlockController>().localAuth;
    setState(() {
      authenticating = true;
      promptShown = true;
      failed = false;
    });
    var success = false;
    try {
      success = await auth.authenticate(
        localizedReason: l10n.settingsBiometricResumeReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      success = false;
    }
    if (!mounted) return;
    setState(() {
      authenticating = false;
      failed = !success;
      if (success) {
        locked = false;
        promptShown = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final showLock = widget.enabled && locked;
    // The child stays mounted (offstage) so the navigation stack survives
    // a lock/unlock cycle.
    return Stack(
      children: [
        Offstage(offstage: showLock, child: widget.child),
        if (showLock) _buildLockScreen(context),
      ],
    );
  }

  Widget _buildLockScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.biometricLockTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  failed ? l10n.biometricLockFailed : l10n.biometricLockBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: failed
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: authenticating ? null : _unlock,
                  icon: authenticating
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.fingerprint),
                  label: Text(l10n.biometricLockUnlockButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
