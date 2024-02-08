import 'package:rust_core/result.dart';
import 'package:storyscape/features/book_selection/domain/entities/stored_book.dart';

abstract interface class StoredBookRepository {
  FutureResult<List<StoredBook>, String> fetchAllBooks();
}
