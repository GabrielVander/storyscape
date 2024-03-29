import 'package:equatable/equatable.dart';

class AvailableBook with EquatableMixin {
  AvailableBook({required this.id, required this.title, required this.author});

  final int id;
  final String? title;
  final String? author;

  @override
  List<Object?> get props => [id, title, author];
}
