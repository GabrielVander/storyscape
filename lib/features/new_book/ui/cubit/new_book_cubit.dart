import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/book_storage/domain/entities/existing_book.dart';
import 'package:storyscape/features/book_storage/domain/usecases/save_book_by_url.dart';

part 'new_book_state.dart';

class NewBookCubit extends Cubit<NewBookState> {
  NewBookCubit({required SaveBookByUrl saveBookByUrlUseCase})
      : _saveBookByUrlUseCase = saveBookByUrlUseCase,
        super(NewBookInitial());

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final SaveBookByUrl _saveBookByUrlUseCase;

  Future<void> addNewBookByUrl(String url) async {
    emit(NewBookLoading());

    _listenToDownloadProgress();

    await _saveBookByUrl(url).inspect((_) => emit(NewBookSaved())).inspectErr((_) => emit(NewBookError()));
  }

  FutureResult<ExistingBook, String> _saveBookByUrl(String url) async =>
      _saveBookByUrlUseCase.call(url).inspectErr(_logger.warn);

  StreamSubscription<double> _listenToDownloadProgress() =>
      _saveBookByUrlUseCase.downloadPercentage().listen(_onDownloadProgressUpdate);

  void _onDownloadProgressUpdate(double percentage) {
    final RegExp leadingZerosRegex = RegExp(r'\.?0*$');
    final String prettyPercentage = percentage.toStringAsFixed(2).replaceFirst(leadingZerosRegex, '');

    emit(NewBookDownloading(percentageDisplay: '$prettyPercentage%', percentageValue: percentage));
  }

  void reset() => emit(NewBookInitial());
}
