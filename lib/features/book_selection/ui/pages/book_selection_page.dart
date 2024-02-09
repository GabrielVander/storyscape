import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:storyscape/core/routing/routes.dart';
import 'package:storyscape/features/book_selection/ui/cubit/book_selection_cubit.dart';
import 'package:storyscape/features/book_selection/ui/widgets/book_url_field.dart';

class BookSelectionPage extends HookWidget {
  const BookSelectionPage({required BookSelectionCubit bookSelectionCubit, super.key})
      : _bookSelectionCubit = bookSelectionCubit;

  final BookSelectionCubit _bookSelectionCubit;

  @override
  Widget build(BuildContext context) {
    final AnimationController bottomSheetAnimationController =
        useAnimationController(duration: const Duration(milliseconds: 200));

    return Scaffold(
      appBar: AppBar(
        title: Text('bookSelection.pageTitle'.tr()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (context) => BottomSheet(
              onClosing: () {},
              animationController: bottomSheetAnimationController,
              showDragHandle: true,
              builder: (BuildContext context) => _AddBookByUrl(
                bookSelectionCubit: _bookSelectionCubit,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: BookSelection(
          bookSelectionCubit: _bookSelectionCubit,
        ),
      ),
    );
  }
}

class BookSelection extends HookWidget {
  const BookSelection({required BookSelectionCubit bookSelectionCubit, super.key})
      : _bookSelectionCubit = bookSelectionCubit;

  final BookSelectionCubit _bookSelectionCubit;

  @override
  Widget build(BuildContext context) {
    useEffect(
      () {
        _bookSelectionCubit.fetchStoredBooks();

        return null;
      },
      [],
    );

    final BookSelectionState state = useBlocBuilder(_bookSelectionCubit);

    switch (state) {
      case BookSelectionSelected(:final url):
        BookReadingRoute(url: url).push<void>(context);
        return const Center(child: CircularProgressIndicator());

      case BookSelectionInitial() || BookSelectionLoading():
        return const Center(child: CircularProgressIndicator());

      case BookSelectionError(:final errorCode, :final errorContext):
        return Center(
          child: Column(
            children: [
              Text('bookSelection.error.genericErrorMessage'.tr()),
              Text('$errorCode: $errorContext'),
            ],
          ),
        );

      case BookSelectionBooksLoaded(:final books):
        return GridView.count(
          crossAxisCount: 2,
          children: books
              .map(
                (book) => Card.outlined(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FlutterLogo(size: 72),
                      Text(book.url),
                    ],
                  ),
                ),
              )
              .toList(),
        );
    }
  }
}

class _AddBookByUrl extends HookWidget {
  const _AddBookByUrl({required this.bookSelectionCubit});

  final BookSelectionCubit bookSelectionCubit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: BookUrlField(
        onFinished: bookSelectionCubit.selectBookUrl,
      ),
    );
  }
}
