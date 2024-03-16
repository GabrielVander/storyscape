import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/book_storage/data/data_sources/remote/internet_file_data_source.dart';
import 'package:storyscape/features/new_book/domain/entities/new_book.dart';
import 'package:storyscape/features/new_book/domain/usecases/save_book_by_url.dart';
import 'package:storyscape/features/new_book/ui/cubit/new_book_cubit.dart';

void main() {
  late SaveBookByUrl storeNewBookUseCase;
  late BookDownloader bookDownloader;

  late NewBookCubit cubit;

  setUp(() {
    storeNewBookUseCase = _MockStoreNewBook();
    bookDownloader = _MockBookDownloader();

    cubit = NewBookCubit(bookDownloader: bookDownloader, saveBookByUrlUseCase: storeNewBookUseCase);

    registerFallbackValue(_MockNewBook());
    registerFallbackValue(_MockBookDownloader());
  });

  blocTest<NewBookCubit, NewBookState>(
    'should emit loading state when adding a new book by url',
    build: () => cubit,
    setUp: () {
      when(() => bookDownloader.progress()).thenAnswer((_) => const Stream<double>.empty());
      when(() => bookDownloader.call(any())).thenAnswer((_) async => Uint8List.fromList(List.empty()));
      when(() => storeNewBookUseCase.execute(any())).thenAnswer((_) async => const Err('HGiWtTQG'));
    },
    act: (cubit) => cubit.addNewBookByUrl('f581f8f5-54e0-4b88-875e-7bd3856c967c'),
    expect: () => containsAllInOrder([NewBookLoading()]),
  );

  blocTest<NewBookCubit, NewBookState>(
    'should emit err state if unable to download book by url',
    build: () => cubit,
    setUp: () {
      when(() => bookDownloader.progress()).thenAnswer((_) => const Stream<double>.empty());
      when(() => bookDownloader.call(any())).thenThrow(Exception());
    },
    act: (cubit) => cubit.addNewBookByUrl('9f5986f9-c870-4f51-a693-d7f3c67d3d60'),
    skip: 1,
    expect: () => [NewBookError()],
    verify: (_) => verify(() => bookDownloader.call('9f5986f9-c870-4f51-a693-d7f3c67d3d60')).called(1),
  );

  blocTest<NewBookCubit, NewBookState>(
    'should emit err state if book storing operation fails when adding a new book by url',
    build: () => cubit,
    setUp: () {
      when(() => bookDownloader.progress()).thenAnswer((_) => const Stream<double>.empty());
      when(() => bookDownloader.call(any())).thenAnswer((_) async => Uint8List.fromList(List.of([1, 0, 1, 0, 0, 1])));
      when(() => storeNewBookUseCase.execute(any())).thenAnswer((_) async => const Err('TZrSiHqR6'));
    },
    act: (cubit) => cubit.addNewBookByUrl('f581f8f5-54e0-4b88-875e-7bd3856c967c'),
    skip: 1,
    expect: () => [NewBookError()],
    verify: (_) => verify(
      () => storeNewBookUseCase.execute(
        NewBook(data: Uint8List.fromList(List.of([1, 0, 1, 0, 0, 1])), url: 'f581f8f5-54e0-4b88-875e-7bd3856c967c'),
      ),
    ).called(1),
  );

  blocTest<NewBookCubit, NewBookState>(
    'should emit saved state if book storing operation succeeds when adding a new book by url',
    build: () => cubit,
    setUp: () {
      when(() => bookDownloader.progress()).thenAnswer((_) => const Stream<double>.empty());
      when(() => bookDownloader.call(any())).thenAnswer((_) async => Uint8List.fromList(List.of([1, 0, 1, 0, 0, 1])));
      when(() => storeNewBookUseCase.execute(any())).thenAnswer((_) async => const Ok(()));
    },
    act: (cubit) => cubit.addNewBookByUrl('836945f1-1d12-419c-a736-69db139a6e62'),
    skip: 1,
    expect: () => [NewBookSaved()],
    verify: (_) => verify(
      () => storeNewBookUseCase.execute(
        NewBook(data: Uint8List.fromList(List.of([1, 0, 1, 0, 0, 1])), url: '836945f1-1d12-419c-a736-69db139a6e62'),
      ),
    ).called(1),
  );
}

class _MockStoreNewBook extends Mock implements SaveBookByUrl {}

class _MockNewBook extends Mock implements NewBook {}

class _MockBookDownloader extends Mock implements BookDownloader {}
