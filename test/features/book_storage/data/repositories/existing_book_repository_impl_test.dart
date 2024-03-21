import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/models/local_book_isar_model.dart';
import 'package:storyscape/features/book_storage/data/repositories/existing_book_repository_impl.dart';
import 'package:storyscape/features/book_storage/domain/entities/existing_book.dart';
import 'package:storyscape/features/book_storage/domain/entities/parsed_book.dart';

void main() {
  late BookIsarDataSource isarDataSource;
  late ExistingBookRepositoryImpl repository;

  setUp(() {
    isarDataSource = _MockBookIsarDataSource();

    repository = ExistingBookRepositoryImpl(isarDataSource: isarDataSource);
    registerFallbackValue(_MockLocalBookIsarModel());
  });

  tearDown(resetMocktailState);

  test('should return Err if isar data source fails when saving new book', () async {
    final ParsedBook input =
        ParsedBook(author: null, title: null, url: '164ae471-41f0-4453-a2ce-cf5576c19172', file: _FakeFile());

    when(() => isarDataSource.upsertBook(any())).thenAnswer((_) async => const Err('FSQXowQV'));

    final Result<ExistingBook, String> result = await repository.storeBook(input);

    expect(result, const Err<dynamic, String>('Unable to store new book'));
    verify(() => isarDataSource.upsertBook(any())).called(1);
  });

  test('should return Ok with existing book if operation succeeds when saving new book', () async {
    const String? author = null;
    const String? title = null;
    const String url = '164ae471-41f0-4453-a2ce-cf5576c19172';
    final File file = _FakeFile();
    const id = 783;

    final ParsedBook input = ParsedBook(author: author, title: title, url: url, file: file);
    final LocalBookIsarModel expectedModel =
        LocalBookIsarModel(id: null, url: url, path: file.path, title: title, author: author);

    when(() => isarDataSource.upsertBook(any())).thenAnswer((_) async => const Ok(id));

    final Result<ExistingBook, String> result = await repository.storeBook(input);

    expect(result, Ok(ExistingBook(id: id, file: file)));
    verify(() => isarDataSource.upsertBook(expectedModel)).called(1);
  });

  test('should return Err if isar data source fails when retrieving book by id', () async {
    const int id = 830;

    when(() => isarDataSource.getBookById(any())).thenAnswer((_) async => const Err('7M6iCi6n'));

    final Result<ExistingBook, String> result = await repository.retrieveBookById(id);

    expect(result, const Err<dynamic, String>('Unable to retrieve book by id: $id'));
    verify(() => isarDataSource.getBookById(id)).called(1);
  });

  test('should return Ok existing book when retrieving book by id', () async {
    const int id = 880;
    const String filePath = 'wNINfe70QTb';
    final LocalBookIsarModel model = LocalBookIsarModel(id: id, url: '', title: null, author: null, path: filePath);

    when(() => isarDataSource.getBookById(id)).thenAnswer((_) async => Ok(model));

    final Result<ExistingBook, String> result = await repository.retrieveBookById(id);

    expect(result.isOk(), true, reason: result.toString());
    expect(
      result.unwrap(),
      isA<ExistingBook>().having((b) => b.id, 'id', id).having((b) => b.file.path, 'file.path', filePath),
    );
  });
}

class _MockBookIsarDataSource extends Mock implements BookIsarDataSource {}

class _MockLocalBookIsarModel extends Mock implements LocalBookIsarModel {}

class _FakeFile extends Fake implements File {
  @override
  String get path => 'df99e355-a38f-4064-a4f2-eb99eee7f4d3';
}
