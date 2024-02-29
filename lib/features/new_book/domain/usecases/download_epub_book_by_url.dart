import 'package:epub_view/epub_view.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/new_book/domain/entities/book_downloader.dart';

abstract interface class DownloadEpubBookByUrl {
  FutureResult<EpubBook, String> call(String url, BookDownloader downloader);
}

class DownloadEpubBookUrlImpl implements DownloadEpubBookByUrl {
  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();

  @override
  FutureResult<EpubBook, String> call(String url, BookDownloader downloader) async {
    try {
      return (await EpubReader.readBook(downloader(url))).toOk();
    } on Exception catch (e, stack) {
      _logger.error('Unable to download book', error: e, stackTrace: stack);
      return const Err('Unable to download book');
    }
  }
}
