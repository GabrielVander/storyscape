import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:internet_file/internet_file.dart';
import 'package:internet_file/storage_io.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';

typedef InternetFileGet = Future<Uint8List> Function(
  String url, {
  InternetFileProgress? progress,
  InternetFileStorage? storage,
  InternetFileStorageAdditional storageAdditional,
});

class InternetFileDataSource {
  InternetFileDataSource({required Directory targetDirectory, required InternetFileGet internetFileGet})
      : _targetDirectory = targetDirectory,
        _internetFileGet = internetFileGet;

  // final StreamController<double> _progressPercentage = StreamController();
  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final Directory _targetDirectory;
  final InternetFileGet _internetFileGet;

  FutureResult<FileDownloadResult, String> downloadFile(FileInput input) =>
      Future.value(Ok<FileInput, (Exception, StackTrace)>(input))
          .map(_toOperation)
          .andThen(_performDownloadOperation)
          .map((bytes) => _toResult(bytes, input))
          .inspectErr((err) => _logger.error(err.$1.toString(), error: err.$1, stackTrace: err.$2))
          .mapErr((_) => 'Unable to download file');

  _DownloadOperation _toOperation(FileInput input) => _DownloadOperation(
        url: input.url,
        fileName: input.fileName,
        targetBasePath: _targetDirectory.path,
        progress: input.progress,
        storageIO: _buildStorageIO(),
      );

  FileDownloadResult _toResult(Uint8List bytes, FileInput input) => FileDownloadResult(
        url: input.url,
        fileName: input.fileName,
        file: File('${_targetDirectory.path}/${input.fileName}'),
      );

  FutureResult<Uint8List, (Exception, StackTrace)> _performDownloadOperation(_DownloadOperation op) async {
    try {
      return Ok(
        await _internetFileGet(
          op.url,
          progress: op.progress,
          storage: op.storageIO,
          storageAdditional: op.storageAdditional,
        ),
      );
    } on Exception catch (e, stack) {
      return Err((e, stack));
    }
  }

  InternetFileStorageIO _buildStorageIO() => InternetFileStorageIO();
}

class FileInput {
  FileInput({required this.url, required this.fileName, required this.progress});

  final String url;
  final String fileName;
  final void Function(int receivedLength, int contentLength)? progress;
}

class FileDownloadResult {
  FileDownloadResult({required this.url, required this.fileName, required this.file});

  final String url;
  final String fileName;
  final File file;
}

class _DownloadOperation {
  _DownloadOperation({
    required this.url,
    required this.fileName,
    required this.targetBasePath,
    required this.storageIO,
    this.progress,
  }) : storageAdditional = storageIO.additional(filename: fileName, location: targetBasePath);

  final String url;
  final String fileName;
  final String targetBasePath;
  final InternetFileStorageIO storageIO;
  final void Function(int receivedLength, int contentLength)? progress;
  final Map<String, Object> storageAdditional;
}
