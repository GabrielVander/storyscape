import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/read_book/domain/entities/book_file.dart';
import 'package:storyscape/features/read_book/domain/usecases/retrieve_book_file_by_id.dart';

part 'book_reader_state.dart';

class BookReaderCubit extends Cubit<BookReaderState> {
  BookReaderCubit({required RetrieveBookFileById retrieveBookFileByIdUseCase})
      : _retrieveBookFileByIdUseCase = retrieveBookFileByIdUseCase,
        super(BookReaderInitial());

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final RetrieveBookFileById _retrieveBookFileByIdUseCase;

  Future<void> open(int id) async {
    emit(BookReaderLoading());

    (await retrieveBookFileById(id))
        .inspect((_) => emit(BookReaderFinished(file: _.value)))
        .inspectErr((_) => emit(BookReaderError(errorCode: BookReaderErrorCodes.generic.value, context: _)));
  }

  FutureResult<BookFile, String> retrieveBookFileById(int id) async =>
      _retrieveBookFileByIdUseCase.call(id).inspectErr(_logger.warn);
}

enum BookReaderErrorCodes {
  generic('genericErrorMessage');

  const BookReaderErrorCodes(this.value);

  final String value;
}

typedef DownloadProgressUpdater = void Function(double percentage);
typedef NetworkFileRetriever = Future<Uint8List> Function(String link, DownloadProgressUpdater progressUpdater);
