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
  late BookIsarDataSourceImpl dataSource;

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
    dataSource = BookIsarDataSourceImpl(isar: isar);
  });

  tearDown(() async {
    resetMocktailState();

    await isar.writeTxn(() async {
      await isar.localBookIsarModels.clear();
    });
  });

  test('should return Ok if operation succeeds when upserting a book', () async {
    final Result<int, String> result =
        await dataSource.upsertBook(const LocalBookIsarModel(id: null, title: 'rmol4j3', url: 'xdtzk7YW'));

    expect(result, const Ok(1));
  });

  test('should return Ok with empty list if there are no books when getting all books', () async {
    final Result<List<LocalBookIsarModel>, String> result = await dataSource.getAllBooks();

    expect(
      result,
      isA<Ok<List<LocalBookIsarModel>, String>>().having((ok) => ok.ok, 'ok', <LocalBookIsarModel>[]),
    );
  });

  test('should return Ok with expected books when getting all books', () async {
    await dataSource.upsertBook(
      const LocalBookIsarModel(id: null, title: 'Xm7Lnk43IAz', url: 'eefd65d5-ff77-4aa0-8ab6-24fa5a4b17a6'),
    );
    await dataSource.upsertBook(
      const LocalBookIsarModel(id: null, title: 'NCTHaP0r9', url: '4df9abd6-47d8-45fe-b38b-5308c9b74ac0'),
    );
    await dataSource.upsertBook(
      const LocalBookIsarModel(id: null, title: 'hjCXwiXRyW', url: 'e47d18a0-c4e0-4647-b423-edfc4738c5db'),
    );

    final Result<List<LocalBookIsarModel>, String> result = await dataSource.getAllBooks();

    expect(
      result,
      isA<Ok<List<LocalBookIsarModel>, String>>().having((ok) => ok.ok, 'ok', [
        isA<LocalBookIsarModel>()
            .having((m) => m.id, 'id', isA<int>())
            .having((m) => m.title, 'title', 'Xm7Lnk43IAz')
            .having((m) => m.url, 'url', 'eefd65d5-ff77-4aa0-8ab6-24fa5a4b17a6'),
        isA<LocalBookIsarModel>()
            .having((m) => m.id, 'id', isA<int>())
            .having((m) => m.title, 'title', 'NCTHaP0r9')
            .having((m) => m.url, 'url', '4df9abd6-47d8-45fe-b38b-5308c9b74ac0'),
        isA<LocalBookIsarModel>()
            .having((m) => m.id, 'id', isA<int>())
            .having((m) => m.title, 'title', 'hjCXwiXRyW')
            .having((m) => m.url, 'url', 'e47d18a0-c4e0-4647-b423-edfc4738c5db'),
      ]),
    );
  });

  test('should return Ok with expected books when watching all books', () async {
    await dataSource
        .upsertBook(const LocalBookIsarModel(id: null, title: '70lzhSe', url: 'eefd65d5-ff77-4aa0-8ab6-24fa5a4b17a6'));
    await dataSource.upsertBook(
      const LocalBookIsarModel(id: null, title: '025n4uknmu', url: '4df9abd6-47d8-45fe-b38b-5308c9b74ac0'),
    );
    await dataSource.upsertBook(
      const LocalBookIsarModel(id: null, title: 'Ru7ePJChaVZ', url: 'e47d18a0-c4e0-4647-b423-edfc4738c5db'),
    );

    final Result<Stream<Unit>, String> result = dataSource.watchLazyAllBooks();

    expect(result.isOk(), true, reason: result.unwrap().toString());

    unawaited(expectLater(result.unwrap(), emitsInOrder([(), (), ()])));

    await dataSource
        .upsertBook(const LocalBookIsarModel(id: null, title: 'dBsm3QG', url: 'eefd65d5-ff77-4aa0-8ab6-24fa5a4b17a6'));
    await dataSource
        .upsertBook(const LocalBookIsarModel(id: null, title: 'R4Ox2V4', url: '4df9abd6-47d8-45fe-b38b-5308c9b74ac0'));
    await dataSource.upsertBook(
      const LocalBookIsarModel(id: null, title: 'RrbijyYfsA', url: 'e47d18a0-c4e0-4647-b423-edfc4738c5db'),
    );
  });
}
