import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/select_book/domain/entities/available_book.dart';
import 'package:storyscape/features/select_book/domain/repositories/available_book_repository.dart';
import 'package:storyscape/features/select_book/domain/usecases/retrieve_available_books.dart';

void main() {
  late AvailableBookRepository availableBookRepository;
  late RetrieveStoredBooksImpl useCase;

  setUp(() {
    availableBookRepository = _MockAvailableBookRepository();

    useCase = RetrieveStoredBooksImpl(availableBookRepository: availableBookRepository);
  });

  tearDown(resetMocktailState);

  test('should return err if book repository fails', () async {
    when(() => availableBookRepository.fetchAllAvailableBooks()).thenAnswer((_) async => const Err('Ro356Dyw'));

    final Result<List<AvailableBook>, String> result = await useCase();

    expect(result, const Err<dynamic, String>('Ro356Dyw'));
  });

  test('should return ok if book repository returns empty list', () async {
    when(() => availableBookRepository.fetchAllAvailableBooks()).thenAnswer((_) async => Ok(List.empty()));

    final Result<List<AvailableBook>, String> result = await useCase();

    expect(result, isA<Ok<List<AvailableBook>, String>>().having((r) => r.ok, 'ok', <AvailableBook>[]));
  });

  test("should return ok with book repository's entities", () async {
    final List<AvailableBook> expected = List.generate(3, (_) => _MockStoredBook());

    when(() => availableBookRepository.fetchAllAvailableBooks()).thenAnswer((_) async => Ok(expected));

    final Result<List<AvailableBook>, String> result = await useCase();

    expect(result, isA<Ok<List<AvailableBook>, String>>().having((r) => r.ok, 'ok', expected));
  });
}

class _MockAvailableBookRepository extends Mock implements AvailableBookRepository {}

class _MockStoredBook extends Mock implements AvailableBook {}
