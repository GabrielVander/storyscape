import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/new_book/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/new_book/data/data_sources/local/models/local_book_isar_model.dart';
import 'package:storyscape/features/new_book/data/repositories/book_repository_impl.dart';
import 'package:storyscape/features/new_book/domain/entities/existing_book.dart';
import 'package:storyscape/features/new_book/domain/entities/new_book.dart';
import 'package:storyscape/features/new_book/domain/entities/stored_book.dart';

void main() {
  late BookIsarDataSource isarDataSource;
  late LocalBookIsarModelMapper localBookIsarModelMapper;
  late BookRepositoryImpl repository;

  setUp(() {
    isarDataSource = _MockBookIsarDataSource();
    localBookIsarModelMapper = _MockLocalBookIsarModelMapper();

    repository = BookRepositoryImpl(isarDataSource: isarDataSource, localBookIsarModelMapper: localBookIsarModelMapper);
    registerFallbackValue(_MockLocalBookIsarModel());
    registerFallbackValue(_MockNewBook());
  });

  tearDown(resetMocktailState);

  test('should return Err if unable to map new book to local Isar book when saving new book', () async {
    when(() => localBookIsarModelMapper.fromNewBook(any())).thenReturn(const Err('plVDTJEUQ'));

    const NewBook newBook = NewBook(url: '164ae471-41f0-4453-a2ce-cf5576c19172');
    final Result<ExistingBook, String> result = await repository.storeNewBook(newBook);

    expect(result, const Err<dynamic, String>('Unable to store new book'));
    verify(() => localBookIsarModelMapper.fromNewBook(newBook)).called(1);
  });

  test('should return Err if isar data source fails when saving new book', () async {
    final LocalBookIsarModel localBookIsarModel = _MockLocalBookIsarModel();

    when(() => localBookIsarModelMapper.fromNewBook(any())).thenReturn(Ok(localBookIsarModel));
    when(() => isarDataSource.upsertBook(any())).thenAnswer((_) async => const Err('FSQXowQV'));

    final Result<ExistingBook, String> result =
        await repository.storeNewBook(const NewBook(url: '164ae471-41f0-4453-a2ce-cf5576c19172'));

    expect(result, const Err<dynamic, String>('Unable to store new book'));
    verify(() => isarDataSource.upsertBook(localBookIsarModel)).called(1);
  });

  test('should return Ok with existing book if operation succeeds when saving new book', () async {
    final LocalBookIsarModel localBookIsarModel = _MockLocalBookIsarModel();
    const String url = '164ae471-41f0-4453-a2ce-cf5576c19172';
    const NewBook newBook = NewBook(url: url);
    const int id = 783;

    when(() => localBookIsarModelMapper.fromNewBook(any())).thenReturn(Ok(localBookIsarModel));
    when(() => isarDataSource.upsertBook(any())).thenAnswer((_) async => const Ok(id));

    final Result<ExistingBook, String> result = await repository.storeNewBook(newBook);

    expect(result, const Ok(ExistingBook(id: id, url: url)));
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

  test('should return Err if book Isar data source fails when fetching all books', () async {
    when(() => isarDataSource.getAllBooks()).thenAnswer((_) async => const Err('C10qegAc'));

    final Result<List<StoredBook>, String> result = await repository.fetchAllBooks();

    expect(result, const Err<dynamic, String>('Unable to fetch books'));
  });

  test('should return Ok with empty list if no books are returned from book Isar data source when fetching all books',
      () async {
    when(() => isarDataSource.getAllBooks()).thenAnswer((_) async => const Ok([]));

    final Result<List<StoredBook>, String> result = await repository.fetchAllBooks();

    expect(result, isA<Ok<List<StoredBook>, String>>().having((r) => r.ok, 'ok', <StoredBook>[]));
  });

  test('should return Ok with expected books when fetching all books', () async {
    when(() => isarDataSource.getAllBooks()).thenAnswer(
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

class _MockLocalBookIsarModel extends Mock implements LocalBookIsarModel {}

class _MockLocalBookIsarModelMapper extends Mock implements LocalBookIsarModelMapper {}

class _MockNewBook extends Mock implements NewBook {}

class _MockExistingBook extends Mock implements ExistingBook {}
