import 'dart:io';

import 'package:equatable/equatable.dart';

class BookFile with EquatableMixin {
  BookFile({required this.id, required this.value});

  final int id;
  final File value;

  @override
  List<Object?> get props => [id, value];
}
