import 'dart:io';

import 'package:equatable/equatable.dart';

class ExistingBook with EquatableMixin {
  const ExistingBook({required this.id, required this.file});

  final int id;
  final File file;

  @override
  List<Object?> get props => [id, file];
}
