import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/models/local_book_isar_model.dart';
import 'package:storyscape/features/book_storage/domain/entities/existing_book.dart';
import 'package:storyscape/features/book_storage/domain/entities/parsed_book.dart';
import 'package:storyscape/features/book_storage/domain/repositories/existing_book_repository.dart';

class ExistingBookRepositoryImpl implements ExistingBookRepository {
  ExistingBookRepositoryImpl({
    required BookIsarDataSource isarDataSource,
  }) : _isarDataSource = isarDataSource;

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final BookIsarDataSource _isarDataSource;

  @override
  FutureResult<ExistingBook, String> storeDownloadedBook(ParsedBook book) => Future.value(Ok<ParsedBook, String>(book))
      .inspect((_) => _logger.debug('Storing downloaded book...'))
      .andThen(_storeBookLocally)
      .inspect((_) => _logger.debug('Book stored successfully'))
      .inspectErr(_logger.warn)
      .mapErr((_) => 'Unable to store new book');

  FutureResult<ExistingBook, String> _storeBookLocally(ParsedBook book) => Future.value(Ok<ParsedBook, String>(book))
      .map(_toIsarModel)
      .andThen(_storeLocalBookIsarModel)
      .map((_) => ExistingBook(id: _, file: book.file))
      .inspectErr(_logger.warn);

  FutureResult<int, String> _storeLocalBookIsarModel(LocalBookIsarModel model) =>
      _isarDataSource.upsertBook(model).inspectErr(_logger.warn);

  LocalBookIsarModel _toIsarModel(ParsedBook book) =>
      LocalBookIsarModel(id: null, path: book.file.path, url: book.url, title: book.title, author: book.author);
}
