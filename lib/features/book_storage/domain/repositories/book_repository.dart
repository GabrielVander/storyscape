import 'package:rust_core/result.dart';
import 'package:storyscape/features/book_storage/domain/entities/existing_book.dart';
import 'package:storyscape/features/book_storage/domain/entities/new_book.dart';

abstract interface class BookRepository {
  Future<Result<ExistingBook, String>> storeNewBook(NewBook book);
}
