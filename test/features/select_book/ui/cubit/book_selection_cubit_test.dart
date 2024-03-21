import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:rust_core/typedefs.dart';
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
          AvailableBook(id: 962, author: null, title: null),
          AvailableBook(id: 753, title: 'xrd9WEwNkfk', author: 'iPDRhA4'),
        ]),
      );
      when(() => checkAvailableBooksChange.call()).thenReturn(const Err('T1KwTc6'));
    },
    act: (cubit) => cubit.loadStoredBooks(),
    skip: 1,
    expect: () => [
      BookSelectionBooksLoaded(
        books: [
          BookSelectionItemViewModel(id: 962, title: null),
          BookSelectionItemViewModel(id: 753, title: 'xrd9WEwNkfk'),
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
          AvailableBook(id: 962, author: null, title: null),
          AvailableBook(id: 753, title: 'xrd9WEwNkfk', author: 'iPDRhA4'),
        ]),
      );

      when(() => checkAvailableBooksChange.call()).thenReturn(Ok(Stream<Unit>.fromIterable([(), ()])));
    },
    act: (cubit) async => cubit.loadStoredBooks(),
    skip: 1,
    expect: () => [
      BookSelectionBooksLoaded(
        books: [
          BookSelectionItemViewModel(id: 962, title: null),
          BookSelectionItemViewModel(id: 753, title: 'xrd9WEwNkfk'),
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
          AvailableBook(id: 962, author: null, title: null),
          AvailableBook(id: 753, title: 'xrd9WEwNkfk', author: 'iPDRhA4'),
        ]),
      );

      when(() => checkAvailableBooksChange.call()).thenReturn(Ok(Stream<Unit>.fromIterable([(), ()])));
    },
    act: (cubit) async {
      await cubit.loadStoredBooks();
      await cubit.open(BookSelectionItemViewModel(id: 753, title: 'xrd9WEwNkfk'));
    },
    skip: 2,
    expect: () => [BookSelectionLoading(), anything, anything, anything],
  );

  blocTest<BookSelectionCubit, BookSelectionState>(
    'should emit error state when opening book',
    build: () => cubit,
    setUp: () {
      when(() => retrieveStoredBooks.call()).thenAnswer(
        (_) async => Ok([
          AvailableBook(id: 962, author: null, title: null),
          AvailableBook(id: 753, title: 'xrd9WEwNkfk', author: 'iPDRhA4'),
        ]),
      );

      when(() => checkAvailableBooksChange.call()).thenReturn(Ok(Stream<Unit>.fromIterable([(), ()])));
    },
    act: (cubit) async {
      await cubit.loadStoredBooks();
      await cubit.open(BookSelectionItemViewModel(id: 444, title: 'qiqycg665s'));
    },
    skip: 3,
    expect: () => [
      BookSelectionLoadingError(errorCode: BookSelectionErrorCode.unableToSelectBook.name, errorContext: null),
      anything,
    ],
  );

  blocTest<BookSelectionCubit, BookSelectionState>(
    'should emit selected state when opening book',
    build: () => cubit,
    setUp: () {
      when(() => retrieveStoredBooks.call()).thenAnswer(
        (_) async => Ok([
          AvailableBook(id: 962, author: null, title: null),
          AvailableBook(id: 753, title: 'xrd9WEwNkfk', author: 'iPDRhA4'),
        ]),
      );

      when(() => checkAvailableBooksChange.call()).thenReturn(Ok(Stream<Unit>.fromIterable([(), ()])));
    },
    act: (cubit) async {
      await cubit.loadStoredBooks();
      await cubit.open(BookSelectionItemViewModel(id: 962, title: null));
    },
    skip: 3,
    expect: () => [const BookSelectionSelected(id: 962), BookSelectionInitial(), anything],
  );
}

class _MockRetrieveStoredBooks extends Mock implements RetrieveStoredBooks {}

class _MockCheckAvailableBooksChange extends Mock implements CheckAvailableBooksChange {}
