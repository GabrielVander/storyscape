import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/new_book/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/new_book/data/data_sources/local/models/local_book_isar_model.dart';
import 'package:storyscape/features/select_book/domain/entities/available_book.dart';
import 'package:storyscape/features/select_book/domain/repositories/available_book_repository.dart';

class AvailableBookRepositoryImpl implements AvailableBookRepository {
  AvailableBookRepositoryImpl({required BookIsarDataSource isarDataSource}) : _isarDataSource = isarDataSource;

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final BookIsarDataSource _isarDataSource;

  @override
  FutureResult<List<AvailableBook>, String> fetchAllAvailableBooks() async {
    _logger.debug('Fetching all stored books...');

    return _fetchAllBooksFromIsar()
        .map((models) => _mapLocalIsarBookModelsToStoredBooks(models).toList())
        .mapErr((_) => 'Unable to fetch books');
  }

  Iterable<AvailableBook> _mapLocalIsarBookModelsToStoredBooks(List<LocalBookIsarModel> models) =>
      models.map(_mapSingleLocalIsarBookToStoredBook);

  AvailableBook _mapSingleLocalIsarBookToStoredBook(LocalBookIsarModel m) => AvailableBook(url: m.url);

  FutureResult<List<LocalBookIsarModel>, String> _fetchAllBooksFromIsar() =>
      _isarDataSource.getAllBooks().inspectErr(_logger.warn);
}
