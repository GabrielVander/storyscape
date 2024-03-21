import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/read_book/domain/entities/book_file.dart';
import 'package:storyscape/features/read_book/domain/usecases/retrieve_book_file_by_id.dart';
import 'package:storyscape/features/read_book/ui/cubit/book_reader_cubit.dart';

Future<Uint8List> dummyNetworkFileRetriever(String link, void Function(double) p) async =>
    Uint8List.fromList(List.empty());

void main() {
  late RetrieveBookFileById retrieveBookFileById;
  late File dummyFile;
  late BookReaderCubit cubit;

  setUp(() {
    retrieveBookFileById = _MockRetrieveBookFileById();
    dummyFile = _FakeFile();

    cubit = BookReaderCubit(retrieveBookFileByIdUseCase: retrieveBookFileById);
  });

  test('emits [BookReaderInitial] as initial state', () {
    expect(cubit.state, BookReaderInitial());
  });

  blocTest<BookReaderCubit, BookReaderState>(
    'emits [BookReaderLoading] when starting book retrieval',
    build: () => cubit,
    setUp: () => when(() => retrieveBookFileById.call(any())).thenAnswer((_) async => const Err('pXBEuQFKP')),
    act: (cubit) => cubit.open(241),
    expect: () => [BookReaderLoading(), isA<BookReaderError>()],
  );

  blocTest<BookReaderCubit, BookReaderState>(
    'emits [BookReaderError] when unable to retrieve book',
    setUp: () =>
        when(() => retrieveBookFileById.call(146)).thenAnswer((_) async => const Err<BookFile, String>('zKnP43VaI4')),
    build: () => cubit,
    act: (BookReaderCubit cubit) => cubit.open(146),
    skip: 1,
    expect: () => [BookReaderError(errorCode: BookReaderErrorCodes.generic.value, context: 'zKnP43VaI4')],
  );

  blocTest<BookReaderCubit, BookReaderState>(
    'emits [BookReaderFinished] when book retrieved successfully',
    setUp: () => when(() => retrieveBookFileById.call(191))
        .thenAnswer((invocation) async => Ok(BookFile(id: 191, value: dummyFile))),
    build: () => cubit,
    act: (BookReaderCubit cubit) => cubit.open(191),
    skip: 1,
    expect: () => [BookReaderFinished(file: dummyFile)],
  );
}

class _MockRetrieveBookFileById extends Mock implements RetrieveBookFileById {}

class _FakeFile extends Fake implements File {}
