import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/core.dart';
import 'features/auth/auth.dart';

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
        RepositoryProvider(create: (context) => AuthRepository()),
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
