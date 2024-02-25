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
  BookSelectionViewModel({required this.displayName});

  final String displayName;

  BookSelectionViewModel copyWith({String? displayName}) =>
      BookSelectionViewModel(displayName: displayName ?? this.displayName);

  @override
  List<Object> get props => [displayName];

  @override
  String toString() => 'BookSelectionViewModel{displayName: $displayName}';
}
