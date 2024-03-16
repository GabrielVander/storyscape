import 'dart:io';

class ParsedBook {
  ParsedBook({required this.url, required this.author, required this.title, required this.file});

  final String url;
  final String? author;
  final String? title;
  final File file;
}
