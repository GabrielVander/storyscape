import 'package:rust_core/result.dart';
import 'package:rust_core/typedefs.dart';
import 'package:storyscape/features/new_book/domain/entities/existing_book.dart';
import 'package:storyscape/features/new_book/domain/entities/new_book.dart';

abstract interface class BookRepository {
  Future<Result<Unit, String>> storeNewBook(NewBook book);

  Future<Result<ExistingBook, String>> retrieveBookById(int id);
}
