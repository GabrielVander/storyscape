import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/select_book/domain/entities/available_book.dart';
import 'package:storyscape/features/select_book/domain/usecases/retrieve_available_books.dart';

part 'book_selection_state.dart';

class BookSelectionCubit extends Cubit<BookSelectionState> {
  BookSelectionCubit({required RetrieveStoredBooks retrieveStoredBooks})
      : _retrieveStoredBooks = retrieveStoredBooks,
        super(BookSelectionInitial());

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final RetrieveStoredBooks _retrieveStoredBooks;

  Future<void> loadStoredBooks() async {
    emit(BookSelectionLoading());

    (await _retrieveStoredBooks())
        .inspect(_emitStoredBooksLoaded)
        .inspectErr(_logger.warn)
        .inspectErr(_emitStoredBooksLoadingError);
  }

  void _emitStoredBooksLoaded(List<AvailableBook> books) => emit(
        BookSelectionBooksLoaded(
          books: books.map((e) => BookSelectionViewModel(displayName: e.url)).toList(),
        ),
      );

  void _emitStoredBooksLoadingError(String error) =>
      emit(BookSelectionError(errorCode: BookSelectionErrorCode.unableToLoadStoredBooks.name, errorContext: error));
}

enum BookSelectionErrorCode { unableToSelectBookByUrl, unableToLoadStoredBooks }
