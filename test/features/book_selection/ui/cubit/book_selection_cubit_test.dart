import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/book_selection/ui/cubit/book_selection_cubit.dart';
import 'package:storyscape/features/book_storage/domain/entities/existing_book.dart';
import 'package:storyscape/features/book_storage/domain/entities/new_book.dart';
import 'package:storyscape/features/book_storage/domain/use_cases/store_new_book.dart';

void main() {
  late StoreNewBook storeNewBookUseCase;
  late BookSelectionCubit cubit;

  setUp(() {
    storeNewBookUseCase = _MockStoreNewBook();

    cubit = BookSelectionCubit(storeNewBookUseCase: storeNewBookUseCase);

    registerFallbackValue(_MockNewBook());
  });

  tearDown(resetMocktailState);

  test('should emit initial state', () => expect(cubit.state, BookSelectionInitial()));

  blocTest<BookSelectionCubit, BookSelectionState>(
    'should emit loading state when selecting book url',
    build: () => cubit,
    setUp: () => when(() => storeNewBookUseCase.execute(any())).thenAnswer((_) async => const Err('if4iL8dbK')),
    act: (cubit) => cubit.selectBookUrl('f581f8f5-54e0-4b88-875e-7bd3856c967c'),
    expect: () => containsAllInOrder([BookSelectionLoading()]),
  );

  blocTest<BookSelectionCubit, BookSelectionState>(
    'should emit err state if book storing operation fails when selecting book url',
    build: () => cubit,
    setUp: () => when(() => storeNewBookUseCase.execute(any())).thenAnswer((_) async => const Err('TZrSiHqR6')),
    act: (cubit) => cubit.selectBookUrl('f581f8f5-54e0-4b88-875e-7bd3856c967c'),
    skip: 1,
    expect: () => [
      BookSelectionError(
        errorCode: BookSelectionErrorCode.unableToSelectBookByUrl.name,
        errorContext: 'TZrSiHqR6',
      ),
    ],
    verify: (_) =>
        verify(() => storeNewBookUseCase.execute(const NewBook(url: 'f581f8f5-54e0-4b88-875e-7bd3856c967c'))).called(1),
  );

  blocTest<BookSelectionCubit, BookSelectionState>(
    'should emit selected state if book storing operation succeeds when selecting book url',
    build: () => cubit,
    setUp: () => when(() => storeNewBookUseCase.execute(any()))
        .thenAnswer((_) async => const Ok(ExistingBook(id: 264, url: 'a8938035-7de0-45a0-bf26-01110e1a9a01'))),
    act: (cubit) => cubit.selectBookUrl('836945f1-1d12-419c-a736-69db139a6e62'),
    skip: 1,
    expect: () => [const BookSelectionSelected(url: 'a8938035-7de0-45a0-bf26-01110e1a9a01')],
    verify: (_) =>
        verify(() => storeNewBookUseCase.execute(const NewBook(url: '836945f1-1d12-419c-a736-69db139a6e62'))).called(1),
  );
}

class _MockStoreNewBook extends Mock implements StoreNewBook {}

class _MockNewBook extends Mock implements NewBook {}
