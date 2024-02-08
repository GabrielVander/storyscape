import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/src/result/result.dart';
import 'package:storyscape/features/book_selection/data/repositories/stored_book_repository_impl.dart';
import 'package:storyscape/features/book_selection/domain/entities/stored_book.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/models/local_book_isar_model.dart';

void main() {
  late BookIsarDataSource bookIsarDataSource;
  late StoredBookRepositoryImpl repository;

  setUp(() {
    bookIsarDataSource = _MockBookIsarDataSource();
    repository = StoredBookRepositoryImpl(bookIsarDataSource: bookIsarDataSource);
  });

  tearDown(resetMocktailState);

  test('should return Err if book Isar data source fails when fetching all books', () async {
    when(() => bookIsarDataSource.getAllBooks()).thenAnswer((_) async => const Err('C10qegAc'));

    final Result<List<StoredBook>, String> result = await repository.fetchAllBooks();

    expect(result, const Err<dynamic, String>('Unable to fetch books'));
  });

  test('should return Ok with empty list if no books are returned from book Isar data source when fetching all books',
      () async {
    when(() => bookIsarDataSource.getAllBooks()).thenAnswer((_) async => const Ok([]));

    final Result<List<StoredBook>, String> result = await repository.fetchAllBooks();

    expect(result, isA<Ok<List<StoredBook>, String>>().having((r) => r.ok, 'ok', <StoredBook>[]));
  });

  test('should return Ok with expected books when fetching all books', () async {
    when(() => bookIsarDataSource.getAllBooks()).thenAnswer(
      (_) async => const Ok([
        LocalBookIsarModel(id: 238, url: 'f71fcfe7-a09f-4775-9efb-d62a00b7323d'),
        LocalBookIsarModel(id: 8, url: '98d04a24-5672-4eaa-89a9-5850d1a8370e'),
        LocalBookIsarModel(id: 224, url: 'bae3a379-cf80-41d7-b4ad-b892acf00a1b'),
      ]),
    );

    final Result<List<StoredBook>, String> result = await repository.fetchAllBooks();

    expect(
      result,
      isA<Ok<List<StoredBook>, String>>().having((r) => r.ok, 'ok', <StoredBook>[
        StoredBook(url: 'f71fcfe7-a09f-4775-9efb-d62a00b7323d'),
        StoredBook(url: '98d04a24-5672-4eaa-89a9-5850d1a8370e'),
        StoredBook(url: 'bae3a379-cf80-41d7-b4ad-b892acf00a1b'),
      ]),
    );
  });
}

class _MockBookIsarDataSource extends Mock implements BookIsarDataSource {}
