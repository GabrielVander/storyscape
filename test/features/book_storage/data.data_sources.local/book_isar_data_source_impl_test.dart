import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/src/result/result.dart';
import 'package:storyscape/core/library_wrappers/isar_database/isar_database_wrapper.dart';
import 'package:storyscape/features/book_storage/data.data_sources.local/book_isar_data_source.dart';
import 'package:storyscape/features/book_storage/data.data_sources.local/models/local_book_isar_model.dart';

void main() {
  late IsarDatabaseInstance isarDb;
  late BookIsarDataSourceImpl dataSource;

  setUp(() {
    isarDb = _MockIsarDatabaseInstance();
    dataSource = BookIsarDataSourceImpl(isarDatabase: isarDb);

    registerFallbackValue(_MockLocalBookIsarModel());
  });

  tearDown(resetMocktailState);

  test('should return Err if unable to retrieve Isar collection when upserting a book', () async {
    when(() => isarDb.getCollection<LocalBookIsarModel>()).thenThrow(Exception('WZ3iDO1J'));

    final Result<int, String> result = await dataSource.upsertBook(const LocalBookIsarModel(id: null, url: '7tTeH1zc'));

    expect(result, const Err<dynamic, String>('Unable to perform upsert operation'));
  });

  test('should return Err if operation fails when upserting a book', () async {
    final IsarCollection<LocalBookIsarModel> collection = _MockLocalBookIsarCollection();

    when(() => isarDb.getCollection<LocalBookIsarModel>()).thenReturn(collection);
    when(() => collection.put(any())).thenThrow(Exception('qjrKpB6RLk'));

    final Result<int, String> result = await dataSource.upsertBook(const LocalBookIsarModel(id: null, url: 'xdtzk7YW'));

    expect(result, const Err<dynamic, String>('Unable to perform upsert operation'));
  });

  test('should return Ok if operation succeeds when upserting a book', () async {
    final IsarCollection<LocalBookIsarModel> collection = _MockLocalBookIsarCollection();

    when(() => isarDb.getCollection<LocalBookIsarModel>()).thenReturn(collection);
    when(() => collection.put(any())).thenAnswer((_) async => 648);

    final Result<int, String> result = await dataSource.upsertBook(const LocalBookIsarModel(id: null, url: 'xdtzk7YW'));

    expect(result, const Ok(648));
  });
}

class _MockIsarDatabaseInstance extends Mock implements IsarDatabaseInstance {}

class _MockLocalBookIsarCollection extends Mock implements IsarCollection<LocalBookIsarModel> {}

class _MockLocalBookIsarModel extends Mock implements LocalBookIsarModel {}
