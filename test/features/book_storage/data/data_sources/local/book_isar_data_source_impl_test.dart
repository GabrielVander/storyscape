import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/src/result/result.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/models/local_book_isar_model.dart';

void main() {
  late Isar isar;
  late BookIsarDataSourceImpl dataSource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [LocalBookIsarModelSchema],
      directory: 'test/features/book_storage/data/data_sources/local/isar_db',
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
}
