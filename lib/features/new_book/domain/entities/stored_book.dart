import 'package:equatable/equatable.dart';

class StoredBook with EquatableMixin {
  StoredBook({required this.url});

  final String url;

  @override
  List<Object?> get props => [url];
}
