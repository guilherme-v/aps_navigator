import 'package:flutter/material.dart';

/// Function called when creating a new [Page] instance that will be included in the Navigation Stack.
///
/// [RouteData] contains data about the current location being build
///
/// Usually we use this type to configure [ApsNavigator.from] route param. E.g.:
///
/// ```dart
///
/// // 1 - Create the navigation and the route
/// final navigator = APSNavigator.from(
///   routes: {
///     '/static_url_example': StaticURLPage.route, // ..
///   }
/// )
///
/// class StaticURLPage extends StatefulWidget {
///   // 2 - Define a ApsRouteBuilderFunction
///   static Page route(RouteData data) {
///     return MaterialPage(
///       // 3 - Important! Always include a key
///       key: ValueKey('StaticURLPage'),
///       child: StaticURLPage(tabIndex: data.values['tab']),
///     );
///   }
/// }
///
/// ```
typedef ApsRouteBuilderFunction = Page<dynamic> Function(
  RouteData data,
);

/// Data used by [ApsRouteBuilderFunction] when creating a new route
///
/// [location] is the current location being build (path + queries). E.g.: '/path/abc?tab=0'
///
/// [values] is a map containing all values extracted from [location] variables. E.g.:
/// * Given the configured route: `/path/{var1}/abc/?{?tab}`
/// * And the following location: `/path/post_a/abc/?tab=0`
/// * [values] will contain: `{'var1': 'post_a', 'tab': 0}`
///
class RouteData {
  final Map<String, dynamic> values;
  final String location;

  const RouteData({
    required this.location,
    this.values = const {},
  });
}
