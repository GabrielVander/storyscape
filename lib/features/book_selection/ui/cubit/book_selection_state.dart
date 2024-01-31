part of 'book_selection_cubit.dart';

abstract class BookSelectionState extends Equatable {
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

class BookSelectionError extends BookSelectionState {
  const BookSelectionError({required this.errorCode, required this.errorContext});

  final String errorCode;
  final String? errorContext;

  @override
  List<Object?> get props => [errorCode, errorContext];
}

class BookSelectionSelected extends BookSelectionState {
  const BookSelectionSelected({required this.url});

  final String url;

  @override
  List<Object?> get props => [url];
}
