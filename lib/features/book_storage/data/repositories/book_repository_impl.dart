import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/book_isar_data_source.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/models/local_book_isar_model.dart';
import 'package:storyscape/features/book_storage/domain/entities/existing_book.dart';
import 'package:storyscape/features/book_storage/domain/entities/new_book.dart';
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
  Future<Result<ExistingBook, String>> storeNewBook(NewBook book) async => Future.value(Ok<NewBook, String>(book))
      .andThen(_localBookIsarModelMapper.fromNewBook)
      .andThen(_isarDataSource.upsertBook)
      .map((id) => ExistingBook(id: id, url: book.url))
      .inspectErr(_logger.warn);
}
