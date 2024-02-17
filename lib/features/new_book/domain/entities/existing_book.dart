import 'package:equatable/equatable.dart';

class ExistingBook extends Equatable {
  const ExistingBook({required this.id, required this.url});

  final int id;
  final String url;

  @override
  List<Object> get props => [id, url];
}
