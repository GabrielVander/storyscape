import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/book_selection/domain/entities/stored_book.dart';
import 'package:storyscape/features/book_selection/domain/repositories/stored_book_repository.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/models/local_book_isar_model.dart';

class StoredBookRepositoryImpl implements StoredBookRepository {
  StoredBookRepositoryImpl({required BookIsarDataSource bookIsarDataSource}) : _bookIsarDataSource = bookIsarDataSource;

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final BookIsarDataSource _bookIsarDataSource;

  @override
  FutureResult<List<StoredBook>, String> fetchAllBooks() async {
    _logger.debug('Fetching all stored books...');

    return _fetchAllBooksFromIsar()
        .map((models) => _mapLocalIsarBookModelsToStoredBooks(models).toList())
        .mapErr((_) => 'Unable to fetch books');
  }

  Iterable<StoredBook> _mapLocalIsarBookModelsToStoredBooks(List<LocalBookIsarModel> models) =>
      models.map(_mapSingleLocalIsarBookToStoredBook);

  StoredBook _mapSingleLocalIsarBookToStoredBook(LocalBookIsarModel m) => StoredBook(url: m.url);

  FutureResult<List<LocalBookIsarModel>, String> _fetchAllBooksFromIsar() =>
      _bookIsarDataSource.getAllBooks().inspectErr(_logger.warn);
}
