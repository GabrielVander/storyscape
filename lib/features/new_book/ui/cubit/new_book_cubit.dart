import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'new_book_state.dart';

class NewBookCubit extends Cubit<NewBookState> {
  NewBookCubit() : super(NewBookInitial());

  Future<void> downloadBookByUrl(String url) async {
    emit(NewBookLoading());
    await Future.delayed(const Duration(seconds: 2), () {});
    await Future.delayed(
      const Duration(seconds: 2),
      () => emit(const NewBookDownloading(percentageDisplay: '10%', percentageValue: .1)),
    );
    await Future.delayed(
      const Duration(seconds: 1),
      () => emit(const NewBookDownloading(percentageDisplay: '30%', percentageValue: .3)),
    );
    await Future.delayed(
      const Duration(seconds: 1),
      () => emit(const NewBookDownloading(percentageDisplay: '50%', percentageValue: .5)),
    );
    await Future.delayed(
      const Duration(seconds: 1),
      () => emit(const NewBookDownloading(percentageDisplay: '60%', percentageValue: .6)),
    );
    await Future.delayed(
      const Duration(seconds: 1),
      () => emit(const NewBookDownloading(percentageDisplay: '90%', percentageValue: .9)),
    );
    await Future.delayed(
      const Duration(seconds: 1),
      () => emit(const NewBookDownloading(percentageDisplay: '99%', percentageValue: .99)),
    );
    await Future.delayed(
      const Duration(seconds: 1),
      () => emit(const NewBookDownloading(percentageDisplay: '100%', percentageValue: 1)),
    );
  }
}
