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
  const BookReaderDownloading({required this.percentageDisplay, required this.percentageValue});

  final String percentageDisplay;
  final double percentageValue;

  @override
  List<Object> get props => [percentageDisplay, percentageValue];
}

class BookReaderError extends BookReaderState {
  const BookReaderError({required this.errorCode, required this.context});

  final String errorCode;
  final String context;

  @override
  List<Object> get props => [errorCode, context];
}

class BookReaderFinished extends BookReaderState {
  const BookReaderFinished({required this.file});

  final File file;

  @override
  List<Object> get props => [file];
}
