// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Habit Tracker';

  @override
  String get signIn => 'Sign in';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get continueWithoutAccount => 'Continue without account';

  @override
  String get fieldRequired => 'Required';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get habits => 'Habits';

  @override
  String habitsCount(int count) {
    return '$count habits';
  }

  @override
  String get emptyHabits => 'Create your first habit';

  @override
  String get newHabit => 'New habit';

  @override
  String get editHabit => 'Edit habit';

  @override
  String get deleteHabit => 'Delete habit';

  @override
  String get deleteHabitConfirm =>
      'This habit and its history will be removed. This cannot be undone.';

  @override
  String get deleteAction => 'Delete';

  @override
  String get habitName => 'Habit name';

  @override
  String get save => 'Save';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This week';

  @override
  String get streaks => 'Streaks';

  @override
  String get library => 'Library';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get last3Months => 'Last 3 months';

  @override
  String get rangeTitle => 'Range';

  @override
  String get reactivate => 'Reactivate';

  @override
  String get markComplete => 'Mark habit as completed';

  @override
  String get completedHabits => 'Completed habits';

  @override
  String get noCompletedHabits => 'No completed habits yet';

  @override
  String completedOn(String date) {
    return 'Completed: $date';
  }

  @override
  String get importConflicts => 'Resolve import conflicts';

  @override
  String get importMerge => 'Merge';

  @override
  String get importRename => 'Rename as new';

  @override
  String get importApply => 'Apply import';

  @override
  String get remainingToday => 'Still open today';

  @override
  String remainingTodayCount(int count) {
    return '$count still open today';
  }

  @override
  String atRiskList(String names) {
    return 'At risk: $names';
  }

  @override
  String get allCaughtUp => 'All caught up today';

  @override
  String get startToday => 'Start today';

  @override
  String streakDays(int count) {
    return '$count days';
  }

  @override
  String activeCompletedSummary(int active, int completed) {
    return '$active active · $completed completed';
  }

  @override
  String get tapToComplete => 'Tap to complete';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get totalCheckIns => 'Days completed';

  @override
  String get markToday => 'Mark today';

  @override
  String get markOtherDay => 'Another day';

  @override
  String get pickDay => 'Pick a day';

  @override
  String dayMarked(String date) {
    return '$date marked';
  }

  @override
  String dayUnmarked(String date) {
    return '$date unmarked';
  }

  @override
  String get weekdaysShort => 'Mo,Tu,We,Th,Fr,Sa,Su';

  @override
  String get monthsShort => 'JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC';

  @override
  String get undoToday => 'Undo today';

  @override
  String get doneToday => 'Done today';

  @override
  String get pendingToday => 'Pending today';

  @override
  String get todayMarked => 'Marked for today';

  @override
  String get todayUnmarked => 'Unmarked for today';

  @override
  String get undo => 'Undo';

  @override
  String get settings => 'Settings';

  @override
  String get settingsProfileSection => 'Profile';

  @override
  String get settingsChangeEmail => 'Change email';

  @override
  String get settingsChangeEmailDialogTitle => 'Change email';

  @override
  String get settingsNewEmailLabel => 'New email';

  @override
  String get settingsChangeEmailSubmit => 'Update';

  @override
  String get settingsChangeEmailSuccess =>
      'Check your new email to confirm the change.';

  @override
  String get settingsChangeEmailInvalid => 'Enter a valid email address.';

  @override
  String get settingsChangeEmailSameAsCurrent => 'That is already your email.';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsChangePasswordSubtitle =>
      'Updates the password you use to sign in.';

  @override
  String get settingsChangePasswordDialogTitle => 'Change password';

  @override
  String get settingsNewPasswordLabel => 'New password';

  @override
  String get settingsConfirmNewPasswordLabel => 'Confirm new password';

  @override
  String get settingsChangePasswordSubmit => 'Update password';

  @override
  String get settingsChangePasswordSuccess => 'Your password was updated.';

  @override
  String get settingsPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get settingsPasswordTooShort => 'Use at least 6 characters.';

  @override
  String get settingsSecuritySection => 'Security';

  @override
  String get settingsBiometricUnlockTitle => 'Face ID & fingerprint';

  @override
  String get settingsBiometricUnlockSubtitle =>
      'Use biometrics to unlock the app.';

  @override
  String get settingsBiometricUnavailable =>
      'Biometric unlock is not available on this device.';

  @override
  String get settingsBiometricAuthReason =>
      'Confirm to enable biometric unlock.';

  @override
  String get settingsBiometricResumeReason => 'Unlock Habit Tracker';

  @override
  String get biometricLockTitle => 'App locked';

  @override
  String get biometricLockBody =>
      'Unlock with biometrics to get back to your habits.';

  @override
  String get biometricLockFailed =>
      'Couldn\'t verify your identity. Try again.';

  @override
  String get biometricLockUnlockButton => 'Unlock';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsHabitsSection => 'Habits';

  @override
  String get settingsExportJson => 'Export JSON';

  @override
  String get settingsImportJson => 'Import JSON';

  @override
  String get settingsExportShareTitle => 'Habit Tracker export';

  @override
  String get settingsImportInvalidFile => 'The file is not valid';

  @override
  String get signOut => 'Sign out';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsAboutApp => 'About';

  @override
  String get settingsRateApp => 'Rate on Google Play';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsTermsOfUse => 'Terms of use';

  @override
  String get settingsAboutTagline => 'Habits and streaks in one place.';

  @override
  String get settingsAboutVersionLabel => 'Version';

  @override
  String get settingsAboutFeaturesHeading => 'What you can do';

  @override
  String get settingsAboutBulletHabits =>
      'Create habits and check in each day.';

  @override
  String get settingsAboutBulletViews =>
      'Switch between heatmap, list, and month views, and reorder your list.';

  @override
  String get settingsAboutBulletDashboard =>
      'Track streaks and weekly progress on the dashboard.';

  @override
  String get settingsAboutDataHeading => 'Your data';

  @override
  String get settingsAboutDataBody =>
      'As a guest, your habits stay on this device. If you sign in, they sync with Supabase. An account is optional.';

  @override
  String get settingsAboutDeveloperHeading => 'Developer';

  @override
  String get settingsAboutDeveloperGithub => 'GitHub';

  @override
  String get settingsAboutDeveloperWebsite => 'Website';

  @override
  String get settingsAboutDeveloperYoutube => 'YouTube';

  @override
  String get settingsAboutDeveloperLinkedin => 'LinkedIn';

  @override
  String get settingsPrivacyTagline => 'How this app treats your information.';

  @override
  String get settingsPrivacyDataTitle => 'Account (optional)';

  @override
  String get settingsPrivacyDataBody =>
      'You can use the app without an account. If you sign in, authentication is provided by Supabase. Your email and credentials are processed by Supabase; this app does not store your password.';

  @override
  String get settingsPrivacyInfraTitle => 'What we store today — and later';

  @override
  String get settingsPrivacyInfraBody =>
      'As a guest, your habits stay on this device. If you are signed in, your habits are stored in Supabase and tied to your account. In the future we may also store other app-generated information (for example favorites) in Supabase when you are signed in.';

  @override
  String get settingsPrivacySharingTitle => 'Sharing and ads';

  @override
  String get settingsPrivacySharingBody =>
      'We do not sell your data or use it for advertising. Sign-in and, when used, sync are processed by Supabase.';

  @override
  String get settingsTermsTagline => 'Rules for using this app.';

  @override
  String get settingsTermsAcceptanceTitle => 'Acceptance';

  @override
  String get settingsTermsAcceptanceBody =>
      'By using Habit Tracker, you accept these terms. Sign-in is optional and is handled by Supabase.';

  @override
  String get settingsTermsDataTitle => 'Your data';

  @override
  String get settingsTermsDataBody =>
      'Without an account, habits stay on the device. When signed in they are stored in Supabase. Later we may sync additional app-generated data the same way.';

  @override
  String get settingsTermsDisclaimerTitle => 'Not professional advice';

  @override
  String get settingsTermsDisclaimerBody =>
      'The app does not provide medical or professional advice.';

  @override
  String get settingsTermsResponsibilitiesTitle => 'Your responsibility';

  @override
  String get settingsTermsResponsibilitiesBody =>
      'You are responsible for your device, your account, and exported backups.';
}
