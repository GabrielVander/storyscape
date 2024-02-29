import 'package:equatable/equatable.dart';

class NewBook extends Equatable {
  const NewBook({required this.title, required this.url});

  final String? url;
  final String? title;

  @override
  List<Object?> get props => [title, url];
}
