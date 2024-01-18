import 'package:storyscape/core/logging/impl/source_horizon_logger_impl.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';

abstract class StoryscapeLoggerFactory {
  static StoryscapeLogger generic() => SourceHorizonLoggerImpl();
}
