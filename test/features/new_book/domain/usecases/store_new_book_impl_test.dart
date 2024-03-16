import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:rust_core/typedefs.dart';
import 'package:storyscape/features/new_book/domain/entities/new_book.dart';
import 'package:storyscape/features/new_book/domain/repositories/existing_book_repository.dart';
import 'package:storyscape/features/new_book/domain/usecases/save_book_by_url.dart';

void main() {
  late ExistingBookRepository bookRepository;
  late SaveBookByUrl useCase;

  setUp(() {
    bookRepository = _MockBookRepository();

    useCase = StoreNewBookImpl(bookRepository: bookRepository);

    registerFallbackValue(_MockNewBook());
  });

  test('should return Err if unable to save new book', () async {
    final NewBook newBook = _MockNewBook();

    when(() => bookRepository.storeDownloadedBook(any())).thenAnswer((_) async => const Err('r06y2gUcW3'));

    final Result<Unit, String> result = await useCase.execute(newBook);

    expect(result, const Err<dynamic, String>('r06y2gUcW3'));
    verify(() => bookRepository.storeDownloadedBook(newBook)).called(1);
  });

  test('should return Ok if operation succeeds', () async {
    final NewBook newBook = _MockNewBook();

    when(() => bookRepository.storeDownloadedBook(any())).thenAnswer((_) async => const Ok(()));

    final Result<Unit, String> result = await useCase.execute(newBook);

    expect(result, const Ok(()));
    verify(() => bookRepository.storeDownloadedBook(newBook)).called(1);
  });
}

class _MockBookRepository extends Mock implements ExistingBookRepository {}

class _MockNewBook extends Mock implements NewBook {}
