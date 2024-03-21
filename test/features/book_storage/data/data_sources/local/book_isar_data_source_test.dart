import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/src/result/result.dart';
import 'package:rust_core/typedefs.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/models/local_book_isar_model.dart';

void main() {
  const String isarDbDirectoryPath = 'test/features/new_book/data/data_sources/local/isar_db';
  late Isar isar;
  late BookIsarDataSource dataSource;

  setUpAll(() async {
    final Directory isarDbDirectory = await Directory(isarDbDirectoryPath).create(recursive: true);

    await Isar.initializeIsarCore(download: true);

    isar = await Isar.open(
      [LocalBookIsarModelSchema],
      directory: isarDbDirectory.path,
    );

    await isar.writeTxn(() async {
      await isar.localBookIsarModels.clear();
    });
  });

  tearDownAll(() async {
    await Directory(isarDbDirectoryPath).delete(recursive: true);
    await isar.close(deleteFromDisk: true);
  });

  setUp(() {
    dataSource = BookIsarDataSource(isar: isar);
  });

  tearDown(() async {
    resetMocktailState();

    await isar.writeTxn(() async {
      await isar.localBookIsarModels.clear();
    });
  });

  test('should return Ok if operation succeeds when upserting a book', () async {
    final Result<int, String> result = await dataSource.upsertBook(
      LocalBookIsarModel(id: null, path: 'bRQWjCWzrRT', author: 'UVENh9EvC4', title: 'OCXxyvEX', url: 'xdtzk7YW'),
    );

    expect(result, const Ok(1));
  });

  test('should return Ok with empty list if there are no books when getting all books', () async {
    final Result<List<LocalBookIsarModel>, String> result = await dataSource.getAllBooks();

    expect(result.isOk(), true, reason: result.toString());
    expect(result.unwrap(), <LocalBookIsarModel>[]);
  });

  test('should return Ok with expected books when getting all books', () async {
    final LocalBookIsarModel model1 = LocalBookIsarModel(
      id: null,
      path: '8Qe35H3K',
      url: 'eefd65d5-ff77-4aa0-8ab6-24fa5a4b17a6',
      title: 'a0z4pSSbY1J',
      author: 'GcYmg4ft',
    );
    final LocalBookIsarModel model2 = LocalBookIsarModel(
      id: null,
      path: null,
      url: null,
      title: null,
      author: null,
    );
    final LocalBookIsarModel model3 = LocalBookIsarModel(
      id: null,
      url: 'e47d18a0-c4e0-4647-b423-edfc4738c5db',
      path: '1GXSrZaf9X',
      title: 'Nisllobortis',
      author: null,
    );
    final List<LocalBookIsarModel> expected = [
      LocalBookIsarModel(
        id: 1,
        path: model1.path,
        url: model1.url,
        title: model1.title,
        author: model1.author,
      ),
      LocalBookIsarModel(
        id: 2,
        path: model2.path,
        url: model2.url,
        title: model2.title,
        author: model2.author,
      ),
      LocalBookIsarModel(
        id: 3,
        path: model3.path,
        url: model3.url,
        title: model3.title,
        author: model3.author,
      ),
    ];

    await dataSource.upsertBook(model1);
    await dataSource.upsertBook(model2);
    await dataSource.upsertBook(model3);

    final Result<List<LocalBookIsarModel>, String> result = await dataSource.getAllBooks();

    expect(result.isOk(), true, reason: result.toString());
    expect(result.unwrap(), expected);
  });

  test('should return Ok with expected books when watching all books', () async {
    final LocalBookIsarModel model1 = LocalBookIsarModel(
      id: null,
      path: '8Qe35H3K',
      url: 'eefd65d5-ff77-4aa0-8ab6-24fa5a4b17a6',
      title: 'a0z4pSSbY1J',
      author: 'GcYmg4ft',
    );
    final LocalBookIsarModel model2 = LocalBookIsarModel(
      id: null,
      path: null,
      url: null,
      title: null,
      author: null,
    );
    final LocalBookIsarModel model3 = LocalBookIsarModel(
      id: null,
      url: 'e47d18a0-c4e0-4647-b423-edfc4738c5db',
      path: '1GXSrZaf9X',
      title: 'Nisllobortis',
      author: null,
    );

    final LocalBookIsarModel model4 = LocalBookIsarModel(
      id: null,
      url: '0zyhi8vmS',
      path: 'PRsqJciAdu',
      title: null,
      author: null,
    );

    await dataSource.upsertBook(model1);
    await dataSource.upsertBook(model2);
    await dataSource.upsertBook(model3);

    final Result<Stream<Unit>, String> result = dataSource.watchLazyAllBooks();

    expect(result.isOk(), true, reason: result.unwrap().toString());

    unawaited(expectLater(result.unwrap(), emitsInOrder([(), (), ()])));

    await dataSource.upsertBook(model4);
    await dataSource.upsertBook(model4);
    await dataSource.upsertBook(model4);
  });

  test('should return Ok with expected book when fetching book by id', () async {
    final LocalBookIsarModel model1 = LocalBookIsarModel(
      id: null,
      path: '8Qe35H3K',
      url: 'eefd65d5-ff77-4aa0-8ab6-24fa5a4b17a6',
      title: 'a0z4pSSbY1J',
      author: 'GcYmg4ft',
    );
    final LocalBookIsarModel model2 = LocalBookIsarModel(
      id: null,
      path: null,
      url: null,
      title: null,
      author: null,
    );

    await dataSource.upsertBook(model1);
    await dataSource.upsertBook(model2);

    final Result<LocalBookIsarModel?, String> result1 = await dataSource.getBookById(1);

    expect(result1.isOk(), true, reason: result1.unwrap().toString());
    expect(
      result1.unwrap(),
      LocalBookIsarModel(
        id: 1,
        path: model1.path,
        url: model1.url,
        title: model1.title,
        author: model1.author,
      ),
    );

    final Result<LocalBookIsarModel?, String> result2 = await dataSource.getBookById(2);

    expect(result2.isOk(), true, reason: result1.unwrap().toString());
    expect(
      result2.unwrap(),
      LocalBookIsarModel(
        id: 2,
        path: model2.path,
        url: model2.url,
        title: model2.title,
        author: model2.author,
      ),
    );
  });

  test('should return null when fetching unknown book by id', () async {
    final LocalBookIsarModel model1 = LocalBookIsarModel(
      id: null,
      path: '8Qe35H3K',
      url: 'eefd65d5-ff77-4aa0-8ab6-24fa5a4b17a6',
      title: 'a0z4pSSbY1J',
      author: 'GcYmg4ft',
    );
    final LocalBookIsarModel model2 = LocalBookIsarModel(
      id: null,
      path: null,
      url: null,
      title: null,
      author: null,
    );

    await dataSource.upsertBook(model1);
    await dataSource.upsertBook(model2);

    final Result<LocalBookIsarModel?, String> result = await dataSource.getBookById(3);

    expect(result.isOk(), true, reason: result.unwrap().toString());
    expect(result.unwrap(), null);
  });
}
