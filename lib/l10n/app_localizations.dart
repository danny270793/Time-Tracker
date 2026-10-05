import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit Tracker'**
  String get appTitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @continueWithoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get continueWithoutAccount;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habits;

  /// No description provided for @habitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} habits'**
  String habitsCount(int count);

  /// No description provided for @emptyHabits.
  ///
  /// In en, this message translates to:
  /// **'Create your first habit'**
  String get emptyHabits;

  /// No description provided for @newHabit.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get newHabit;

  /// No description provided for @editHabit.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get editHabit;

  /// No description provided for @deleteHabit.
  ///
  /// In en, this message translates to:
  /// **'Delete habit'**
  String get deleteHabit;

  /// No description provided for @deleteHabitConfirm.
  ///
  /// In en, this message translates to:
  /// **'This habit and its history will be removed. This cannot be undone.'**
  String get deleteHabitConfirm;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @habitName.
  ///
  /// In en, this message translates to:
  /// **'Habit name'**
  String get habitName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @streaks.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get streaks;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @last3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get last3Months;

  /// No description provided for @rangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get rangeTitle;

  /// No description provided for @reactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get reactivate;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark habit as completed'**
  String get markComplete;

  /// No description provided for @completedHabits.
  ///
  /// In en, this message translates to:
  /// **'Completed habits'**
  String get completedHabits;

  /// No description provided for @noCompletedHabits.
  ///
  /// In en, this message translates to:
  /// **'No completed habits yet'**
  String get noCompletedHabits;

  /// No description provided for @completedOn.
  ///
  /// In en, this message translates to:
  /// **'Completed: {date}'**
  String completedOn(String date);

  /// No description provided for @importConflicts.
  ///
  /// In en, this message translates to:
  /// **'Resolve import conflicts'**
  String get importConflicts;

  /// No description provided for @importMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get importMerge;

  /// No description provided for @importRename.
  ///
  /// In en, this message translates to:
  /// **'Rename as new'**
  String get importRename;

  /// No description provided for @importApply.
  ///
  /// In en, this message translates to:
  /// **'Apply import'**
  String get importApply;

  /// No description provided for @remainingToday.
  ///
  /// In en, this message translates to:
  /// **'Still open today'**
  String get remainingToday;

  /// No description provided for @remainingTodayCount.
  ///
  /// In en, this message translates to:
  /// **'{count} still open today'**
  String remainingTodayCount(int count);

  /// No description provided for @atRiskList.
  ///
  /// In en, this message translates to:
  /// **'At risk: {names}'**
  String atRiskList(String names);

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up today'**
  String get allCaughtUp;

  /// No description provided for @startToday.
  ///
  /// In en, this message translates to:
  /// **'Start today'**
  String get startToday;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String streakDays(int count);

  /// No description provided for @activeCompletedSummary.
  ///
  /// In en, this message translates to:
  /// **'{active} active · {completed} completed'**
  String activeCompletedSummary(int active, int completed);

  /// No description provided for @tapToComplete.
  ///
  /// In en, this message translates to:
  /// **'Tap to complete'**
  String get tapToComplete;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @totalCheckIns.
  ///
  /// In en, this message translates to:
  /// **'Days completed'**
  String get totalCheckIns;

  /// No description provided for @markToday.
  ///
  /// In en, this message translates to:
  /// **'Mark today'**
  String get markToday;

  /// No description provided for @markOtherDay.
  ///
  /// In en, this message translates to:
  /// **'Another day'**
  String get markOtherDay;

  /// No description provided for @pickDay.
  ///
  /// In en, this message translates to:
  /// **'Pick a day'**
  String get pickDay;

  /// No description provided for @dayMarked.
  ///
  /// In en, this message translates to:
  /// **'{date} marked'**
  String dayMarked(String date);

  /// No description provided for @dayUnmarked.
  ///
  /// In en, this message translates to:
  /// **'{date} unmarked'**
  String dayUnmarked(String date);

  /// Comma-separated short weekday names, Monday first.
  ///
  /// In en, this message translates to:
  /// **'Mo,Tu,We,Th,Fr,Sa,Su'**
  String get weekdaysShort;

  /// Comma-separated short month names, January first.
  ///
  /// In en, this message translates to:
  /// **'JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC'**
  String get monthsShort;

  /// No description provided for @undoToday.
  ///
  /// In en, this message translates to:
  /// **'Undo today'**
  String get undoToday;

  /// No description provided for @doneToday.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get doneToday;

  /// No description provided for @pendingToday.
  ///
  /// In en, this message translates to:
  /// **'Pending today'**
  String get pendingToday;

  /// No description provided for @todayMarked.
  ///
  /// In en, this message translates to:
  /// **'Marked for today'**
  String get todayMarked;

  /// No description provided for @todayUnmarked.
  ///
  /// In en, this message translates to:
  /// **'Unmarked for today'**
  String get todayUnmarked;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsProfileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfileSection;

  /// No description provided for @settingsChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get settingsChangeEmail;

  /// No description provided for @settingsChangeEmailDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get settingsChangeEmailDialogTitle;

  /// No description provided for @settingsNewEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get settingsNewEmailLabel;

  /// No description provided for @settingsChangeEmailSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get settingsChangeEmailSubmit;

  /// No description provided for @settingsChangeEmailSuccess.
  ///
  /// In en, this message translates to:
  /// **'Check your new email to confirm the change.'**
  String get settingsChangeEmailSuccess;

  /// No description provided for @settingsChangeEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get settingsChangeEmailInvalid;

  /// No description provided for @settingsChangeEmailSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'That is already your email.'**
  String get settingsChangeEmailSameAsCurrent;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePassword;

  /// No description provided for @settingsChangePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Updates the password you use to sign in.'**
  String get settingsChangePasswordSubtitle;

  /// No description provided for @settingsChangePasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePasswordDialogTitle;

  /// No description provided for @settingsNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get settingsNewPasswordLabel;

  /// No description provided for @settingsConfirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get settingsConfirmNewPasswordLabel;

  /// No description provided for @settingsChangePasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get settingsChangePasswordSubmit;

  /// No description provided for @settingsChangePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password was updated.'**
  String get settingsChangePasswordSuccess;

  /// No description provided for @settingsPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get settingsPasswordsDoNotMatch;

  /// No description provided for @settingsPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters.'**
  String get settingsPasswordTooShort;

  /// No description provided for @settingsSecuritySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecuritySection;

  /// No description provided for @settingsBiometricUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Face ID & fingerprint'**
  String get settingsBiometricUnlockTitle;

  /// No description provided for @settingsBiometricUnlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics to unlock the app.'**
  String get settingsBiometricUnlockSubtitle;

  /// No description provided for @settingsBiometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock is not available on this device.'**
  String get settingsBiometricUnavailable;

  /// No description provided for @settingsBiometricAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm to enable biometric unlock.'**
  String get settingsBiometricAuthReason;

  /// No description provided for @settingsBiometricResumeReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Habit Tracker'**
  String get settingsBiometricResumeReason;

  /// No description provided for @biometricLockTitle.
  ///
  /// In en, this message translates to:
  /// **'App locked'**
  String get biometricLockTitle;

  /// No description provided for @biometricLockBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics to get back to your habits.'**
  String get biometricLockBody;

  /// No description provided for @biometricLockFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t verify your identity. Try again.'**
  String get biometricLockFailed;

  /// No description provided for @biometricLockUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get biometricLockUnlockButton;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsHabitsSection.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get settingsHabitsSection;

  /// No description provided for @settingsExportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get settingsExportJson;

  /// No description provided for @settingsImportJson.
  ///
  /// In en, this message translates to:
  /// **'Import JSON'**
  String get settingsImportJson;

  /// No description provided for @settingsExportShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit Tracker export'**
  String get settingsExportShareTitle;

  /// No description provided for @settingsImportInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'The file is not valid'**
  String get settingsImportInvalidFile;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutApp;

  /// No description provided for @settingsRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate on Google Play'**
  String get settingsRateApp;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get settingsTermsOfUse;

  /// No description provided for @settingsAboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Habits and streaks in one place.'**
  String get settingsAboutTagline;

  /// No description provided for @settingsAboutVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsAboutVersionLabel;

  /// No description provided for @settingsAboutFeaturesHeading.
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get settingsAboutFeaturesHeading;

  /// No description provided for @settingsAboutBulletHabits.
  ///
  /// In en, this message translates to:
  /// **'Create habits and check in each day.'**
  String get settingsAboutBulletHabits;

  /// No description provided for @settingsAboutBulletViews.
  ///
  /// In en, this message translates to:
  /// **'Switch between heatmap, list, and month views, and reorder your list.'**
  String get settingsAboutBulletViews;

  /// No description provided for @settingsAboutBulletDashboard.
  ///
  /// In en, this message translates to:
  /// **'Track streaks and weekly progress on the dashboard.'**
  String get settingsAboutBulletDashboard;

  /// No description provided for @settingsAboutDataHeading.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsAboutDataHeading;

  /// No description provided for @settingsAboutDataBody.
  ///
  /// In en, this message translates to:
  /// **'As a guest, your habits stay on this device. If you sign in, they sync with Supabase. An account is optional.'**
  String get settingsAboutDataBody;

  /// No description provided for @settingsAboutDeveloperHeading.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settingsAboutDeveloperHeading;

  /// No description provided for @settingsAboutDeveloperGithub.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get settingsAboutDeveloperGithub;

  /// No description provided for @settingsAboutDeveloperWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get settingsAboutDeveloperWebsite;

  /// No description provided for @settingsAboutDeveloperYoutube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get settingsAboutDeveloperYoutube;

  /// No description provided for @settingsAboutDeveloperLinkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get settingsAboutDeveloperLinkedin;

  /// No description provided for @settingsPrivacyTagline.
  ///
  /// In en, this message translates to:
  /// **'How this app treats your information.'**
  String get settingsPrivacyTagline;

  /// No description provided for @settingsPrivacyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Account (optional)'**
  String get settingsPrivacyDataTitle;

  /// No description provided for @settingsPrivacyDataBody.
  ///
  /// In en, this message translates to:
  /// **'You can use the app without an account. If you sign in, authentication is provided by Supabase. Your email and credentials are processed by Supabase; this app does not store your password.'**
  String get settingsPrivacyDataBody;

  /// No description provided for @settingsPrivacyInfraTitle.
  ///
  /// In en, this message translates to:
  /// **'What we store today — and later'**
  String get settingsPrivacyInfraTitle;

  /// No description provided for @settingsPrivacyInfraBody.
  ///
  /// In en, this message translates to:
  /// **'As a guest, your habits stay on this device. If you are signed in, your habits are stored in Supabase and tied to your account. In the future we may also store other app-generated information (for example favorites) in Supabase when you are signed in.'**
  String get settingsPrivacyInfraBody;

  /// No description provided for @settingsPrivacySharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sharing and ads'**
  String get settingsPrivacySharingTitle;

  /// No description provided for @settingsPrivacySharingBody.
  ///
  /// In en, this message translates to:
  /// **'We do not sell your data or use it for advertising. Sign-in and, when used, sync are processed by Supabase.'**
  String get settingsPrivacySharingBody;

  /// No description provided for @settingsTermsTagline.
  ///
  /// In en, this message translates to:
  /// **'Rules for using this app.'**
  String get settingsTermsTagline;

  /// No description provided for @settingsTermsAcceptanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Acceptance'**
  String get settingsTermsAcceptanceTitle;

  /// No description provided for @settingsTermsAcceptanceBody.
  ///
  /// In en, this message translates to:
  /// **'By using Habit Tracker, you accept these terms. Sign-in is optional and is handled by Supabase.'**
  String get settingsTermsAcceptanceBody;

  /// No description provided for @settingsTermsDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsTermsDataTitle;

  /// No description provided for @settingsTermsDataBody.
  ///
  /// In en, this message translates to:
  /// **'Without an account, habits stay on the device. When signed in they are stored in Supabase. Later we may sync additional app-generated data the same way.'**
  String get settingsTermsDataBody;

  /// No description provided for @settingsTermsDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Not professional advice'**
  String get settingsTermsDisclaimerTitle;

  /// No description provided for @settingsTermsDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'The app does not provide medical or professional advice.'**
  String get settingsTermsDisclaimerBody;

  /// No description provided for @settingsTermsResponsibilitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your responsibility'**
  String get settingsTermsResponsibilitiesTitle;

  /// No description provided for @settingsTermsResponsibilitiesBody.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for your device, your account, and exported backups.'**
  String get settingsTermsResponsibilitiesBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
