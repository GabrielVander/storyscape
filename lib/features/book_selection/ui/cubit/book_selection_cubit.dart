import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/book_selection/domain/entities/stored_book.dart';
import 'package:storyscape/features/book_storage/domain/entities/new_book.dart';
import 'package:storyscape/features/book_storage/domain/use_cases/store_new_book.dart';

part 'book_selection_state.dart';

class BookSelectionCubit extends Cubit<BookSelectionState> {
  BookSelectionCubit({required StoreNewBook storeNewBookUseCase})
      : _storeNewBookUseCase = storeNewBookUseCase,
        super(BookSelectionInitial());

  final StoreNewBook _storeNewBookUseCase;

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

  Future<void> fetchStoredBooks() async {
    emit(BookSelectionLoading());
    emit(
      BookSelectionBooksLoaded(
        books: [
          StoredBook(url: 'c68e4cca-a833-4669-ba86-893948b4d918'),
          StoredBook(url: 'c5a7aa38-01c3-414d-943d-3fcff3e94c8e'),
          StoredBook(url: '276ceb47-a69d-42da-b971-ae26777e7698'),
        ],
      ),
    );
  }
}

enum BookSelectionErrorCode { unableToSelectBookByUrl }
