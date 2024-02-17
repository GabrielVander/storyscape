import 'dart:async';

import 'package:isar/isar.dart';
import 'package:rust_core/result.dart';
import 'package:rust_core/typedefs.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/new_book/data/data_sources/local/models/local_book_isar_model.dart';

abstract interface class BookIsarDataSource {
  Future<Result<int, String>> upsertBook(LocalBookIsarModel model);

  Future<Result<LocalBookIsarModel, String>> getBookById(Id id);

  Future<Result<List<LocalBookIsarModel>, String>> getAllBooks();
}

class BookIsarDataSourceImpl implements BookIsarDataSource {
  BookIsarDataSourceImpl({required Isar isar}) : _isar = isar;

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final Isar _isar;

  @override
  Future<Result<int, String>> upsertBook(LocalBookIsarModel model) async {
    _logger.debug('Upserting local book...');

    return _putBookInCollection(model).inspect((ok) => _logger.debug('Book upserted correctly'));
  }

  Future<Result<Id, Infallible>> _putBookInCollection(LocalBookIsarModel model) async =>
      Future.value(Ok<LocalBookIsarModel, Infallible>(model)).andThen(_putBookOnIsarLocalBookCollection);

  Future<Result<Id, Infallible>> _putBookOnIsarLocalBookCollection(LocalBookIsarModel book) async =>
      Ok(await _isar.writeTxn(() async => _isar.collection<LocalBookIsarModel>().put(book)));

  @override
  Future<Result<LocalBookIsarModel, String>> getBookById(Id id) {
    // TODO: implement getBookById
    throw UnimplementedError();
  }

  @override
  Future<Result<List<LocalBookIsarModel>, String>> getAllBooks() async {
    _logger.debug('Getting all books from Isar...');

    return Ok<List<LocalBookIsarModel>, String>(await _isar.collection<LocalBookIsarModel>().where().findAll())
        .inspect((models) => _logger.debug('Found ${models.length} models'));
  }
}
