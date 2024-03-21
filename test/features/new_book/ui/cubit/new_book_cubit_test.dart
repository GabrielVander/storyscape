import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/book_storage/domain/entities/existing_book.dart';
import 'package:storyscape/features/book_storage/domain/usecases/save_book_by_url.dart';
import 'package:storyscape/features/new_book/ui/cubit/new_book_cubit.dart';

void main() {
  late SaveBookByUrl storeNewBookUseCase;

  late NewBookCubit cubit;

  setUp(() {
    storeNewBookUseCase = _MockStoreNewBook();

    cubit = NewBookCubit(saveBookByUrlUseCase: storeNewBookUseCase);
  });

  blocTest<NewBookCubit, NewBookState>(
    'should emit loading state when adding a new book by url',
    build: () => cubit,
    setUp: () {
      when(() => storeNewBookUseCase.downloadPercentage()).thenAnswer((_) => const Stream<double>.empty());
      when(() => storeNewBookUseCase.call(any())).thenAnswer((_) async => const Err('HGiWtTQG'));
    },
    act: (cubit) => cubit.addNewBookByUrl('f581f8f5-54e0-4b88-875e-7bd3856c967c'),
    expect: () => containsAllInOrder([NewBookLoading()]),
  );

  blocTest<NewBookCubit, NewBookState>(
    'should emit err state if book storing operation fails when adding a new book by url',
    build: () => cubit,
    setUp: () {
      when(() => storeNewBookUseCase.downloadPercentage()).thenAnswer((_) => const Stream<double>.empty());
      when(() => storeNewBookUseCase.call('f581f8f5-54e0-4b88-875e-7bd3856c967c'))
          .thenAnswer((_) async => const Err('TZrSiHqR6'));
    },
    act: (cubit) => cubit.addNewBookByUrl('f581f8f5-54e0-4b88-875e-7bd3856c967c'),
    skip: 1,
    expect: () => [NewBookError()],
    verify: (_) => verify(() => storeNewBookUseCase.call('f581f8f5-54e0-4b88-875e-7bd3856c967c')).called(1),
  );

  blocTest<NewBookCubit, NewBookState>(
    'should emit saved state if book storing operation succeeds when adding a new book by url',
    build: () => cubit,
    setUp: () {
      when(() => storeNewBookUseCase.downloadPercentage()).thenAnswer((_) => const Stream<double>.empty());
      when(() => storeNewBookUseCase.call(any())).thenAnswer((_) async => Ok(_FakeExistingBook()));
    },
    act: (cubit) => cubit.addNewBookByUrl('836945f1-1d12-419c-a736-69db139a6e62'),
    skip: 1,
    expect: () => [NewBookSaved()],
    verify: (_) => verify(() => storeNewBookUseCase.call('836945f1-1d12-419c-a736-69db139a6e62')).called(1),
  );
}

class _MockStoreNewBook extends Mock implements SaveBookByUrl {}

class _FakeExistingBook extends Fake implements ExistingBook {}
