import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/core.dart';
import 'core/di/dependency_injection.dart';
import 'features/auth/auth.dart';
import 'features/home/settings/bloc/preferences_bloc.dart';
import 'shared/shared.dart';
import 'shared/utils/shared_prefs_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await SharedPrefsHelper.init();

  // Initialize dependencies
  await DependencyInjection.init();

  // Configure system UI
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
        listenWhen: (previous, current) => previous.language != current.language,
        listener: (context, state) {
          if (state.language.isNotEmpty) {
            context.setLocale(Locale(state.language));
          }
        },
        child: Builder(
          builder: (context) {
            final authBloc = context.read<AuthBloc>();
            final appRouter = AppRouter(authBloc: authBloc);
            
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0)
              ),
              child: MaterialApp.router(
                title: 'Apiarium',
                theme: AppTheme.lightTheme,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                routerConfig: appRouter.router,
              ),
            );
          },
        ),
      ),
    );
  }
}
