import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storyscape/features/book_reading/presentation/cubit/book_reader_cubit.dart';

void main() {
  Future<Uint8List> dummyNetworkFileRetriever(p) async => Uint8List.fromList(List.empty());

  test('emits [BookReaderInitial] as initial state', () {
    expect(BookReaderCubit(networkFileRetriever: dummyNetworkFileRetriever).state, BookReaderInitial());
  });

  blocTest<BookReaderCubit, BookReaderState>(
    'emits [BookReaderLoading] when starting book download',
    build: () => BookReaderCubit(networkFileRetriever: dummyNetworkFileRetriever),
    act: (cubit) => cubit.download('8kWs26km7n'),
    expect: () => [BookReaderLoading()],
  );

  for (final bundle in [
    ([const BookReaderDownloading(percentageDisplay: '0%')], [0.0]),
    (
      [
        const BookReaderDownloading(percentageDisplay: '4.51%'),
        const BookReaderDownloading(percentageDisplay: '5%'),
        const BookReaderDownloading(percentageDisplay: '9.86%'),
        const BookReaderDownloading(percentageDisplay: '90.3%'),
        const BookReaderDownloading(percentageDisplay: '99.14%'),
      ],
      [4.51, 5.00002, 9.86, 90.3, 99.14442]
    ),
  ]) {
    final List<BookReaderDownloading> expectedStates = bundle.$1;
    final List<double> progressUpdates = bundle.$2;

    blocTest<BookReaderCubit, BookReaderState>(
      'emits $expectedStates when starting book download with given progress updates: $progressUpdates',
      build: () => BookReaderCubit(
        networkFileRetriever: (p) async {
          progressUpdates.forEach(p);

          return Uint8List.fromList(List.empty());
        },
      ),
      act: (BookReaderCubit cubit) => cubit.download('L749Z5lJ4K'),
      skip: 1,
      expect: () => expectedStates,
    );
  }
}
