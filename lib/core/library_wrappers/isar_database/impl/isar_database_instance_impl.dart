import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart' as isar show Isar, IsarCollection;
import 'package:storyscape/core/library_wrappers/isar_database/impl/isar_collection_impl.dart';
import 'package:storyscape/core/library_wrappers/isar_database/isar_database_wrapper.dart';

class IsarDatabaseInstanceImpl with EquatableMixin implements IsarDatabaseInstance {
  IsarDatabaseInstanceImpl({required isar.Isar isar}) : _isar = isar;

  final isar.Isar _isar;

  @override
  IsarCollection<T> getCollection<T>() {
    final isar.IsarCollection<T> collection = _isar.collection<T>();

    return IsarCollectionImpl(collection: collection);
  }

  @override
  Future<T> performWriteTransaction<T>(Future<T> Function() callback, {bool silent = false}) async {
    return _isar.writeTxn(callback, silent: silent);
  }

  @override
  List<Object?> get props => [_isar];
}
