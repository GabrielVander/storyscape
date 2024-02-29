import 'package:flutter_test/flutter_test.dart';
import 'package:rust_core/src/result/result.dart';
import 'package:storyscape/features/book_storage/data/data_sources/local/models/local_book_isar_model.dart';
import 'package:storyscape/features/new_book/domain/entities/new_book.dart';

void main() {
  test('should map from new book as expected', () {
    final Result<LocalBookIsarModel, String> result =
        LocalBookIsarModelMapperImpl().fromNewBook(const NewBook(title: 'H231OT5A', url: 'esnzEC5T8p'));

    expect(result, isA<Ok<LocalBookIsarModel, String>>());
    expect(
      result,
      isA<Ok<LocalBookIsarModel, String>>()
          .having((r) => r.ok.id, 'id', null)
          .having((r) => r.ok.url, 'url', 'esnzEC5T8p'),
    );
  });
}
