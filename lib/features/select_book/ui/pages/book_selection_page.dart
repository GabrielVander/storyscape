import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:storyscape/core/routing/routes.dart';
import 'package:storyscape/features/new_book/ui/widgets/new_book_by_url.dart';
import 'package:storyscape/features/select_book/ui/cubit/book_selection_cubit.dart';

class BookSelectionPage extends HookWidget {
  const BookSelectionPage({
    required BookSelectionCubit bookSelectionCubit,
    required NewBookByUrl newBookByUrlWidget,
    super.key,
  })  : _bookSelectionCubit = bookSelectionCubit,
        _newBookByUrlWidget = newBookByUrlWidget;

  final BookSelectionCubit _bookSelectionCubit;
  final NewBookByUrl _newBookByUrlWidget;

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
              builder: (BuildContext context) => _newBookByUrlWidget,
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
        _bookSelectionCubit.loadStoredBooks();

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
                      Text(book.displayName),
                    ],
                  ),
                ),
              )
              .toList(),
        );
    }
  }
}
