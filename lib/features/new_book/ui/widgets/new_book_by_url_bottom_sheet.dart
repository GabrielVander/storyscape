import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:storyscape/features/new_book/ui/cubit/new_book_cubit.dart';
import 'package:storyscape/features/new_book/ui/widgets/book_url_field.dart';

class NewBookByUrlBottomSheet extends HookWidget {
  const NewBookByUrlBottomSheet({required void Function() onClosing, required NewBookCubit newBookCubit, super.key})
      : _newBookCubit = newBookCubit,
        _onClosing = onClosing;

  final NewBookCubit _newBookCubit;
  final void Function() _onClosing;

  @override
  Widget build(BuildContext context) {
    final AnimationController bottomSheetAnimationController =
        useAnimationController(duration: const Duration(milliseconds: 200));

    return BottomSheet(
      onClosing: () {
        _onClosing();
        _newBookCubit.reset();
      },
      animationController: bottomSheetAnimationController,
      showDragHandle: true,
      builder: (BuildContext context) => _BottomSheetBody(newBookCubit: _newBookCubit),
    );
  }
}

class _BottomSheetBody extends HookWidget {
  const _BottomSheetBody({required NewBookCubit newBookCubit}) : _newBookCubit = newBookCubit;
  final NewBookCubit _newBookCubit;

  @override
  Widget build(BuildContext context) {
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
        return const Center(child: CircularProgressIndicator());
      case NewBookSaved():
        return Center(child: Text('newBook.bookSavedSuccessfully'.tr()));
      case NewBookError():
        return Center(child: Text('newBook.urlBookFailure'.tr()));
      case NewBookDownloading(:final percentageDisplay, :final percentageValue):
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: percentageValue),
            Text(percentageDisplay),
          ],
        );
    }
  }
}
