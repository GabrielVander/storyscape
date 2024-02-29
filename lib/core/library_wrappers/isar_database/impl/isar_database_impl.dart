import 'package:isar/isar.dart' as isar;
import 'package:storyscape/core/library_wrappers/isar_database/impl/isar_database_instance_impl.dart';
import 'package:storyscape/core/library_wrappers/isar_database/isar_database_wrapper.dart';

class IsarDatabaseImpl implements IsarDatabaseWrapper {
  IsarDatabaseImpl({
    required IsarInitializer isarInitializer,
  }) : _isarInitializer = isarInitializer;

  final IsarInitializer _isarInitializer;

  @override
  Future<IsarDatabaseInstance> init({
    required List<isar.CollectionSchema<dynamic>> schemas,
    required String databaseLocation,
  }) async {
    final isar.Isar isarInstance = await _isarInitializer(schemas, directory: databaseLocation);

    return IsarDatabaseInstanceImpl(isar: isarInstance);
  }
}

typedef IsarInitializer = Future<isar.Isar> Function(
  List<isar.CollectionSchema<dynamic>> schemas, {
  required String directory,
});
