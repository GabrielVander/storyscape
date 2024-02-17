import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/new_book/domain/entities/new_book.dart';
import 'package:storyscape/features/new_book/domain/use_cases/store_new_book.dart';
import 'package:storyscape/features/select_book/domain/entities/available_book.dart';
import 'package:storyscape/features/select_book/domain/use_cases/retrieve_available_books.dart';

part 'book_selection_state.dart';

class BookSelectionCubit extends Cubit<BookSelectionState> {
  BookSelectionCubit({required StoreNewBook storeNewBookUseCase, required RetrieveStoredBooks retrieveStoredBooks})
      : _storeNewBookUseCase = storeNewBookUseCase,
        _retrieveStoredBooks = retrieveStoredBooks,
        super(BookSelectionInitial());

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final StoreNewBook _storeNewBookUseCase;
  final RetrieveStoredBooks _retrieveStoredBooks;

  Future<void> selectBookUrl(String url) async {
    emit(BookSelectionLoading());

    await _storeNewBookUseCase
        .execute(NewBook(url: url))
        .map((book) => BookSelectionSelected(url: book.url))
        .mapErr(
          (error) => BookSelectionError(
            errorCode: BookSelectionErrorCode.unableToSelectBookByUrl.name,
            errorContext: error,
          ),
        )
        .inspect(emit)
        .inspectErr(emit);
  }

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
