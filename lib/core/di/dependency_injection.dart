import 'package:apiarium/features/settings/settings.dart';
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
    getIt.registerLazySingleton(() => InspectionRepository());
    
    // Initialize all repositories (this opens the Hive boxes)
    await getIt<QueenRepository>().initialize();
    await getIt<QueenBreedRepository>().initialize();
    await getIt<ApiaryRepository>().initialize();
    await getIt<HiveRepository>().initialize();
    await getIt<HiveTypeRepository>().initialize();
    await getIt<StorageRepository>().initialize();
    await getIt<TransactionRepository>().initialize();
    await getIt<HistoryLogRepository>().initialize();
    await getIt<InspectionRepository>().initialize();
    // getIt.registerLazySingleton(() => ReportRepository());
    
    // Services - register and initialize them
    getIt.registerLazySingleton(() => NameGeneratorService(getIt<SettingsRepository>()));
    getIt<NameGeneratorService>().initialize();
    
    // Note: Initial data loading is handled by PreferencesBloc when language is set
    
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

    getIt.registerLazySingleton(() => InspectionService(
      inspectionRepository: getIt<InspectionRepository>(),
      historyService: getIt<HistoryService>(),
      userRepository: getIt<UserRepository>(),
    ));

    getIt.registerLazySingleton(() => StorageService(
      storageRepository: getIt<StorageRepository>(),
      transactionRepository: getIt<TransactionRepository>(),
      historyService: getIt<HistoryService>(),
      userRepository: getIt<UserRepository>(),
    ));

    // Register SyncService with all required services
    getIt.registerLazySingleton(() => SyncService(
      queenService: getIt<QueenService>(),
      hiveService: getIt<HiveService>(),
      apiaryService: getIt<ApiaryService>(),
      historyService: getIt<HistoryService>(),
      inspectionService: getIt<InspectionService>(),
      storageService: getIt<StorageService>(),
      userRepository: getIt<UserRepository>(),
    ));

    // Register DashboardService
    getIt.registerLazySingleton<DashboardService>(
      () => DashboardService(
        apiaryRepository: getIt<ApiaryRepository>(),
        hiveRepository: getIt<HiveRepository>(),
        queenRepository: getIt<QueenRepository>(),
        inspectionRepository: getIt<InspectionRepository>(),
        historyRepository: getIt<HistoryLogRepository>(),
      ),
    );
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
