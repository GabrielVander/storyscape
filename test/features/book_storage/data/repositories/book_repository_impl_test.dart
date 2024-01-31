import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/models/local_book_isar_model.dart';
import 'package:storyscape/features/book_storage/data/repositories/book_repository_impl.dart';
import 'package:storyscape/features/book_storage/domain/entities/existing_book.dart';
import 'package:storyscape/features/book_storage/domain/entities/new_book.dart';

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
    when(() => localBookIsarModelMapper.call(any())).thenReturn(const Err('plVDTJEUQ'));

    final newBook = NewBook(url: '164ae471-41f0-4453-a2ce-cf5576c19172');
    final Result<ExistingBook, String> result = await repository.storeNewBook(newBook);

    expect(result, const Err<dynamic, String>('plVDTJEUQ'));
    verify(() => localBookIsarModelMapper.call(newBook)).called(1);
  });

  test('should return Err if isar data source fails when saving new book', () async {
    final LocalBookIsarModel localBookIsarModel = _MockLocalBookIsarModel();

    when(() => localBookIsarModelMapper.call(any())).thenReturn(Ok(localBookIsarModel));
    when(() => isarDataSource.upsertBook(any())).thenAnswer((_) async => const Err('FSQXowQV'));

    final Result<ExistingBook, String> result =
        await repository.storeNewBook(NewBook(url: '164ae471-41f0-4453-a2ce-cf5576c19172'));

    expect(result, const Err<dynamic, String>('FSQXowQV'));
    verify(() => isarDataSource.upsertBook(localBookIsarModel)).called(1);
  });

  test('should return Ok with existing book if operation succeeds when saving new book', () async {
    final LocalBookIsarModel localBookIsarModel = _MockLocalBookIsarModel();
    const String url = '164ae471-41f0-4453-a2ce-cf5576c19172';
    final NewBook newBook = NewBook(url: url);
    const int id = 783;

    when(() => localBookIsarModelMapper.call(any())).thenReturn(Ok(localBookIsarModel));
    when(() => isarDataSource.upsertBook(any())).thenAnswer((_) async => const Ok(id));

    final Result<ExistingBook, String> result = await repository.storeNewBook(newBook);

    expect(result, const Ok(ExistingBook(id: id, url: url)));
    verify(() => localBookIsarModelMapper.call(newBook)).called(1);
    verify(() => isarDataSource.upsertBook(localBookIsarModel)).called(1);
  });
}

class _MockBookIsarDataSource extends Mock implements BookIsarDataSource {}

class _MockLocalBookIsarModel extends Mock implements LocalBookIsarModel {}

class _MockLocalBookIsarModelMapper extends Mock implements LocalBookIsarModelMapper {}

class _MockNewBook extends Mock implements NewBook {}
