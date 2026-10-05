import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/di/injection.dart';
import '../core/locale/app_locale_controller.dart';
import '../core/logger/app_logger.dart';
import '../core/security/app_biometric_unlock_controller.dart';
import '../core/theme/app_theme_controller.dart';
import '../features/auth/domain/usecases/update_email_usecase.dart';
import '../features/auth/domain/usecases/update_password_usecase.dart';
import '../features/auth/presentation/cubit/session_cubit.dart';
import '../features/auth/presentation/cubit/session_state.dart';
import '../features/habits/data/datasources/habits_backup_datasource.dart';
import '../features/habits/presentation/cubit/habits_cubit.dart';
import '../l10n/app_localizations.dart';
import '../widgets/bottom_sheet_pinned_title.dart';

const _playStoreUrl =
    'https://play.google.com/store/apps/details?id=io.github.danny270793.timetracker';

String _languageOptionLabel(AppLocalizations l10n, AppLanguagePreference p) =>
    switch (p) {
      AppLanguagePreference.system => l10n.settingsLanguageSystem,
      AppLanguagePreference.en => l10n.settingsLanguageEnglish,
      AppLanguagePreference.es => l10n.settingsLanguageSpanish,
    };

String _themeOptionLabel(AppLocalizations l10n, AppThemePreference p) =>
    switch (p) {
      AppThemePreference.system => l10n.settingsThemeSystem,
      AppThemePreference.light => l10n.settingsThemeLight,
      AppThemePreference.dark => l10n.settingsThemeDark,
    };

/// Bottom sheet with one check-marked row per option.
Future<void> _showOptionPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required T selected,
  required String Function(T) label,
  required Future<void> Function(T) onSelected,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: false,
    isScrollControlled: true,
    builder: (sheetContext) => BottomSheetPinnedTitleScrollView(
      padding: EdgeInsets.zero,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final option in options)
            ListTile(
              title: Text(label(option)),
              trailing: selected == option
                  ? Icon(
                      Icons.check,
                      color: Theme.of(sheetContext).colorScheme.primary,
                    )
                  : null,
              onTap: () async {
                await onSelected(option);
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    ),
  );
}

Future<void> _setBiometricUnlockEnabled(
  BuildContext context,
  AppLocalizations l10n,
  AppBiometricUnlockController ctrl,
  bool enabled,
) async {
  if (!enabled) {
    await ctrl.setEnabled(false);
    return;
  }
  await ctrl.refreshAuthenticatorAvailability();
  if (!ctrl.authenticatorAvailable) {
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.settingsBiometricUnavailable)),
      );
    }
    return;
  }
  var ok = false;
  try {
    ok = await ctrl.localAuth.authenticate(
      localizedReason: l10n.settingsBiometricAuthReason,
      biometricOnly: true,
      persistAcrossBackgrounding: true,
    );
  } catch (error) {
    AppLogger.warn('biometric enable failed: $error');
  }
  if (!context.mounted) return;
  if (ok) await ctrl.setEnabled(true);
}

Future<void> _showChangeEmailSheet(
  BuildContext context,
  AppLocalizations l10n,
  String currentEmail,
) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: false,
    isScrollControlled: true,
    builder: (_) => BottomSheetPinnedTitleScrollView(
      title: l10n.settingsChangeEmailDialogTitle,
      child: _ChangeEmailSheetBody(
        hostContext: context,
        currentEmail: currentEmail,
        l10n: l10n,
      ),
    ),
  );
  if (ok == true && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.settingsChangeEmailSuccess)));
  }
}

Future<void> _showChangePasswordSheet(
  BuildContext context,
  AppLocalizations l10n,
) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: false,
    isScrollControlled: true,
    builder: (_) => BottomSheetPinnedTitleScrollView(
      title: l10n.settingsChangePasswordDialogTitle,
      child: _ChangePasswordSheetBody(hostContext: context, l10n: l10n),
    ),
  );
  if (ok == true && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.settingsChangePasswordSuccess)));
  }
}

Future<void> _exportHabits(BuildContext context, AppLocalizations l10n) async {
  final json = context.read<HabitsCubit>().exportJson();
  await getIt<HabitsBackupDatasource>().share(
    json,
    title: l10n.settingsExportShareTitle,
  );
}

Future<void> _importHabits(BuildContext context, AppLocalizations l10n) async {
  final cubit = context.read<HabitsCubit>();
  final raw = await getIt<HabitsBackupDatasource>().pickJson();
  if (raw == null || !context.mounted) return;
  try {
    final plan = cubit.prepareImport(raw);
    if (plan.conflicts.isEmpty) {
      await cubit.applyImport(plan, const []);
    } else if (context.mounted) {
      await context.push('/import-conflicts', extra: plan);
    }
  } catch (error) {
    AppLogger.warn('habit import failed: $error');
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsImportInvalidFile)));
    }
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        getIt<AppBiometricUnlockController>()
            .refreshAuthenticatorAvailability(),
      );
    });
  }

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    try {
      await context.read<SessionCubit>().signOut();
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final session = context.watch<SessionCubit>().state;
    final signedIn = session.status == SessionStatus.authenticated;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
          children: [
            if (signedIn) ...[
              _SectionHeader(l10n.settingsProfileSection),
              _NavigationTile(
                icon: Icons.person_outline_rounded,
                title: l10n.settingsChangeEmail,
                subtitle: session.user?.email ?? '',
                onTap: () => _showChangeEmailSheet(
                  context,
                  l10n,
                  session.user?.email ?? '',
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Icon(
                  Icons.lock_outline_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(l10n.settingsChangePassword),
                subtitle: Text(
                  l10n.settingsChangePasswordSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showChangePasswordSheet(context, l10n),
              ),
              const _SectionDivider(),
              // Biometric unlock only gates signed-in (cloud) sessions.
              _SectionHeader(l10n.settingsSecuritySection),
              ListenableBuilder(
                listenable: getIt<AppBiometricUnlockController>(),
                builder: (context, _) {
                  final bio = getIt<AppBiometricUnlockController>();
                  return SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    secondary: Icon(
                      Icons.fingerprint_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(l10n.settingsBiometricUnlockTitle),
                    subtitle: Text(
                      bio.authenticatorAvailable
                          ? l10n.settingsBiometricUnlockSubtitle
                          : l10n.settingsBiometricUnavailable,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    value: bio.enabled,
                    onChanged: bio.authenticatorAvailable
                        ? (v) =>
                              _setBiometricUnlockEnabled(context, l10n, bio, v)
                        : null,
                  );
                },
              ),
              const _SectionDivider(),
            ],
            _SectionHeader(l10n.settingsAppearance),
            ListenableBuilder(
              listenable: getIt<AppLocaleController>(),
              builder: (context, _) {
                final ctrl = getIt<AppLocaleController>();
                return _NavigationTile(
                  icon: Icons.language_outlined,
                  title: l10n.settingsLanguage,
                  subtitle: _languageOptionLabel(l10n, ctrl.preference),
                  onTap: () => _showOptionPickerSheet(
                    context,
                    title: l10n.settingsLanguage,
                    options: AppLanguagePreference.values,
                    selected: ctrl.preference,
                    label: (p) => _languageOptionLabel(l10n, p),
                    onSelected: ctrl.setPreference,
                  ),
                );
              },
            ),
            ListenableBuilder(
              listenable: getIt<AppThemeController>(),
              builder: (context, _) {
                final ctrl = getIt<AppThemeController>();
                return _NavigationTile(
                  icon: Icons.palette_outlined,
                  title: l10n.settingsTheme,
                  subtitle: _themeOptionLabel(l10n, ctrl.preference),
                  onTap: () => _showOptionPickerSheet(
                    context,
                    title: l10n.settingsTheme,
                    options: AppThemePreference.values,
                    selected: ctrl.preference,
                    label: (p) => _themeOptionLabel(l10n, p),
                    onSelected: ctrl.setPreference,
                  ),
                );
              },
            ),
            const _SectionDivider(),
            _SectionHeader(l10n.settingsHabitsSection),
            _NavigationTile(
              icon: Icons.inventory_2_outlined,
              title: l10n.completedHabits,
              onTap: () => context.push('/completed-habits'),
            ),
            // Signed-in habits live in Supabase, so the JSON backup is only
            // offered while the data is local to this device.
            if (!signedIn) ...[
              _ActionTile(
                icon: Icons.file_upload_outlined,
                title: l10n.settingsExportJson,
                onTap: () => _exportHabits(context, l10n),
              ),
              _ActionTile(
                icon: Icons.file_download_outlined,
                title: l10n.settingsImportJson,
                onTap: () => _importHabits(context, l10n),
              ),
            ],
            const _SectionDivider(),
            _SectionHeader(l10n.settingsAboutSection),
            _NavigationTile(
              icon: Icons.info_outline_rounded,
              title: l10n.settingsAboutApp,
              onTap: () => context.push('/settings/about'),
            ),
            _NavigationTile(
              icon: Icons.star_outline_rounded,
              title: l10n.settingsRateApp,
              trailingIcon: Icons.open_in_new_rounded,
              onTap: () => launchUrl(
                Uri.parse(_playStoreUrl),
                mode: LaunchMode.externalApplication,
              ),
            ),
            _NavigationTile(
              icon: Icons.privacy_tip_outlined,
              title: l10n.settingsPrivacyPolicy,
              onTap: () => context.push('/settings/privacy'),
            ),
            _NavigationTile(
              icon: Icons.description_outlined,
              title: l10n.settingsTermsOfUse,
              onTap: () => context.push('/settings/terms'),
            ),
            const _SectionDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: signedIn
                    ? _SignOutButton(
                        loading: _signingOut,
                        label: l10n.signOut,
                        onPressed: _signOut,
                      )
                    // Guests leave guest mode and land on the sign-in screen.
                    : FilledButton.tonalIcon(
                        key: const ValueKey('session-action'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _signingOut ? null : _signOut,
                        icon: const Icon(Icons.login_rounded),
                        label: Text(l10n.signIn),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  final bool loading;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = FilledButton.styleFrom(
      backgroundColor: theme.colorScheme.error,
      foregroundColor: theme.colorScheme.onError,
      padding: const EdgeInsets.symmetric(vertical: 14),
    );
    if (loading) {
      return FilledButton(
        key: const ValueKey('session-action'),
        style: style,
        onPressed: null,
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.onError,
          ),
        ),
      );
    }
    return FilledButton.icon(
      key: const ValueKey('session-action'),
      style: style,
      onPressed: onPressed,
      icon: const Icon(Icons.logout_rounded),
      label: Text(label),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Divider(height: 1),
  );
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailingIcon = Icons.chevron_right,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final IconData trailingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Icon(trailingIcon),
      onTap: onTap,
    );
  }
}

/// Tile that runs an action in place (no trailing chevron).
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
    title: Text(title),
    onTap: onTap,
  );
}

class _ChangeEmailSheetBody extends StatefulWidget {
  const _ChangeEmailSheetBody({
    required this.hostContext,
    required this.currentEmail,
    required this.l10n,
  });

  final BuildContext hostContext;
  final String currentEmail;
  final AppLocalizations l10n;

  @override
  State<_ChangeEmailSheetBody> createState() => _ChangeEmailSheetBodyState();
}

class _ChangeEmailSheetBodyState extends State<_ChangeEmailSheetBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      widget.hostContext,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final next = _controller.text.trim();
    if (next == widget.currentEmail.trim()) {
      _snack(widget.l10n.settingsChangeEmailSameAsCurrent);
      return;
    }
    setState(() => _loading = true);
    try {
      await getIt<UpdateEmailUsecase>()(newEmail: next);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      if (mounted) setState(() => _loading = false);
      _snack(e.message);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
      _snack(widget.l10n.unexpectedError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofocus: true,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(labelText: l10n.settingsNewEmailLabel),
            enabled: !_loading,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
              final t = v.trim();
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                return l10n.settingsChangeEmailInvalid;
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.settingsChangeEmailSubmit),
          ),
        ],
      ),
    );
  }
}

const int _kMinPasswordLength = 6;

class _ChangePasswordSheetBody extends StatefulWidget {
  const _ChangePasswordSheetBody({
    required this.hostContext,
    required this.l10n,
  });

  final BuildContext hostContext;
  final AppLocalizations l10n;

  @override
  State<_ChangePasswordSheetBody> createState() =>
      _ChangePasswordSheetBodyState();
}

class _ChangePasswordSheetBodyState extends State<_ChangePasswordSheetBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _newController;
  late final TextEditingController _confirmController;
  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _newController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      widget.hostContext,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await getIt<UpdatePasswordUsecase>()(newPassword: _newController.text);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      if (mounted) setState(() => _loading = false);
      _snack(e.message);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
      _snack(widget.l10n.unexpectedError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _newController,
            obscureText: _obscureNew,
            textInputAction: TextInputAction.next,
            autofocus: true,
            autofillHints: const [AutofillHints.newPassword],
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l10n.settingsNewPasswordLabel,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
            enabled: !_loading,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.fieldRequired;
              if (v.length < _kMinPasswordLength) {
                return l10n.settingsPasswordTooShort;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l10n.settingsConfirmNewPasswordLabel,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            enabled: !_loading,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.fieldRequired;
              if (v != _newController.text) {
                return l10n.settingsPasswordsDoNotMatch;
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.settingsChangePasswordSubmit),
          ),
        ],
      ),
    );
  }
}
