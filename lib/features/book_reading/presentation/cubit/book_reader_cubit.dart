import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'book_reader_state.dart';

class BookReaderCubit extends Cubit<BookReaderState> {
  BookReaderCubit({required NetworkFileRetriever networkFileRetriever})
      : _networkFileRetriever = networkFileRetriever,
        super(BookReaderInitial());

  final NetworkFileRetriever _networkFileRetriever;

  Future<void> download(String link) async {
    emit(BookReaderLoading());

    await _networkFileRetriever(
      updateDownloadPercentage,
    );
  }

  void updateDownloadPercentage(double percentage) {
    final RegExp leadingZerosRegex = RegExp(r'\.?0*$');
    final String prettyPercentage = percentage.toStringAsFixed(2).replaceFirst(leadingZerosRegex, '');

    emit(
      BookReaderDownloading(
        percentageDisplay: '$prettyPercentage%',
      ),
    );
  }
}

typedef DownloadProgressUpdater = void Function(double percentage);
typedef NetworkFileRetriever = Future<Uint8List> Function(DownloadProgressUpdater progressUpdater);
