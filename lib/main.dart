import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/core.dart';
import 'features/auth/auth.dart';
import 'shared/shared.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Supabase.initialize(
    url: EnvDev.supabaseUrl,
    anonKey: EnvDev.supabaseAnonKey,
  );

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('pl')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
    providers: [
      // Existing repositories
      RepositoryProvider(create: (context) => QueenRepository()),
      RepositoryProvider(create: (context) => QueenBreedRepository()),
      RepositoryProvider(create: (context) => AuthRepository()),
      RepositoryProvider(create: (context) => ApiaryRepository()),
      RepositoryProvider(create: (context) => HiveRepository()),
      RepositoryProvider(create: (context) => HiveTypeRepository()),
      RepositoryProvider(create: (context) => ReportRepository()),
      RepositoryProvider(create: (context) => HistoryLogRepository()),
      
      // Services
      RepositoryProvider(create: (context) => UserService()),
      RepositoryProvider(create: (context) => SyncService()),
      RepositoryProvider(create: (context) => NameGeneratorService(
        context.read<UserService>(),
      )),

      // Voice services
      RepositoryProvider(create: (context) => TtsService()),
      RepositoryProvider(create: (context) => VoskService()),
      RepositoryProvider(
        create: (context) => VcService(
          ttsService: context.read<TtsService>(),
          voskService: context.read<VoskService>(),
          userService: context.read<UserService>(),
        )
      ),
      
      RepositoryProvider(
        create: (context) => ReportService(
          reportRepository: context.read<ReportRepository>(),
          historyLogRepository: context.read<HistoryLogRepository>(),
          syncService: context.read<SyncService>(),
        )
      ),
      
      RepositoryProvider(
        create: (context) => ApiaryService(
          apiaryRepository: context.read<ApiaryRepository>(),
          historyLogRepository: context.read<HistoryLogRepository>(),
        )
      ),

      RepositoryProvider(
        create: (context) => HiveService(
          hiveRepository: context.read<HiveRepository>(),
          hiveTypeRepository: context.read<HiveTypeRepository>(),
          historyLogRepository: context.read<HistoryLogRepository>(),
        )
      ),

      RepositoryProvider(
        create: (context) => QueenService(
          queenRepository: context.read<QueenRepository>(),
          queenBreedRepository: context.read<QueenBreedRepository>(),
          historyLogRepository: context.read<HistoryLogRepository>(),
        )
      ),
    ],
      child: BlocProvider(
        create: (context) => AuthBloc(
          authRepository: context.read<AuthRepository>(),
        )..add(CheckAuthStatus()),
        child: Builder(
          builder: (context) {
            final authBloc = context.read<AuthBloc>();
            final appRouter = AppRouter(authBloc: authBloc);
            
            return MaterialApp.router(
              title: 'Apiarium',
              theme: AppTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              routerConfig: appRouter.router,
            );
          },
        ),
      ),
    );
  }
}
