import 'package:isar/isar.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/book_storage/domain/entities/existing_book.dart';
import 'package:storyscape/features/book_storage/domain/entities/new_book.dart';

part 'local_book_isar_model.g.dart';

@collection
class LocalBookIsarModel {
  const LocalBookIsarModel({required this.id, required this.url});

  final Id? id;
  final String url;
}

abstract interface class LocalBookIsarModelMapper {
  Result<LocalBookIsarModel, String> fromNewBook(NewBook book);

  Result<ExistingBook, String> toExistingBook(LocalBookIsarModel model);
}

class LocalBookIsarModelMapperImpl implements LocalBookIsarModelMapper {
  @override
  Result<LocalBookIsarModel, String> fromNewBook(NewBook book) =>
      Ok<NewBook, String>(book).map((b) => LocalBookIsarModel(id: null, url: b.url));

  @override
  Result<ExistingBook, String> toExistingBook(LocalBookIsarModel model) {
    // TODO: implement toExistingBook
    throw UnimplementedError();
  }
}
