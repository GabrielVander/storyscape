import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rust_core/result.dart';
import 'package:storyscape/features/book_storage/domain/entities/existing_book.dart';
import 'package:storyscape/features/book_storage/domain/entities/parsed_book.dart';
import 'package:storyscape/features/book_storage/domain/repositories/downloaded_book_repository.dart';
import 'package:storyscape/features/book_storage/domain/repositories/existing_book_repository.dart';
import 'package:storyscape/features/book_storage/domain/usecases/save_book_by_url.dart';

void main() {
  late ExistingBookRepository existingBookRepository;
  late DownloadedBookRepository downloadedBookRepository;
  late SaveBookByUrl useCase;

  setUp(() {
    existingBookRepository = _MockBookRepository();
    downloadedBookRepository = _MockDownloadedBookRepository();

    useCase = SaveBookByUrl(
      downloadedBookRepository: downloadedBookRepository,
      existingBookRepository: existingBookRepository,
    );

    // registerFallbackValue(_MockNewBook());
  });

  test('should return Err if unable to download book', () async {
    const String url = '746xcrzE822';

    when(() => downloadedBookRepository.downloadAndParseBookByUrl(url, any()))
        .thenAnswer((_) async => const Err('r06y2gUcW3'));

    final Result<ExistingBook, String> result = await useCase.call(url);

    expect(result, const Err<dynamic, String>('Unable to save book by url'));
    verify(() => downloadedBookRepository.downloadAndParseBookByUrl(url, any())).called(1);
  });

  test('should return stream download percentage', () async {
    const String url = 'JJ0QJh9';
    final List<(int, int)> downloadProgress = [(10, 100), (1813, 181300), (39, 40)];
    final List<double> expecetdPercentages = [10.0, 1.0, 97.0];

    when(() => downloadedBookRepository.downloadAndParseBookByUrl(url, any())).thenAnswer((i) async {
      for (final b in downloadProgress) {
        (i.positionalArguments[1] as OnProgressUpdate).call(b.$1, b.$2);
      }

      return const Err('d0dSfOfHLb');
    });
    unawaited(expectLater(useCase.downloadPercentage(), emitsInOrder(expecetdPercentages)));

    await useCase.call(url);
  });

  test('should return Err if unable to store book', () async {
    const String url = '746xcrzE822';
    final ParsedBook book = _FakeParsedBook();

    when(() => downloadedBookRepository.downloadAndParseBookByUrl(url, any())).thenAnswer((_) async => Ok(book));
    when(() => existingBookRepository.storeBook(book)).thenAnswer((_) async => const Err('e14DvieQRC0'));

    final Result<ExistingBook, String> result = await useCase.call(url);

    expect(result, const Err<dynamic, String>('Unable to save book by url'));
    verify(() => existingBookRepository.storeBook(book)).called(1);
  });

  test('should return Ok if operation succeeds', () async {
    const String url = '746xcrzE822';
    final ParsedBook parsedBook = _FakeParsedBook();
    final ExistingBook expected = _FakeExistingBook();

    when(() => downloadedBookRepository.downloadAndParseBookByUrl(url, any())).thenAnswer((_) async => Ok(parsedBook));
    when(() => existingBookRepository.storeBook(parsedBook)).thenAnswer((_) async => Ok(expected));

    final Result<ExistingBook, String> result = await useCase.call(url);

    expect(result, Ok(expected));
  });
}

class _MockBookRepository extends Mock implements ExistingBookRepository {}

class _MockDownloadedBookRepository extends Mock implements DownloadedBookRepository {}

class _FakeParsedBook extends Fake implements ParsedBook {}

class _FakeExistingBook extends Fake implements ExistingBook {}
