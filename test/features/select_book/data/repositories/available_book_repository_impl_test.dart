import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:rust_core/typedefs.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/models/local_book_isar_model.dart';
import 'package:storyscape/features/select_book/data/repositories/available_book_repository_impl.dart';
import 'package:storyscape/features/select_book/domain/entities/available_book.dart';

void main() {
  late BookIsarDataSource isarDataSource;
  late AvailableBookRepositoryImpl repository;

  setUp(() {
    isarDataSource = _MockBookIsarDataSource();

    repository = AvailableBookRepositoryImpl(isarDataSource: isarDataSource);
    registerFallbackValue(_MockLocalBookIsarModel());
  });

  tearDown(resetMocktailState);

  test('should return Err if book Isar data source fails when fetching all books', () async {
    when(() => isarDataSource.getAllBooks()).thenAnswer((_) async => const Err('C10qegAc'));

    final Result<List<AvailableBook>, String> result = await repository.fetchAllAvailableBooks();

    expect(result, const Err<dynamic, String>('Unable to fetch books'));
  });

  test('should return Ok with empty list if no books are returned from book Isar data source when fetching all books',
      () async {
    when(() => isarDataSource.getAllBooks()).thenAnswer((_) async => const Ok([]));

    final Result<List<AvailableBook>, String> result = await repository.fetchAllAvailableBooks();

    expect(result, isA<Ok<List<AvailableBook>, String>>().having((r) => r.ok, 'ok', <AvailableBook>[]));
  });

  test('should return Ok with expected books when fetching all books', () async {
    when(() => isarDataSource.getAllBooks()).thenAnswer(
      (_) async => const Ok([
        LocalBookIsarModel(id: 238, url: 'f71fcfe7-a09f-4775-9efb-d62a00b7323d'),
        LocalBookIsarModel(id: 8, url: '98d04a24-5672-4eaa-89a9-5850d1a8370e'),
        LocalBookIsarModel(id: 224, url: 'bae3a379-cf80-41d7-b4ad-b892acf00a1b'),
      ]),
    );

    final Result<List<AvailableBook>, String> result = await repository.fetchAllAvailableBooks();

    expect(
      result,
      isA<Ok<List<AvailableBook>, String>>().having((r) => r.ok, 'ok', <AvailableBook>[
        AvailableBook(id: 238, url: 'f71fcfe7-a09f-4775-9efb-d62a00b7323d'),
        AvailableBook(id: 8, url: '98d04a24-5672-4eaa-89a9-5850d1a8370e'),
        AvailableBook(id: 224, url: 'bae3a379-cf80-41d7-b4ad-b892acf00a1b'),
      ]),
    );
  });

  test('should return Err if unable to watch Isar local book collection when notifying on available books change', () {
    when(() => isarDataSource.watchLazyAllBooks()).thenReturn(const Err('BKLSA8s'));

    final Result<Stream<Unit>, String> result = repository.onAvaliableBooksChange();

    expect(result, const Err<dynamic, String>('Unable to watch book changes'));
  });

  test('should return Ok when notifying on available books change', () {
    final StreamController<Unit> streamController = StreamController<Unit>();

    when(() => isarDataSource.watchLazyAllBooks()).thenReturn(Ok(streamController.stream));

    final Result<Stream<Unit>, String> result = repository.onAvaliableBooksChange();

    expectLater(
      result.unwrap(),
      emitsInOrder([(), (), ()]),
    );

    streamController
      ..add(())
      ..add(())
      ..add(());
  });
}

class _MockBookIsarDataSource extends Mock implements BookIsarDataSource {}

class _MockLocalBookIsarModel extends Mock implements LocalBookIsarModel {}
