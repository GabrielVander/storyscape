part of 'book_reader_cubit.dart';

abstract class BookReaderState extends Equatable {
  const BookReaderState();
}

class BookReaderInitial extends BookReaderState {
  @override
  List<Object> get props => [];
}

class BookReaderLoading extends BookReaderState {
  @override
  List<Object> get props => [];
}

class BookReaderDownloading extends BookReaderState {
  const BookReaderDownloading({required this.percentageDisplay});

  final String percentageDisplay;

  @override
  List<Object> get props => [percentageDisplay];
}
