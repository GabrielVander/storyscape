import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/models/local_book_isar_model.dart';
import 'package:storyscape/features/book_storage/domain/entities/existing_book.dart';
import 'package:storyscape/features/book_storage/domain/entities/new_book.dart';
import 'package:storyscape/features/book_storage/domain/entities/stored_book.dart';
import 'package:storyscape/features/book_storage/domain/repositories/book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl({
    required BookIsarDataSource isarDataSource,
    required LocalBookIsarModelMapper localBookIsarModelMapper,
  })  : _isarDataSource = isarDataSource,
        _localBookIsarModelMapper = localBookIsarModelMapper;

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final BookIsarDataSource _isarDataSource;
  final LocalBookIsarModelMapper _localBookIsarModelMapper;

  @override
  FutureResult<ExistingBook, String> storeNewBook(NewBook book) async => Future.value(Ok<NewBook, String>(book))
      .inspect((_) => _logger.debug('Storing new book...'))
      .andThen(_storeBookLocally)
      .inspect((_) => _logger.debug('Book stored successfully'))
      .inspectErr(_logger.warn)
      .mapErr((_) => 'Unable to store new book');

  FutureResult<ExistingBook, String> _storeBookLocally(NewBook book) => Future.value(Ok<NewBook, String>(book))
      .inspect((_) => _logger.debug('Storing book locally...'))
      .andThen(_storeLocalBookWithIsar)
      .inspect((_) => _logger.debug('Book stored locally successfully'))
      .inspectErr(_logger.warn)
      .mapErr((_) => 'Unable to store book locally');

  FutureResult<ExistingBook, String> _storeLocalBookWithIsar(NewBook book) async =>
      Future.value(Ok<NewBook, String>(book))
          .andThen(_parseNewBookToIsarModel)
          .andThen(_storeLocalBookIsarModel)
          .map((id) => ExistingBook(id: id, url: book.url))
          .inspectErr(_logger.warn);

  FutureResult<int, String> _storeLocalBookIsarModel(LocalBookIsarModel model) =>
      Future.value(Ok<LocalBookIsarModel, String>(model))
          .andThen(_isarDataSource.upsertBook)
          .inspectErr(_logger.warn)
          .mapErr((_) => 'Unable to store local book Isar model');

  Result<LocalBookIsarModel, String> _parseNewBookToIsarModel(NewBook book) => Ok<NewBook, String>(book)
      .andThen(_localBookIsarModelMapper.fromNewBook)
      .inspectErr(_logger.warn)
      .mapErr((_) => 'Unable to parse book to local Isar model');

  @override
  FutureResult<ExistingBook, String> retrieveBookById(int id) async => Future.value(Ok<int, String>(id))
      .inspect((_) => _logger.debug('Retrieving book by id...'))
      .andThen(_retrieveLocalBook)
      .inspect((_) => _logger.debug('Book retrieved successfully'))
      .inspectErr(_logger.warn)
      .mapErr((_) => 'Unable to retrieve book');

  FutureResult<ExistingBook, String> _retrieveLocalBook(int id) => Future.value(Ok<int, String>(id))
      .inspect((_) => _logger.debug('Retrieving local book by id...'))
      .andThen(_retrieveAndParseLocalIsarBook)
      .inspect((_) => _logger.debug('Local book retrieved successfully'))
      .inspectErr(_logger.warn)
      .mapErr((_) => 'Unable to retrieve local book');

  FutureResult<ExistingBook, String> _retrieveAndParseLocalIsarBook(int id) =>
      _retrieveLocalIsarBookById(id).andThen(_parseLocalIsarModelToExistingBook);

  Result<ExistingBook, String> _parseLocalIsarModelToExistingBook(LocalBookIsarModel model) =>
      Ok<LocalBookIsarModel, String>(model)
          .andThen(_localBookIsarModelMapper.toExistingBook)
          .inspectErr(_logger.warn)
          .mapErr((_) => 'Unable to parse Isar model');

  FutureResult<LocalBookIsarModel, String> _retrieveLocalIsarBookById(int id) =>
      Future.value(Ok<int, String>(id)).andThen(_isarDataSource.getBookById).inspectErr(_logger.warn);

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
      _isarDataSource.getAllBooks().inspectErr(_logger.warn);
}
