import 'package:apiarium/shared/services/auth_service.dart';
import 'package:apiarium/shared/services/sync_service.dart';
import 'package:apiarium/shared/utils/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'core/core.dart';
import 'features/settings/bloc/preferences_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await DependencyInjection.init();
  
  await UIHelper.hideNavigationBarSticky();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('pl')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _hasTriggeredInitialSync = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerSync();
    }
  }

  void _triggerSync() {
    if (!_hasTriggeredInitialSync) {
      _hasTriggeredInitialSync = true;
      // On first launch, do bidirectional sync to push any local changes and pull remote data
      getIt<SyncService>().syncBidirectional().catchError((e) {
        // Error handling is managed within SyncService
      });
    } else {
      // On app resume, also do bidirectional sync
      getIt<SyncService>().syncBidirectional().catchError((e) {
        // Error handling is managed within SyncService
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: DependencyInjection.blocProviders,
      child: BlocListener<PreferencesBloc, PreferencesState>(
        listenWhen: (previous, current) => 
          previous.language != current.language || 
          previous.isFirstTime != current.isFirstTime,
        listener: (context, state) {
          if (state.language.isNotEmpty) {
            context.setLocale(Locale(state.language));
            // Trigger initial sync after language is set
            if (!_hasTriggeredInitialSync) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _triggerSync();
              });
            }
          }
        },
        child: BlocBuilder<PreferencesBloc, PreferencesState>(
          buildWhen: (previous, current) => previous.isFirstTime != current.isFirstTime,
          builder: (context, state) {
            // Handle first time setup
            if (state.isFirstTime && !state.isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final deviceLocale = View.of(context).platformDispatcher.locale.languageCode;
                final supportedLanguages = ['en', 'pl'];
                final deviceLanguage = supportedLanguages.contains(deviceLocale) ? deviceLocale : 'en';
                
                context.read<PreferencesBloc>().add(UpdateLanguage(deviceLanguage));
                context.read<PreferencesBloc>().add(MarkFirstTimeComplete());
              });
            }
            
            final appRouter = AppRouter(authService: getIt<AuthService>());
            
            return MaterialApp.router(
              title: 'Apiarium',
              theme: AppTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              routerConfig: appRouter.router,
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.noScaling,
                  ),
                  child: child!,
                );
              },
            );
          },
        ),
      ),
    );
  }
}