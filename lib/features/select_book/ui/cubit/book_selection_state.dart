part of 'book_selection_cubit.dart';

sealed class BookSelectionState extends Equatable {
  const BookSelectionState();
}

class BookSelectionInitial extends BookSelectionState {
  @override
  List<Object> get props => [];
}

class BookSelectionLoading extends BookSelectionState {
  @override
  List<Object> get props => [];
}

class BookSelectionLoadingError extends BookSelectionState {
  const BookSelectionLoadingError({required this.errorCode, required this.errorContext});

  final String errorCode;
  final String? errorContext;

  @override
  List<Object?> get props => [errorCode, errorContext];
}

class BookSelectionUpdateError extends BookSelectionState {
  const BookSelectionUpdateError();

  @override
  List<Object?> get props => [];
}

class BookSelectionSelected extends BookSelectionState {
  const BookSelectionSelected({required this.id});

  final int id;

  @override
  List<Object?> get props => [id];
}

class BookSelectionBooksLoaded extends BookSelectionState {
  const BookSelectionBooksLoaded({required this.books});

  final List<BookSelectionItemViewModel> books;

  @override
  List<Object?> get props => [books];
}

class BookSelectionItemViewModel with EquatableMixin {
  BookSelectionItemViewModel({required this.id, required this.title});

  final int? id;
  final String? title;

  @override
  List<Object?> get props => [id, title];

  BookSelectionItemViewModel copyWith({int? id, String? title}) => BookSelectionItemViewModel(
        id: id ?? this.id,
        title: title ?? this.title,
      );
}
