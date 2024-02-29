import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:storyscape/features/new_book/ui/cubit/new_book_cubit.dart';
import 'package:storyscape/features/new_book/ui/widgets/book_url_field.dart';

class NewBookByUrlBottomSheet extends HookWidget {
  const NewBookByUrlBottomSheet({required NewBookCubit newBookCubit, super.key}) : _newBookCubit = newBookCubit;

  final NewBookCubit _newBookCubit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _BottomSheetBody(newBookCubit: _newBookCubit),
    );
  }
}

class _BottomSheetBody extends HookWidget {
  const _BottomSheetBody({required NewBookCubit newBookCubit}) : _newBookCubit = newBookCubit;
  final NewBookCubit _newBookCubit;

  @override
  Widget build(BuildContext context) {
    useEffect(
      () {
        return _newBookCubit.reset;
      },
      [],
    );
    final NewBookState state = useBlocBuilder(_newBookCubit);

    switch (state) {
      case NewBookInitial():
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 15),
          child: BookUrlField(
            onFinished: _newBookCubit.addNewBookByUrl,
          ),
        );
      case NewBookLoading():
        return const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        );
      case NewBookSaved():
        WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pop(context));
        return Center(child: Text('newBook.bookSavedSuccessfully'.tr()));
      case NewBookError():
        return Center(child: Text('newBook.urlBookFailure'.tr()));
      case NewBookDownloading(:final percentageDisplay, :final percentageValue):
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(value: percentageValue),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(percentageDisplay),
              ],
            ),
          ],
        );
    }
  }
}
