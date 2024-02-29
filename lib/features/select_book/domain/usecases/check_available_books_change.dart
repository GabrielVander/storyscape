import 'package:rust_core/result.dart';
import 'package:rust_core/typedefs.dart';
import 'package:storyscape/core/logging/storyscape_logger.dart';
import 'package:storyscape/core/logging/storyscape_logger_factory.dart';
import 'package:storyscape/features/select_book/domain/repositories/available_book_repository.dart';

abstract interface class CheckAvailableBooksChange {
  Result<Stream<Unit>, String> call();
}

class CheckAvailableBooksChangeImpl implements CheckAvailableBooksChange {
  CheckAvailableBooksChangeImpl({required AvailableBookRepository availableBookRepository})
      : _bookRepository = availableBookRepository;

  final StoryscapeLogger _logger = StoryscapeLoggerFactory.generic();
  final AvailableBookRepository _bookRepository;

  @override
  Result<Stream<Unit>, String> call() => const Ok('Checking for changes within available books...')
      .inspect(_logger.info)
      .andThen((_) => _onAvaliableBooksChange())
      .mapErr((_) => 'Unable to check for changes within available books');

  Result<Stream<Unit>, String> _onAvaliableBooksChange() =>
      _bookRepository.onAvaliableBooksChange().inspectErr(_logger.warn);
}
