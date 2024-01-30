import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart' as isar;
import 'package:mocktail/mocktail.dart';
import 'package:storyscape/core/library_wrappers/isar_database/impl/isar_collection_impl.dart';
import 'package:storyscape/core/library_wrappers/isar_database/isar_database_wrapper.dart';

void main() {
  late isar.IsarCollection<String> isarCollection;
  late IsarCollection<String> collection;

  setUp(() {
    isarCollection = _MockIsarCollection();
    collection = IsarCollectionImpl(collection: isarCollection);
  });

  tearDown(resetMocktailState);

  test('should delegate operation to Isar collection when inserting an item', () async {
    when(() => isarCollection.put(any())).thenAnswer((_) async => 771);

    final IsarId result = await collection.put('C3XIa7f');

    expect(result, 771);
    verify(() => isarCollection.put('C3XIa7f')).called(1);
  });

  test('should delegate operation to Isar collection when inserting multiple items', () async {
    when(() => isarCollection.putAll(any())).thenAnswer((_) async => [978, 139, 767]);

    final List<IsarId> result = await collection.putAll(['BviETv8', 'n9PCbHVU5', 'stcXfDQS']);

    expect(result, [978, 139, 767]);
    verify(() => isarCollection.putAll(['BviETv8', 'n9PCbHVU5', 'stcXfDQS'])).called(1);
  });
}

class _MockIsarCollection extends Mock implements isar.IsarCollection<String> {}
