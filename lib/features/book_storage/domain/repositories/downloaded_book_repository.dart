import 'package:rust_core/result.dart';
import 'package:storyscape/features/book_storage/domain/entities/parsed_book.dart';

typedef OnProgressUpdate = void Function(int receivedLength, int contentLength);

abstract interface class DownloadedBookRepository {
  FutureResult<ParsedBook, String> downloadAndParseBookByUrl(String url, OnProgressUpdate? onProgressUpdate);
}
