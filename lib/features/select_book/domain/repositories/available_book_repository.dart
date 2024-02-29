import 'package:rust_core/result.dart';
import 'package:rust_core/typedefs.dart';
import 'package:storyscape/features/select_book/domain/entities/available_book.dart';

abstract interface class AvailableBookRepository {
  FutureResult<List<AvailableBook>, String> fetchAllAvailableBooks();

  Result<Stream<Unit>, String> onAvaliableBooksChange();
}
