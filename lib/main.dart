import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:storyscape/storyscape.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('pt', 'BR')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: Storyscape(),
    ),
  );
}
