import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rust_core/result.dart';
import 'package:rust_core/typedefs.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/select_book/domain/entities/available_book.dart';
import 'package:storyscape/features/select_book/domain/usecases/check_available_books_change.dart';
import 'package:storyscape/features/select_book/domain/usecases/retrieve_available_books.dart';

part 'book_selection_state.dart';

class BookSelectionCubit extends Cubit<BookSelectionState> {
  BookSelectionCubit({
    required RetrieveStoredBooks retrieveStoredBooksUseCase,
    required CheckAvailableBooksChange checkAvailableBooksChangeUseCase,
  })  : _retrieveStoredBooksUseCase = retrieveStoredBooksUseCase,
        _checkAvailableBooksChangeUseCase = checkAvailableBooksChangeUseCase,
        super(BookSelectionInitial());

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final RetrieveStoredBooks _retrieveStoredBooksUseCase;
  final CheckAvailableBooksChange _checkAvailableBooksChangeUseCase;

  Future<void> loadStoredBooks() async => Future.value(const Ok(()))
      .inspect((_) => emit(BookSelectionLoading()))
      .andThen((_) => _retrieveStoredBooks())
      .andThen((_) => _listenToUpdates(_updateStoredBooks));

  Result<Stream<Unit>, String> _listenToUpdates(void Function() onUpdate) => const Ok<Unit, String>(())
      .andThen((_) => _checkAvailableBooksChangeUseCase())
      .inspect((stream) => stream.listen((_) => onUpdate()))
      .inspectErr(_logger.warn);

  FutureResult<Unit, String> _retrieveStoredBooks() async => Future.value(const Ok<Unit, String>(()))
      .andThen((_) => _retrieveStoredBooksUseCase())
      .inspect(_emitStoredBooksLoaded)
      .map((_) => ())
      .inspectErr(_logger.warn)
      .inspectErr(_emitStoredBooksLoadingError);

  FutureResult<Unit, String> _updateStoredBooks() async => Future.value(const Ok<Unit, String>(()))
      .andThen((_) => _retrieveStoredBooksUseCase())
      .inspect(_emitStoredBooksLoaded)
      .map((_) => ())
      .inspectErr(_logger.warn)
      .inspectErr((_) => emit(const BookSelectionUpdateError()));

  void _emitStoredBooksLoaded(List<AvailableBook> books) {
    final List<BookSelectionViewModel> viewModels =
        books.map((e) => BookSelectionViewModel(displayName: e.url)).toList();

    return emit(BookSelectionBooksLoaded(books: viewModels));
  }

  void _emitStoredBooksLoadingError(String error) {
    final String errorCode = BookSelectionErrorCode.unableToLoadStoredBooks.name;

    return emit(BookSelectionLoadingError(errorCode: errorCode, errorContext: error));
  }
}

enum BookSelectionErrorCode { unableToSelectBookByUrl, unableToLoadStoredBooks }
