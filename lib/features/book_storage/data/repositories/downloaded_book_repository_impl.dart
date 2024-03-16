import 'dart:io';

import 'package:epub_view/epub_view.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/core/utils/generate_random_string.dart';
import 'package:storyscape/features/book_storage/data/data_sources/remote/internet_file_data_source.dart';
import 'package:storyscape/features/book_storage/domain/entities/parsed_book.dart';
import 'package:storyscape/features/book_storage/domain/repositories/downloaded_book_repository.dart';

typedef EpubBookParser = Future<EpubBook> Function(File);

class DownloadedBookRepositoryImpl implements DownloadedBookRepository {
  DownloadedBookRepositoryImpl({
    required InternetFileDataSource internetFileDataSource,
    required EpubBookParser epubBookParser,
  })  : _internetFileDataSource = internetFileDataSource,
        _epubBookParser = epubBookParser;

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final InternetFileDataSource _internetFileDataSource;
  final EpubBookParser _epubBookParser;

  @override
  FutureResult<ParsedBook, String> downloadAndParseBookByUrl(String url, OnProgressUpdate? onProgressUpdate) {
    _logger.debug('Downloading and parsing book by url...');

    return _downloadBook(url, onProgressUpdate)
        .andThen(_parseBook)
        .inspect((_) => _logger.debug('Book downloaded and parsed successfully'))
        .mapErr((_) => 'Unable to download and parse book by url');
  }

  FutureResult<FileDownloadResult, String> _downloadBook(String url, OnProgressUpdate? onProgressUpdate) {
    final String fileName = '${GenerateRandomStringUtil().call(16)}.epub';
    final FileInput input = FileInput(url: url, fileName: fileName, progress: onProgressUpdate);

    return _internetFileDataSource.downloadFile(input).inspectErr(_logger.warn);
  }

  FutureResult<ParsedBook, String> _parseBook(FileDownloadResult downloadResult) => _readEpubFile(downloadResult.file)
      .map((_) => ParsedBook(url: downloadResult.url, author: _.Author, title: _.Title, file: downloadResult.file))
      .inspectErr((err) => _logger.error(err.$1.toString(), error: err.$1, stackTrace: err.$2))
      .mapErr((_) => _.$1.toString());

  FutureResult<EpubBook, (Exception, StackTrace)> _readEpubFile(File file) async {
    try {
      return Ok(await _epubBookParser(file));
    } on Exception catch (e, stack) {
      return Err((e, stack));
    }
  }
}
