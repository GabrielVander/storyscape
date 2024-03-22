import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

part 'local_book_isar_model.g.dart';

@Collection(inheritance: false)
class LocalBookIsarModel with EquatableMixin {
  LocalBookIsarModel({
    required this.id,
    required this.url,
    required this.path,
    required this.title,
    required this.author,
  });

  final Id? id;
  final String? url;
  final String? path;
  final String? title;
  final String? author;

  @override
  @ignore
  List<Object?> get props => [id, url, path, title, author];
}
