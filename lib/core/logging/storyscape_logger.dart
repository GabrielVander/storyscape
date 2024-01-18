abstract interface class StoryscapeLogger {
  void error(String message, {Exception? error, StackTrace? stackTrace});

  void warn(String message);

  void info(String message);

  void debug(String message);

  void trace(String message);
}
