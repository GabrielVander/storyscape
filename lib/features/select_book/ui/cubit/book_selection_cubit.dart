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
  late List<AvailableBook> _books;

  Future<void> loadStoredBooks() async => Future.value(const Ok(()))
      .inspect((_) => emit(BookSelectionLoading()))
      .andThen((_) => _loadBooks())
      .andThen((_) => _listenToUpdates(_updateBooks));

  FutureResult<Unit, String> _loadBooks() => Future.value(const Ok<Unit, String>(()))
      .andThen((_) => _displayBooks())
      .inspectErr(_emitLoadingError)
      .inspectErr(_logger.warn);

  void _emitLoadingError(String error) {
    return emit(
      BookSelectionLoadingError(
        errorCode: BookSelectionErrorCode.unableToLoadStoredBooks.name,
        errorContext: error,
      ),
    );
  }

  Result<Stream<Unit>, String> _listenToUpdates(void Function() onUpdate) => const Ok<Unit, String>(())
      .andThen((_) => _checkAvailableBooksChangeUseCase())
      .inspect((stream) => stream.listen((_) => onUpdate()))
      .inspectErr(_logger.warn);

  FutureResult<Unit, String> _updateBooks() =>
      _displayBooks().inspectErr((_) => emit(const BookSelectionUpdateError()));

  FutureResult<Unit, String> _displayBooks() async => Future.value(const Ok<Unit, String>(()))
      .andThen((_) => _retrieveAvailableBooks())
      .inspect((books) => emit(BookSelectionBooksLoaded(books: books)))
      .map((_) => ());

  FutureResult<List<BookSelectionItemViewModel>, String> _retrieveAvailableBooks() => _retrieveStoredBooksUseCase()
      .inspect((books) => _books = books)
      .map((books) => books.map(_toItemVIewModel).toList())
      .inspectErr(_logger.warn);

  BookSelectionItemViewModel _toItemVIewModel(AvailableBook book) => BookSelectionItemViewModel(
        id: book.id,
        title: book.title,
      );

  Future<void> open(BookSelectionItemViewModel book) async {
    emit(BookSelectionLoading());

    _retrieveSelectedBook(book)
        .inspect((_) => emit(BookSelectionSelected(url: _.title!)))
        .inspectErr(
          (_) => emit(
            BookSelectionLoadingError(
              errorCode: BookSelectionErrorCode.unableToSelectBookByUrl.name,
              errorContext: null,
            ),
          ),
        )
        .inspect((_) => emit(BookSelectionInitial()));
  }

  Ok<AvailableBook, Object> _retrieveSelectedBook(BookSelectionItemViewModel book) {
    return _books.firstWhere((e) => e.id == book.id).toOk();
  }
}

enum BookSelectionErrorCode { unableToSelectBookByUrl, unableToLoadStoredBooks }
