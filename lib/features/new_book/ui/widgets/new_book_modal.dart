import 'package:flutter/material.dart';
import 'package:storyscape/features/new_book/ui/cubit/new_book_cubit.dart';
import 'package:storyscape/features/new_book/ui/widgets/new_book_by_url_bottom_sheet.dart';

class NewBookModal {
  NewBookModal({required NewBookCubit newBookCubit}) : _newBookCubit = newBookCubit;

  final NewBookCubit _newBookCubit;

  void display(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => NewBookByUrlBottomSheet(newBookCubit: _newBookCubit),
      useSafeArea: true,
    );
  }
}
