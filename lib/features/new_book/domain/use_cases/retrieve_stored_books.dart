import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/new_book/domain/entities/stored_book.dart';
import 'package:storyscape/features/new_book/domain/repositories/book_repository.dart';

abstract interface class RetrieveStoredBooks {
  FutureResult<List<StoredBook>, String> call();
}

class RetrieveStoredBooksImpl implements RetrieveStoredBooks {
  RetrieveStoredBooksImpl({required BookRepository bookRepository}) : _bookRepository = bookRepository;

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final BookRepository _bookRepository;

  @override
  FutureResult<List<StoredBook>, String> call() async {
    _logger.info('Fetching stored books...');

    return _bookRepository
        .fetchAllBooks()
        .inspect((books) => _logger.info('Successfully retrieve ${books.length} books'))
        .inspectErr((e) => _logger.warn('Unable to fetch stored books: $e'));
  }
}
