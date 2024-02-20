import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:storyscape/features/read_book/ui/cubit/book_reader_cubit.dart';
import 'package:storyscape/features/read_book/ui/pages/book_reader_page.dart';
import 'package:storyscape/features/select_book/ui/cubit/book_selection_cubit.dart';
import 'package:storyscape/features/select_book/ui/pages/book_selection_page.dart';

part 'routes.g.dart';

@TypedGoRoute<BookReadingRoute>(path: '/book/read')
@immutable
class BookReadingRoute extends GoRouteData {
  BookReadingRoute({required this.url});

  final GetIt _locator = GetIt.instance;
  final String url;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BookReaderPage(url: url, bookReaderCubit: _locator.get<BookReaderCubit>());
  }
}

@TypedGoRoute<BookSelectionRoute>(path: '/book/select')
@immutable
class BookSelectionRoute extends GoRouteData {
  BookSelectionRoute();

  final GetIt _locator = GetIt.instance;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BookSelectionPage(
      bookSelectionCubit: _locator.get<BookSelectionCubit>(),
      newBookByUrlWidget: _locator.get(),
    );
  }
}
