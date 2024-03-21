import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:storyscape/core/routing/routes.dart';
import 'package:storyscape/features/new_book/ui/widgets/new_book_modal.dart';
import 'package:storyscape/features/select_book/ui/cubit/book_selection_cubit.dart';

class BookSelectionPage extends HookWidget {
  const BookSelectionPage({
    required BookSelectionCubit bookSelectionCubit,
    required NewBookModal newBookModal,
    super.key,
  })  : _bookSelectionCubit = bookSelectionCubit,
        _newBookModal = newBookModal;

  final BookSelectionCubit _bookSelectionCubit;
  final NewBookModal _newBookModal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bookSelection.pageTitle'.tr()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _newBookModal.display(context),
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
    useBlocListener(
      _bookSelectionCubit,
      (_, __, context) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('bookSelection.error.unableToUpdateBooks'.tr()))),
      listenWhen: (s) => s is BookSelectionUpdateError,
    );

    useBlocListener(
      _bookSelectionCubit,
      (_, current, context) {
        if (current case BookSelectionSelected(id: final url)) {
          WidgetsBinding.instance.addPostFrameCallback((_) => BookReadingRoute(id: url).push<void>(context));
        }
      },
      listenWhen: (s) => s is BookSelectionSelected,
    );

    final BookSelectionState state = useBlocBuilder(
      _bookSelectionCubit,
      buildWhen: (s) => [
        BookSelectionInitial,
        BookSelectionLoading,
        BookSelectionLoadingError,
        BookSelectionBooksLoaded,
      ].contains(s.runtimeType),
    );
    final bool shouldUpdate = state is BookSelectionInitial;

    useEffect(
      () {
        _bookSelectionCubit.loadStoredBooks();

        return null;
      },
      [shouldUpdate],
    );

    switch (state) {
      case BookSelectionInitial() || BookSelectionLoading():
        if (state is BookSelectionInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _bookSelectionCubit.loadStoredBooks());
        }
        return const Center(child: CircularProgressIndicator());

      case BookSelectionLoadingError(:final errorCode, :final errorContext):
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
                (book) => GestureDetector(
                  onTap: () => _bookSelectionCubit.open(book),
                  child: SelectionItem(itemViewModel: book),
                ),
              )
              .toList(),
        );
      case _:
        return Center(child: Text('bookSelection.error.unexpectedState'.tr()));
    }
  }
}

class SelectionItem extends StatelessWidget {
  const SelectionItem({
    required this.itemViewModel,
    super.key,
  });

  final BookSelectionItemViewModel itemViewModel;

  @override
  Widget build(BuildContext context) {
    if (itemViewModel.id == null) {
      return _ErrorMessage(text: 'bookSelection.error.noData'.tr());
    }
    return Card.outlined(
      key: ValueKey<int>(itemViewModel.id!),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FlutterLogo(size: 72),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  itemViewModel.title ?? 'bookSelection.error.noDisplayName'.tr(),
                  softWrap: true,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
