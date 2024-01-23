import 'package:flutter_test/flutter_test.dart';
import 'package:storyscape/core/logging/impl/source_horizon_logger_impl.dart';

void main() {
  late SourceHorizonLoggerImpl logger;

  setUp(() => logger = SourceHorizonLoggerImpl());

  test('error without additional info', () => logger.error('0tABfmT'));

  test('error with only exception', () => logger.error('s8x42Tkb', error: Exception('41oXROPjvm')));

  test('error with only stacktrace', () => logger.error('AlyTyfz', stackTrace: StackTrace.current));

  test(
    'error with both exception and stacktrace',
    () => logger.error('95y9rf0', error: Exception('ot45UKOWhKI'), stackTrace: StackTrace.current),
  );

  test('warn', () => logger.warn('xJY7pSDgp'));

  test('info', () => logger.info('wRFN2Zwy'));

  test('debug', () => logger.debug('iIQrIaC'));

  test('trace', () => logger.trace('t08HjGb'));
}
