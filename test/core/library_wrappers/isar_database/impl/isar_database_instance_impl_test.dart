import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart' as isar show Isar, IsarCollection;
import 'package:mocktail/mocktail.dart';
import 'package:storyscape/core/library_wrappers/isar_database/impl/isar_collection_impl.dart';
import 'package:storyscape/core/library_wrappers/isar_database/impl/isar_database_instance_impl.dart';
import 'package:storyscape/core/library_wrappers/isar_database/isar_database_wrapper.dart';

void main() {
  late isar.Isar isarDb;
  late IsarDatabaseInstance isarDatabaseInstance;

  setUp(() {
    isarDb = _MockIsar();
    isarDatabaseInstance = IsarDatabaseInstanceImpl(isar: isarDb);
  });

  test('should return expected collection when fecthing collection', () {
    final _MockCollection<void> collection = _MockCollection<void>();

    when(() => isarDb.collection<void>()).thenReturn(collection);

    final IsarCollection<void> result = isarDatabaseInstance.getCollection<void>();

    expect(result, IsarCollectionImpl<void>(collection: collection));
  });

  test('should execute given callback within an Isar transaction when performing a write transaction', () async {
    final _DummyCallback<String> callback = _MockDummyCallback();

    when(callback.call).thenAnswer((_) async => 'XUchjQ1nq');
    when(() => isarDb.writeTxn(any<Future<String> Function()>(), silent: any(named: 'silent')))
        .thenAnswer((_) async => 'qFDEBY4mp');

    final String result = await isarDatabaseInstance.performWriteTransaction<String>(callback.call);

    expect(result, 'qFDEBY4mp');
    verify(() => isarDb.writeTxn(callback.call)).called(1);
  });
}

class _MockIsar extends Mock implements isar.Isar {}

class _MockCollection<T> extends Mock implements isar.IsarCollection<T> {}

abstract interface class _DummyCallback<T> {
  Future<T> call();
}

class _MockDummyCallback extends Mock implements _DummyCallback<String> {}
