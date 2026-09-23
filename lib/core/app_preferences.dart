import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { system, es, en }

enum AppThemePreference { system, light, dark }

class AppPreferences extends ChangeNotifier {
  AppLanguage language = AppLanguage.system;
  AppThemePreference theme = AppThemePreference.system;
  bool biometricLock = false;

  Locale? get locale => switch (language) {
    AppLanguage.system => null,
    AppLanguage.es => const Locale('es'),
    AppLanguage.en => const Locale('en'),
  };

  ThemeMode get themeMode => switch (theme) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    language = AppLanguage.values.firstWhere(
      (item) => item.name == prefs.getString('language'),
      orElse: () => AppLanguage.system,
    );
    theme = AppThemePreference.values.firstWhere(
      (item) => item.name == prefs.getString('theme'),
      orElse: () => AppThemePreference.system,
    );
    biometricLock = prefs.getBool('biometricLock') ?? false;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage value) async {
    language = value;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(
      'language',
      value.name,
    );
  }

  Future<void> setTheme(AppThemePreference value) async {
    theme = value;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(
      'theme',
      value.name,
    );
  }

  Future<void> setBiometricLock(bool value) async {
    biometricLock = value;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setBool(
      'biometricLock',
      value,
    );
  }
}

class AppStrings {
  AppStrings(this.locale);
  final Locale locale;
  bool get es => locale.languageCode == 'es';

  String get appName => "Danny's Habits Tracker";
  String get settings => es ? 'Ajustes' : 'Settings';
  String get appearance => es ? 'Apariencia' : 'Appearance';
  String get language => es ? 'Idioma' : 'Language';
  String get theme => es ? 'Tema' : 'Theme';
  String get system => es ? 'Sistema' : 'System';
  String get spanish => 'Español';
  String get english => 'English';
  String get light => es ? 'Claro' : 'Light';
  String get dark => es ? 'Oscuro' : 'Dark';
  String get habits => es ? 'Hábitos' : 'Habits';
  String get completed => es ? 'Hábitos completados' : 'Completed habits';
  String get exportJson => es ? 'Exportar JSON' : 'Export JSON';
  String get importJson => es ? 'Importar JSON' : 'Import JSON';
  String get about => es ? 'Acerca de' : 'About';
  String get developer => es ? 'Desarrollador' : 'Developer';
  String get developerGithub => 'GitHub';
  String get developerWebsite => es ? 'Sitio web' : 'Website';
  String get developerYoutube => 'YouTube';
  String get developerLinkedin => 'LinkedIn';
  String get privacy => es ? 'Política de privacidad' : 'Privacy policy';
  String get terms => es ? 'Términos de uso' : 'Terms of use';
  String get newHabit => es ? 'Nuevo hábito' : 'New habit';
  String get editHabit => es ? 'Editar hábito' : 'Edit habit';
  String get deleteHabit => es ? 'Eliminar hábito' : 'Delete habit';
  String get deleteHabitConfirm => es
      ? 'Se borrará este hábito y su historial. Esta acción no se puede deshacer.'
      : 'This habit and its history will be removed. This cannot be undone.';
  String get deleteAction => es ? 'Eliminar' : 'Delete';
  String get lockedTitle => es ? 'App bloqueada' : 'App locked';
  String get lockedBody => es
      ? 'Desbloquea con tu biometría para volver a tus hábitos.'
      : 'Unlock with biometrics to get back to your habits.';
  String get unlock => es ? 'Desbloquear' : 'Unlock';
  String get unlockReason =>
      es ? "Desbloquea Danny's Habits Tracker" : "Unlock Danny's Habits Tracker";
  String get unlockFailed => es
      ? 'No se pudo verificar tu identidad. Inténtalo de nuevo.'
      : "Couldn't verify your identity. Try again.";
  String get habitName => es ? 'Nombre del hábito' : 'Habit name';
  String get save => es ? 'Guardar' : 'Save';
  String get today => es ? 'Hoy' : 'Today';
  String get thisWeek => es ? 'Esta semana' : 'This week';
  String get streaks => es ? 'Rachas' : 'Streaks';
  String get library => es ? 'Biblioteca' : 'Library';
  String get dashboard => es ? 'Resumen' : 'Dashboard';
  String get lastFiveDays => es ? 'Últimos 5 días' : 'Last 5 days';
  String get last7Days => es ? 'Últimos 7 días' : 'Last 7 days';
  String get last30Days => es ? 'Últimos 30 días' : 'Last 30 days';
  String get last3Months => es ? 'Últimos 3 meses' : 'Last 3 months';
  String get rangeTitle => es ? 'Periodo' : 'Range';
  String get reactivate => es ? 'Reactivar' : 'Reactivate';
  String get markComplete =>
      es ? 'Marcar hábito como completado' : 'Mark habit as completed';
  String get importConflicts =>
      es ? 'Resolver conflictos' : 'Resolve import conflicts';
  String get merge => es ? 'Combinar' : 'Merge';
  String get rename => es ? 'Renombrar como nuevo' : 'Rename as new';
  String get apply => es ? 'Aplicar importación' : 'Apply import';
  String get remainingToday => es ? 'Pendientes de hoy' : 'Still open today';
  String get atRisk => es ? 'En riesgo' : 'At risk';
  String get allCaughtUp => es ? 'Todo listo por hoy' : 'All caught up today';
  String get startToday => es ? 'Empieza hoy' : 'Start today';
  String get daysWord => es ? 'días' : 'days';
  String get activeWord => es ? 'activos' : 'active';
  String get completedWord => es ? 'completados' : 'completed';
  String get tapToComplete => es ? 'Toca para marcar' : 'Tap to complete';
  String get currentStreak => es ? 'Racha actual' : 'Current streak';
  String get totalCheckIns => es ? 'Días cumplidos' : 'Days completed';
  String get tapDayToToggle =>
      es ? 'Toca un día para marcarlo' : 'Tap a day to mark it';
  String get markToday => es ? 'Marcar hoy' : 'Mark today';
  String get markOtherDay => es ? 'Otro día' : 'Another day';
  String get pickDay => es ? 'Elige un día' : 'Pick a day';
  String get markedWord => es ? 'marcado' : 'marked';
  String get unmarkedWord => es ? 'sin marcar' : 'unmarked';
  List<String> get weekdaysShort => es
      ? const ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá', 'Do']
      : const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  String get undoToday => es ? 'Deshacer hoy' : 'Undo today';
  String get doneToday => es ? 'Hecho hoy' : 'Done today';
  String get pendingToday => es ? 'Pendiente hoy' : 'Pending today';
  String get todayMarked => es ? 'Hoy marcado' : 'Marked for today';
  String get todayUnmarked => es ? 'Hoy sin marcar' : 'Unmarked for today';
  String get undo => es ? 'Deshacer' : 'Undo';

  static AppStrings of(BuildContext context) =>
      AppStrings(Localizations.localeOf(context));
}
