import 'package:equatable/equatable.dart';

class NewBook extends Equatable {
  const NewBook({required this.url});

  final String? url;

  @override
  List<Object?> get props => [url];
}
