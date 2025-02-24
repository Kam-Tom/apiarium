import 'package:apiarium/core/bootstrap/my_app.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('pl')],
      path: 'assets/translations', 
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}