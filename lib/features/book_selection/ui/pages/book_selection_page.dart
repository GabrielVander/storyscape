import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:storyscape/core/routing/routes.dart';
import 'package:storyscape/features/book_selection/ui/cubit/book_selection_cubit.dart';
import 'package:storyscape/features/book_selection/ui/widgets/book_url_field.dart';

class BookSelectionPage extends StatelessWidget {
  const BookSelectionPage({required BookSelectionCubit bookSelectionCubit, super.key})
      : _bookSelectionCubit = bookSelectionCubit;

  final BookSelectionCubit _bookSelectionCubit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bookSelection.pageTitle'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: _Body(
            bookSelectionCubit: _bookSelectionCubit,
          ),
        ),
      ),
    );
  }
}

class _Body extends HookWidget {
  const _Body({required this.bookSelectionCubit});

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

    return BookUrlField(
      onFinished: bookSelectionCubit.selectBookUrl,
    );
  }
}
