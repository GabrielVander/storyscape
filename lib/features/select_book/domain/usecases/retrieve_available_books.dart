import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/select_book/domain/entities/available_book.dart';
import 'package:storyscape/features/select_book/domain/repositories/available_book_repository.dart';

abstract interface class RetrieveStoredBooks {
  FutureResult<List<AvailableBook>, String> call();
}

class RetrieveStoredBooksImpl implements RetrieveStoredBooks {
  RetrieveStoredBooksImpl({required AvailableBookRepository availableBookRepository})
      : _bookRepository = availableBookRepository;

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final AvailableBookRepository _bookRepository;

  @override
  FutureResult<List<AvailableBook>, String> call() async {
    _logger.info('Fetching stored books...');

    return _bookRepository
        .fetchAllAvailableBooks()
        .inspect((books) => _logger.info('Successfully retrieve ${books.length} books'))
        .inspectErr((e) => _logger.warn('Unable to fetch stored books: $e'));
  }
}
