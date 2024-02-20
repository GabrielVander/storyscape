import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:storyscape/features/new_book/ui/cubit/new_book_cubit.dart';
import 'package:storyscape/features/new_book/ui/widgets/book_url_field.dart';

class NewBookByUrl extends HookWidget {
  const NewBookByUrl({required NewBookCubit newBookCubit, super.key}) : _newBookCubit = newBookCubit;

  final NewBookCubit _newBookCubit;

  @override
  Widget build(BuildContext context) {
    final NewBookState state = useBlocBuilder(_newBookCubit);

    switch (state) {
      case NewBookInitial():
        return Padding(
          padding: const EdgeInsets.all(15),
          child: BookUrlField(
            onFinished: _newBookCubit.downloadBookByUrl,
          ),
        );
      case NewBookLoading():
        return const CircularProgressIndicator();
      case NewBookDownloading(:final percentageDisplay, :final percentageValue):
        return Column(
          children: [
            CircularProgressIndicator(value: percentageValue),
            Text(percentageDisplay),
          ],
        );
    }
  }
}
