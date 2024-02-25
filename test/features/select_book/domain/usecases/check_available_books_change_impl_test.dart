import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:rust_core/typedefs.dart';
import 'package:storyscape/features/select_book/domain/repositories/available_book_repository.dart';
import 'package:storyscape/features/select_book/domain/usecases/check_available_books_change.dart';

void main() {
  late AvailableBookRepository availableBookRepository;

  late CheckAvailableBooksChangeImpl useCase;

  setUp(() {
    availableBookRepository = _MockAvailableBookRepository();

    useCase = CheckAvailableBooksChangeImpl(availableBookRepository: availableBookRepository);
  });

  test('should return Err if unable to retrieve notification stream', () {
    when(() => availableBookRepository.onAvaliableBooksChange()).thenReturn(const Err('9zAFpVt'));

    final Result<Stream<Unit>, String> result = useCase.call();

    expect(result, const Err<dynamic, String>('Unable to check for changes within available books'));
  });
}

class _MockAvailableBookRepository extends Mock implements AvailableBookRepository {}
