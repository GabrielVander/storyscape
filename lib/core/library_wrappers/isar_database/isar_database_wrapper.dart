import 'package:isar/isar.dart' as isar;

typedef IsarId = isar.Id;

abstract interface class IsarDatabaseWrapper {
  Future<IsarDatabaseInstance> init({
    required List<isar.CollectionSchema<dynamic>> schemas,
    required String databaseLocation,
  });
}

abstract interface class IsarDatabaseInstance {
  IsarCollection<T> getCollection<T>();

  Future<T> performWriteTransaction<T>(Future<T> Function() callback, {bool silent = false});
}

abstract interface class IsarCollection<T> {
  Future<IsarId> put(T object);

  Future<List<IsarId>> putAll(List<T> objects);
}
