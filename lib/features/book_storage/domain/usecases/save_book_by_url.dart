import 'dart:async';

import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/book_storage/domain/entities/existing_book.dart';
import 'package:storyscape/features/book_storage/domain/entities/parsed_book.dart';
import 'package:storyscape/features/book_storage/domain/repositories/downloaded_book_repository.dart';
import 'package:storyscape/features/book_storage/domain/repositories/existing_book_repository.dart';

class SaveBookByUrl {
  SaveBookByUrl({
    required ExistingBookRepository existingBookRepository,
    required DownloadedBookRepository downloadedBookRepository,
  })  : _existingBookRepository = existingBookRepository,
        _downloadedBookRepository = downloadedBookRepository;

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final ExistingBookRepository _existingBookRepository;
  final DownloadedBookRepository _downloadedBookRepository;
  final StreamController<double> _streamController = StreamController.broadcast();

  FutureResult<ExistingBook, String> call(String url) => Future.value(Ok<String, String>(url))
      .inspect((_) => _logger.info('Saving book...'))
      .andThen(_downloadBookByUrl)
      .andThen(_storeDownloadedBook)
      .inspect((_) => _logger.info('Book saved successfully'))
      .mapErr((_) => 'Unable to save book by url');

  FutureResult<ExistingBook, String> _storeDownloadedBook(ParsedBook book) => Future.value(Ok<ParsedBook, String>(book))
      .andThen(_existingBookRepository.storeDownloadedBook)
      .inspectErr(_logger.warn);

  FutureResult<ParsedBook, String> _downloadBookByUrl(String url) => Future.value(Ok<String, String>(url))
      .andThen((_) => _downloadedBookRepository.downloadAndParseBookByUrl(_, _updateDownloadPercentage))
      // .inspect((_) => _streamController.close())
      .inspectErr(_logger.warn);

  void _updateDownloadPercentage(int receivedLength, int contentLength) =>
      _streamController.add((receivedLength / contentLength).floorToDouble());

  Stream<double> downloadPercentage() => _streamController.stream;
}
