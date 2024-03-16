import 'package:rust_core/result.dart';
import 'package:storyscape/features/book_storage/domain/entities/existing_book.dart';
import 'package:storyscape/features/book_storage/domain/entities/parsed_book.dart';

abstract interface class ExistingBookRepository {
  FutureResult<ExistingBook, String> storeDownloadedBook(ParsedBook book);
}
