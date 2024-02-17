import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/new_book/domain/entities/stored_book.dart';
import 'package:storyscape/features/new_book/domain/repositories/book_repository.dart';
import 'package:storyscape/features/new_book/domain/use_cases/retrieve_stored_books.dart';

void main() {
  late BookRepository bookRepository;
  late RetrieveStoredBooksImpl useCase;

  setUp(() {
    bookRepository = _MockBookRepository();

    useCase = RetrieveStoredBooksImpl(bookRepository: bookRepository);
  });

  tearDown(resetMocktailState);

  test('should return err if book repository fails', () async {
    when(() => bookRepository.fetchAllBooks()).thenAnswer((_) async => const Err('Ro356Dyw'));

    final Result<List<StoredBook>, String> result = await useCase();

    expect(result, const Err<dynamic, String>('Ro356Dyw'));
  });

  test('should return ok if book repository returns empty list', () async {
    when(() => bookRepository.fetchAllBooks()).thenAnswer((_) async => Ok(List.empty()));

    final Result<List<StoredBook>, String> result = await useCase();

    expect(result, isA<Ok<List<StoredBook>, String>>().having((r) => r.ok, 'ok', <StoredBook>[]));
  });

  test("should return ok with book repository's entities", () async {
    final List<StoredBook> expected = List.generate(3, (_) => _MockStoredBook());

    when(() => bookRepository.fetchAllBooks()).thenAnswer((_) async => Ok(expected));

    final Result<List<StoredBook>, String> result = await useCase();

    expect(result, isA<Ok<List<StoredBook>, String>>().having((r) => r.ok, 'ok', expected));
  });
}

class _MockBookRepository extends Mock implements BookRepository {}

class _MockStoredBook extends Mock implements StoredBook {}
