import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

@collection
class LocalBookIsarModel extends Equatable {
  const LocalBookIsarModel({required this.id, required this.url});

  final Id? id;
  final String url;

  @override
  List<Object?> get props => [id, url];
}
