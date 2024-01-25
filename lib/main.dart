import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_file/internet_file.dart';
import 'package:storyscape/features/book_reading/ui/cubit/book_reader_cubit.dart';
import 'package:storyscape/storyscape.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  _setUp();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('pt', 'BR')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: Storyscape(),
    ),
  );
}

void _setUp() {
  GetIt.I.registerSingleton<BookReaderCubit>(
    BookReaderCubit(
      networkFileRetriever: (String url, void Function(double) progressUpdater) async => InternetFile.get(
        url,
        progress: (receivedLength, contentLength) => progressUpdater(receivedLength / contentLength * 100),
      ),
    ),
  );
}
