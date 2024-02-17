import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_file/internet_file.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storyscape/features/new_book/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/new_book/data/data_sources/local/models/local_book_isar_model.dart';
import 'package:storyscape/features/new_book/data/repositories/book_repository_impl.dart';
import 'package:storyscape/features/new_book/domain/repositories/book_repository.dart';
import 'package:storyscape/features/new_book/domain/use_cases/store_new_book.dart';
import 'package:storyscape/features/read_book/ui/cubit/book_reader_cubit.dart';
import 'package:storyscape/features/select_book/domain/use_cases/retrieve_stored_books.dart';
import 'package:storyscape/features/select_book/ui/cubit/book_selection_cubit.dart';
import 'package:storyscape/storyscape.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await _setUpInjections();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('pt', 'BR')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: Storyscape(),
    ),
  );
}

Future<void> _setUpInjections() async {
  final GetIt locator = GetIt.I;

  await _setUpLibraryInjections(locator);
  _setUpBookReadingInjections(locator);
  _setUpBookStorageInjections(locator);
  _setUpBookSelectionInjections(locator);
}

Future<void> _setUpLibraryInjections(GetIt locator) async {
  final Directory dir = await getApplicationDocumentsDirectory();
  final Isar isarInstance = await Isar.open(
    [LocalBookIsarModelSchema],
    directory: dir.path,
  );

  locator.registerSingleton<Isar>(isarInstance);
}

void _setUpBookReadingInjections(GetIt locator) {
  locator.registerSingleton<BookReaderCubit>(
    BookReaderCubit(
      networkFileRetriever: (String url, void Function(double) progressUpdater) async => InternetFile.get(
        url,
        progress: (receivedLength, contentLength) => progressUpdater(receivedLength / contentLength * 100),
      ),
    ),
  );
}

void _setUpBookStorageInjections(GetIt locator) {
  locator
    ..registerSingleton<BookIsarDataSource>(
      BookIsarDataSourceImpl(
        isar: locator.get<Isar>(),
      ),
    )
    ..registerLazySingleton<LocalBookIsarModelMapper>(LocalBookIsarModelMapperImpl.new)
    ..registerLazySingleton<BookRepository>(
      () => BookRepositoryImpl(
        isarDataSource: locator.get<BookIsarDataSource>(),
        localBookIsarModelMapper: locator.get<LocalBookIsarModelMapper>(),
      ),
    )
    ..registerLazySingleton<StoreNewBook>(() => StoreNewBookImpl(bookRepository: locator.get<BookRepository>()));
}

void _setUpBookSelectionInjections(GetIt locator) {
  locator
    ..registerLazySingleton<RetrieveStoredBooks>(() => RetrieveStoredBooksImpl(bookRepository: locator.get()))
    ..registerLazySingleton<BookSelectionCubit>(
      () => BookSelectionCubit(storeNewBookUseCase: locator.get<StoreNewBook>(), retrieveStoredBooks: locator.get()),
    );
}
