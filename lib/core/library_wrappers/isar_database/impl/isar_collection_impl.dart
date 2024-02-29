import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart' as isar show IsarCollection;
import 'package:storyscape/core/library_wrappers/isar_database/isar_database_wrapper.dart';

class IsarCollectionImpl<T> with EquatableMixin implements IsarCollection<T> {
  IsarCollectionImpl({required isar.IsarCollection<T> collection}) : _collection = collection;

  final isar.IsarCollection<T> _collection;

  @override
  Future<IsarId> put(T object) async {
    return _collection.put(object);
  }

  @override
  Future<List<IsarId>> putAll(List<T> objects) {
    return _collection.putAll(objects);
  }

  @override
  List<Object?> get props => [_collection];
}
