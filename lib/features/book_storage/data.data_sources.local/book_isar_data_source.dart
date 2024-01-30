import 'dart:async';

import 'package:isar/isar.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/book_storage/data.data_sources.local/models/local_book_isar_model.dart';

abstract interface class BookIsarDataSource {
  Future<Result<int, String>> upsertBook(LocalBookIsarModel model);
}

class BookIsarDataSourceImpl implements BookIsarDataSource {
  BookIsarDataSourceImpl({required Isar isar}) : _isar = isar;

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final Isar _isar;

  @override
  Future<Result<int, String>> upsertBook(LocalBookIsarModel model) async {
    _logger.debug('Upserting local book...');

    return putBookInCollection(model).mapErr((error) => 'Unable to perform upsert operation');
  }

  Future<Result<int, Exception>> putBookInCollection(LocalBookIsarModel model) async {
    try {
      return Ok(await _isar.collection<LocalBookIsarModel>().put(model));
    } on Exception catch (e, stack) {
      _logger.error('Unable to perform upsert operation', error: e, stackTrace: stack);

      return Err(e);
    }
  }
}
