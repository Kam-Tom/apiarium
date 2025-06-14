import 'package:apiarium/shared/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/core.dart';
import 'core/di/dependency_injection.dart';
import 'features/home/settings/bloc/preferences_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await DependencyInjection.init();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
    return MultiBlocProvider(
      providers: DependencyInjection.blocProviders,
      child: BlocListener<PreferencesBloc, PreferencesState>(
        listenWhen: (previous, current) => 
          previous.language != current.language || 
          (previous.isFirstTime && !current.isFirstTime),
        listener: (context, state) {
          if (state.isFirstTime) {
            // Set device language on first time
            final deviceLocale = View.of(context).platformDispatcher.locale.languageCode;
            final supportedLanguages = ['en', 'pl'];
            final deviceLanguage = supportedLanguages.contains(deviceLocale) ? deviceLocale : 'en';
            
            context.read<PreferencesBloc>().add(UpdateLanguage(deviceLanguage));
            context.read<PreferencesBloc>().add(MarkFirstTimeComplete());
            context.setLocale(Locale(deviceLanguage));
          } else if (state.language.isNotEmpty) {
            context.setLocale(Locale(state.language));
          }
        },
        child: Builder(
          builder: (context) {
            final appRouter = AppRouter(authService: getIt<AuthService>());
            
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