import 'package:isar/isar.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/book_storage/domain/entities/new_book.dart';

@collection
class LocalBookIsarModel {
  const LocalBookIsarModel({required this.id, required this.url});

  final Id? id;
  final String url;
}

abstract interface class LocalBookIsarModelMapper {
  Result<LocalBookIsarModel, String> call(NewBook book);
}
