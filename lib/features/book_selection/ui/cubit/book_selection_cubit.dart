import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rust_core/result.dart';
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
}

enum BookSelectionErrorCode { unableToSelectBookByUrl }
