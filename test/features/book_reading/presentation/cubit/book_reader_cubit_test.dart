import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storyscape/features/book_reading/presentation/cubit/book_reader_cubit.dart';

Future<Uint8List> dummyNetworkFileRetriever(String link, void Function(double) p) async =>
    Uint8List.fromList(List.empty());

void main() {
  test('emits [BookReaderInitial] as initial state', () {
    expect(BookReaderCubit(networkFileRetriever: dummyNetworkFileRetriever).state, BookReaderInitial());
  });

  blocTest<BookReaderCubit, BookReaderState>(
    'emits [BookReaderLoading] when starting book download',
    build: () => BookReaderCubit(networkFileRetriever: dummyNetworkFileRetriever),
    act: (BookReaderCubit cubit) => cubit.download('8kWs26km7n'),
    expect: () => [BookReaderLoading(), BookReaderFinished(content: Uint8List.fromList(List.empty()))],
  );

  for (final bundle in [
    (
      [
        isA<BookReaderDownloading>()
            .having((s) => s.percentageDisplay, 'percentageDisplay', '0%')
            .having((s) => s.percentageValue, 'percentageValue', closeTo(0, 0.001)),
        isA<BookReaderFinished>().having((s) => s.content, 'content', Uint8List.fromList(List.empty())),
      ],
      [0.0]
    ),
    (
      [
        isA<BookReaderDownloading>()
            .having((s) => s.percentageDisplay, 'percentageDisplay', '4.51%')
            .having((s) => s.percentageValue, 'percentageValue', closeTo(0.0451, 0.001)),
        isA<BookReaderDownloading>()
            .having((s) => s.percentageDisplay, 'percentageDisplay', '5%')
            .having((s) => s.percentageValue, 'percentageValue', closeTo(0.05, 0.001)),
        isA<BookReaderDownloading>()
            .having((s) => s.percentageDisplay, 'percentageDisplay', '9.86%')
            .having((s) => s.percentageValue, 'percentageValue', closeTo(0.0986, 0.001)),
        isA<BookReaderDownloading>()
            .having((s) => s.percentageDisplay, 'percentageDisplay', '90.3%')
            .having((s) => s.percentageValue, 'percentageValue', closeTo(0.903, 0.001)),
        isA<BookReaderDownloading>()
            .having((s) => s.percentageDisplay, 'percentageDisplay', '99.14%')
            .having((s) => s.percentageValue, 'percentageValue', closeTo(0.9914, 0.001)),
        isA<BookReaderFinished>().having((s) => s.content, 'content', Uint8List.fromList(List.empty())),
      ],
      [4.51, 5.00002, 9.86, 90.3, 99.14442]
    ),
  ]) {
    final List<Matcher> expectedStates = bundle.$1;
    final List<double> progressUpdates = bundle.$2;

    blocTest<BookReaderCubit, BookReaderState>(
      'emits $expectedStates when starting book download with given progress updates: $progressUpdates',
      build: () => BookReaderCubit(
        networkFileRetriever: (l, p) async {
          progressUpdates.forEach(p);

          return Uint8List.fromList(List.empty());
        },
      ),
      act: (BookReaderCubit cubit) => cubit.download('L749Z5lJ4K'),
      skip: 1,
      expect: () => expectedStates,
    );
  }

  blocTest<BookReaderCubit, BookReaderState>(
    'emits [BookReaderError] when book download fails',
    build: () => BookReaderCubit(networkFileRetriever: (_, __) => throw Exception('AWS5hgz')),
    act: (BookReaderCubit cubit) => cubit.download('RCjoC9H'),
    skip: 1,
    expect: () => [BookReaderError(errorCode: BookReaderErrorCodes.generic.value, context: 'Exception: AWS5hgz')],
  );

  blocTest<BookReaderCubit, BookReaderState>(
    'emits [BookReaderFinished] when book download succeeds returning no bytes',
    build: () => BookReaderCubit(networkFileRetriever: (_, __) async => Uint8List.fromList(List.empty())),
    act: (BookReaderCubit cubit) => cubit.download('JeW5kkqtYnk'),
    skip: 1,
    expect: () => [BookReaderFinished(content: Uint8List.fromList(List.empty()))],
  );

  for (final content in [
    Uint8List.fromList([875]),
    Uint8List.fromList([631, 339, 824, 249]),
  ]) {
    blocTest<BookReaderCubit, BookReaderState>(
      'emits [BookReaderFinished] when book download succeeds returning $content as content',
      build: () => BookReaderCubit(networkFileRetriever: (_, __) async => content),
      act: (BookReaderCubit cubit) => cubit.download('os8wHuV'),
      skip: 1,
      expect: () => [BookReaderFinished(content: content)],
    );
  }
}
