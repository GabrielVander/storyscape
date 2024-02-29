part of 'new_book_cubit.dart';

sealed class NewBookState extends Equatable {
  const NewBookState();
}

class NewBookInitial extends NewBookState {
  @override
  List<Object> get props => [];
}

class NewBookLoading extends NewBookState {
  @override
  List<Object> get props => [];
}

class NewBookError extends NewBookState {
  @override
  List<Object> get props => [];
}

class NewBookSaved extends NewBookState {
  @override
  List<Object> get props => [];
}

class NewBookDownloading extends NewBookState {
  const NewBookDownloading({required this.percentageDisplay, required this.percentageValue});

  final String percentageDisplay;

  final double percentageValue;

  @override
  List<Object> get props => [percentageDisplay, percentageValue];
}
