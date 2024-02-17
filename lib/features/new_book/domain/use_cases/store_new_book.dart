import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/new_book/domain/entities/existing_book.dart';
import 'package:storyscape/features/new_book/domain/entities/new_book.dart';
import 'package:storyscape/features/new_book/domain/repositories/book_repository.dart';

abstract interface class StoreNewBook {
  Future<Result<ExistingBook, String>> execute(NewBook book);
}

class StoreNewBookImpl implements StoreNewBook {
  StoreNewBookImpl({required BookRepository bookRepository}) : _bookRepository = bookRepository;

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final BookRepository _bookRepository;

  @override
  Future<Result<ExistingBook, String>> execute(NewBook book) async {
    _logger.info('Storing new book...');

    return _bookRepository
        .storeNewBook(book)
        .inspect((_) => _logger.info('Book stored successfully'))
        .inspectErr(_logger.warn)
        .inspectErr((_) => _logger.warn('Unable to store new book'));
  }
}
