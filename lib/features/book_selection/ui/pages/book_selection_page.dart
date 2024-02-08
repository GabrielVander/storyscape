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
    final bottomSheetAnimationController = useAnimationController(duration: const Duration(milliseconds: 200));

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
      body: const Padding(
        padding: EdgeInsets.all(15),
        child: Center(
          child: FlutterLogo(),
        ),
      ),
    );
  }
}

class _AddBookByUrl extends HookWidget {
  const _AddBookByUrl({required this.bookSelectionCubit});

  final BookSelectionCubit bookSelectionCubit;

  @override
  Widget build(BuildContext context) {
    useBlocListener(
      bookSelectionCubit,
      (bloc, current, context) {
        if (current case BookSelectionSelected(:final url)) {
          BookReadingRoute(url: url).push<void>(context);
        }
      },
      listenWhen: (current) => current is BookSelectionSelected,
    );

    return Padding(
      padding: const EdgeInsets.all(15),
      child: BookUrlField(
        onFinished: bookSelectionCubit.selectBookUrl,
      ),
    );
  }
}
