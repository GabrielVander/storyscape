import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:rust_core/src/typedefs/unit.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/models/local_book_isar_model.dart';
import 'package:storyscape/features/new_book/data/repositories/existing_book_repository_impl.dart';
import 'package:storyscape/features/new_book/domain/entities/existing_book.dart';
import 'package:storyscape/features/new_book/domain/entities/new_book.dart';

void main() {
  late BookIsarDataSource isarDataSource;
  late LocalBookIsarModelMapper localBookIsarModelMapper;
  late ExistingBookRepositoryImpl repository;

  setUp(() {
    isarDataSource = _MockBookIsarDataSource();
    localBookIsarModelMapper = _MockLocalBookIsarModelMapper();

    repository =
        ExistingBookRepositoryImpl(isarDataSource: isarDataSource, localBookIsarModelMapper: localBookIsarModelMapper);
    registerFallbackValue(_MockLocalBookIsarModel());
    registerFallbackValue(_MockNewBook());
  });

  tearDown(resetMocktailState);

  test('should return Err if unable to map new book to local Isar book when saving new book', () async {
    when(() => localBookIsarModelMapper.fromNewBook(any())).thenReturn(const Err('plVDTJEUQ'));

    final NewBook newBook =
        NewBook(data: Uint8List.fromList(List.of([1, 0, 1, 0, 0, 1])), url: '164ae471-41f0-4453-a2ce-cf5576c19172');
    final Result<Unit, String> result = await repository.storeDownloadedBook(newBook);

    expect(result, const Err<dynamic, String>('Unable to store new book'));
    verify(() => localBookIsarModelMapper.fromNewBook(newBook)).called(1);
  });

  test('should return Err if isar data source fails when saving new book', () async {
    final LocalBookIsarModel localBookIsarModel = _MockLocalBookIsarModel();

    when(() => localBookIsarModelMapper.fromNewBook(any())).thenReturn(Ok(localBookIsarModel));
    when(() => isarDataSource.upsertBook(any())).thenAnswer((_) async => const Err('FSQXowQV'));

    final Result<Unit, String> result = await repository.storeDownloadedBook(
        NewBook(data: Uint8List.fromList(List.empty()), url: '164ae471-41f0-4453-a2ce-cf5576c19172'));

    expect(result, const Err<dynamic, String>('Unable to store new book'));
    verify(() => isarDataSource.upsertBook(localBookIsarModel)).called(1);
  });

  test('should return Ok with existing book if operation succeeds when saving new book', () async {
    final LocalBookIsarModel localBookIsarModel = _MockLocalBookIsarModel();
    const String url = '164ae471-41f0-4453-a2ce-cf5576c19172';
    final NewBook newBook = NewBook(data: Uint8List.fromList(List.empty()), url: url);
    const int id = 783;

    when(() => localBookIsarModelMapper.fromNewBook(any())).thenReturn(Ok(localBookIsarModel));
    when(() => isarDataSource.upsertBook(any())).thenAnswer((_) async => const Ok(id));

    final Result<Unit, String> result = await repository.storeDownloadedBook(newBook);

    expect(result, const Ok(()));
    verify(() => localBookIsarModelMapper.fromNewBook(newBook)).called(1);
    verify(() => isarDataSource.upsertBook(localBookIsarModel)).called(1);
  });

  test('should return Err if isar data source fails when retrieving book by id', () async {
    when(() => isarDataSource.getBookById(any())).thenAnswer((_) async => const Err('7M6iCi6n'));

    final Result<ExistingBook, String> result = await repository.retrieveBookById(830);

    expect(result, const Err<dynamic, String>('Unable to retrieve book'));
    verify(() => isarDataSource.getBookById(830)).called(1);
  });

  test('should return Err if unable to map local Isar book to existing book when retrieving book by id', () async {
    final LocalBookIsarModel localBookModel = _MockLocalBookIsarModel();

    when(() => isarDataSource.getBookById(any())).thenAnswer((_) async => Ok(localBookModel));
    when(() => localBookIsarModelMapper.toExistingBook(any())).thenReturn(const Err('K1sRlujJo'));

    final Result<ExistingBook, String> result = await repository.retrieveBookById(430);

    expect(result, const Err<dynamic, String>('Unable to retrieve book'));
    verify(() => localBookIsarModelMapper.toExistingBook(localBookModel)).called(1);
  });

  test('should return Ok existing book when retrieving book by id', () async {
    final ExistingBook book = _MockExistingBook();

    when(() => isarDataSource.getBookById(any())).thenAnswer((_) async => Ok(_MockLocalBookIsarModel()));
    when(() => localBookIsarModelMapper.toExistingBook(any())).thenReturn(Ok(book));

    final Result<ExistingBook, String> result = await repository.retrieveBookById(880);

    expect(result, Ok(book));
  });
}

class _MockBookIsarDataSource extends Mock implements BookIsarDataSource {}

class _MockLocalBookIsarModel extends Mock implements LocalBookIsarModel {}

class _MockLocalBookIsarModelMapper extends Mock implements LocalBookIsarModelMapper {}

class _MockNewBook extends Mock implements NewBook {}

class _MockExistingBook extends Mock implements ExistingBook {}
