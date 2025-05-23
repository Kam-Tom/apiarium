import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI to completely hide all bars
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.leanBack,
  );

  runApp(const TmpApp());
}

class TmpApp extends StatelessWidget {
  const TmpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(1.0)
      ),
      child: MaterialApp(
        title: 'Lean Back Test',
        home: const TestPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Lean Back Navigation Test',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Test button
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Button pressed!')),
                  );
                },
                child: const Text('Test Button'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'core/core.dart';
// import 'features/auth/auth.dart';
// import 'features/home/settings/bloc/preferences_bloc.dart';
// import 'shared/shared.dart';
// import 'shared/utils/shared_prefs_helper.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await EasyLocalization.ensureInitialized();
//   await SharedPrefsHelper.init();

//   await Supabase.initialize(
//     url: EnvDev.supabaseUrl,
//     anonKey: EnvDev.supabaseAnonKey,
//   );

//   runApp(
//     EasyLocalization(
//       supportedLocales: [Locale('en'), Locale('pl')],
//       path: 'assets/translations',
//       fallbackLocale: Locale('en'),
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Create repositories
//     final queenRepository = QueenRepository();
//     final queenBreedRepository = QueenBreedRepository();
//     final authRepository = AuthRepository();
//     final apiaryRepository = ApiaryRepository();
//     final hiveRepository = HiveRepository();
//     final hiveTypeRepository = HiveTypeRepository();
//     final reportRepository = ReportRepository();
//     final historyLogRepository = HistoryLogRepository();
    
//     return MultiRepositoryProvider(
//       providers: [
//         // Services
//         RepositoryProvider(create: (context) => UserService()),
//         RepositoryProvider(create: (context) => SyncService()),
//         RepositoryProvider(create: (context) => NameGeneratorService(
//           context.read<UserService>(),
//         )),

//         // Voice services
//         RepositoryProvider(create: (context) => TtsService()),
//         RepositoryProvider(create: (context) => VoskService()),
//         RepositoryProvider(
//           create: (context) => VcService(
//             ttsService: context.read<TtsService>(),
//             voskService: context.read<VoskService>(),
//             userService: context.read<UserService>(),
//           )
//         ),
        
//         RepositoryProvider(
//           create: (context) => ReportService(
//             reportRepository: reportRepository,
//             historyLogRepository: historyLogRepository,
//             syncService: context.read<SyncService>(),
//           )
//         ),
        
//         RepositoryProvider(
//           create: (context) => ApiaryService(
//             apiaryRepository: apiaryRepository,
//             historyLogRepository: historyLogRepository,
//           )
//         ),

//         RepositoryProvider(
//           create: (context) => HiveService(
//             hiveRepository: hiveRepository,
//             hiveTypeRepository: hiveTypeRepository,
//             historyLogRepository: historyLogRepository,
//           )
//         ),

//         RepositoryProvider(
//           create: (context) => QueenService(
//             queenRepository: queenRepository,
//             queenBreedRepository: queenBreedRepository,
//             historyLogRepository: historyLogRepository,
//           )
//         ),
//       ],
//       child: MultiBlocProvider(
//         providers: [
//           BlocProvider(
//             create: (context) => AuthBloc(
//               authRepository: authRepository,
//             )..add(CheckAuthStatus()),
//           ),
//           BlocProvider(
//             create: (context) => PreferencesBloc(
//               userService: context.read<UserService>(),
//             )..add(LoadPreferences()),
//           ),
//         ],
//         child: BlocListener<PreferencesBloc, PreferencesState>(
//           listenWhen: (previous, current) => previous.language != current.language,
//           listener: (context, state) {
//             if (state.language.isNotEmpty) {
//               context.setLocale(Locale(state.language));
//             }
//           },
//           child: Builder(
//             builder: (context) {
//               final authBloc = context.read<AuthBloc>();
//               final appRouter = AppRouter(authBloc: authBloc);
              
//               return MediaQuery(
//                 data: MediaQuery.of(context).copyWith(
//                   textScaler : TextScaler.linear(1.0)
//                 ),
//                 child: MaterialApp.router(
//                   title: 'Apiarium',
//                   theme: AppTheme.lightTheme,
//                   debugShowCheckedModeBanner: false,
//                   localizationsDelegates: context.localizationDelegates,
//                   supportedLocales: context.supportedLocales,
//                   locale: context.locale,
//                   routerConfig: appRouter.router,
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
