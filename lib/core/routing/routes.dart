import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:storyscape/features/book_reading/ui/cubit/book_reader_cubit.dart';
import 'package:storyscape/features/book_reading/ui/pages/book_reader_page.dart';
import 'package:storyscape/features/book_selection/ui/pages/book_selection_page.dart';

part 'routes.g.dart';

@TypedGoRoute<BookReadingRoute>(path: '/book/read')
@immutable
class BookReadingRoute extends GoRouteData {
  const BookReadingRoute({required this.url});

  final String url;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BookReaderPage(url: url, bookReaderCubit: GetIt.I<BookReaderCubit>());
  }
}

@TypedGoRoute<BookSelectionRoute>(path: '/book/select')
@immutable
class BookSelectionRoute extends GoRouteData {
  const BookSelectionRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BookSelectionPage();
  }
}
