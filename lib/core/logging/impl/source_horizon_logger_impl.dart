import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';

class SourceHorizonLoggerImpl extends Equatable implements StoryscapeLogger {
  final Logger _logger = Logger(
    filter: _DynamicFilter(),
    level: Level.all,
    printer: HybridPrinter(
      _SimplePrinterWithFullPrefixesAndFullColor(),
      error: PrettyPrinter(
        printTime: true,
        methodCount: null,
        errorMethodCount: null,
        excludePaths: <String>['package:storyscape/core/logging/impl/source_horizon_logger_impl.dart'],
      ),
    ),
  );

  @override
  void debug(String message) => _logger.d(message, time: DateTime.now());

  @override
  void error(String message, {Exception? error, StackTrace? stackTrace}) =>
      _logger.e(message, time: DateTime.now(), error: error, stackTrace: stackTrace);

  @override
  void info(String message) => _logger.i(message, time: DateTime.now());

  @override
  void trace(String message) => _logger.t(message, time: DateTime.now());

  @override
  void warn(String message) => _logger.w(message, time: DateTime.now());

  @override
  List<Object?> get props => <Object?>[];
}

class _DynamicFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    final Level logLevel = getMinimumLogLevel();

    return event.level.value >= logLevel.value;
  }

  Level getMinimumLogLevel() {
    final int value = _getMinimumLogLevelUpToInfo();

    return kReleaseMode ? Level.values.firstWhere((Level element) => element.value == value) : level!;
  }

  int _getMinimumLogLevelUpToInfo() => min(level!.value, Level.info.value);
}

class _SimplePrinterWithFullPrefixesAndFullColor extends LogPrinter {
  _SimplePrinterWithFullPrefixesAndFullColor({bool printTime = true, bool colors = true})
      : _printTime = printTime,
        _colors = colors;

  static final Map<Level, String> levelPrefixes = <Level, String>{
    Level.trace: '[TRACE]',
    Level.debug: '[DEBUG]',
    Level.info: '[INFO]',
    Level.warning: '[WARNING]',
    Level.error: '[ERROR]',
    Level.fatal: '[FATAL]',
  };

  static final Map<Level, AnsiColor> levelColors = <Level, AnsiColor>{
    Level.trace: AnsiColor.fg(AnsiColor.grey(0.5)),
    Level.debug: const AnsiColor.none(),
    Level.info: const AnsiColor.fg(12),
    Level.warning: const AnsiColor.fg(208),
    Level.error: const AnsiColor.fg(196),
    Level.fatal: const AnsiColor.fg(199),
  };
  final bool _printTime;

  final bool _colors;

  @override
  List<String> log(LogEvent event) {
    final String messageStr = _stringifyMessage(event.message);
    final String errorStr = event.error != null ? '  ERROR: ${event.error}' : '';
    final String timeStr = _printTime ? event.time.toIso8601String() : '';
    return <String>['$timeStr ${_getMessageParser(event.level)("${_prefixFor(event.level)} $messageStr$errorStr")}'];
  }

  String Function(String) _getMessageParser(Level level) => _colors ? _colorFor(level).call : (String msg) => msg;

  String _prefixFor(Level level) => levelPrefixes[level]!;

  AnsiColor _colorFor(Level level) => levelColors[level]!;

  String _stringifyMessage(dynamic message) {
    // ignore: avoid_dynamic_calls
    final dynamic finalMessage = message is Function ? message() : message;

    if (finalMessage is Map || finalMessage is Iterable) {
      const JsonEncoder encoder = JsonEncoder.withIndent(null);

      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }
}
