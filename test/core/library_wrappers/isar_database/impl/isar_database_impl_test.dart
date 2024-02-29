import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart' as isar;
import 'package:mocktail/mocktail.dart';
import 'package:storyscape/core/library_wrappers/isar_database/impl/isar_database_impl.dart';
import 'package:storyscape/core/library_wrappers/isar_database/impl/isar_database_instance_impl.dart';
import 'package:storyscape/core/library_wrappers/isar_database/isar_database_wrapper.dart';

void main() {
  test('init should return expected instance', () async {
    final isar.Isar isarInstance = _MockIsar();
    final IsarInitializer initializer = _DummyIsarInitializer(isarInstance).call;

    final IsarDatabaseInstance result = await IsarDatabaseImpl(isarInitializer: initializer)
        .init(schemas: [_MockCollectionSchema(), _MockCollectionSchema()], databaseLocation: '');

    expect(result, IsarDatabaseInstanceImpl(isar: isarInstance));
  });
}

class _MockIsar extends Mock implements isar.Isar {}

class _DummyIsarInitializer extends Mock {
  _DummyIsarInitializer(this.isarMock);

  final isar.Isar isarMock;

  Future<isar.Isar> call(
    List<isar.CollectionSchema<dynamic>> schemas, {
    required String directory,
  }) async =>
      isarMock;
}

class _MockCollectionSchema extends Mock implements isar.CollectionSchema<void> {}
