// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $bookReadingRoute,
      $bookSelectionRoute,
    ];

RouteBase get $bookReadingRoute => GoRouteData.$route(
      path: '/book/read',
      factory: $BookReadingRouteExtension._fromState,
    );

extension $BookReadingRouteExtension on BookReadingRoute {
  static BookReadingRoute _fromState(GoRouterState state) => BookReadingRoute(
        url: state.uri.queryParameters['url']!,
      );

  String get location => GoRouteData.$location(
        '/book/read',
        queryParams: {
          'url': url,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $bookSelectionRoute => GoRouteData.$route(
      path: '/book/select',
      factory: $BookSelectionRouteExtension._fromState,
    );

extension $BookSelectionRouteExtension on BookSelectionRoute {
  static BookSelectionRoute _fromState(GoRouterState state) =>
      const BookSelectionRoute();

  String get location => GoRouteData.$location(
        '/book/select',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
