import 'package:rust_core/result.dart';
import 'package:storyscape/features/select_book/domain/entities/available_book.dart';

abstract interface class AvailableBookRepository {
  FutureResult<List<AvailableBook>, String> fetchAllAvailableBooks();
}
