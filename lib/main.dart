import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_file/internet_file.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/models/local_book_isar_model.dart';
import 'package:storyscape/features/book_storage/data/data_sources/remote/internet_file_data_source.dart';
import 'package:storyscape/features/book_storage/data/repositories/downloaded_book_repository_impl.dart';
import 'package:storyscape/features/book_storage/data/repositories/existing_book_repository_impl.dart';
import 'package:storyscape/features/book_storage/domain/repositories/downloaded_book_repository.dart';
import 'package:storyscape/features/book_storage/domain/repositories/existing_book_repository.dart';
import 'package:storyscape/features/book_storage/domain/usecases/save_book_by_url.dart';
import 'package:storyscape/features/new_book/ui/cubit/new_book_cubit.dart';
import 'package:storyscape/features/new_book/ui/widgets/new_book_modal.dart';
import 'package:storyscape/features/read_book/ui/cubit/book_reader_cubit.dart';
import 'package:storyscape/features/select_book/data/repositories/available_book_repository_impl.dart';
import 'package:storyscape/features/select_book/domain/repositories/available_book_repository.dart';
import 'package:storyscape/features/select_book/domain/usecases/check_available_books_change.dart';
import 'package:storyscape/features/select_book/domain/usecases/retrieve_available_books.dart';
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

  await _setUpAppDirectory(locator);
  await _setUpIsarInstance(locator);
  _setUpReadBookInjections(locator);
  _setUpBookStorageInjections(locator);
  _setUpNewBookInjections(locator);
  _setUpSelectBookInjections(locator);
}

Future<void> _setUpIsarInstance(GetIt locator) async {
  final Isar isarInstance = await Isar.open(
    [LocalBookIsarModelSchema],
    directory: locator.get<_StoryscapeDocumentDirectory>().value.path,
  );

  locator.registerSingleton<Isar>(isarInstance);
}

Future<void> _setUpAppDirectory(GetIt locator) async {
  final Directory documentsDir = await getApplicationDocumentsDirectory();
  final Directory storyscapeDir = await Directory('${documentsDir.path}/storyscape').create();

  locator.registerSingleton<_StoryscapeDocumentDirectory>(_StoryscapeDocumentDirectory(value: storyscapeDir));
}

void _setUpReadBookInjections(GetIt locator) {
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
    ..registerLazySingleton<InternetFileDataSource>(
      () => InternetFileDataSource(
        internetFileGet: InternetFile.get,
        targetDirectory: locator.get<_StoryscapeDocumentDirectory>().value,
      ),
    )
    ..registerLazySingleton<ExistingBookRepository>(
      () => ExistingBookRepositoryImpl(isarDataSource: locator.get<BookIsarDataSource>()),
    )
    ..registerLazySingleton<DownloadedBookRepository>(
      () => DownloadedBookRepositoryImpl(
        epubBookParser: EpubDocument.openFile,
        internetFileDataSource: locator.get<InternetFileDataSource>(),
      ),
    )
    ..registerFactory<SaveBookByUrl>(
      () => SaveBookByUrl(
        existingBookRepository: locator.get<ExistingBookRepository>(),
        downloadedBookRepository: locator.get<DownloadedBookRepository>(),
      ),
    );
}

void _setUpNewBookInjections(GetIt locator) {
  locator
    ..registerLazySingleton<NewBookCubit>(
      () => NewBookCubit(saveBookByUrlUseCase: locator.get<SaveBookByUrl>()),
    )
    ..registerFactory<NewBookModal>(() => NewBookModal(newBookCubit: locator.get()));
}

void _setUpSelectBookInjections(GetIt locator) {
  locator
    ..registerLazySingleton<AvailableBookRepository>(() => AvailableBookRepositoryImpl(isarDataSource: locator.get()))
    ..registerLazySingleton<RetrieveStoredBooks>(() => RetrieveStoredBooksImpl(availableBookRepository: locator.get()))
    ..registerLazySingleton<CheckAvailableBooksChange>(
      () => CheckAvailableBooksChangeImpl(availableBookRepository: locator.get()),
    )
    ..registerLazySingleton<BookSelectionCubit>(
      () => BookSelectionCubit(
        retrieveStoredBooksUseCase: locator.get(),
        checkAvailableBooksChangeUseCase: locator.get(),
      ),
    );
}

class _StoryscapeDocumentDirectory {
  _StoryscapeDocumentDirectory({required this.value});

  final Directory value;
}
