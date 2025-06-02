import 'package:apiarium/features/auth/bloc/auth_bloc.dart';
import 'package:apiarium/features/auth/repositories/auth_repository.dart';
import 'package:apiarium/shared/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../shared/shared.dart';
import '../../features/auth/auth_repository.dart';
import '../../features/home/settings/bloc/preferences_bloc.dart';

final getIt = GetIt.instance;

class DependencyInjection {
  static Future<void> init() async {
    // Core services
    getIt.registerLazySingleton(() => ApiService());
    getIt.registerLazySingleton(() => UserService(getIt<ApiService>()));
    
    // Initialize user service to load existing user
    await getIt<UserService>().initialize();
    
    // Repositories
    getIt.registerLazySingleton(() => AuthRepository(
      getIt<ApiService>(),
      getIt<UserService>(),
    ));
    getIt.registerLazySingleton(() => QueenRepository());
    getIt.registerLazySingleton(() => QueenBreedRepository());
    getIt.registerLazySingleton(() => ApiaryRepository());
    getIt.registerLazySingleton(() => HiveRepository());
    getIt.registerLazySingleton(() => HiveTypeRepository());
    getIt.registerLazySingleton(() => ReportRepository());
    getIt.registerLazySingleton(() => HistoryLogRepository());

    // Services
    getIt.registerLazySingleton(() => SyncService());
    getIt.registerLazySingleton(() => TtsService());
    getIt.registerLazySingleton(() => VoskService());
    
    getIt.registerLazySingleton(() => NameGeneratorService(getIt<UserService>()));
    getIt.registerLazySingleton(() => VcService(
      ttsService: getIt<TtsService>(),
      voskService: getIt<VoskService>(),
      userService: getIt<UserService>(),
    ));
    
    getIt.registerLazySingleton(() => ReportService(
      reportRepository: getIt<ReportRepository>(),
      historyLogRepository: getIt<HistoryLogRepository>(),
      syncService: getIt<SyncService>(),
    ));
    
    getIt.registerLazySingleton(() => ApiaryService(
      apiaryRepository: getIt<ApiaryRepository>(),
      historyLogRepository: getIt<HistoryLogRepository>(),
    ));

    getIt.registerLazySingleton(() => HiveService(
      hiveRepository: getIt<HiveRepository>(),
      hiveTypeRepository: getIt<HiveTypeRepository>(),
      historyLogRepository: getIt<HistoryLogRepository>(),
    ));

    getIt.registerLazySingleton(() => QueenService(
      queenRepository: getIt<QueenRepository>(),
      queenBreedRepository: getIt<QueenBreedRepository>(),
      historyLogRepository: getIt<HistoryLogRepository>(),
    ));
  }

  //Root BlocProviders
  static List<BlocProvider> get blocProviders => [
    BlocProvider(
      create: (context) => AuthBloc(
        authRepository: getIt<AuthRepository>(),
      )..add(CheckAuthStatus()),
    ),
    BlocProvider(
      create: (context) => PreferencesBloc(
        userService: getIt<UserService>(),
      )..add(LoadPreferences()),
    ),
  ];

}
