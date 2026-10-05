import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../locale/app_locale_controller.dart';
import '../security/app_biometric_unlock_controller.dart';
import '../theme/app_theme_controller.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/update_email_usecase.dart';
import '../../features/auth/domain/usecases/update_password_usecase.dart';
import '../../features/auth/presentation/cubit/session_cubit.dart';
import '../../features/habits/data/datasources/habits_backup_datasource.dart';
import '../../features/habits/data/repositories/habits_migrator.dart';
import '../../features/habits/data/repositories/local_habits_repository.dart';
import '../../features/habits/data/repositories/supabase_habits_repository.dart';
import '../../features/habits/domain/repositories/habits_repository.dart';
import '../../features/habits/presentation/cubit/habits_cubit.dart';

final getIt = GetIt.instance;

/// Registers every dependency, backed by the initialized Supabase client.
void setupDi() {
  setupCoreDi();

  final client = Supabase.instance.client;
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(client));
  HabitsRepository cloud(String userId) =>
      SupabaseHabitsRepository(client, userId);
  getIt.registerLazySingleton<SessionCubit>(
    () => SessionCubit(
      auth: getIt<AuthRepository>(),
      migrator: HabitsMigrator(
        local: getIt<LocalHabitsRepository>(),
        cloudForUser: cloud,
      ),
      localRepository: getIt<LocalHabitsRepository>(),
      cloudRepository: cloud,
    ),
  );
  getIt.registerLazySingleton<UpdateEmailUsecase>(
    () => UpdateEmailUsecase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<UpdatePasswordUsecase>(
    () => UpdatePasswordUsecase(getIt<AuthRepository>()),
  );
}

/// Dependencies that do not need Supabase (also used by widget tests).
void setupCoreDi() {
  getIt.registerLazySingleton<AppLocaleController>(AppLocaleController.new);
  getIt.registerLazySingleton<AppThemeController>(AppThemeController.new);
  getIt.registerLazySingleton<AppBiometricUnlockController>(
    AppBiometricUnlockController.new,
  );

  // habits
  getIt.registerLazySingleton<LocalHabitsRepository>(
    LocalHabitsRepository.new,
  );
  getIt.registerLazySingleton<HabitsBackupDatasource>(
    HabitsBackupDatasource.new,
  );
  getIt.registerFactoryParam<HabitsCubit, HabitsRepository, void>(
    (repository, _) => HabitsCubit(repository),
  );
}
