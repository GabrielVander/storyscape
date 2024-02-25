import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/new_book/domain/entities/new_book.dart';
import 'package:storyscape/features/select_book/domain/entities/available_book.dart';
import 'package:storyscape/features/select_book/domain/usecases/retrieve_available_books.dart';
import 'package:storyscape/features/select_book/ui/cubit/book_selection_cubit.dart';

void main() {
  late RetrieveStoredBooks retrieveStoredBooks;
  late BookSelectionCubit cubit;

  setUp(() {
    retrieveStoredBooks = _MockRetrieveStoredBooks();

    cubit = BookSelectionCubit(retrieveStoredBooks: retrieveStoredBooks);

    registerFallbackValue(_MockNewBook());
  });

  tearDown(resetMocktailState);

  test('should emit initial state', () => expect(cubit.state, BookSelectionInitial()));

  blocTest<BookSelectionCubit, BookSelectionState>(
    'should emit loading state when loading stored books',
    build: () => cubit,
    setUp: () => when(() => retrieveStoredBooks()).thenAnswer((_) async => const Err('2jsXCkkYd6W')),
    act: (cubit) => cubit.loadStoredBooks(),
    expect: () => containsAllInOrder([BookSelectionLoading()]),
  );

  blocTest<BookSelectionCubit, BookSelectionState>(
    'should emit err state if book retrieval operation fails when loading stored books',
    build: () => cubit,
    setUp: () => when(() => retrieveStoredBooks.call()).thenAnswer((_) async => const Err('AEMUHhSVT2Z')),
    act: (cubit) => cubit.loadStoredBooks(),
    skip: 1,
    expect: () => [
      BookSelectionError(
        errorCode: BookSelectionErrorCode.unableToLoadStoredBooks.name,
        errorContext: 'AEMUHhSVT2Z',
      ),
    ],
    verify: (_) => verify(() => retrieveStoredBooks.call()).called(1),
  );

  blocTest<BookSelectionCubit, BookSelectionState>(
    'should emit loaded state if book retrieval operation succeeds when loading stored books',
    build: () => cubit,
    setUp: () => when(() => retrieveStoredBooks.call()).thenAnswer(
      (_) async => Ok([
        AvailableBook(url: '0598b842-3781-4daa-8a4a-c9001f219ada'),
        AvailableBook(url: 'ef0ba65d-f281-4b5e-a7cf-164171627918'),
      ]),
    ),
    act: (cubit) => cubit.loadStoredBooks(),
    skip: 1,
    expect: () => [
      BookSelectionBooksLoaded(
        books: [
          BookSelectionViewModel(displayName: '0598b842-3781-4daa-8a4a-c9001f219ada'),
          BookSelectionViewModel(displayName: 'ef0ba65d-f281-4b5e-a7cf-164171627918'),
        ],
      ),
    ],
    verify: (_) => verify(() => retrieveStoredBooks()).called(1),
  );
}

class _MockRetrieveStoredBooks extends Mock implements RetrieveStoredBooks {}

class _MockNewBook extends Mock implements NewBook {}
