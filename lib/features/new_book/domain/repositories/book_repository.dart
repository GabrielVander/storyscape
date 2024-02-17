import 'package:rust_core/result.dart';
import 'package:storyscape/features/new_book/domain/entities/existing_book.dart';
import 'package:storyscape/features/new_book/domain/entities/new_book.dart';
import 'package:storyscape/features/select_book/domain/entities/stored_book.dart';

abstract interface class BookRepository {
  Future<Result<ExistingBook, String>> storeNewBook(NewBook book);

  Future<Result<ExistingBook, String>> retrieveBookById(int id);

  FutureResult<List<StoredBook>, String> fetchAllBooks();
}
