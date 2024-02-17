import 'package:equatable/equatable.dart';

class AvailableBook with EquatableMixin {
  AvailableBook({required this.url});

  final String url;

  @override
  List<Object?> get props => [url];
}
