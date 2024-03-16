import 'package:isar/isar.dart';

part 'local_book_isar_model.g.dart';

@collection
class LocalBookIsarModel {
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
}
