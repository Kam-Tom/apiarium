import 'package:apiarium/features/auth/bloc/auth_bloc.dart';
import 'package:apiarium/features/settings/bloc/preferences_bloc.dart';
import 'package:apiarium/shared/services/auth_service.dart';
import 'package:apiarium/shared/services/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../shared/shared.dart';

final getIt = GetIt.instance;

class DependencyInjection {
  static Future<void> init() async {
    // Core services
    getIt.registerLazySingleton(() => AuthService());
    getIt.registerLazySingleton(() => UserRepository());
    
    // Create needed services
    final settingsRepository = await SettingsRepository.create();

    getIt.registerSingleton<SettingsRepository>(settingsRepository);

    // Initialize needed services
    await getIt<UserRepository>().initialize();
    
  //   // Repositories
  //   getIt.registerLazySingleton(() => AuthRepository(
  //     getIt<ApiService>(),
  //     getIt<UserService>(),
  //   ));
  //   getIt.registerLazySingleton(() => QueenRepository());
  //   getIt.registerLazySingleton(() => QueenBreedRepository());
  //   getIt.registerLazySingleton(() => ApiaryRepository());
  //   getIt.registerLazySingleton(() => HiveRepository());
  //   getIt.registerLazySingleton(() => HiveTypeRepository());
  //   getIt.registerLazySingleton(() => ReportRepository());
  //   getIt.registerLazySingleton(() => HistoryLogRepository());

  //   // Services
  //   getIt.registerLazySingleton(() => SyncService());
  //   getIt.registerLazySingleton(() => TtsService());
  //   getIt.registerLazySingleton(() => VoskService());
    
  //   getIt.registerLazySingleton(() => NameGeneratorService(getIt<UserRepository>()));
  //   getIt.registerLazySingleton(() => VcService(
  //     ttsService: getIt<TtsService>(),
  //     voskService: getIt<VoskService>(),
  //     userService: getIt<UserRepository>(),
  //   ));
    
  //   getIt.registerLazySingleton(() => ReportService(
  //     reportRepository: getIt<ReportRepository>(),
  //     historyLogRepository: getIt<HistoryLogRepository>(),
  //     syncService: getIt<SyncService>(),
  //   ));
    
  //   getIt.registerLazySingleton(() => ApiaryService(
  //     apiaryRepository: getIt<ApiaryRepository>(),
  //     historyLogRepository: getIt<HistoryLogRepository>(),
  //   ));

  //   getIt.registerLazySingleton(() => HiveService(
  //     hiveRepository: getIt<HiveRepository>(),
  //     hiveTypeRepository: getIt<HiveTypeRepository>(),
  //     historyLogRepository: getIt<HistoryLogRepository>(),
  //   ));

  //   getIt.registerLazySingleton(() => QueenService(
  //     queenRepository: getIt<QueenRepository>(),
  //     queenBreedRepository: getIt<QueenBreedRepository>(),
  //     historyLogRepository: getIt<HistoryLogRepository>(),
  //   ));
  }

  //Root BlocProviders
  static List<BlocProvider> get blocProviders => [
    BlocProvider<PreferencesBloc>(
      create: (context) => PreferencesBloc(
        userRepository: getIt<UserRepository>(),
        settingsRepository: getIt<SettingsRepository>(),
      )..add(LoadPreferences()),
    ),
  ];

}
