import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:internet_file/internet_file.dart';

abstract interface class BookDownloader {
  Future<Uint8List> call(String url);

  Stream<double> progress();
}

class InternetFileBookDownloader implements BookDownloader {
  final StreamController<double> _progressPercentage = StreamController();

  @override
  Future<Uint8List> call(String url) {
    return InternetFile.get(
      url,
      progress: (receivedLength, contentLength) {
        final double progressPercentage = receivedLength / contentLength * 100;

        return _progressPercentage.add(progressPercentage);
      },
    );
  }

  @override
  Stream<double> progress() => _progressPercentage.stream;
}
