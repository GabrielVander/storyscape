import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';

part 'book_reader_state.dart';

class BookReaderCubit extends Cubit<BookReaderState> {
  BookReaderCubit({required NetworkFileRetriever networkFileRetriever})
      : _networkFileRetriever = networkFileRetriever,
        super(BookReaderInitial());

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final NetworkFileRetriever _networkFileRetriever;

  Future<void> download(String link) async {
    _logger.info('Downloading book from $link...');
    emit(BookReaderLoading());

    (await performDownloadOperation(link))
        .inspect((content) => emit(BookReaderFinished(content: content)))
        .mapErr((e) => e.toString())
        .inspectErr((error) => emit(BookReaderError(errorCode: BookReaderErrorCodes.generic.value, context: error)));
  }

  Future<Result<Uint8List, Exception>> performDownloadOperation(String link) async {
    try {
      return Ok(await downloadFileUsingNetworkRetriever(link));
    } on Exception catch (e, stacktrace) {
      _logger.error(e.toString(), error: e, stackTrace: stacktrace);

      return Err(e);
    }
  }

  Future<Uint8List> downloadFileUsingNetworkRetriever(String link) async {
    _logger.debug('Downloading book from network file retriever...');

    return _networkFileRetriever(link, updateDownloadPercentage);
  }

  void updateDownloadPercentage(double percentage) {
    _logger.debug('Updating download percentage');
    final leadingZerosRegex = RegExp(r'\.?0*$');
    final String prettyPercentage = percentage.toStringAsFixed(2).replaceFirst(leadingZerosRegex, '');

    emit(
      BookReaderDownloading(
        percentageDisplay: '$prettyPercentage%',
        percentageValue: percentage / 100,
      ),
    );
  }
}

enum BookReaderErrorCodes {
  generic('genericErrorMessage');

  const BookReaderErrorCodes(this.value);

  final String value;
}

typedef DownloadProgressUpdater = void Function(double percentage);
typedef NetworkFileRetriever = Future<Uint8List> Function(String link, DownloadProgressUpdater progressUpdater);
