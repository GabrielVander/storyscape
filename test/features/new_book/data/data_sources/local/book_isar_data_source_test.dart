import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/src/result/result.dart';
import 'package:storyscape/features/new_book/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/new_book/data/data_sources/local/models/local_book_isar_model.dart';

void main() {
  late Isar isar;
  late BookIsarDataSourceImpl dataSource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [LocalBookIsarModelSchema],
      directory: 'test/features/new_book/data/data_sources/local/isar_db',
    );

    await isar.writeTxn(() async {
      await isar.localBookIsarModels.clear();
    });
  });

  tearDownAll(() {
    isar.close(deleteFromDisk: true);
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
    final Result<int, String> result = await dataSource.upsertBook(const LocalBookIsarModel(id: null, url: 'xdtzk7YW'));

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
    await dataSource.upsertBook(const LocalBookIsarModel(id: null, url: 'eefd65d5-ff77-4aa0-8ab6-24fa5a4b17a6'));
    await dataSource.upsertBook(const LocalBookIsarModel(id: null, url: '4df9abd6-47d8-45fe-b38b-5308c9b74ac0'));
    await dataSource.upsertBook(const LocalBookIsarModel(id: null, url: 'e47d18a0-c4e0-4647-b423-edfc4738c5db'));

    final Result<List<LocalBookIsarModel>, String> result = await dataSource.getAllBooks();

    expect(
      result,
      isA<Ok<List<LocalBookIsarModel>, String>>().having((ok) => ok.ok, 'ok', [
        isA<LocalBookIsarModel>()
            .having((m) => m.id, 'id', isA<int>())
            .having((m) => m.url, 'url', 'eefd65d5-ff77-4aa0-8ab6-24fa5a4b17a6'),
        isA<LocalBookIsarModel>()
            .having((m) => m.id, 'id', isA<int>())
            .having((m) => m.url, 'url', '4df9abd6-47d8-45fe-b38b-5308c9b74ac0'),
        isA<LocalBookIsarModel>()
            .having((m) => m.id, 'id', isA<int>())
            .having((m) => m.url, 'url', 'e47d18a0-c4e0-4647-b423-edfc4738c5db'),
      ]),
    );
  });
}
