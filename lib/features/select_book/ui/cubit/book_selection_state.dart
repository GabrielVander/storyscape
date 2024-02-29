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
  const BookSelectionSelected({required this.url});

  final String url;

  @override
  List<Object?> get props => [url];
}

class BookSelectionBooksLoaded extends BookSelectionState {
  const BookSelectionBooksLoaded({required this.books});

  final List<BookSelectionViewModel> books;

  @override
  List<Object?> get props => [books];
}

class BookSelectionViewModel with EquatableMixin {
  BookSelectionViewModel({required this.id, required this.displayName});

  final int id;
  final String displayName;

  @override
  List<Object> get props => [id, displayName];

  @override
  String toString() => 'BookSelectionViewModel{id: $id, displayName: $displayName}';

  BookSelectionViewModel copyWith({
    int? id,
    String? displayName,
  }) =>
      BookSelectionViewModel(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
      );
}
