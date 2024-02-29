import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rust_core/result.dart';
import 'package:rust_core/typedefs.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/new_book/domain/entities/book_downloader.dart';
import 'package:storyscape/features/new_book/domain/entities/new_book.dart';
import 'package:storyscape/features/new_book/domain/usecases/download_epub_book_by_url.dart';
import 'package:storyscape/features/new_book/domain/usecases/store_new_book.dart';

part 'new_book_state.dart';

class NewBookCubit extends Cubit<NewBookState> {
  NewBookCubit({required DownloadEpubBookByUrl downloadEpubBookByUrl, required StoreNewBook storeNewBook})
      : _downloadEpubBookByUrl = downloadEpubBookByUrl,
        _storeNewBook = storeNewBook,
        super(NewBookInitial());

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final DownloadEpubBookByUrl _downloadEpubBookByUrl;
  final StoreNewBook _storeNewBook;

  Future<void> addNewBookByUrl(String url) async {
    emit(NewBookLoading());
    final BookDownloader downloader = InternetFileBookDownloader()..progress().listen(_onDownloadProgressUpdate);

    await _dowloadBook(url, downloader)
        .andThen(_storeBook)
        .inspect((_) => emit(NewBookSaved()))
        .inspectErr((_) => emit(NewBookError()));
  }

  Future<Result<Unit, String>> _storeBook(NewBook book) => _storeNewBook.execute(book);

  FutureResult<NewBook, String> _dowloadBook(String url, BookDownloader downloader) =>
      _downloadEpubBookByUrl(url, downloader)
          .inspectErr(_logger.warn)
          .map((book) => NewBook(title: book.Title, url: url));

  void _onDownloadProgressUpdate(double percentage) {
    final RegExp leadingZerosRegex = RegExp(r'\.?0*$');
    final String prettyPercentage = percentage.toStringAsFixed(2).replaceFirst(leadingZerosRegex, '');

    emit(NewBookDownloading(percentageDisplay: '$prettyPercentage%', percentageValue: percentage));
  }

  void reset() => emit(NewBookInitial());
}
