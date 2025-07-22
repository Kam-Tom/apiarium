import 'package:apiarium/features/auth/bloc/auth_bloc.dart';
import 'package:apiarium/features/settings/bloc/preferences_bloc.dart';
import 'package:apiarium/shared/repositories/transaction_repository.dart';
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

    getIt.registerSingleton<SettingsRepository>(settingsRepository);    // Initialize needed services
    await getIt<UserRepository>().initialize();
    
    // Repositories - register and initialize them
    getIt.registerLazySingleton(() => QueenRepository());
    getIt.registerLazySingleton(() => QueenBreedRepository());
    getIt.registerLazySingleton(() => ApiaryRepository());
    getIt.registerLazySingleton(() => HiveRepository());
    getIt.registerLazySingleton(() => HiveTypeRepository());
    getIt.registerLazySingleton(() => StorageRepository());
    getIt.registerLazySingleton(() => TransactionRepository());
    getIt.registerLazySingleton(() => HistoryLogRepository());
    
    // Initialize all repositories (this opens the Hive boxes)
    await getIt<QueenRepository>().initialize();
    await getIt<QueenBreedRepository>().initialize();
    await getIt<ApiaryRepository>().initialize();
    await getIt<HiveRepository>().initialize();
    await getIt<HiveTypeRepository>().initialize();
    await getIt<StorageRepository>().initialize();
    await getIt<TransactionRepository>().initialize();
    await getIt<HistoryLogRepository>().initialize();
    // getIt.registerLazySingleton(() => ReportRepository());
    
    // Services - register and initialize them
    getIt.registerLazySingleton(() => NameGeneratorService(getIt<SettingsRepository>()));
    getIt<NameGeneratorService>().initialize();
  //   getIt.registerLazySingleton(() => SyncService());
  //   getIt.registerLazySingleton(() => TtsService());
  //   getIt.registerLazySingleton(() => VoskService());
    
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
    getIt.registerLazySingleton(() => HistoryService(
      repository: getIt<HistoryLogRepository>(),
      userRepository: getIt<UserRepository>(),
    ));
    
    getIt.registerLazySingleton(() => ApiaryService(
      apiaryRepository: getIt<ApiaryRepository>(),
      hiveRepository: getIt<HiveRepository>(),
      queenRepository: getIt<QueenRepository>(),
      userRepository: getIt<UserRepository>(), 
      historyService: getIt<HistoryService>(),
    ));

    getIt.registerLazySingleton(() => HiveService(
      hiveRepository: getIt<HiveRepository>(),
      userRepository: getIt<UserRepository>(), 
      hiveTypeRepository: getIt<HiveTypeRepository>(), 
      apiaryRepository: getIt<ApiaryRepository>(), 
      queenRepository: getIt<QueenRepository>(),
      historyService: getIt<HistoryService>(),
    ));

    getIt.registerLazySingleton(() => QueenService(
      queenRepository: getIt<QueenRepository>(),
      breedRepository: getIt<QueenBreedRepository>(),
      hiveRepository: getIt<HiveRepository>(),
      userRepository: getIt<UserRepository>(),
      historyService: getIt<HistoryService>(),
    ));

    getIt.registerLazySingleton(() => StorageService(
      storageRepository: getIt<StorageRepository>(),
      transactionRepository: getIt<TransactionRepository>(),
      historyService: getIt<HistoryService>(),
      userRepository: getIt<UserRepository>(),
    ));
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
