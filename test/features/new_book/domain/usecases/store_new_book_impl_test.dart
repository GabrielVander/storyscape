import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:rust_core/typedefs.dart';
import 'package:storyscape/features/new_book/domain/entities/new_book.dart';
import 'package:storyscape/features/new_book/domain/repositories/book_repository.dart';
import 'package:storyscape/features/new_book/domain/usecases/store_new_book.dart';

void main() {
  late BookRepository bookRepository;
  late StoreNewBook useCase;

  setUp(() {
    bookRepository = _MockBookRepository();

    useCase = StoreNewBookImpl(bookRepository: bookRepository);

    registerFallbackValue(_MockNewBook());
  });

  test('should return Err if unable to save new book', () async {
    final NewBook newBook = _MockNewBook();

    when(() => bookRepository.storeNewBook(any())).thenAnswer((_) async => const Err('r06y2gUcW3'));

    final Result<Unit, String> result = await useCase.execute(newBook);

    expect(result, const Err<dynamic, String>('r06y2gUcW3'));
    verify(() => bookRepository.storeNewBook(newBook)).called(1);
  });

  test('should return Ok if operation succeeds', () async {
    final NewBook newBook = _MockNewBook();

    when(() => bookRepository.storeNewBook(any())).thenAnswer((_) async => const Ok(()));

    final Result<Unit, String> result = await useCase.execute(newBook);

    expect(result, const Ok(()));
    verify(() => bookRepository.storeNewBook(newBook)).called(1);
  });
}

class _MockBookRepository extends Mock implements BookRepository {}

class _MockNewBook extends Mock implements NewBook {}
