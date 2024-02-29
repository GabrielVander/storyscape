import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:rust_core/typedefs.dart';
import 'package:storyscape/features/new_book/domain/entities/new_book.dart';
import 'package:storyscape/features/select_book/domain/entities/available_book.dart';
import 'package:storyscape/features/select_book/domain/usecases/check_available_books_change.dart';
import 'package:storyscape/features/select_book/domain/usecases/retrieve_available_books.dart';
import 'package:storyscape/features/select_book/ui/cubit/book_selection_cubit.dart';

void main() {
  late RetrieveStoredBooks retrieveStoredBooks;
  late CheckAvailableBooksChange checkAvailableBooksChange;

  late BookSelectionCubit cubit;

  setUp(() {
    retrieveStoredBooks = _MockRetrieveStoredBooks();
    checkAvailableBooksChange = _MockCheckAvailableBooksChange();

    cubit = BookSelectionCubit(
      retrieveStoredBooksUseCase: retrieveStoredBooks,
      checkAvailableBooksChangeUseCase: checkAvailableBooksChange,
    );

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
      BookSelectionLoadingError(
        errorCode: BookSelectionErrorCode.unableToLoadStoredBooks.name,
        errorContext: 'AEMUHhSVT2Z',
      ),
    ],
    verify: (_) => verify(() => retrieveStoredBooks.call()).called(1),
  );

  blocTest<BookSelectionCubit, BookSelectionState>(
    'should emit loaded state if book retrieval operation succeeds when loading stored books',
    build: () => cubit,
    setUp: () {
      when(() => retrieveStoredBooks.call()).thenAnswer(
        (_) async => Ok([
          AvailableBook(id: 962, url: '0598b842-3781-4daa-8a4a-c9001f219ada'),
          AvailableBook(id: 753, url: 'ef0ba65d-f281-4b5e-a7cf-164171627918'),
        ]),
      );
      when(() => checkAvailableBooksChange.call()).thenReturn(const Err('T1KwTc6'));
    },
    act: (cubit) => cubit.loadStoredBooks(),
    skip: 1,
    expect: () => [
      BookSelectionBooksLoaded(
        books: [
          BookSelectionViewModel(id: 962, displayName: '0598b842-3781-4daa-8a4a-c9001f219ada'),
          BookSelectionViewModel(id: 753, displayName: 'ef0ba65d-f281-4b5e-a7cf-164171627918'),
        ],
      ),
    ],
    verify: (_) => verify(() => retrieveStoredBooks()).called(1),
  );

  blocTest<BookSelectionCubit, BookSelectionState>(
    'should emit loaded state on change when loading stored books',
    build: () => cubit,
    setUp: () {
      when(() => retrieveStoredBooks.call()).thenAnswer(
        (_) async => Ok([
          AvailableBook(id: 4, url: '0598b842-3781-4daa-8a4a-c9001f219ada'),
          AvailableBook(id: 531, url: 'ef0ba65d-f281-4b5e-a7cf-164171627918'),
        ]),
      );

      when(() => checkAvailableBooksChange.call()).thenReturn(Ok(Stream<Unit>.fromIterable([(), ()])));
    },
    act: (cubit) async => cubit.loadStoredBooks(),
    skip: 1,
    expect: () => [
      BookSelectionBooksLoaded(
        books: [
          BookSelectionViewModel(id: 4, displayName: '0598b842-3781-4daa-8a4a-c9001f219ada'),
          BookSelectionViewModel(id: 531, displayName: 'ef0ba65d-f281-4b5e-a7cf-164171627918'),
        ],
      ),
    ],
    verify: (_) {
      verify(() => retrieveStoredBooks()).called(3);
      verify(() => checkAvailableBooksChange()).called(1);
    },
  );

  blocTest<BookSelectionCubit, BookSelectionState>(
    'should emit loading state when opening book',
    build: () => cubit,
    setUp: () {
      when(() => retrieveStoredBooks.call()).thenAnswer(
        (_) async => Ok([
          AvailableBook(id: 97, url: '0598b842-3781-4daa-8a4a-c9001f219ada'),
          AvailableBook(id: 497, url: 'ef0ba65d-f281-4b5e-a7cf-164171627918'),
        ]),
      );

      when(() => checkAvailableBooksChange.call()).thenReturn(Ok(Stream<Unit>.fromIterable([(), ()])));
    },
    act: (cubit) async {
      await cubit.loadStoredBooks();
      await cubit.open(BookSelectionViewModel(id: 97, displayName: '0598b842-3781-4daa-8a4a-c9001f219ada'));
    },
    skip: 2,
    expect: () => [BookSelectionLoading(), anything, anything, anything],
  );

  blocTest<BookSelectionCubit, BookSelectionState>(
    'should emit selected state when opening book',
    build: () => cubit,
    setUp: () {
      when(() => retrieveStoredBooks.call()).thenAnswer(
        (_) async => Ok([
          AvailableBook(id: 447, url: '0598b842-3781-4daa-8a4a-c9001f219ada'),
          AvailableBook(id: 234, url: 'ef0ba65d-f281-4b5e-a7cf-164171627918'),
        ]),
      );

      when(() => checkAvailableBooksChange.call()).thenReturn(Ok(Stream<Unit>.fromIterable([(), ()])));
    },
    act: (cubit) async {
      await cubit.loadStoredBooks();
      await cubit.open(BookSelectionViewModel(id: 234, displayName: 'ef0ba65d-f281-4b5e-a7cf-164171627918'));
    },
    skip: 3,
    expect: () =>
        [const BookSelectionSelected(url: 'ef0ba65d-f281-4b5e-a7cf-164171627918'), BookSelectionInitial(), anything],
  );
}

class _MockRetrieveStoredBooks extends Mock implements RetrieveStoredBooks {}

class _MockCheckAvailableBooksChange extends Mock implements CheckAvailableBooksChange {}

class _MockNewBook extends Mock implements NewBook {}
