import 'package:easy_localization/easy_localization.dart';
import 'package:epub_view/epub_view.dart';
// ignore: implementation_imports
import 'package:epub_view/src/data/models/chapter_view_value.dart' show EpubChapterViewValue;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:storyscape/features/read_book/ui/cubit/book_reader_cubit.dart';

class BookReaderPage extends HookWidget {
  const BookReaderPage({required this.id, required this.bookReaderCubit, super.key});

  final int id;
  final BookReaderCubit bookReaderCubit;

  @override
  Widget build(BuildContext context) {
    useEffect(
      () {
        bookReaderCubit.open(id);

        return null;
      },
      [],
    );

    final BookReaderState bookReaderState = useBlocBuilder(bookReaderCubit);

    if ([BookReaderInitial, BookReaderLoading, BookReaderDownloading].contains(bookReaderState.runtimeType)) {
      final String title = bookReaderState is BookReaderDownloading
          ? 'bookReading.downloadingLabel'.tr()
          : 'bookReading.loadingLabel'.tr();

      final Widget content = bookReaderState is BookReaderDownloading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: bookReaderState.percentageValue,
                  ),
                  Text(bookReaderState.percentageDisplay),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator());

      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: content,
        ),
      );
    }

    if (bookReaderState is BookReaderError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('bookReading.errorLabel').tr(),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('bookReading.error.${bookReaderState.errorCode}').tr(),
              Text(bookReaderState.context),
            ],
          ),
        ),
      );
    }

    if (bookReaderState is BookReaderFinished) {
      final EpubController epubController = EpubController(
        document: EpubDocument.openFile(bookReaderState.file),
      );

      return Scaffold(
        appBar: AppBar(
          title: EpubViewActualChapter(
            controller: epubController,
            builder: (EpubChapterViewValue? chapterValue) => Text(
              chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
              textAlign: TextAlign.start,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save_alt),
              color: Colors.white,
              onPressed: () => (BuildContext context) {
                final String? cfi = epubController.generateEpubCfi();

                if (cfi != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(cfi),
                      action: SnackBarAction(
                        label: 'GO',
                        onPressed: () {
                          epubController.gotoEpubCfi(cfi);
                        },
                      ),
                    ),
                  );
                }
              }(context),
            ),
          ],
        ),
        drawer: Drawer(
          child: EpubViewTableOfContents(controller: epubController),
        ),
        body: EpubView(
          builders: EpubViewBuilders<DefaultBuilderOptions>(
            options: const DefaultBuilderOptions(),
            chapterDividerBuilder: (_) => const Divider(),
          ),
          controller: epubController,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Text('Invalid state: $bookReaderState'),
      ),
    );
  }
}
