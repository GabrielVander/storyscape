import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:internet_file/internet_file.dart';

class BookReaderPage extends HookWidget {
  const BookReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useState<EpubController?>(null);
    useEffect(
      () {
        buildController().then((value) => controller.value = value);

        return null;
      },
      [],
    );

    if (controller.value == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading..'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: EpubViewActualChapter(
          controller: controller.value!,
          builder: (chapterValue) => Text(
            chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
            textAlign: TextAlign.start,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save_alt),
            color: Colors.white,
            onPressed: () => (BuildContext context) {
              final cfi = controller.value?.generateEpubCfi();

              if (cfi != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(cfi),
                    action: SnackBarAction(
                      label: 'GO',
                      onPressed: () {
                        controller.value?.gotoEpubCfi(cfi);
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
        child: EpubViewTableOfContents(controller: controller.value!),
      ),
      body: EpubView(
        builders: EpubViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          chapterDividerBuilder: (_) => const Divider(),
        ),
        controller: controller.value!,
      ),
    );
  }

  Future<EpubController> buildController() async {
    final bytes = await InternetFile.get('https://www.gutenberg.org/cache/epub/72732/pg72732-images-3.epub');

    return EpubController(
      document:
          // EpubDocument.openAsset('assets/New-Findings-on-Shirdi-Sai-Baba.epub'),
          EpubDocument.openData(bytes), // epubCfi:
      //     'epubcfi(/6/26[id4]!/4/2/2[id4]/22)', // book.epub Chapter 3 paragraph 10
      // epubCfi:
      //     'epubcfi(/6/6[chapter-2]!/4/2/1612)', // book_2.epub Chapter 16 paragraph 3
    );
  }
}
