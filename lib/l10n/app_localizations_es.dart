// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Habit Tracker';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get email => 'Correo';

  @override
  String get password => 'Contraseña';

  @override
  String get continueWithoutAccount => 'Continuar sin cuenta';

  @override
  String get fieldRequired => 'Obligatorio';

  @override
  String get unexpectedError => 'Ocurrió un error inesperado';

  @override
  String get habits => 'Hábitos';

  @override
  String habitsCount(int count) {
    return '$count hábitos';
  }

  @override
  String get emptyHabits => 'Crea tu primer hábito';

  @override
  String get newHabit => 'Nuevo hábito';

  @override
  String get editHabit => 'Editar hábito';

  @override
  String get deleteHabit => 'Eliminar hábito';

  @override
  String get deleteHabitConfirm =>
      'Se borrará este hábito y su historial. Esta acción no se puede deshacer.';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get habitName => 'Nombre del hábito';

  @override
  String get save => 'Guardar';

  @override
  String get today => 'Hoy';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get streaks => 'Rachas';

  @override
  String get library => 'Biblioteca';

  @override
  String get dashboard => 'Resumen';

  @override
  String get last7Days => 'Últimos 7 días';

  @override
  String get last30Days => 'Últimos 30 días';

  @override
  String get last3Months => 'Últimos 3 meses';

  @override
  String get rangeTitle => 'Periodo';

  @override
  String get reactivate => 'Reactivar';

  @override
  String get markComplete => 'Marcar hábito como completado';

  @override
  String get completedHabits => 'Hábitos completados';

  @override
  String get noCompletedHabits => 'Aún no hay hábitos';

  @override
  String completedOn(String date) {
    return 'Completado: $date';
  }

  @override
  String get importConflicts => 'Resolver conflictos';

  @override
  String get importMerge => 'Combinar';

  @override
  String get importRename => 'Renombrar como nuevo';

  @override
  String get importApply => 'Aplicar importación';

  @override
  String get remainingToday => 'Pendientes de hoy';

  @override
  String remainingTodayCount(int count) {
    return '$count pendientes de hoy';
  }

  @override
  String atRiskList(String names) {
    return 'En riesgo: $names';
  }

  @override
  String get allCaughtUp => 'Todo listo por hoy';

  @override
  String get startToday => 'Empieza hoy';

  @override
  String streakDays(int count) {
    return '$count días';
  }

  @override
  String activeCompletedSummary(int active, int completed) {
    return '$active activos · $completed completados';
  }

  @override
  String get tapToComplete => 'Toca para marcar';

  @override
  String get currentStreak => 'Racha actual';

  @override
  String get totalCheckIns => 'Días cumplidos';

  @override
  String get markToday => 'Marcar hoy';

  @override
  String get markOtherDay => 'Otro día';

  @override
  String get pickDay => 'Elige un día';

  @override
  String dayMarked(String date) {
    return '$date marcado';
  }

  @override
  String dayUnmarked(String date) {
    return '$date sin marcar';
  }

  @override
  String get weekdaysShort => 'Lu,Ma,Mi,Ju,Vi,Sá,Do';

  @override
  String get monthsShort => 'ENE,FEB,MAR,ABR,MAY,JUN,JUL,AGO,SEP,OCT,NOV,DIC';

  @override
  String get undoToday => 'Deshacer hoy';

  @override
  String get doneToday => 'Hecho hoy';

  @override
  String get pendingToday => 'Pendiente hoy';

  @override
  String get todayMarked => 'Hoy marcado';

  @override
  String get todayUnmarked => 'Hoy sin marcar';

  @override
  String get undo => 'Deshacer';

  @override
  String get settings => 'Ajustes';

  @override
  String get settingsProfileSection => 'Perfil';

  @override
  String get settingsChangeEmail => 'Cambiar correo';

  @override
  String get settingsChangeEmailDialogTitle => 'Cambiar correo';

  @override
  String get settingsNewEmailLabel => 'Correo nuevo';

  @override
  String get settingsChangeEmailSubmit => 'Actualizar';

  @override
  String get settingsChangeEmailSuccess =>
      'Revisa tu correo nuevo para confirmar el cambio.';

  @override
  String get settingsChangeEmailInvalid => 'Introduce un correo válido.';

  @override
  String get settingsChangeEmailSameAsCurrent => 'Ese ya es tu correo.';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsChangePasswordSubtitle =>
      'Actualiza la contraseña con la que inicias sesión.';

  @override
  String get settingsChangePasswordDialogTitle => 'Cambiar contraseña';

  @override
  String get settingsNewPasswordLabel => 'Contraseña nueva';

  @override
  String get settingsConfirmNewPasswordLabel => 'Confirmar contraseña';

  @override
  String get settingsChangePasswordSubmit => 'Actualizar contraseña';

  @override
  String get settingsChangePasswordSuccess => 'Tu contraseña se actualizó.';

  @override
  String get settingsPasswordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String get settingsPasswordTooShort => 'Usa al menos 6 caracteres.';

  @override
  String get settingsSecuritySection => 'Seguridad';

  @override
  String get settingsBiometricUnlockTitle => 'Face ID y huella dactilar';

  @override
  String get settingsBiometricUnlockSubtitle =>
      'Usa la biometría para desbloquear la app.';

  @override
  String get settingsBiometricUnavailable =>
      'El desbloqueo biométrico no está disponible en este dispositivo.';

  @override
  String get settingsBiometricAuthReason =>
      'Confirma para activar el desbloqueo biométrico.';

  @override
  String get settingsBiometricResumeReason => 'Desbloquea Habit Tracker';

  @override
  String get biometricLockTitle => 'App bloqueada';

  @override
  String get biometricLockBody =>
      'Desbloquea con tu biometría para volver a tus hábitos.';

  @override
  String get biometricLockFailed =>
      'No se pudo verificar tu identidad. Inténtalo de nuevo.';

  @override
  String get biometricLockUnlockButton => 'Desbloquear';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String get settingsLanguageEnglish => 'Inglés';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Predeterminado del sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsHabitsSection => 'Hábitos';

  @override
  String get settingsExportJson => 'Exportar JSON';

  @override
  String get settingsImportJson => 'Importar JSON';

  @override
  String get settingsExportShareTitle => 'Exportación de Habit Tracker';

  @override
  String get settingsImportInvalidFile => 'El archivo no es válido';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get settingsAboutSection => 'Acerca de';

  @override
  String get settingsAboutApp => 'Acerca de';

  @override
  String get settingsRateApp => 'Calificar en Google Play';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsTermsOfUse => 'Términos de uso';

  @override
  String get settingsAboutTagline => 'Hábitos y rachas en un lugar.';

  @override
  String get settingsAboutVersionLabel => 'Versión';

  @override
  String get settingsAboutFeaturesHeading => 'Qué puedes hacer';

  @override
  String get settingsAboutBulletHabits =>
      'Crea hábitos y regístralos cada día.';

  @override
  String get settingsAboutBulletViews =>
      'Cambia entre las vistas de mapa de calor, lista y mes, y reordena tu lista.';

  @override
  String get settingsAboutBulletDashboard =>
      'Sigue tus rachas y tu progreso semanal en el resumen.';

  @override
  String get settingsAboutDataHeading => 'Tus datos';

  @override
  String get settingsAboutDataBody =>
      'Como invitado, tus hábitos se guardan en este dispositivo. Si inicias sesión, se sincronizan con Supabase. La cuenta es opcional.';

  @override
  String get settingsAboutDeveloperHeading => 'Desarrollador';

  @override
  String get settingsAboutDeveloperGithub => 'GitHub';

  @override
  String get settingsAboutDeveloperWebsite => 'Sitio web';

  @override
  String get settingsAboutDeveloperYoutube => 'YouTube';

  @override
  String get settingsAboutDeveloperLinkedin => 'LinkedIn';

  @override
  String get settingsPrivacyTagline => 'Cómo trata esta app tu información.';

  @override
  String get settingsPrivacyDataTitle => 'Cuenta (opcional)';

  @override
  String get settingsPrivacyDataBody =>
      'Puedes usar la app sin cuenta. Si inicias sesión, la autenticación la proporciona Supabase. Tu correo y credenciales los procesa Supabase; esta app no guarda tu contraseña.';

  @override
  String get settingsPrivacyInfraTitle => 'Qué guardamos hoy — y más adelante';

  @override
  String get settingsPrivacyInfraBody =>
      'Como invitado, tus hábitos se quedan en este dispositivo. Si has iniciado sesión, tus hábitos se guardan en Supabase ligados a tu cuenta. En el futuro también podremos guardar otra información generada por la app (por ejemplo favoritos) en Supabase cuando hayas iniciado sesión.';

  @override
  String get settingsPrivacySharingTitle => 'Compartir y anuncios';

  @override
  String get settingsPrivacySharingBody =>
      'No vendemos datos ni los usamos para anuncios. El inicio de sesión y, si aplica, la sincronización los procesa Supabase.';

  @override
  String get settingsTermsTagline => 'Reglas para usar esta app.';

  @override
  String get settingsTermsAcceptanceTitle => 'Aceptación';

  @override
  String get settingsTermsAcceptanceBody =>
      'Al usar Habit Tracker aceptas estos términos. El inicio de sesión es opcional y lo gestiona Supabase.';

  @override
  String get settingsTermsDataTitle => 'Tus datos';

  @override
  String get settingsTermsDataBody =>
      'Sin cuenta, los hábitos se quedan en el dispositivo. Con sesión iniciada se guardan en Supabase. Más adelante podremos sincronizar datos adicionales generados por la app.';

  @override
  String get settingsTermsDisclaimerTitle => 'No es consejo profesional';

  @override
  String get settingsTermsDisclaimerBody =>
      'La app no ofrece consejo médico ni profesional.';

  @override
  String get settingsTermsResponsibilitiesTitle => 'Responsabilidad';

  @override
  String get settingsTermsResponsibilitiesBody =>
      'Eres responsable de tu dispositivo, tu cuenta y tus copias exportadas.';
}
