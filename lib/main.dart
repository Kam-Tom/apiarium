import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/core.dart';

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
      child: MyApp(),
    ),
  );
}