import 'package:bloc_test/bloc_test.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/new_book/domain/entities/book_downloader.dart';
import 'package:storyscape/features/new_book/domain/entities/new_book.dart';
import 'package:storyscape/features/new_book/domain/usecases/download_epub_book_by_url.dart';
import 'package:storyscape/features/new_book/domain/usecases/store_new_book.dart';
import 'package:storyscape/features/new_book/ui/cubit/new_book_cubit.dart';

void main() {
  late StoreNewBook storeNewBookUseCase;
  late DownloadEpubBookByUrl downloadEpubBookByUrlUseCase;

  late NewBookCubit cubit;

  setUp(() {
    storeNewBookUseCase = _MockStoreNewBook();
    downloadEpubBookByUrlUseCase = _MockDownloadEpubBookUrl();

    cubit = NewBookCubit(downloadEpubBookByUrl: downloadEpubBookByUrlUseCase, storeNewBook: storeNewBookUseCase);

    registerFallbackValue(_MockNewBook());
    registerFallbackValue(_MockBookDownloader());
  });

  blocTest<NewBookCubit, NewBookState>(
    'should emit loading state when adding a new book by url',
    build: () => cubit,
    setUp: () {
      when(() => downloadEpubBookByUrlUseCase.call(any(), any())).thenAnswer((_) async => const Err('if4iL8dbK'));
    },
    act: (cubit) => cubit.addNewBookByUrl('f581f8f5-54e0-4b88-875e-7bd3856c967c'),
    expect: () => containsAllInOrder([NewBookLoading()]),
  );

  blocTest<NewBookCubit, NewBookState>(
    'should emit err state if book storing operation fails when adding a new book by url',
    build: () => cubit,
    setUp: () =>
        when(() => downloadEpubBookByUrlUseCase.call(any(), any())).thenAnswer((_) async => const Err('okDFScXwKoD')),
    act: (cubit) => cubit.addNewBookByUrl('9f5986f9-c870-4f51-a693-d7f3c67d3d60'),
    skip: 1,
    expect: () => [NewBookError()],
    verify: (_) =>
        verify(() => downloadEpubBookByUrlUseCase.call('9f5986f9-c870-4f51-a693-d7f3c67d3d60', any())).called(1),
  );

  blocTest<NewBookCubit, NewBookState>(
    'should emit err state if book storing operation fails when adding a new book by url',
    build: () => cubit,
    setUp: () {
      when(() => downloadEpubBookByUrlUseCase.call(any(), any()))
          .thenAnswer((_) async => Ok(EpubBook()..Title = 'Q6KMDXPNJ'));
      when(() => storeNewBookUseCase.execute(any())).thenAnswer((_) async => const Err('TZrSiHqR6'));
    },
    act: (cubit) => cubit.addNewBookByUrl('f581f8f5-54e0-4b88-875e-7bd3856c967c'),
    skip: 1,
    expect: () => [NewBookError()],
    verify: (_) => verify(
      () => storeNewBookUseCase.execute(const NewBook(title: 'Q6KMDXPNJ', url: 'f581f8f5-54e0-4b88-875e-7bd3856c967c')),
    ).called(1),
  );

  blocTest<NewBookCubit, NewBookState>(
    'should emit saved state if book storing operation succeeds when adding a new book by url',
    build: () => cubit,
    setUp: () {
      when(() => downloadEpubBookByUrlUseCase.call(any(), any()))
          .thenAnswer((_) async => Ok(EpubBook()..Title = 'vf6gU65bGf'));
      when(() => storeNewBookUseCase.execute(any())).thenAnswer((_) async => const Ok(()));
    },
    act: (cubit) => cubit.addNewBookByUrl('836945f1-1d12-419c-a736-69db139a6e62'),
    skip: 1,
    expect: () => [NewBookSaved()],
    verify: (_) => verify(
      () =>
          storeNewBookUseCase.execute(const NewBook(title: 'vf6gU65bGf', url: '836945f1-1d12-419c-a736-69db139a6e62')),
    ).called(1),
  );
}

class _MockStoreNewBook extends Mock implements StoreNewBook {}

class _MockDownloadEpubBookUrl extends Mock implements DownloadEpubBookByUrl {}

class _MockNewBook extends Mock implements NewBook {}

class _MockBookDownloader extends Mock implements BookDownloader {}
