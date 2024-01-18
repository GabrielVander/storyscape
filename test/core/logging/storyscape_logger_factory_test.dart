import 'package:flutter_test/flutter_test.dart';
import 'package:storyscape/core/logging/impl/source_horizon_logger_impl.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';

void main() {
  test('generic should return SourceHorizonLoggerImpl', () {
    expect(StoryscapeLoggerFactory.generic(), SourceHorizonLoggerImpl());
  });
}
