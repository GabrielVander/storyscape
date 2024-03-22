import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/book_storage/domain/repositories/existing_book_repository.dart';
import 'package:storyscape/features/read_book/domain/entities/book_file.dart';

class RetrieveBookFileById {
  RetrieveBookFileById({required ExistingBookRepository existingBookRepository})
      : _existingBookRepository = existingBookRepository;

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final ExistingBookRepository _existingBookRepository;

  FutureResult<BookFile, String> call(int id) async {
    _logger.info('Retrieving book file by id...');

    return _existingBookRepository
        .retrieveBookById(id)
        .map((_) => BookFile(id: _.id, value: _.file))
        .inspectErr(_logger.warn)
        .mapErr((_) => 'Unable to retrieve book file by id');
  }
}
